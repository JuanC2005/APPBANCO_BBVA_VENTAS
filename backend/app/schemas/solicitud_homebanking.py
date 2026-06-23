from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class SolicitudClienteCreate(BaseModel):
    monto_solicitado: float
    plazo_meses: int = 12
    destino_credito: str = ""
    garantia: str = "sin_garantia"
    con_seguro: bool = False


class SolicitudClienteResponse(BaseModel):
    id: str
    numero_expediente: str | None
    cliente_id: str
    asesor_id: str | None
    monto_solicitado: float
    plazo_meses: int
    tea_referencial: float
    cuota_estimada: float
    garantia: str
    destino_credito: str | None
    con_seguro: bool
    canal: str
    estado: str
    monto_aprobado: float | None
    motivo_rechazo: str | None
    condicion_adicional: str | None
    created_at: datetime
    updated_at: datetime


class DecidirRequest(BaseModel):
    decision: str
    monto_aprobado: float | None = None
    motivo_rechazo: str | None = None
    condicion_adicional: str | None = None
