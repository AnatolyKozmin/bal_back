from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import Column, Integer, String, DateTime, Text, JSON
from sqlalchemy.orm import DeclarativeBase
from datetime import datetime
from config import settings

# Создаем асинхронный движок базы данных
engine = create_async_engine(settings.DATABASE_URL)
AsyncSessionLocal = async_sessionmaker(
    engine, 
    class_=AsyncSession, 
    expire_on_commit=False
)

class Base(DeclarativeBase):
    pass

class TicketForm(Base):
    __tablename__ = "ticket_forms"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)  # Telegram user ID
    form_data = Column(JSON, nullable=False)  # JSON данные анкеты
    status = Column(String(50), default="draft")  # draft, submitted, processed
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    notes = Column(Text, nullable=True)  # Дополнительные заметки

async def create_tables():
    """Создать таблицы в базе данных"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def get_db():
    """Получить сессию базы данных"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
