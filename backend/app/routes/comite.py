from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status

from app.core.dependencies import get_current_user
from app.repositories.solicitud_repository import SolicitudRepository
from app.schemas.solicitud_homebanking import DecidirRequest

router = APIRouter(prefix="/comite", tags=["comite"])


@router.get("/pendientes")
async def listar_pendientes_comite(user: dict = Depends(get_current_user)):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador", "super_operador"):
        raise HTTPException(status_code=403, detail="Solo supervisores y administradores pueden acceder al comité")
    repo = SolicitudRepository()
    return await repo.listar_para_comite()


@router.get("/{solicitud_id}")
async def obtener_detalle_comite(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador", "super_operador"):
        raise HTTPException(status_code=403, detail="Acceso denegado")
    repo = SolicitudRepository()
    solicitud = await repo.obtener(solicitud_id)
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return solicitud


@router.put("/{solicitud_id}/evaluar")
async def evaluar_solicitud(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador", "super_operador"):
        raise HTTPException(status_code=403, detail="Acceso denegado")
    repo = SolicitudRepository()
    ok = await repo.actualizar_estado(solicitud_id, "en_evaluacion")
    if not ok:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")

    await repo.insertar_sync_outbox(
        solicitud_id=solicitud_id,
        tabla_destino="bd_core_financiero",
        accion="UPDATE",
        payload={"estado": "en_evaluacion"},
    )
    return {"mensaje": "Solicitud en evaluación"}


@router.put("/{solicitud_id}/decidir")
async def decidir_solicitud(
    solicitud_id: str,
    req: DecidirRequest,
    user: dict = Depends(get_current_user),
):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador", "super_operador"):
        raise HTTPException(status_code=403, detail="Acceso denegado")

    if req.decision not in ("aprobado", "condicionado", "rechazado"):
        raise HTTPException(status_code=400, detail="Decisión inválida. Use: aprobado, condicionado, rechazado")

    repo = SolicitudRepository()
    solicitud = await repo.obtener(solicitud_id)
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")

    # ── Idempotency guard: si ya fue desembolsado, retornar sin duplicar ──
    if solicitud.estado == "desembolsado":
        return {"mensaje": "Solicitud ya fue desembolsada previamente"}

    update_data = {"estado": req.decision, "updated_at": datetime.now(timezone.utc).isoformat()}

    if req.decision == "rechazado":
        if not req.motivo_rechazo:
            raise HTTPException(status_code=400, detail="Debe proporcionar un motivo de rechazo")
        update_data["motivo_rechazo"] = req.motivo_rechazo
    elif req.decision in ("aprobado", "condicionado"):
        monto = req.monto_aprobado or solicitud.monto_solicitado
        update_data["monto_aprobado"] = monto
        if req.decision == "condicionado":
            update_data["condicion_adicional"] = req.condicion_adicional or ""

    await repo.actualizar_datos(solicitud_id, update_data)

    # Si es aprobado o condicionado ⇒ desembolsar automáticamente
    if req.decision in ("aprobado", "condicionado"):
        monto_final = req.monto_aprobado or solicitud.monto_solicitado
        resultado = await repo.desembolsar(solicitud_id, monto_final)
        if not resultado:
            raise HTTPException(status_code=500, detail="Error al procesar el desembolso")

        await repo.insertar_sync_outbox(
            solicitud_id=solicitud_id,
            tabla_destino="bd_core_financiero",
            accion="UPDATE",
            payload={
                "estado": "desembolsado",
                "monto_desembolsado": monto_final,
            },
        )

        return {
            "mensaje": f"Solicitud {req.decision} y desembolsada",
            "credito_id": resultado["credito_id"],
            "cuotas_generadas": resultado["cuotas_generadas"],
        }

    # Si es rechazado
    await repo.insertar_sync_outbox(
        solicitud_id=solicitud_id,
        tabla_destino="bd_core_financiero",
        accion="UPDATE",
        payload={"estado": "rechazado", "motivo": req.motivo_rechazo},
    )

    return {"mensaje": f"Solicitud {req.decision}"}
