#!/bin/bash

# Скрипт для применения миграций
echo "🚀 Инициализация базы данных..."

# Проверяем, что контейнер запущен
if ! docker-compose ps | grep -q "bal_bot_app"; then
    echo "❌ Контейнер приложения не запущен. Запустите: docker-compose up -d"
    exit 1
fi

# Ждем запуска базы данных
echo "⏳ Ожидание запуска базы данных..."
sleep 10

# Инициализируем базу данных
echo "🔄 Создание таблиц в базе данных..."
docker-compose exec app python scripts/simple_init.py

if [ $? -eq 0 ]; then
    echo "✅ База данных успешно инициализирована"
else
    echo "❌ Ошибка при инициализации базы данных"
    exit 1
fi
