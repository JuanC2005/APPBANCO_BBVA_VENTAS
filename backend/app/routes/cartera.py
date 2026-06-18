from fastapi import APIRouter, Depends, HTTPException

from app.core.dependencies import get_current_user
from app.repositories.cartera_repository import CarteraRepository
from app.schemas.cartera import CarteraVisitaResponse, VisitaUpdateRequest, FichaCampoCreate

router = APIRouter(prefix="/cartera", tags=["cartera"])


@router.get("/", response_model=list[CarteraVisitaResponse])
async def listar_cartera(user: dict = Depends(get_current_user)):
    repo = CarteraRepository()
    return await repo.obtener_cartera(user["id"])


@router.get("/completa")
async def listar_cartera_completa(user: dict = Depends(get_current_user)):
    repo = CarteraRepository()
    return await repo.obtener_cartera_completa(user["id"])


@router.put("/{visita_id}/visita")
async def registrar_visita(
    visita_id: str,
    req: VisitaUpdateRequest,
    user: dict = Depends(get_current_user),
):
    repo = CarteraRepository()
    ok = await repo.registrar_visita(visita_id, req)
    if not ok:
        raise HTTPException(status_code=404, detail="Visita no encontrada")
    return {"mensaje": "Visita registrada"}


@router.post("/ficha-campo")
async def crear_ficha_campo(
    req: FichaCampoCreate,
    user: dict = Depends(get_current_user),
):
    repo = CarteraRepository()
    ficha_id = await repo.crear_ficha_campo(user["id"], req)
    return {"id": ficha_id, "mensaje": "Ficha de campo creada"}
