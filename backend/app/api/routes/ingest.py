from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.services.ingestion_service import IngestionService

router = APIRouter(prefix="/ingest", tags=["ingestion"])
service = IngestionService()

@router.post("/{game_name}/{tag_line}")
def ingest(game_name: str, tag_line: str, count: int = Query(20, ge=1, le=50), db: Session = Depends(get_db)):
    # count limited to reduce rate-limit pain while developing
    return service.ingest_recent_matches(db, game_name, tag_line, count=count)