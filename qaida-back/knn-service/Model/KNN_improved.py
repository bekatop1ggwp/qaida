from pymongo import MongoClient
from bson import ObjectId
import numpy as np

client = MongoClient("mongodb+srv://ald1k0n:264166@cluster0.ppiyo0p.mongodb.net/qaida")
db = client["qaida"]

def get_user_data_by_id(user_id):
    users_collection = db["users"]
    pipeline = [
        {"$match": {"_id": ObjectId(user_id)}},
        {"$lookup": {
            "from": "rubrics",
            "localField": "interests",
            "foreignField": "_id",
            "as": "interests_info"
        }},
        {"$unwind": "$interests_info"},
        {"$lookup": {
            "from": "categories",
            "localField": "interests_info.category_ids",
            "foreignField": "_id",
            "as": "categories_info"
        }},
        {"$group": {
            "_id": "$_id",
            "email": {"$first": "$email"},
            "interests": {"$push": "$interests_info._id"},
            "minor_categories": {"$push": "$categories_info._id"}
        }},
        {"$project": {
            "_id": 1,
            "email": 1,
            "interests": 1,
            "minor_categories": {"$reduce": {
                "input": "$minor_categories",
                "initialValue": [],
                "in": {"$concatArrays": ["$$value", "$$this"]}
            }}
        }}
    ]
    user = list(users_collection.aggregate(pipeline))
    if user:
        user_data = user[0]
        user_name = user_data["email"]
        user_interests = user_data["interests"]
        user_minor_categories = user_data["minor_categories"]
        
        visited_places_pipeline = [
            {
                "$match": {
                    "user_id": ObjectId(user_id),
                    "status": "VISITED"
                }
            },
            {
                "$group": {
                    "_id": "$place_id"
                }
            }
        ]
        visited_places = list(db["visiteds"].aggregate(visited_places_pipeline))
        visited_place_ids = [str(place["_id"]) for place in visited_places]
        
        return user_name, user_interests, user_minor_categories, visited_place_ids
    else:
        return None, [], [], []
    

def get_visited_places_by_user(user_id):
    visited_collection = db["visiteds"]
    visited_places = []
    visited_records = visited_collection.find({"user_id": ObjectId(user_id), "status": "VISITED"})
    for record in visited_records:
        place_id = record.get("place_id")
        visited_places.append(place_id)
    return visited_places

def generate_user_interest_vector(user_interests):
    num_minor_categories = db["categories"].estimated_document_count()
    
  
    category_index_map = {}
    for i, category_doc in enumerate(db["categories"].find()):
        category_index_map[category_doc["_id"]] = i
    

    user_interest_vector = [0] * num_minor_categories  

    pipeline = [
        {"$match": {"_id": {"$in": user_interests}}},
        {"$lookup": {
            "from": "rubrics",
            "localField": "_id",
            "foreignField": "category_ids",
            "as": "rubrics"
        }},
        {"$unwind": "$rubrics"},
        {"$project": {"category_ids": "$rubrics.category_ids"}}
    ]
    
    category_ids = []
    for doc in db["categories"].aggregate(pipeline):
        category_ids.extend(doc.get("category_ids", []))

    for category_id in category_ids:
        index = category_index_map.get(category_id)
        if index is not None:
            user_interest_vector[index] = 1
    
    return user_interest_vector


def get_places_for_user(user_minor_categories):
    places_collection = db["places"]
    places_for_user = []
    try:
        # Convert category IDs to ObjectIds
        category_object_ids = [ObjectId(cat_id) for cat_id in user_minor_categories]
        
        # Filter category IDs by checking if they exist in the categories collection
        existing_categories = db["categories"].distinct("_id", {"_id": {"$in": category_object_ids}})
        
        # Aggregate pipeline to match places with existing categories and perform lookup
        pipeline = [
            {"$match": {"category_id": {"$in": existing_categories}}},
            {"$addFields": {
                "matching_categories": {
                    "$setIntersection": ["$category_id", existing_categories]
                }
            }},
            {"$match": {"matching_categories.0": {"$exists": True}}},  # Filter out places with no matching categories
            {"$lookup": {
                "from": "rubrics",
                "localField": "category_id",
                "foreignField": "category_ids",
                "as": "global_category"
            }},
            {"$unwind": "$global_category"},  # Unwind to flatten the result array
            {"$group": {"_id": "$_id", "place": {"$first": "$$ROOT"}}},
            {"$replaceRoot": {"newRoot": "$place"}}
        ]

        # Execute the aggregate pipeline
        places = places_collection.aggregate(pipeline)
        places_for_user = list(places)
    except Exception as e:
        print("Error fetching places:", e)
    return places_for_user


def generate_place_category_vector(place_categories, all_minor_categories, place_global_category):
    place_category_vector = []
    for category_id in all_minor_categories:
        if category_id in place_categories:
            place_category_vector.append(1)
        elif category_id in place_global_category.get("category_ids", []):
            num_categories_in_global = len(place_global_category.get("category_ids", []))
            num_all_minor_categories = len(all_minor_categories)
            value = 1 - (num_categories_in_global / num_all_minor_categories)
            place_category_vector.append(value)
        else:
            place_category_vector.append(0)
    return place_category_vector


