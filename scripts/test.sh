#!/bin/bash

# Скрипт для тестирования API
echo "🧪 Тестирование API..."

# Проверяем, что контейнер запущен
if ! docker-compose ps | grep -q "bal_bot_app"; then
    echo "❌ Контейнер приложения не запущен. Запустите: docker-compose up -d"
    exit 1
fi

# Ждем запуска приложения
echo "⏳ Ожидание запуска приложения..."
sleep 10

# Тестируем основные эндпоинты
echo "🔍 Тестирование основных эндпоинтов..."

# Тест главной страницы
echo "📄 Тест главной страницы..."
curl -f http://localhost:8000/ || echo "❌ Главная страница недоступна"

# Тест API документации
echo "📚 Тест API документации..."
curl -f http://localhost:8000/docs || echo "❌ API документация недоступна"

# Тест создания анкеты
echo "📝 Тест создания анкеты..."
curl -X POST "http://localhost:8000/api/form-data/" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123456789,
    "form_data": {
      "name": "Тестовый пользователь",
      "email": "test@example.com",
      "ticket_type": "VIP"
    },
    "status": "draft"
  }' || echo "❌ Ошибка создания анкеты"

# Тест получения анкет пользователя
echo "📋 Тест получения анкет пользователя..."
curl -f "http://localhost:8000/api/form-data/123456789" || echo "❌ Ошибка получения анкет"

# Тест Telegram webhook
echo "🤖 Тест Telegram webhook..."
curl -f "http://localhost:8000/telegram/webhook-info" || echo "❌ Telegram webhook недоступен"

echo "✅ Тестирование завершено"
