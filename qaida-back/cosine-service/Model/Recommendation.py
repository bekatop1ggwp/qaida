from pymongo import MongoClient
from bson import ObjectId
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

client = MongoClient("mongodb+srv://ald1k0n:264166@cluster0.ppiyo0p.mongodb.net/qaida")
db = client["qaida"]


def fetchUsers():
    data = db.users.aggregate([
        {"$match": {
            "interests": {"$ne": []}
        }},
        {"$lookup": {
            "from": "rubrics",
            "localField": "interests",
            "foreignField": "_id",
            "as": "interests"
        }},
        {"$unwind": "$interests"},
        {"$lookup": {
            "from": "categories",
            "localField": "interests.category_ids",
            "foreignField": "_id",
            "as": "interests.category_ids"
        }},
        {"$group": {
            "_id": "$_id",
            "email": {"$first": "$email"},
            "interests": {"$push": "$interests"}
        }},
        {"$project": {
            "_id": 1,
            "email": 1,
            "interests._id": 1,
            "interests.name": 1,
            "interests.category_ids": 1,
        }}
    ])
                
    return data


def listToDict(userList):
    results = []
    for user in userList:
        user_dict = {
            "_id": str(user["_id"]),
            "email": user["email"],
            "interests": [{"_id": str(interest["_id"]), "name": interest["name"], "category_ids": interest["category_ids"]} for interest in user["interests"]]
        }
        results.append(user_dict)
    return results



def custom_encoder(obj):
    if isinstance(obj, ObjectId):
        return str(obj)
    raise TypeError("Object of type {} is not JSON serializable".format(type(obj)))


def one_hot_encode(interests, all_categories):
    encoded_interests = np.zeros(len(all_categories))
    for interest in interests:
        for category_id in interest["category_ids"]:
            category_name = category_id["name"]
            if category_name in all_categories:
                category_index = all_categories.index(category_name)
                encoded_interests[category_index] = 1
    return encoded_interests

def get_interest_vector(interest_names, all_categories):
    interest_vector = np.zeros(len(all_categories))
    for interest_name in interest_names:
        if interest_name in all_categories:
            interest_index = all_categories.index(interest_name)
            interest_vector[interest_index] = 1
    return interest_vector


def generate_interests(user_interest_names):
    users = fetchUsers()
    data = listToDict(users)

    all_categories = set()
    for interest in data[0]["interests"]:
        for category in interest["category_ids"]:
            all_categories.add(category["name"])
    for interest in data[1]["interests"]:
        for category in interest["category_ids"]:
            all_categories.add(category["name"])
    all_categories = sorted(list(all_categories))


    encoded_data = []
    for user in data:
        encoded_interests = one_hot_encode(user["interests"], all_categories)
        encoded_data.append(encoded_interests)

    user_interest_vector = get_interest_vector(user_interest_names, all_categories)
    user_similarities = cosine_similarity([user_interest_vector], encoded_data)

    most_similar_user_index = np.argmax(user_similarities)
    recommended_interests = data[most_similar_user_index]["interests"]

    rec_data = []
    for interest in recommended_interests:
        rec_data.append({"name":interest['name'], "interest_id": interest['_id']})
    return rec_data 

# user_interest_names = ["Рестораны", "Быстрое питание", "Кофейни"]

# print(generate_interests(user_interest_names))

