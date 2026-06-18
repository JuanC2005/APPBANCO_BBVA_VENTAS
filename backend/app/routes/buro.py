from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user
from app.repositories.buro_repository import BuroRepository
from app.schemas.buro import BuroConsultaRequest, BuroConsultaResponse, BuroHistorialResponse

router = APIRouter(prefix="/buro", tags=["buro"])


@router.post("/consultar", response_model=BuroConsultaResponse)
async def consultar_buro(
    req: BuroConsultaRequest,
    user: dict = Depends(get_current_user),
):
    repo = BuroRepository()
    return await repo.consultar(user["id"], req)


@router.get("/historial/{cliente_id}", response_model=list[BuroHistorialResponse])
async def historial_buro(
    cliente_id: str,
    user: dict = Depends(get_current_user),
):
    repo = BuroRepository()
    return await repo.historial(cliente_id)
