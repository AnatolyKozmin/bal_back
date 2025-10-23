import asyncio
import logging
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton, WebAppInfo
from config import settings

# Настройка логирования
logging.basicConfig(level=logging.INFO)

# Инициализация бота и диспетчера
bot = Bot(token=settings.TELEGRAM_BOT_TOKEN)
dp = Dispatcher()

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

async def main():
    """Главная функция для запуска бота"""
    # Удаляем webhook если он был установлен
    await bot.delete_webhook(drop_pending_updates=True)
    
    # Запускаем polling
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
