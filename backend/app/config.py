from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    ENV: str = "dev"
    DATABASE_URL: str

    RIOT_API_KEY: str
    RIOT_REGION: str = "americas"
    RIOT_PLATFORM: str = "na1"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()