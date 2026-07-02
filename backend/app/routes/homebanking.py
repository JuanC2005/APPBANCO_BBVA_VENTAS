from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.dependencies_cliente import get_current_cliente
from app.repositories.homebanking_repository import HomebankingRepository
from app.schemas.homebanking import (
    ClienteAppLoginRequest,
    RegistroClienteRequest,
    TransferenciaRequest,
    PagoCuotaRequest,
)

router = APIRouter(prefix="/homebanking", tags=["homebanking"])


@router.post("/registro")
async def registrar_cliente(req: RegistroClienteRequest):
    repo = HomebankingRepository()
    result = await repo.registrar_cliente(req)
    if result is None:
        raise HTTPException(status_code=400, detail="El número de documento ya está registrado")
    return result


@router.post("/login")
async def login_cliente(req: ClienteAppLoginRequest):
    repo = HomebankingRepository()
    result = await repo.login(req)
    if result is None:
        raise HTTPException(status_code=401, detail="Documento o contraseña incorrectos")
    return result


@router.get("/perfil")
async def get_perfil(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    perfil = await repo.get_profile(cliente["id"])
    if not perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")
    return perfil


@router.get("/cuentas")
async def get_cuentas(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    cuentas = await repo.get_cuentas(cliente["cliente_id"])
    return cuentas


@router.get("/cuentas/{cuenta_id}/movimientos")
async def get_movimientos(
    cuenta_id: str,
    limite: int = Query(20, ge=1, le=100),
    cliente: dict = Depends(get_current_cliente),
):
    repo = HomebankingRepository()
    movimientos = await repo.get_movimientos(cuenta_id, cliente["cliente_id"], limite)
    return movimientos


@router.get("/dashboard")
async def get_dashboard(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    cuentas = await repo.get_cuentas(cliente["cliente_id"])
    creditos = await repo.get_creditos(cliente["cliente_id"])
    tarjetas = await repo.get_tarjetas(cliente["cliente_id"])
    notificaciones = await repo.get_notificaciones(cliente["cliente_id"], limite=5)

    saldo_total = sum(c["saldo_actual"] for c in cuentas)

    cuentas_con_movs = []
    for c in cuentas:
        movs = await repo.get_movimientos(c["id"], cliente["cliente_id"], limite=5)
        cuentas_con_movs.append({
            "cuenta": c,
            "ultimos_movimientos": movs,
        })

    return {
        "saldo_total": saldo_total,
        "num_cuentas": len(cuentas),
        "num_creditos": len(creditos),
        "num_tarjetas": len(tarjetas),
        "notificaciones_no_leidas": sum(1 for n in notificaciones if not n["leida"]),
        "cuentas": cuentas_con_movs,
        "creditos": creditos,
        "tarjetas_recientes": tarjetas[:3],
        "notificaciones_recientes": notificaciones[:3],
    }


@router.get("/creditos")
async def get_creditos(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    creditos = await repo.get_creditos(cliente["cliente_id"])
    return creditos


@router.get("/creditos/{credito_id}/cronograma")
async def get_cronograma(
    credito_id: str,
    cliente: dict = Depends(get_current_cliente),
):
    repo = HomebankingRepository()
    cronograma = await repo.get_cronograma(credito_id, cliente["cliente_id"])
    if not cronograma:
        raise HTTPException(status_code=404, detail="Cronograma no encontrado")
    return cronograma


@router.get("/tarjetas")
async def get_tarjetas(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    tarjetas = await repo.get_tarjetas(cliente["cliente_id"])
    return tarjetas


@router.post("/transferencias")
async def realizar_transferencia(
    req: TransferenciaRequest,
    cliente: dict = Depends(get_current_cliente),
):
    repo = HomebankingRepository()
    result = await repo.realizar_transferencia(
        cuenta_origen_id=req.cuenta_origen_id,
        cliente_id=cliente["cliente_id"],
        cuenta_destino=req.cuenta_destino,
        monto=req.monto,
        descripcion=req.descripcion,
    )
    if result is None:
        raise HTTPException(status_code=400, detail="Transferencia no pudo ser completada. Verifique saldo y cuenta origen.")
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result


@router.post("/pagos")
async def pagar_cuota(
    req: PagoCuotaRequest,
    cliente: dict = Depends(get_current_cliente),
):
    repo = HomebankingRepository()
    result = await repo.pagar_cuota(
        credito_id=req.credito_id,
        cliente_id=cliente["cliente_id"],
        monto=req.monto,
        cuenta_origen_id=req.cuenta_origen_id,
    )
    if result is None:
        raise HTTPException(status_code=400, detail="Pago no pudo ser completado")
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result


@router.get("/notificaciones")
async def get_notificaciones(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    notificaciones = await repo.get_notificaciones(cliente["cliente_id"])
    return notificaciones


@router.put("/notificaciones/{notificacion_id}/leer")
async def marcar_notificacion_leida(
    notificacion_id: str,
    cliente: dict = Depends(get_current_cliente),
):
    repo = HomebankingRepository()
    ok = await repo.marcar_notificacion_leida(notificacion_id, cliente["cliente_id"])
    if not ok:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    return {"mensaje": "Notificación marcada como leída"}


@router.put("/notificaciones/leer-todas")
async def marcar_todas_leidas(cliente: dict = Depends(get_current_cliente)):
    repo = HomebankingRepository()
    await repo.marcar_todas_notificaciones_leidas(cliente["cliente_id"])
    return {"mensaje": "Todas las notificaciones marcadas como leídas"}
