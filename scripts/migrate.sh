#!/bin/bash

# Скрипт для применения миграций
echo "🚀 Применение миграций базы данных..."

# Проверяем, что контейнер запущен
if ! docker-compose ps | grep -q "bal_bot_app"; then
    echo "❌ Контейнер приложения не запущен. Запустите: docker-compose up -d"
    exit 1
fi

# Создаем миграцию если нужно
if [ "$1" = "create" ]; then
    echo "📝 Создание новой миграции..."
    docker-compose exec app alembic revision --autogenerate -m "$2"
    echo "✅ Миграция создана"
    exit 0
fi

# Применяем миграции
echo "🔄 Применение миграций..."
docker-compose exec app alembic upgrade head

if [ $? -eq 0 ]; then
    echo "✅ Миграции успешно применены"
else
    echo "❌ Ошибка при применении миграций"
    exit 1
fi
