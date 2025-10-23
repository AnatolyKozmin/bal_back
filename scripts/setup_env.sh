#!/bin/bash

# Скрипт для настройки переменных окружения
echo "🔧 Настройка переменных окружения для Bal Bot Backend"

# Создаем .env файл если его нет
if [ ! -f .env ]; then
    cp env.docker .env
    echo "✅ Создан файл .env"
fi

# Генерируем SECRET_KEY
echo "🔐 Генерация SECRET_KEY..."
SECRET_KEY=$(python3 scripts/generate_secret.py | grep "SECRET_KEY=" | cut -d'=' -f2)
echo "Сгенерированный SECRET_KEY: $SECRET_KEY"

# Обновляем .env файл
sed -i "s/SECRET_KEY=your_secret_key_here/SECRET_KEY=$SECRET_KEY/" .env

echo ""
echo "📝 Теперь отредактируйте .env файл и заполните:"
echo "   - TELEGRAM_BOT_TOKEN (получите от @BotFather)"
echo "   - WEBHOOK_URL (URL вашего бекенда после развертывания)"
echo "   - MINI_APP_URL (URL вашего фронтенда на GitHub Pages)"
echo ""
echo "🔍 Для редактирования: nano .env"
echo "📋 Пример заполнения:"
echo "   TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
echo "   WEBHOOK_URL=https://your-app.railway.app"
echo "   MINI_APP_URL=https://yourusername.github.io/bal-bot-frontend"
