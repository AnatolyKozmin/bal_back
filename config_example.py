"""
Пример конфигурации для проекта Bal Bot
Скопируйте этот файл в .env и заполните реальными значениями
"""

# База данных
DATABASE_URL = "sqlite:///./bal_bot.db"
# Для PostgreSQL: DATABASE_URL = "postgresql://user:password@localhost/bal_bot_db"

# Telegram Bot
TELEGRAM_BOT_TOKEN = "your_bot_token_here"

# Webhook настройки
WEBHOOK_URL = "https://yourdomain.com"
SECRET_KEY = "your_secret_key_here"

# URL мини-апп
MINI_APP_URL = "https://yourdomain.com/mini-app"
