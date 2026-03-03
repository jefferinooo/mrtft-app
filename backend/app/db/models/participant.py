from sqlalchemy import ForeignKey, Integer, BigInteger, DateTime, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from app.db.base import Base


class Participant(Base):
    __tablename__ = "participants"

    __table_args__ = (
        UniqueConstraint(
            "match_id",
            "player_id",
            name="uq_participant_match_player",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)

    match_id: Mapped[int] = mapped_column(
        ForeignKey("matches.id"),
        nullable=False,
        index=True,
    )

    player_id: Mapped[int] = mapped_column(
        ForeignKey("players.id"),
        nullable=False,
        index=True,
    )

    placement: Mapped[int | None] = mapped_column(Integer, nullable=True)
    level: Mapped[int | None] = mapped_column(Integer, nullable=True)
    gold_left: Mapped[int | None] = mapped_column(Integer, nullable=True)
    last_round: Mapped[int | None] = mapped_column(Integer, nullable=True)
    total_damage: Mapped[int | None] = mapped_column(BigInteger, nullable=True)

    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )