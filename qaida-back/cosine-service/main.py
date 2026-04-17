from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from Model.Recommendation import generate_interests
from typing import List
from pydantic import BaseModel

class UserInterests(BaseModel):
    user_interests: List[str]

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post('/recommend')
async def get_recommendation(user_interests: UserInterests):
  if not user_interests:
    raise HTTPException(status_code=400, detail="Интересы не выявлены")
  
  interests = generate_interests(user_interests)
  return interests


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)