from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.responses import JSONResponse
import traceback
import time

from Model.KNN_improved import generateRecommendation

app = FastAPI()


class UserId(BaseModel):
    user_id: str


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/recommend")
def recommend(payload: UserId):
    start = time.time()
    print(f"[RECOMMEND] request user_id={payload.user_id}")

    try:
        result = generateRecommendation(payload.user_id)
        elapsed = time.time() - start
        print(f"[RECOMMEND] success elapsed={elapsed:.3f}s count={len(result)}")
        return result
    except Exception as e:
        elapsed = time.time() - start
        print(f"[RECOMMEND] ERROR elapsed={elapsed:.3f}s error={e}")
        traceback.print_exc()
        return JSONResponse(status_code=200, content=[])