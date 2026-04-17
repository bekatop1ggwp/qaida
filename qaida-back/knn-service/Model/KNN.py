from pymongo import MongoClient
from bson import ObjectId
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from bson import Decimal128

client = MongoClient("mongodb+srv://ald1k0n:264166@cluster0.ppiyo0p.mongodb.net/qaida")
db = client["qaida"]

def get_user_data_by_id(user_id):
    users_collection = db["users"]
    user = users_collection.find_one({"_id": ObjectId(user_id)})
    if user:
        user_name = user["email"]
        user_interests = [str(interest) for interest in user.get("interests", [])]
        return user_name, user_interests
    else:
        return None, []

def get_user_interests(user_interests):
    categories_collection = db["rubrics"]
    user_interests_minor = []
    for interest_id in user_interests:
        global_category = categories_collection.find_one({"_id": ObjectId(interest_id)})
        if global_category:
            user_interests_minor.append([str(category_id) for category_id in global_category["category_ids"]])
    return user_interests_minor

def generate_user_interest_vector(user_interests):
    num_minor_categories = db["categories"].estimated_document_count() 
    user_interest_vector = [0] * num_minor_categories
    
    category_index_map = {}
    for i, category_doc in enumerate(db["categories"].find()):
        category_index_map[category_doc["_id"]] = i
    
    for global_category_id in user_interests:
        global_category = db["rubrics"].find_one({"_id": ObjectId(global_category_id)})
        if global_category:
            for category_id in global_category["category_ids"]:
                index = category_index_map.get(category_id)
                if index is not None:
                    user_interest_vector[index] = 1
    return user_interest_vector

def get_places_for_user(user_minor_categories):
    places_collection = db["places"]
    places_for_user = []
    visited_ids = set()
    try:
        for category_ids in user_minor_categories:
            for category_id in category_ids:
                places = places_collection.find({"category_id": {"$in": [ObjectId(category_id)]}})
                for place in places:
                    place_id = str(place["_id"])
                    if place_id not in visited_ids:
                        places_for_user.append(place)
                        visited_ids.add(place_id)
    except Exception as e:
        print("Error fetching places:", e)
    return places_for_user

def generate_place_category_vector(place_categories):
    all_minor_categories = db["categories"].distinct("_id")
    place_category_vector = [1 if str(category_id) in place_categories else 0 for category_id in all_minor_categories]
    return place_category_vector

def generate_place_feature_vectors(places):
    feature_vectors = []
    for place in places:
        try:
            if place.get("category_id") is None:
                continue
            place_categories = [str(category) for category in place.get("category_id", [])]  # Extract category IDs
            place_score = place.get("score_2gis", 0)  # You can choose the appropriate score field
            place_category_vector = generate_place_category_vector(place_categories)
            feature_vector = place_category_vector + [place_score]
            feature_vectors.append(feature_vector)
        except Exception as e:
            print("Error generating feature vector for place:", e)
    return feature_vectors

def get_visited_places_by_user(user_id):
    visited_collection = db["visiteds"]
    visited_places = []
    visited_records = visited_collection.find({"user_id": ObjectId(user_id), "status": "VISITED"})
    for record in visited_records:
        place_id = record.get("place_id")
        visited_places.append(place_id)
    return visited_places

def get_users_with_similar_interests(user_interests):
    users_collection = db["users"]
    similar_users = []
    
    interest_object_ids = [ObjectId(interest) for interest in user_interests]
    
    query = {"interests": {"$in": interest_object_ids}}
    
    users = list(users_collection.find(query))
    similar_users.extend(users)
    return similar_users

def plot_visited_places_categories(visited_places_by_similar_users):
    categories_frequency = {}
    global_categories_mapping = {} 
    
    for place_id in visited_places_by_similar_users:
        place = db["places"].find_one({"_id": ObjectId(place_id)})
        if place:
            category_ids = place.get("category_id", [])  # Assuming category_id holds the category IDs
            for category_id in category_ids:
                category = db["categories"].find_one({"_id": ObjectId(category_id)})
                if category:
                    category_name = category.get("name")
                    global_category = db["rubrics"].find_one({"category_ids": category_id})
                    if global_category:
                        global_category_name = global_category.get("name")
                        if category_name in categories_frequency:
                            categories_frequency[category_name] += 1
                        else:
                            categories_frequency[category_name] = 1
                        global_categories_mapping[category_name] = global_category_name

