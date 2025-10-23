#!/usr/bin/env python3
"""
Простая инициализация базы данных без Alembic
"""

import asyncio
import sys
import os

# Добавляем путь к проекту
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from database import create_tables, engine
from sqlalchemy import text

async def init_database():
    """Инициализация базы данных"""
    try:
        print("🔄 Создание таблиц в базе данных...")
        
        # Создаем таблицы
        await create_tables()
        
        # Проверяем подключение
        async with engine.begin() as conn:
            result = await conn.execute(text("SELECT 1"))
            print("✅ Подключение к базе данных успешно")
        
        print("✅ База данных успешно инициализирована!")
        
    except Exception as e:
        print(f"❌ Ошибка инициализации базы данных: {e}")
        sys.exit(1)
    finally:
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(init_database())
