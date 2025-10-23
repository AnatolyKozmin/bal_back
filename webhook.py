import asyncio
import logging
from fastapi import FastAPI, Request, HTTPException
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton, WebAppInfo
from config import settings
import json

# Настройка логирования
logging.basicConfig(level=logging.INFO)

# Инициализация бота и диспетчера
bot = Bot(token=settings.TELEGRAM_BOT_TOKEN)
dp = Dispatcher()

# Создаем FastAPI приложение для вебхуков
webhook_app = FastAPI(title="Telegram Webhook")

@dp.message(Command("start"))
async def start_command(message: types.Message):
    """Обработчик команды /start"""
    keyboard = InlineKeyboardMarkup(
        inline_keyboard=[
            [
                InlineKeyboardButton(
                    text="🎫 Заполнить анкету для билета",
                    web_app=WebAppInfo(url=settings.MINI_APP_URL)
                )
            ]
        ]
    )
    
    welcome_text = (
        "🎉 Добро пожаловать!\n\n"
        "Этот бот поможет вам заполнить анкету для получения билетов.\n\n"
        "Нажмите на кнопку ниже, чтобы открыть форму:"
    )
    
    await message.answer(welcome_text, reply_markup=keyboard)

@dp.message(Command("help"))
async def help_command(message: types.Message):
    """Обработчик команды /help"""
    help_text = (
        "📋 Доступные команды:\n\n"
        "/start - Начать работу с ботом\n"
        "/help - Показать эту справку\n\n"
        "Для заполнения анкеты используйте кнопку в меню /start"
    )
    await message.answer(help_text)

@dp.message()
async def handle_message(message: types.Message):
    """Обработчик всех остальных сообщений"""
    await message.answer(
        "Используйте команду /start для начала работы с ботом."
    )

@webhook_app.post("/webhook")
async def webhook_handler(request: Request):
    """Обработчик вебхуков от Telegram"""
    try:
        # Получаем данные от Telegram
        update_data = await request.json()
        update = types.Update(**update_data)
        
        # Обрабатываем обновление
        await dp.feed_update(bot, update)
        
        return {"status": "ok"}
    except Exception as e:
        logging.error(f"Ошибка обработки вебхука: {e}")
        raise HTTPException(status_code=400, detail="Ошибка обработки вебхука")

@webhook_app.get("/set-webhook")
async def set_webhook():
    """Установить вебхук"""
    try:
        webhook_url = f"{settings.WEBHOOK_URL}/webhook"
        await bot.set_webhook(url=webhook_url)
        return {"status": "webhook установлен", "url": webhook_url}
    except Exception as e:
        return {"error": str(e)}

@webhook_app.get("/delete-webhook")
async def delete_webhook():
    """Удалить вебхук"""
    try:
        await bot.delete_webhook()
        return {"status": "webhook удален"}
    except Exception as e:
        return {"error": str(e)}

@webhook_app.get("/webhook-info")
async def webhook_info():
    """Получить информацию о вебхуке"""
    try:
        webhook_info = await bot.get_webhook_info()
        return {
            "url": webhook_info.url,
            "has_custom_certificate": webhook_info.has_custom_certificate,
            "pending_update_count": webhook_info.pending_update_count,
            "last_error_date": webhook_info.last_error_date,
            "last_error_message": webhook_info.last_error_message,
            "max_connections": webhook_info.max_connections,
            "allowed_updates": webhook_info.allowed_updates
        }
    except Exception as e:
        return {"error": str(e)}
