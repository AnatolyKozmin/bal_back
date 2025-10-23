from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, update
from database import get_db, TicketForm
from schemas import FormDataRequest, FormDataResponse, FormDataUpdate
from typing import List
import json

app = FastAPI(title="Bal Bot API", description="API для телеграм мини-апп с анкетой билетов")

@app.get("/")
async def root():
    return {"message": "Bal Bot API работает!"}

@app.post("/form-data/", response_model=FormDataResponse)
async def create_form_data(form_data: FormDataRequest, db: AsyncSession = Depends(get_db)):
    """Создать новую запись анкеты"""
    db_form = TicketForm(
        user_id=form_data.user_id,
        form_data=form_data.form_data,
        status=form_data.status
    )
    db.add(db_form)
    await db.commit()
    await db.refresh(db_form)
    return db_form

@app.get("/form-data/{user_id}", response_model=List[FormDataResponse])
async def get_user_forms(user_id: int, db: AsyncSession = Depends(get_db)):
    """Получить все анкеты пользователя"""
    result = await db.execute(
        select(TicketForm).filter(TicketForm.user_id == user_id)
    )
    forms = result.scalars().all()
    return forms

@app.get("/form-data/{user_id}/latest", response_model=FormDataResponse)
async def get_latest_form(user_id: int, db: AsyncSession = Depends(get_db)):
    """Получить последнюю анкету пользователя"""
    result = await db.execute(
        select(TicketForm)
        .filter(TicketForm.user_id == user_id)
        .order_by(TicketForm.created_at.desc())
        .limit(1)
    )
    form = result.scalar_one_or_none()
    if not form:
        raise HTTPException(status_code=404, detail="Анкета не найдена")
    return form

@app.put("/form-data/{form_id}", response_model=FormDataResponse)
async def update_form_data(form_id: int, form_update: FormDataUpdate, db: AsyncSession = Depends(get_db)):
    """Обновить данные анкеты"""
    # Получаем существующую запись
    result = await db.execute(
        select(TicketForm).filter(TicketForm.id == form_id)
    )
    db_form = result.scalar_one_or_none()
    if not db_form:
        raise HTTPException(status_code=404, detail="Анкета не найдена")
    
    # Обновляем поля
    if form_update.form_data is not None:
        db_form.form_data = form_update.form_data
    if form_update.status is not None:
        db_form.status = form_update.status
    if form_update.notes is not None:
        db_form.notes = form_update.notes
    
    await db.commit()
    await db.refresh(db_form)
    return db_form

@app.delete("/form-data/{form_id}")
async def delete_form_data(form_id: int, db: AsyncSession = Depends(get_db)):
    """Удалить анкету"""
    # Проверяем существование записи
    result = await db.execute(
        select(TicketForm).filter(TicketForm.id == form_id)
    )
    db_form = result.scalar_one_or_none()
    if not db_form:
        raise HTTPException(status_code=404, detail="Анкета не найдена")
    
    await db.execute(
        delete(TicketForm).filter(TicketForm.id == form_id)
    )
    await db.commit()
    return {"message": "Анкета удалена"}

@app.get("/form-data/", response_model=List[FormDataResponse])
async def get_all_forms(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    """Получить все анкеты (для админов)"""
    result = await db.execute(
        select(TicketForm).offset(skip).limit(limit)
    )
    forms = result.scalars().all()
    return forms
