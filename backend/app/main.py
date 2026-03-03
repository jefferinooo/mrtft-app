from fastapi import FastAPI
from app.api.routes.health import router as health_router
from app.api.routes.ingest import router as ingest_router

app = FastAPI(title="MR TFT API")

app.include_router(health_router)
app.include_router(ingest_router)

@app.get("/")
def root():
    return {"message": "MrTFT is running"}