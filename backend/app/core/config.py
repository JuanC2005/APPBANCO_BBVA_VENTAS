import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "BBVA Fuerza de Ventas API"
    VERSION: str = "2.0.0"
    DEBUG: bool = False

    SECRET_KEY: str = "cambiar_en_produccion_bbva_fv_2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480
    JWT_ISSUER: str = "bbva-fv-api"

    CORS_ORIGINS: list[str] = ["*"]

    SUPABASE_URL: str = "https://slvfourmyqgkzjddyliv.supabase.co"
    SUPABASE_SERVICE_KEY: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
