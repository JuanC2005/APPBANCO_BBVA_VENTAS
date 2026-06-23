from fastapi import APIRouter, Depends, HTTPException

from app.core.dependencies import get_current_user
from app.repositories.solicitud_repository import SolicitudRepository

router = APIRouter(prefix="/sync", tags=["sync"])


@router.get("/pendientes")
async def listar_sync_pendientes(user: dict = Depends(get_current_user)):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador"):
        raise HTTPException(status_code=403, detail="Acceso denegado")
    repo = SolicitudRepository()
    return await repo.listar_sync_pendientes()


@router.post("/promover")
async def promover_sincronizacion(user: dict = Depends(get_current_user)):
    perfil = user.get("perfil", "")
    if perfil not in ("supervisor", "administrador"):
        raise HTTPException(status_code=403, detail="Acceso denegado")
    repo = SolicitudRepository()
    result = await repo.promover_sync()
    return {
        "mensaje": "Sincronización completada",
        "procesados": result["procesados"],
        "errores": result["errores"],
    }
