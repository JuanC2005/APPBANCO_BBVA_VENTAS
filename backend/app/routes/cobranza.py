from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.repositories.cobranza_repository import CobranzaRepository
from app.schemas.cobranza import ClienteMoraResponse, AccionCobranzaCreate, AccionCobranzaResponse

router = APIRouter(prefix="/cobranza", tags=["cobranza"])


@router.get("/mora", response_model=list[ClienteMoraResponse])
async def listar_mora(
    user: dict = Depends(get_current_user),
):
    repo = CobranzaRepository()
    return await repo.listar_mora(user["id"])


@router.post("/acciones")
async def registrar_accion(
    req: AccionCobranzaCreate,
    user: dict = Depends(get_current_user),
):
    repo = CobranzaRepository()
    ok = await repo.registrar_accion(user["id"], req)
    return {"mensaje": "Acción registrada"}


@router.get("/acciones/{cliente_id}", response_model=list[AccionCobranzaResponse])
async def historial_acciones(
    cliente_id: str,
    user: dict = Depends(get_current_user),
):
    repo = CobranzaRepository()
    return await repo.historial_acciones(cliente_id)
