#!/bin/bash

# Скрипт для развертывания на сервере
echo "🚀 Развертывание Bal Bot Backend..."

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker сначала."
    exit 1
fi

# Проверяем наличие Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Установите Docker Compose сначала."
    exit 1
fi

# Останавливаем существующие контейнеры
echo "🛑 Остановка существующих контейнеров..."
docker-compose down

# Собираем новые образы
echo "🔨 Сборка Docker образов..."
docker-compose build --no-cache

# Запускаем контейнеры
echo "▶️ Запуск контейнеров..."
docker-compose up -d

# Ждем запуска базы данных
echo "⏳ Ожидание запуска базы данных..."
sleep 15

# Применяем миграции
echo "🔄 Применение миграций..."
./scripts/migrate.sh

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps

echo "✅ Развертывание завершено!"
echo "🌐 Приложение доступно по адресу: http://localhost:8000"
echo "📚 API документация: http://localhost:8000/docs"
