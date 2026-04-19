import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient
from bson import ObjectId
import numpy as np

ENV_PATH = Path(__file__).resolve().parents[2] / "src" / "core" / ".env"
load_dotenv(dotenv_path=ENV_PATH)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

client = MongoClient(DATABASE_URL)
db = client.get_default_database()
if db is None:
    db = client["qaida"]


def to_object_id(value):
    if isinstance(value, ObjectId):
        return value
    return ObjectId(str(value))


def to_str_id(value):
    return str(value)


def decimal_to_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(str(value))
    except Exception:
        return default


def get_user_data_by_id(user_id):
    users_collection = db["users"]

    pipeline = [
        {"$match": {"_id": to_object_id(user_id)}},
        {
            "$lookup": {
                "from": "rubrics",
                "localField": "interests",
                "foreignField": "_id",
                "as": "interests_info",
            }
        },
        {
            "$group": {
                "_id": "$_id",
                "email": {"$first": "$email"},
                "interests": {"$first": "$interests"},
                "interests_info": {"$first": "$interests_info"},
            }
        },
    ]

    user = list(users_collection.aggregate(pipeline))
    if not user:
        return None, [], [], []

    user_data = user[0]
    user_name = user_data.get("email")
    user_interests = user_data.get("interests", [])

    user_minor_categories = []
    for rubric in user_data.get("interests_info", []):
        for category_id in rubric.get("category_ids", []):
            user_minor_categories.append(category_id)

    visited_places_pipeline = [
        {
            "$match": {
                "user_id": to_object_id(user_id),
                "status": "VISITED",
            }
        },
        {"$group": {"_id": "$place_id"}},
    ]

    visited_places = list(db["visiteds"].aggregate(visited_places_pipeline))
    visited_place_ids = [to_str_id(place["_id"]) for place in visited_places]

    return user_name, user_interests, user_minor_categories, visited_place_ids


def get_visited_places_by_user(user_id):
    visited_collection = db["visiteds"]
    visited_records = visited_collection.find(
        {
            "user_id": to_object_id(user_id),
            "status": "VISITED",
        },
        {"place_id": 1},
    )

    visited_places = []
    for record in visited_records:
        place_id = record.get("place_id")
        if place_id:
            visited_places.append(to_str_id(place_id))

    return visited_places


def generate_user_interest_vector(user_minor_categories):
    all_minor_categories = list(db["categories"].find({}, {"_id": 1}))
    all_minor_category_ids = [doc["_id"] for doc in all_minor_categories]

    category_index_map = {
        category_id: index for index, category_id in enumerate(all_minor_category_ids)
    }

    user_interest_vector = [0] * len(all_minor_category_ids)

    for category_id in user_minor_categories:
        category_id = to_object_id(category_id)
        index = category_index_map.get(category_id)
        if index is not None:
            user_interest_vector[index] = 1

    return user_interest_vector, all_minor_category_ids


def get_places_for_user(user_minor_categories):
    places_collection = db["places"]
    category_object_ids = [to_object_id(cat_id) for cat_id in user_minor_categories]

    if not category_object_ids:
        return []

    existing_categories = db["categories"].distinct("_id", {"_id": {"$in": category_object_ids}})
    if not existing_categories:
        return []

    pipeline = [
        {"$match": {"category_id": {"$in": existing_categories}}},
        {
            "$addFields": {
                "matching_categories": {
                    "$setIntersection": ["$category_id", existing_categories]
                }
            }
        },
        {"$match": {"matching_categories.0": {"$exists": True}}},
        {
            "$lookup": {
                "from": "rubrics",
                "localField": "category_id",
                "foreignField": "category_ids",
                "as": "global_category",
            }
        },
    ]

    return list(places_collection.aggregate(pipeline))


def generate_place_category_vector(place_categories, all_minor_categories, place_global_category):
    place_category_vector = []

    global_category_ids = set()
    for rubric in place_global_category or []:
        for category_id in rubric.get("category_ids", []):
            global_category_ids.add(category_id)

    place_category_set = set(place_categories or [])

    total_minor = len(all_minor_categories) if all_minor_categories else 1
    global_count = len(global_category_ids)

    global_weight = 1 - (global_count / total_minor)
    if global_weight < 0:
        global_weight = 0

    for category_id in all_minor_categories:
        if category_id in place_category_set:
            place_category_vector.append(1)
        elif category_id in global_category_ids:
            place_category_vector.append(global_weight)
        else:
            place_category_vector.append(0)

    return place_category_vector


def generate_place_feature_map(places, all_minor_categories):
    feature_map = {}

    for place in places:
        try:
            place_id = to_str_id(place["_id"])
            place_categories = place.get("category_id", [])
            if not isinstance(place_categories, list):
                place_categories = [place_categories]

            place_global_category = place.get("global_category", [])
            category_vector = generate_place_category_vector(
                place_categories,
                all_minor_categories,
                place_global_category,
            )

            place_score = decimal_to_float(place.get("score_2gis", 0), 0.0)
            feature_map[place_id] = {
                "vector": category_vector + [place_score],
                "place": place,
            }
        except Exception as e:
            print("Error generating feature vector for place:", e)

    return feature_map


