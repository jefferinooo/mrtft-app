from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    ENV: str = "dev"
    DATABASE_URL: str

    class Config:
        env_file = ".env"

settings = Settings()