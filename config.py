import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./bal_bot.db")
    TELEGRAM_BOT_TOKEN: str = os.getenv("TELEGRAM_BOT_TOKEN", "")
    WEBHOOK_URL: str = os.getenv("WEBHOOK_URL", "")
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here")
    
    # Настройки для мини-апп
    MINI_APP_URL: str = os.getenv("MINI_APP_URL", "https://yourdomain.com/mini-app")

settings = Settings()
