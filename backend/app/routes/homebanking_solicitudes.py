import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status

from app.core.dependencies import get_current_cliente
from app.repositories.homebanking_repository import HomebankingRepository
from app.repositories.solicitud_repository import SolicitudRepository
from app.schemas.solicitud_homebanking import SolicitudClienteCreate, SolicitudClienteResponse, UbicacionSolicitudUpdate

router = APIRouter(prefix="/homebanking", tags=["homebanking"])


@router.put("/solicitudes/{solicitud_id}/ubicacion")
async def actualizar_ubicacion(
    solicitud_id: str,
    req: UbicacionSolicitudUpdate,
    user: dict = Depends(get_current_cliente),
):
    cliente_id = user.get("cliente_id") or user.get("sub")
    repo = HomebankingRepository()
    ok = await repo.actualizar_ubicacion_solicitud(solicitud_id, cliente_id, req.lat_captura, req.lng_captura)
    if not ok:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return {"mensaje": "Ubicación actualizada", "lat_captura": req.lat_captura, "lng_captura": req.lng_captura}


@router.post("/solicitudes", response_model=SolicitudClienteResponse)
async def crear_solicitud_cliente(
    req: SolicitudClienteCreate,
    user: dict = Depends(get_current_cliente),
):
    cliente_id = user.get("cliente_id") or user.get("sub")
    repo = HomebankingRepository()
    sol_repo = SolicitudRepository()

    # Validar monto
    if req.monto_solicitado <= 0:
        raise HTTPException(status_code=400, detail="El monto debe ser mayor a 0")
    if req.plazo_meses < 3 or req.plazo_meses > 48:
        raise HTTPException(status_code=400, detail="El plazo debe estar entre 3 y 48 meses")

    # Calcular TEA según tarifario
    tea = 40.92 if req.con_seguro else 43.92

    # Calcular cuota estimada (fórmula francesa)
    tem = (1 + tea / 100) ** (1 / 12) - 1
    if tem == 0:
        cuota_estimada = req.monto_solicitado / req.plazo_meses
    else:
        cuota_estimada = req.monto_solicitado * tem / (1 - (1 + tem) ** (-req.plazo_meses))

    # Generar número de expediente
    expediente = f"EXP-{uuid.uuid4().hex[:8].upper()}"

    result = await repo.crear_solicitud_cliente(
        cliente_id=cliente_id,
        monto=req.monto_solicitado,
        plazo=req.plazo_meses,
        tea=tea,
        cuota_estimada=round(cuota_estimada, 2),
        destino=req.destino_credito,
        garantia=req.garantia,
        con_seguro=req.con_seguro,
        numero_expediente=expediente,
        lat_captura=req.lat_captura,
        lng_captura=req.lng_captura,
    )

    if not result:
        raise HTTPException(status_code=500, detail="Error al crear la solicitud")

    # Insertar en sync_outbox
    await sol_repo.insertar_sync_outbox(
        solicitud_id=result["id"],
        tabla_destino="bd_core_financiero",
        accion="INSERT",
        payload={
            "numero_expediente": expediente,
            "cliente_id": cliente_id,
            "monto_solicitado": req.monto_solicitado,
            "plazo_meses": req.plazo_meses,
            "tea": tea,
            "estado": "enviado",
            "canal": "cliente",
        },
    )

    return SolicitudClienteResponse(
        id=result["id"],
        numero_expediente=expediente,
        cliente_id=cliente_id,
        asesor_id=None,
        monto_solicitado=req.monto_solicitado,
        plazo_meses=req.plazo_meses,
        tea_referencial=tea,
        cuota_estimada=round(cuota_estimada, 2),
        garantia=req.garantia,
        destino_credito=req.destino_credito,
        con_seguro=req.con_seguro,
        canal="cliente",
        estado="enviado",
        monto_aprobado=None,
        motivo_rechazo=None,
        condicion_adicional=None,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )


@router.get("/solicitudes", response_model=list[SolicitudClienteResponse])
async def listar_solicitudes_cliente(
    user: dict = Depends(get_current_cliente),
):
    cliente_id = user.get("cliente_id") or user.get("sub")
    repo = HomebankingRepository()
    results = await repo.listar_solicitudes_cliente(cliente_id)
    return [
        SolicitudClienteResponse(
            id=r["id"],
            numero_expediente=r.get("numero_expediente"),
            cliente_id=r["cliente_id"],
            asesor_id=r.get("asesor_id"),
            monto_solicitado=float(r["monto_solicitado"]),
            plazo_meses=r["plazo_meses"],
            tea_referencial=float(r.get("tea_referencial", 0)),
            cuota_estimada=float(r.get("cuota_estimada", 0)),
            garantia=r.get("garantia", ""),
            destino_credito=r.get("destino_credito"),
            con_seguro=r.get("con_seguro", False),
            canal=r.get("canal", "cliente"),
            estado=r["estado"],
            monto_aprobado=float(r["monto_aprobado"]) if r.get("monto_aprobado") else None,
            motivo_rechazo=r.get("motivo_rechazo"),
            condicion_adicional=r.get("condicion_adicional"),
            created_at=r["created_at"],
            updated_at=r["updated_at"],
        )
        for r in results
    ]


@router.get("/solicitudes/{solicitud_id}", response_model=SolicitudClienteResponse)
async def obtener_solicitud_cliente(
    solicitud_id: str,
    user: dict = Depends(get_current_cliente),
):
    cliente_id = user.get("cliente_id") or user.get("sub")
    repo = HomebankingRepository()
    r = await repo.obtener_solicitud_cliente(solicitud_id, cliente_id)
    if not r:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")

    return SolicitudClienteResponse(
        id=r["id"],
        numero_expediente=r.get("numero_expediente"),
        cliente_id=r["cliente_id"],
        asesor_id=r.get("asesor_id"),
        monto_solicitado=float(r["monto_solicitado"]),
        plazo_meses=r["plazo_meses"],
        tea_referencial=float(r.get("tea_referencial", 0)),
        cuota_estimada=float(r.get("cuota_estimada", 0)),
        garantia=r.get("garantia", ""),
        destino_credito=r.get("destino_credito"),
        con_seguro=r.get("con_seguro", False),
        canal=r.get("canal", "cliente"),
        estado=r["estado"],
        monto_aprobado=float(r["monto_aprobado"]) if r.get("monto_aprobado") else None,
        motivo_rechazo=r.get("motivo_rechazo"),
        condicion_adicional=r.get("condicion_adicional"),
        created_at=r["created_at"],
        updated_at=r["updated_at"],
    )
