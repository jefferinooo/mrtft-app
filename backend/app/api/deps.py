from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.db.models.player import Player
from app.core.utils import normalize_riot_id_component

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_player(
    game_name: str,
    tag_line: str,
    db: Session = Depends(get_db),
) -> Player:
    normalized_game_name = normalize_riot_id_component(game_name)
    normalized_tag_line = normalize_riot_id_component(tag_line)

    player = (
        db.query(Player)
        .filter(
            Player.game_name == normalized_game_name,
            Player.tag_line == normalized_tag_line,
        )
        .one_or_none()
    )

    if player is None:
        raise HTTPException(
            status_code=404,
            detail="Player not found in database. Ingest them first.",
        )

    return player