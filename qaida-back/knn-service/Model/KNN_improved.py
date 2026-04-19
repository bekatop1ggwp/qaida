import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient
from bson import ObjectId
import numpy as np
import math

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


def jaccard_similarity(set_a, set_b):
    if not set_a and not set_b:
        return 0.0
    union = len(set_a | set_b)
    if union == 0:
        return 0.0
    return len(set_a & set_b) / union


def normalize_scores(score_map):
    if not score_map:
        return {}

    values = list(score_map.values())
    min_v = min(values)
    max_v = max(values)

    if math.isclose(max_v, min_v):
        return {k: 1.0 for k in score_map.keys()}

    return {k: (v - min_v) / (max_v - min_v) for k, v in score_map.items()}


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
            "$project": {
                "_id": 1,
                "email": 1,
                "interests": {"$ifNull": ["$interests", []]},
                "favorites": {"$ifNull": ["$favorites", []]},
                "interests_info": 1,
            }
        },
    ]

    user = list(users_collection.aggregate(pipeline))
    if not user:
        return None, [], [], [], []

    user_data = user[0]
    user_name = user_data.get("email")
    user_interests = user_data.get("interests", [])
    user_favorites = [to_str_id(x) for x in user_data.get("favorites", [])]

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

    return user_name, user_interests, user_minor_categories, visited_place_ids, user_favorites


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


def get_global_place_popularity():
    pipeline = [
        {"$match": {"status": "VISITED"}},
        {"$group": {"_id": "$place_id", "count": {"$sum": 1}}},
    ]
    rows = list(db["visiteds"].aggregate(pipeline))
    return {to_str_id(row["_id"]): row["count"] for row in rows}


def generate_user_interest_vector(user_minor_categories):
    all_minor_categories = list(db["categories"].find({}, {"_id": 1}))
    all_minor_category_ids = [doc["_id"] for doc in all_minor_categories]

    category_index_map = {
        category_id: index for index, category_id in enumerate(all_minor_category_ids)
    }

    user_interest_vector = [0.0] * len(all_minor_category_ids)

    for category_id in user_minor_categories:
        category_id = to_object_id(category_id)
        index = category_index_map.get(category_id)
        if index is not None:
            user_interest_vector[index] = 1.0

    return user_interest_vector, all_minor_category_ids


def get_places_for_user(user_minor_categories):
    places_collection = db["places"]
    category_object_ids = [to_object_id(cat_id) for cat_id in user_minor_categories]

    if not category_object_ids:
        return []

    existing_categories = db["categories"].distinct(
        "_id",
        {"_id": {"$in": category_object_ids}}
    )
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
    global_weight = max(0.0, 1 - (global_count / total_minor))

    for category_id in all_minor_categories:
        if category_id in place_category_set:
            place_category_vector.append(1.0)
        elif category_id in global_category_ids:
            place_category_vector.append(global_weight)
        else:
            place_category_vector.append(0.0)

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
                "vector": category_vector,
                "rating": place_score,
                "place": place,
            }
        except Exception as e:
            print("Error generating feature vector for place:", e)

    return feature_map


def calculate_content_similarity(user_vector, place_vector):
    user_arr = np.array(user_vector, dtype=float)
    place_arr = np.array(place_vector, dtype=float)

    if len(user_arr) != len(place_arr):
        min_len = min(len(user_arr), len(place_arr))
        user_arr = user_arr[:min_len]
        place_arr = place_arr[:min_len]

    user_norm = np.linalg.norm(user_arr)
    place_norm = np.linalg.norm(place_arr)

    if user_norm == 0 or place_norm == 0:
        return 0.0

    cosine_sim = float(np.dot(user_arr, place_arr) / (user_norm * place_norm))
    return max(0.0, cosine_sim)


def get_top_similar_users(user_interests, target_user_id, top_n=30, min_similarity=0.2):
    users_collection = db["users"]

    target_interest_set = set(to_str_id(interest) for interest in user_interests)
    if not target_interest_set:
        return []

    users = list(
        users_collection.find(
            {"_id": {"$ne": to_object_id(target_user_id)}},
            {"interests": 1, "favorites": 1}
        )
    )

    scored_users = []
    for user in users:
        user_interest_set = set(to_str_id(interest) for interest in user.get("interests", []))
        similarity = jaccard_similarity(target_interest_set, user_interest_set)

        if similarity >= min_similarity:
            scored_users.append({
                "user_id": to_str_id(user["_id"]),
                "similarity": similarity,
                "favorites": [to_str_id(x) for x in user.get("favorites", [])],
            })

    scored_users.sort(key=lambda x: x["similarity"], reverse=True)
    return scored_users[:top_n]


