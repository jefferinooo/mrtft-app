from fastapi import FastAPI
from app.api.routes.health import router as health_router

app = FastAPI(title="MR TFT API")

app.include_router(health_router)

@app.get("/")
def root():
    return {"message": "MR TFT API is running"}