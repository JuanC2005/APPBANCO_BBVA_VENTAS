from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional


class ClienteAppLoginRequest(BaseModel):
    numero_documento: str
    password: str


class ClienteAppLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    cliente: dict


class RegistroClienteRequest(BaseModel):
    tipo_documento: str = "DNI"
    numero_documento: str
    nombres: str
    apellidos: str
    telefono: str | None = None
    email: str | None = None
    password: str


class ClienteAppPerfilResponse(BaseModel):
    id: str
    numero_documento: str
    tipo_documento: str
    nombres: str
    apellidos: str
    email: str | None
    telefono: str | None
    direccion: str | None
    fecha_nacimiento: date | None
    estado_civil: str | None


class CuentaAhorroResponse(BaseModel):
    id: str
    numero_cuenta: str
    tipo_cuenta: str
    moneda: str
    saldo_actual: float
    estado: str
    fecha_apertura: date


class MovimientoResponse(BaseModel):
    id: str
    tipo_movimiento: str
    monto: float
    moneda: str
    descripcion: str | None
    referencia: str | None
    fecha_operacion: date
    saldo_anterior: float
    saldo_posterior: float


class CreditoClienteResponse(BaseModel):
    id: str
    producto: str
    monto_desembolsado: float
    plazo_meses: int
    tea: float
    saldo_actual: float
    estado: str
    cuotas_totales: int
    cuotas_pagadas: int
    cuotas_mora: int
    fecha_desembolso: date | None
    fecha_vencimiento: date | None


class CuotaCronogramaResponse(BaseModel):
    id: str
    nro_cuota: int
    fecha_vencimiento: date
    capital: float
    interes: float
    seguro: float
    cuota_total: float
    saldo: float
    estado: str
    fecha_pago: date | None


class TarjetaResponse(BaseModel):
    id: str
    numero_tarjeta: str
    tipo_tarjeta: str
    marca: str
    estado: str
    limite_credito: float
    saldo_utilizado: float
    fecha_vencimiento: date


class NotificacionClienteResponse(BaseModel):
    id: str
    tipo: str
    titulo: str
    mensaje: str
    leida: bool
    created_at: datetime


class TransferenciaRequest(BaseModel):
    cuenta_origen_id: str
    cuenta_destino: str
    monto: float
    descripcion: str = ""


class PagoCuotaRequest(BaseModel):
    credito_id: str
    monto: float
    cuenta_origen_id: str
