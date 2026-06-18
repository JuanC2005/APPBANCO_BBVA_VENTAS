from fastapi import APIRouter, Depends, HTTPException

from app.core.dependencies import get_current_user
from app.repositories.cliente_repository import ClienteRepository
from app.schemas.cliente import ClienteResponse, ClienteDetailResponse

router = APIRouter(prefix="/clientes", tags=["clientes"])


@router.get("/{cliente_id}", response_model=ClienteDetailResponse)
async def obtener_cliente(
    cliente_id: str,
    user: dict = Depends(get_current_user),
):
    repo = ClienteRepository()
    detalle = await repo.obtener_detalle(cliente_id)
    if not detalle:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    return detalle


@router.get("/buscar/{numero_documento}", response_model=ClienteResponse)
async def buscar_cliente(
    numero_documento: str,
    user: dict = Depends(get_current_user),
):
    repo = ClienteRepository()
    cliente = await repo.buscar_por_documento(numero_documento)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    return ClienteResponse.model_validate(cliente)
