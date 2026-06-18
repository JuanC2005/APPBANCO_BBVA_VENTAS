from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional


class ClienteResponse(BaseModel):
    id: str
    numero_documento: str
    tipo_documento: str
    nombres: str
    apellidos: str
    fecha_nacimiento: date | None
    estado_civil: str | None
    genero: str | None
    telefono: str | None
    email: str | None
    direccion: str | None
    tipo_negocio: str | None
    nombre_negocio: str | None
    antiguedad_negocio_meses: int
    ingresos_estimados: float
    gastos_mensuales: float
    deuda_actual: float
    entidades_deuda: int
    lat: float | None
    lng: float | None
    calificacion_sbs: str
    estado_cliente: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CreditoResponse(BaseModel):
    id: str
    cliente_id: str
    asesor_id: str | None
    producto: str
    monto_desembolsado: float
    plazo_meses: int
    saldo_actual: float
    estado: str
    fecha_desembolso: date | None
    fecha_vencimiento: date | None
    created_at: datetime

    class Config:
        from_attributes = True


class ScoreResponse(BaseModel):
    score: float
    segmento: str
    recomendacion: str
    monto_max_sugerido: float
    nivel_confianza: int
    calculado_at: datetime

    class Config:
        from_attributes = True


class PreaprobadoResponse(BaseModel):
    id: str
    monto_maximo: float
    plazo_sugerido_meses: int
    tea_referencial: float
    score_confianza: int
    vigente: bool

    class Config:
        from_attributes = True


class MovimientoMensualResponse(BaseModel):
    periodo: str
    total_creditos: float
    total_debitos: float
    saldo_promedio: float
    num_transacciones: int

    class Config:
        from_attributes = True


class PerfilClienteResponse(BaseModel):
    tipo_negocio: str | None
    antiguedad_negocio: int | None
    local_propio: bool | None
    zona_negocio: str | None
    ingreso_mensual_est: float
    gasto_mensual_est: float
    patrimonio_estimado: float
    puntaje_crediticio: float

    class Config:
        from_attributes = True


class ClienteDetailResponse(BaseModel):
    cliente: ClienteResponse
    creditos: list[CreditoResponse]
    score: ScoreResponse | None
    preaprobado: PreaprobadoResponse | None
    movimientos: list[MovimientoMensualResponse]
    perfil: PerfilClienteResponse | None
