import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient
from bson import ObjectId
import numpy as np
from collections import Counter

ENV_PATH = Path(__file__).resolve().parents[2] / "src" / "core" / ".env"
load_dotenv(dotenv_path=ENV_PATH)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

client = MongoClient(DATABASE_URL)
db = client.get_default_database()
if db is None:
    db = client["qaida"]

# -------------------------
# Global in-memory caches
# -------------------------
ALL_MINOR_CATEGORY_IDS = []
CATEGORY_INDEX_MAP = {}
PLACE_CACHE = {}
PLACE_VECTOR_CACHE = {}


def _to_oid(value):
    if isinstance(value, ObjectId):
        return value
    return ObjectId(str(value))


def _to_str(value):
    return str(value)


def _to_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(str(value))
    except Exception:
        return default


def warmup_cache():
    global ALL_MINOR_CATEGORY_IDS, CATEGORY_INDEX_MAP, PLACE_CACHE, PLACE_VECTOR_CACHE

    ALL_MINOR_CATEGORY_IDS = list(db["categories"].distinct("_id"))
    CATEGORY_INDEX_MAP = {
        category_id: idx for idx, category_id in enumerate(ALL_MINOR_CATEGORY_IDS)
    }

    places = list(
        db["places"].aggregate([
            {
                "$lookup": {
                    "from": "rubrics",
                    "localField": "category_id",
                    "foreignField": "category_ids",
                    "as": "global_category"
                }
            }
        ])
    )

    place_cache = {}
    place_vector_cache = {}

    for place in places:
        place_id = _to_str(place["_id"])
        place_cache[place_id] = place

        place_categories = place.get("category_id", [])
        if not isinstance(place_categories, list):
            place_categories = [place_categories]

        global_category_ids = set()
        for rubric in place.get("global_category", []):
            for category_id in rubric.get("category_ids", []):
                global_category_ids.add(category_id)

        total_minor = len(ALL_MINOR_CATEGORY_IDS) or 1
        global_weight = max(0.0, 1 - (len(global_category_ids) / total_minor))

        vector = []
        place_category_set = set(place_categories)

        for category_id in ALL_MINOR_CATEGORY_IDS:
            if category_id in place_category_set:
                vector.append(1.0)
            elif category_id in global_category_ids:
                vector.append(global_weight)
            else:
                vector.append(0.0)

        place_vector_cache[place_id] = {
            "vector": vector,
            "score": _to_float(place.get("score_2gis", 0)),
        }

    PLACE_CACHE = place_cache
    PLACE_VECTOR_CACHE = place_vector_cache


def get_user_data_by_id(user_id):
    pipeline = [
        {"$match": {"_id": _to_oid(user_id)}},
        {
            "$lookup": {
                "from": "rubrics",
                "localField": "interests",
                "foreignField": "_id",
                "as": "interests_info"
            }
        },
        {
            "$project": {
                "email": 1,
                "interests": {"$ifNull": ["$interests", []]},
                "minor_categories": {
                    "$reduce": {
                        "input": {
                            "$map": {
                                "input": "$interests_info",
                                "as": "rubric",
                                "in": {"$ifNull": ["$$rubric.category_ids", []]}
                            }
                        },
                        "initialValue": [],
                        "in": {"$concatArrays": ["$$value", "$$this"]}
                    }
                }
            }
        }
    ]

    rows = list(db["users"].aggregate(pipeline))
    if not rows:
        return None, [], [], []

    row = rows[0]

    visited_rows = list(db["visiteds"].aggregate([
        {
            "$match": {
                "user_id": _to_oid(user_id),
                "status": "VISITED"
            }
        },
        {
            "$group": {"_id": "$place_id"}
        }
    ]))

    visited_place_ids = [_to_str(x["_id"]) for x in visited_rows]

    return (
        row.get("email"),
        row.get("interests", []),
        row.get("minor_categories", []),
        visited_place_ids,
    )


