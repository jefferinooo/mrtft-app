from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.db.models.player import Player


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
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(
            status_code=404,
            detail="Player not found in database. Ingest them first.",
        )

    return player