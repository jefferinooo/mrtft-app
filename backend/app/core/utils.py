def format_game_length(seconds: float | None) -> str | None:
    """
    convert game length from seconds to MM:SS format.
    ex: 2209.65 -> "36:49"
    """
    if seconds is None:
        return None

    total_seconds = int(seconds)
    minutes = total_seconds // 60
    remaining_seconds = total_seconds % 60

    return f"{minutes}:{remaining_seconds:02d}"