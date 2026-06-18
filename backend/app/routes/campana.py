from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.repositories.campana_repository import CampanaRepository
from app.schemas.campana import CampanaCreate, CampanaResponse

router = APIRouter(prefix="/campanas", tags=["campanas"])


@router.get("/", response_model=list[CampanaResponse])
async def listar_campanas(
    user: dict = Depends(get_current_user),
):
    repo = CampanaRepository()
    return await repo.obtener_activas(user["id"])


@router.get("/todas", response_model=list[CampanaResponse])
async def listar_todas(
    user: dict = Depends(get_current_user),
):
    repo = CampanaRepository()
    return await repo.obtener_todas()


@router.post("/", response_model=CampanaResponse)
async def crear_campana(
    req: CampanaCreate,
    user: dict = Depends(get_current_user),
):
    repo = CampanaRepository()
    return await repo.crear(req, user["id"])


@router.post("/{campana_id}/leer")
async def marcar_leida(
    campana_id: str,
    user: dict = Depends(get_current_user),
):
    repo = CampanaRepository()
    await repo.marcar_leida(campana_id, user["id"])
    return {"mensaje": "Campaña marcada como leída"}


@router.put("/{campana_id}/toggle")
async def toggle_campana(
    campana_id: str,
    activa: bool,
    user: dict = Depends(get_current_user),
):
    repo = CampanaRepository()
    ok = await repo.toggle_activa(campana_id, activa)
    return {"activa": activa}