def calculate_euclidean_distance(user_vector, place_vector):
    user_features = np.array(user_vector, dtype=float)
    place_features = np.array(place_vector[:-1], dtype=float)
    place_score = float(place_vector[-1])

    if len(user_features) != len(place_features):
        min_len = min(len(user_features), len(place_features))
        user_features = user_features[:min_len]
        place_features = place_features[:min_len]

    # У пользователя отдельного score нет, поэтому сравниваем только категориальную часть
    distance = np.linalg.norm(user_features - place_features)

    # Можно слегка учитывать рейтинг места как бонус/штраф
    # Чем выше rating, тем чуть лучше итог
    rating_penalty = max(0.0, 5.0 - place_score) * 0.05

    return float(distance + rating_penalty)


def get_users_with_similar_interests(user_interests, target_user_id):
    users_collection = db["users"]
    similar_users = []

    interest_object_ids = [to_object_id(interest) for interest in user_interests]
    provided_interest_set = set(to_str_id(interest) for interest in interest_object_ids)

    if not provided_interest_set:
        return []

    query = {
        "_id": {"$ne": to_object_id(target_user_id)},
        "interests": {"$size": len(interest_object_ids)},
    }

    users = list(users_collection.find(query, {"interests": 1}))
    for user in users:
        user_interest_set = set(to_str_id(interest) for interest in user.get("interests", []))
        if user_interest_set == provided_interest_set:
            similar_users.append(user)

    return similar_users


def rank_candidate_places(candidate_place_ids, place_frequency, place_feature_map, user_vector):
    ranked = []

    for place_id in candidate_place_ids:
        feature_entry = place_feature_map.get(place_id)
        if not feature_entry:
            continue

        distance = calculate_euclidean_distance(user_vector, feature_entry["vector"])
        frequency = place_frequency.get(place_id, 0)

        # Сортируем в первую очередь по частоте среди similar users,
        # затем по близости к интересам пользователя.
        ranked.append(
            {
                "place_id": place_id,
                "frequency": frequency,
                "distance": distance,
            }
        )

    ranked.sort(key=lambda x: (-x["frequency"], x["distance"]))
    return ranked


def find_k_nearest_neighbors_for_user(user_id, k):
    user_name, user_interests, user_minor_categories, user_visited_places = get_user_data_by_id(user_id)

    if not user_name:
        print("User not found.")
        return []

    if not user_interests:
        print("User has no interests.")
        return []

    similar_users = get_users_with_similar_interests(user_interests, user_id)
    if not similar_users:
        print("No users with similar interests found.")
        return []

    visited_places_by_similar_users = []
    for similar_user in similar_users:
        similar_user_id = similar_user["_id"]
        visited_places = get_visited_places_by_user(similar_user_id)
        visited_places_by_similar_users.extend(visited_places)

    if not visited_places_by_similar_users:
        print("No visited places by similar users found.")
        return []

    # Частота посещений similar users
    place_frequency = {}
    for place_id in visited_places_by_similar_users:
        place_frequency[place_id] = place_frequency.get(place_id, 0) + 1

    # Убираем уже посещённые target user места
    user_visited_set = set(user_visited_places)
    candidate_place_ids = [
        place_id for place_id in place_frequency.keys()
        if place_id not in user_visited_set
    ]

    if not candidate_place_ids:
        print("No candidate places left after excluding user's visited places.")
        return []

    user_interest_vector, all_minor_categories = generate_user_interest_vector(user_minor_categories)
    places_for_user = get_places_for_user(user_minor_categories)
    place_feature_map = generate_place_feature_map(places_for_user, all_minor_categories)

    ranked_places = rank_candidate_places(
        candidate_place_ids=candidate_place_ids,
        place_frequency=place_frequency,
        place_feature_map=place_feature_map,
        user_vector=user_interest_vector,
    )

    nearest_places_with_distances = [
        (item["place_id"], item["distance"]) for item in ranked_places[:k]
    ]

    return nearest_places_with_distances


def getPlacesByIds(ids):
    object_ids = [to_object_id(place_id) for place_id in ids]
    places = []
    places_cursor = db["places"].find({"_id": {"$in": object_ids}})

    places_map = {}
    for place in places_cursor:
        place["_id"] = to_str_id(place["_id"])

        if place.get("schedule_id"):
            place["schedule_id"] = to_str_id(place["schedule_id"])
        if place.get("location_id"):
            place["location_id"] = to_str_id(place["location_id"])

        place["category_id"] = [to_str_id(idx) for idx in place.get("category_id", [])]
        place["score_2gis"] = str(place.get("score_2gis", "0"))

        places_map[place["_id"]] = place

    # сохраняем порядок рекомендаций
    for place_id in ids:
        if place_id in places_map:
            places.append(places_map[place_id])

    return places


def generateRecommendation(user_id):
    nearest_places_with_distances = find_k_nearest_neighbors_for_user(user_id, 10)
    nearest_place_ids = [place_id for place_id, _ in nearest_places_with_distances]
    places = getPlacesByIds(nearest_place_ids)
    return places