from fastapi import FastAPI
from api import app as api_app
from webhook import webhook_app
from database import create_tables
from config import settings
import uvicorn

# Создаем основное приложение
app = FastAPI(title="Bal Bot Backend", description="Бекенд для телеграм мини-апп с анкетой билетов")

# Подключаем API роуты
app.include_router(api_app.router, prefix="/api", tags=["API"])

# Подключаем вебхук роуты
app.include_router(webhook_app.router, prefix="/telegram", tags=["Telegram"])

@app.on_event("startup")
async def startup_event():
    """Инициализация при запуске приложения"""
    await create_tables()
    print("База данных инициализирована")

@app.get("/")
async def root():
    return {
        "message": "Bal Bot Backend работает!",
        "api_docs": "/docs",
        "telegram_webhook": "/telegram/webhook"
    }

if __name__ == "__main__":
    try:
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=True
        )
    except ImportError:
        print("Для запуска установите uvicorn: pip install uvicorn")
        print("Или запустите: uvicorn main:app --host 0.0.0.0 --port 8000 --reload")