def build_user_vector(user_minor_categories):
    vector = [0.0] * len(ALL_MINOR_CATEGORY_IDS)
    for category_id in user_minor_categories:
        idx = CATEGORY_INDEX_MAP.get(category_id)
        if idx is not None:
            vector[idx] = 1.0
    return vector


def get_similar_users(user_interests, user_id):
    target_set = set(_to_str(x) for x in user_interests)
    if not target_set:
        return []

    users = list(
        db["users"].find(
            {"_id": {"$ne": _to_oid(user_id)}},
            {"interests": 1}
        )
    )

    similar = []
    for user in users:
        other_set = set(_to_str(x) for x in user.get("interests", []))
        if not other_set:
            continue

        union = len(target_set | other_set)
        if union == 0:
            continue

        similarity = len(target_set & other_set) / union
        if similarity >= 0.2:
            similar.append({
                "user_id": user["_id"],
                "similarity": similarity,
            })

    similar.sort(key=lambda x: x["similarity"], reverse=True)
    return similar[:30]


def get_candidate_places_from_similar_users(similar_users, user_visited_places):
    if not similar_users:
        return {}

    similar_user_ids = [x["user_id"] for x in similar_users]
    similarity_map = {_to_str(x["user_id"]): x["similarity"] for x in similar_users}
    user_visited_set = set(user_visited_places)

    rows = list(db["visiteds"].find(
        {
            "user_id": {"$in": similar_user_ids},
            "status": "VISITED",
        },
        {
            "user_id": 1,
            "place_id": 1,
        }
    ))

    scores = Counter()

    for row in rows:
        place_id = _to_str(row["place_id"])
        if place_id in user_visited_set:
            continue

        sim_user_id = _to_str(row["user_id"])
        scores[place_id] += similarity_map.get(sim_user_id, 0.0)

    return dict(scores)


def cosine_sim(a, b):
    a = np.array(a, dtype=float)
    b = np.array(b, dtype=float)

    denom = np.linalg.norm(a) * np.linalg.norm(b)
    if denom == 0:
        return 0.0

    return float(np.dot(a, b) / denom)


def rank_places(user_vector, candidate_scores):
    ranked = []

    for place_id, collaborative_score in candidate_scores.items():
        place_data = PLACE_VECTOR_CACHE.get(place_id)
        if not place_data:
            continue

        content_score = cosine_sim(user_vector, place_data["vector"])
        rating_bonus = min(place_data["score"] / 5.0, 1.0) * 0.1

        final_score = (0.7 * collaborative_score) + (0.3 * content_score) + rating_bonus

        ranked.append((place_id, final_score))

    ranked.sort(key=lambda x: x[1], reverse=True)
    return ranked


def getPlacesByIds(ids):
    places = []
    for place_id in ids:
        place = PLACE_CACHE.get(_to_str(place_id))
        if not place:
            continue

        prepared = dict(place)
        prepared["_id"] = _to_str(prepared["_id"])

        if prepared.get("schedule_id") is not None:
            prepared["schedule_id"] = _to_str(prepared["schedule_id"])

        if prepared.get("location_id") is not None:
            prepared["location_id"] = _to_str(prepared["location_id"])

        prepared["category_id"] = [_to_str(x) for x in prepared.get("category_id", [])]
        prepared["score_2gis"] = str(prepared.get("score_2gis", "0"))

        places.append(prepared)

    return places


def generateRecommendation(user_id):
    user_name, user_interests, user_minor_categories, user_visited_places = get_user_data_by_id(user_id)
    if not user_name or not user_interests:
        return []

    user_vector = build_user_vector(user_minor_categories)
    similar_users = get_similar_users(user_interests, user_id)
    candidate_scores = get_candidate_places_from_similar_users(similar_users, user_visited_places)
    ranked = rank_places(user_vector, candidate_scores)

    top_ids = [place_id for place_id, _ in ranked[:10]]
    return getPlacesByIds(top_ids)


warmup_cache()