from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class SolicitudCreate(BaseModel):
    cliente_id: str
    agencia_id: str | None = None
    cartera_id: str | None = None
    tipo_negocio: str | None = None
    nombre_negocio: str | None = None
    actividad_economica: str | None = None
    antiguedad_negocio_meses: int = 0
    tiene_conyuge: bool = False
    conyuge_json: dict | None = None
    tiene_garante: bool = False
    garante_json: dict | None = None
    ingresos_estimados: float = 0
    gastos_mensuales: float = 0
    patrimonio_estimado: float = 0
    destino_credito: str | None = None
    monto_solicitado: float
    plazo_meses: int = 12
    moneda: str = "PEN"
    tipo_cuota: str = "mensual"
    garantia: str = "sin_garantia"
    cuota_estimada: float = 0
    tea_referencial: float = 15.0
    firma_cliente_base64: str | None = None
    lat_captura: float | None = None
    lng_captura: float | None = None


class SolicitudResponse(BaseModel):
    id: str
    numero_expediente: str | None
    asesor_id: str | None
    cliente_id: str
    estado: str
    monto_solicitado: float
    plazo_meses: int
    moneda: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class SolicitudDetailResponse(SolicitudResponse):
    tipo_negocio: str | None
    nombre_negocio: str | None
    ingresos_estimados: float
    gastos_mensuales: float
    destino_credito: str | None
    monto_aprobado: float | None
    motivo_rechazo: str | None

    class Config:
        from_attributes = True