def calculate_euclidean_distance(user_vector, place_vectors):
    distances = []
    for place_vector in place_vectors:
        user_features = np.array(user_vector[:-1] + [0])
        place_features = np.array(place_vector[:-1])
        user_score = float(user_vector[-1])
        place_score = float(str(place_vector[-1]))
        score_difference = user_score - place_score
        distance = np.linalg.norm(user_features - place_features) + abs(score_difference)
        distances.append(distance)
    return distances

def find_k_nearest_neighbors_for_user(user_id, k):
    user_name, user_interests = get_user_data_by_id(user_id)
    if user_interests:
        similar_users = get_users_with_similar_interests(user_interests)
        if similar_users:
            visited_places_by_similar_users = []
            for similar_user in similar_users:
                visited_places = get_visited_places_by_user(str(similar_user["_id"]))
                visited_places_by_similar_users.extend(visited_places)

            if visited_places_by_similar_users:
                plot_visited_places_categories(visited_places_by_similar_users)
            else:
                print()
            
            visited_places_by_similar_users = list(set(visited_places_by_similar_users))
            
            visited_places_by_similar_users = [place for place in visited_places_by_similar_users if place not in get_visited_places_by_user(user_id)]
            
            place_frequency = {}
            for place in visited_places_by_similar_users:
                if place in place_frequency:
                    place_frequency[place] += 1
                else:
                    place_frequency[place] = 1
            
            sorted_places = sorted(place_frequency.items(), key=lambda x: x[1], reverse=True)
            
            user_interest_vector = generate_user_interest_vector(user_interests)
            places_for_user = get_places_for_user(get_user_interests(user_interests))
            place_feature_vectors = generate_place_feature_vectors(places_for_user)
            distances = calculate_euclidean_distance(user_interest_vector, place_feature_vectors)
            
            places_with_distances = zip(sorted_places, distances)
            
            nearest_places_with_distances = sorted([(place, distance) for (place, _), distance in places_with_distances], key=lambda x: x[1])[:k]
            
            for place, _ in nearest_places_with_distances:
                place_id = str(place)
                if not db["places"].find_one({"_id": ObjectId(place_id)}):
                    print(f"Place with ID {place_id} does not exist in the database.")
            
            return nearest_places_with_distances
        else:
            return []
    else:
        return []

def generateRecommendationIds(user_id:str):
  rec = []
  user_name, user_interests = get_user_data_by_id(user_id)
  if user_name:
      if user_interests:
          user_minor_categories = get_user_interests(user_interests)
          if user_minor_categories:
              user_interest_vector = generate_user_interest_vector(user_interests)
              
              places_for_user = get_places_for_user(user_minor_categories)
              if places_for_user:
                  
                  place_feature_vectors = generate_place_feature_vectors(places_for_user)
                  if place_feature_vectors:
                      
                      distances = calculate_euclidean_distance(user_interest_vector, place_feature_vectors)
                      
                      k = 10
                      nearest_places_with_distances = find_k_nearest_neighbors_for_user(user_id, k)
                      if nearest_places_with_distances:
                          for place, distance in nearest_places_with_distances:
                              rec.append(place)
                      else:
                          return []
  return rec

import json
from bson import ObjectId


def getPlacesByIds(ids):
    places = []
    placesCursor = db.places.find({
        "_id": {
            "$in": ids
        }
    })
    for place in placesCursor:
        place['_id'] = str(place['_id'])
        place['schedule_id'] = str(place["schedule_id"])
        place['location_id'] = str(place["location_id"])
        place['category_id'] = [str(idx) for idx in place.get('category_id', [])]
        place['score_2gis'] = str(place['score_2gis'])
        places.append(place)

    return places


