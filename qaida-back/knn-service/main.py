from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.responses import JSONResponse
import traceback
import time
from threading import Lock

from Model.KNN_improved import generateRecommendation

app = FastAPI()


class UserId(BaseModel):
    user_id: str


# user_id -> {"data": [...], "expires_at": float}
RECOMMENDATION_CACHE = {}
CACHE_TTL_SECONDS = 60
CACHE_LOCK = Lock()


def get_cached_recommendations(user_id: str):
    now = time.time()

    with CACHE_LOCK:
        cached = RECOMMENDATION_CACHE.get(user_id)
        if not cached:
            return None

        if cached["expires_at"] <= now:
            RECOMMENDATION_CACHE.pop(user_id, None)
            return None

        return cached["data"]


def set_cached_recommendations(user_id: str, data):
    expires_at = time.time() + CACHE_TTL_SECONDS

    with CACHE_LOCK:
        RECOMMENDATION_CACHE[user_id] = {
            "data": data,
            "expires_at": expires_at,
        }


def cleanup_expired_cache():
    now = time.time()

    with CACHE_LOCK:
        expired_keys = [
            user_id
            for user_id, payload in RECOMMENDATION_CACHE.items()
            if payload["expires_at"] <= now
        ]

        for user_id in expired_keys:
            RECOMMENDATION_CACHE.pop(user_id, None)


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/recommend")
def recommend(payload: UserId):
    start = time.time()
    print(f"[RECOMMEND] request user_id={payload.user_id}")

    try:
        cleanup_expired_cache()

        cached = get_cached_recommendations(payload.user_id)
        if cached is not None:
            elapsed = time.time() - start
            print(
                f"[RECOMMEND] cache hit user_id={payload.user_id} "
                f"elapsed={elapsed:.3f}s count={len(cached)}"
            )
            return cached

        result = generateRecommendation(payload.user_id)
        set_cached_recommendations(payload.user_id, result)

        elapsed = time.time() - start
        print(
            f"[RECOMMEND] success user_id={payload.user_id} "
            f"elapsed={elapsed:.3f}s count={len(result)}"
        )
        return result

    except Exception as e:
        elapsed = time.time() - start
        print(f"[RECOMMEND] ERROR elapsed={elapsed:.3f}s error={e}")
        traceback.print_exc()
        return JSONResponse(status_code=200, content=[])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)