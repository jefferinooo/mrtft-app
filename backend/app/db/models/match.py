from sqlalchemy import String, Integer, DateTime, Float
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Match(Base):
    __tablename__ = "matches"

    id: Mapped[int] = mapped_column(primary_key=True)
    match_id: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    patch: Mapped[str | None] = mapped_column(String, nullable=True)
    queue_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    game_datetime: Mapped[DateTime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    game_length: Mapped[float | None] = mapped_column(Float, nullable=True)