def build_collaborative_scores(similar_users, user_visited_set, user_favorites_set):
    collaborative_scores = {}
    favorite_scores = {}

    for similar_user in similar_users:
        sim_user_id = similar_user["user_id"]
        sim_weight = similar_user["similarity"]
        sim_favorites = set(similar_user.get("favorites", []))

        visited_places = set(get_visited_places_by_user(sim_user_id))

        for place_id in visited_places:
            if place_id in user_visited_set:
                continue
            collaborative_scores[place_id] = collaborative_scores.get(place_id, 0.0) + sim_weight

        for place_id in sim_favorites:
            if place_id in user_visited_set:
                continue
            if place_id in user_favorites_set:
                continue
            favorite_scores[place_id] = favorite_scores.get(place_id, 0.0) + (sim_weight * 1.15)

    return collaborative_scores, favorite_scores


def build_content_scores(candidate_place_ids, place_feature_map, user_vector):
    content_scores = {}

    for place_id in candidate_place_ids:
        place_data = place_feature_map.get(place_id)
        if not place_data:
            continue

        similarity = calculate_content_similarity(user_vector, place_data["vector"])
        rating_bonus = min(place_data["rating"] / 5.0, 1.0) * 0.15

        content_scores[place_id] = similarity + rating_bonus

    return content_scores


def build_popularity_penalty(candidate_place_ids, global_popularity):
    if not candidate_place_ids:
        return {}

    # Штрафуем только внутри текущего кандидатного пула
    popularity_map = {
        place_id: global_popularity.get(place_id, 0)
        for place_id in candidate_place_ids
    }

    norm_popularity = normalize_scores(popularity_map)

    # Чем популярнее место глобально, тем больше штраф.
    # Но штраф мягкий, чтобы хорошие места не убить полностью.
    return {place_id: score * 0.25 for place_id, score in norm_popularity.items()}


def rank_places(collaborative_scores, favorite_scores, content_scores, popularity_penalty,
                alpha=0.50, beta=0.25, gamma=0.30, delta=0.15):
    norm_collab = normalize_scores(collaborative_scores)
    norm_fav = normalize_scores(favorite_scores)
    norm_content = normalize_scores(content_scores)

    all_place_ids = set(norm_collab.keys()) | set(norm_fav.keys()) | set(norm_content.keys())

    ranked = []
    for place_id in all_place_ids:
        collab = norm_collab.get(place_id, 0.0)
        fav = norm_fav.get(place_id, 0.0)
        content = norm_content.get(place_id, 0.0)
        pop_penalty = popularity_penalty.get(place_id, 0.0)

        final_score = (alpha * collab) + (beta * fav) + (gamma * content) - (delta * pop_penalty)

        ranked.append({
            "place_id": place_id,
            "collaborative_score": collab,
            "favorite_score": fav,
            "content_score": content,
            "popularity_penalty": pop_penalty,
            "final_score": final_score,
        })

    ranked.sort(key=lambda x: x["final_score"], reverse=True)
    return ranked


def find_k_recommendations_for_user(user_id, k):
    user_name, user_interests, user_minor_categories, user_visited_places, user_favorites = get_user_data_by_id(user_id)

    if not user_name or not user_interests:
        return []

    user_visited_set = set(user_visited_places)
    user_favorites_set = set(user_favorites)

    similar_users = get_top_similar_users(
        user_interests=user_interests,
        target_user_id=user_id,
        top_n=30,
        min_similarity=0.2,
    )
    if not similar_users:
        return []

    collaborative_scores, favorite_scores = build_collaborative_scores(
        similar_users=similar_users,
        user_visited_set=user_visited_set,
        user_favorites_set=user_favorites_set,
    )

    candidate_place_ids = set(collaborative_scores.keys()) | set(favorite_scores.keys())
    if not candidate_place_ids:
        return []

    user_vector, all_minor_categories = generate_user_interest_vector(user_minor_categories)
    places_for_user = get_places_for_user(user_minor_categories)
    place_feature_map = generate_place_feature_map(places_for_user, all_minor_categories)

    # Оставляем только места, для которых реально можем посчитать content signal
    candidate_place_ids = [place_id for place_id in candidate_place_ids if place_id in place_feature_map]
    if not candidate_place_ids:
        return []

    content_scores = build_content_scores(candidate_place_ids, place_feature_map, user_vector)
    global_popularity = get_global_place_popularity()
    popularity_penalty = build_popularity_penalty(candidate_place_ids, global_popularity)

    ranked_places = rank_places(
        collaborative_scores={k: v for k, v in collaborative_scores.items() if k in candidate_place_ids},
        favorite_scores={k: v for k, v in favorite_scores.items() if k in candidate_place_ids},
        content_scores=content_scores,
        popularity_penalty=popularity_penalty,
        alpha=0.50,
        beta=0.25,
        gamma=0.30,
        delta=1.0,
    )

    return [item["place_id"] for item in ranked_places[:k]]


def getPlacesByIds(ids):
    object_ids = [to_object_id(place_id) for place_id in ids]
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

    ordered_places = []
    for place_id in ids:
        if place_id in places_map:
            ordered_places.append(places_map[place_id])

    return ordered_places


def generateRecommendation(user_id):
    recommended_ids = find_k_recommendations_for_user(user_id, 10)
    return getPlacesByIds(recommended_ids)