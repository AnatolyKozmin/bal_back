from pydantic import BaseModel
from typing import Dict, Any, Optional
from datetime import datetime

class FormDataRequest(BaseModel):
    user_id: int
    form_data: Dict[str, Any]
    status: Optional[str] = "draft"

class FormDataResponse(BaseModel):
    id: int
    user_id: int
    form_data: Dict[str, Any]
    status: str
    created_at: datetime
    updated_at: datetime
    notes: Optional[str] = None

class FormDataUpdate(BaseModel):
    form_data: Optional[Dict[str, Any]] = None
    status: Optional[str] = None
    notes: Optional[str] = None

class TelegramWebhook(BaseModel):
    update_id: int
    message: Optional[Dict[str, Any]] = None
    callback_query: Optional[Dict[str, Any]] = None