def generate_place_feature_vectors(places):
    all_minor_categories = db["categories"].distinct("_id")
    place_category_vectors = {}  # Dictionary to store category vectors for each place
    
    # Iterate over places to generate category vectors
    for place in places:
        try:
            if place.get("category_id") is None:
                print("Error: category missing for place:", place["_id"])
                continue

            place_id = str(place["_id"])
            place_categories = place.get("category_id", [])  # Extract category IDs

            # Ensure place_categories is always a list
            if not isinstance(place_categories, list):
                place_categories = [place_categories]

            # Get place_global_category
            place_global_category = place.get("global_category")

            place_category_vectors[place_id] = generate_place_category_vector(place_categories, all_minor_categories, place_global_category)

        except Exception as e:
            print("Error generating category vector for place:", e)

    # Create feature vectors for places
    feature_vectors = []
    for place in places:
        try:
            place_id = str(place["_id"])
            place_score = place.get("score_2gis", 0)  # Convert Decimal128 to float
            category_vector = place_category_vectors.get(place_id, [0] * len(all_minor_categories))  # Default to all zeros if category vector not found
            feature_vector = category_vector + [place_score]
            feature_vectors.append(feature_vector)

        except Exception as e:
            print("Error generating feature vector for place:", e)

    return feature_vectors


def calculate_euclidean_distance(user_vector, place_vectors):
    distances = []
    for place_vector in place_vectors:
        user_features = np.array(user_vector[:-1] + [0])  # Adjust length of user feature vector to match place vector
        place_features = np.array(place_vector[:-1])  # Exclude the score from the place vector
        user_score = float(user_vector[-1])  # Convert Decimal128 to float
        place_score = float(str(place_vector[-1]))  # Convert Decimal128 to float
        score_difference = user_score - place_score  # Calculate the difference in scores
        distance = np.linalg.norm(user_features - place_features) + abs(score_difference)  # Calculate the Euclidean distance
        distances.append(distance)
    return distances


def get_users_with_similar_interests(user_interests):
    users_collection = db["users"]
    similar_users = []
    
    # Convert interest strings to ObjectIds
    interest_object_ids = [ObjectId(interest) for interest in user_interests]
    
    # Query users with exactly the same number of interests
    query = {"interests": {"$size": len(interest_object_ids)}}

    users = list(users_collection.find(query))
    for user in users:
        user_interest_set = set(str(interest) for interest in user["interests"])
        provided_interest_set = set(str(interest) for interest in interest_object_ids)
        if user_interest_set == provided_interest_set:
            similar_users.append(user)

    return similar_users


def find_k_nearest_neighbors_for_user(user_id, k):
    user_name, user_interests, user_minor_categories, user_visited_places = get_user_data_by_id(user_id)
    if user_name:
        print("User name:", user_name)

        if user_interests:
            print("User interests (global category):", user_interests)

            user_interest_vector = generate_user_interest_vector(user_minor_categories)

            if user_interest_vector:
                print("User interest vector:", user_interest_vector)
            else:
                print("No user interest vector")

        else:
            print("User has no interests.")

        if user_visited_places:
            print("Visited places by user: ", user_visited_places)
        else:
            print("User has not visited any place")

        similar_users = get_users_with_similar_interests(user_interests)
        if similar_users:
            # Get visited places by similar users
            visited_places_by_similar_users = []
            for similar_user in similar_users:
                visited_places = get_visited_places_by_user(str(similar_user["_id"]))
                visited_places_by_similar_users.extend(visited_places)

            if visited_places_by_similar_users:
                print("Number of visited places by similar users:", len(visited_places_by_similar_users))
            else:
                print("No visited places by similar users found.")

            # Calculate Euclidean distance between user and places
            user_interest_vector = generate_user_interest_vector(user_minor_categories)
            places_for_user = get_places_for_user(user_minor_categories)
            place_feature_vectors = generate_place_feature_vectors(places_for_user)
            distances = calculate_euclidean_distance(user_interest_vector, place_feature_vectors)

            # Remove duplicates from visited places
            visited_places_by_similar_users = list(set(visited_places_by_similar_users))

            # Filter out places visited by the target user
            visited_places_by_similar_users = [place for place in visited_places_by_similar_users if
                                               place not in user_visited_places]

            # Count the frequency of visited places
            place_frequency = {}
            for place in visited_places_by_similar_users:
                if place in place_frequency:
                    place_frequency[place] += 1
                else:
                    place_frequency[place] = 1

            # Sort places by frequency
            sorted_places = sorted(place_frequency.items(), key=lambda x: x[1], reverse=True)

            # Combine places with distances
            places_with_distances = zip(sorted_places, distances)

            # Return top k places with their distances
            nearest_places_with_distances = sorted(
                [(place, distance) for (place, _), distance in places_with_distances],
                key=lambda x: x[1])[:k]

            # Check if the returned place IDs exist in the database
            for place, _ in nearest_places_with_distances:
                place_id = str(place)
                if not db["places"].find_one({"_id": ObjectId(place_id)}):
                    print(f"Place with ID {place_id} does not exist in the database.")

            return nearest_places_with_distances

        else:
            print("No users with similar interests found.")
            return []

    else:
        print("User not found.")
        return []
    


# user_id = "663e46ff4763edf79b67147c"
# k = 10

def getPlacesByIds(ids):
    places = []
    placesCursor = db.places.find({
        "_id": {
            "$in": ids
        }
    })
    print("cursor", placesCursor)
    for place in placesCursor:  
        place['_id'] = str(place['_id'])
        place['schedule_id'] = str(place["schedule_id"])
        place['location_id'] = str(place["location_id"])
        place['category_id'] = [str(idx) for idx in place.get('category_id', [])]
        place['score_2gis'] = str(place['score_2gis'])
        places.append(place)
    
    return places


def generateRecommendation(user_id):
    nearest_places_with_distances = find_k_nearest_neighbors_for_user(user_id, 10)
    nearest_place_ids = [place[0] for place in nearest_places_with_distances]
    places = getPlacesByIds(nearest_place_ids)
    return places

