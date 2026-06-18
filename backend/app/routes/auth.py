from fastapi import APIRouter, Depends, HTTPException, status

from app.core.dependencies import get_current_user
from app.repositories.auth_repository import AuthRepository
from app.schemas.auth import LoginRequest, RegisterRequest

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
async def login(req: LoginRequest):
    repo = AuthRepository()
    result = await repo.login(req)
    if result is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Email o contraseña incorrectos")
    return result


@router.post("/register")
async def register(req: RegisterRequest):
    repo = AuthRepository()
    codigo = await repo.register(req)
    if codigo is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No se pudo registrar. Verifique que el email no exista y la agencia sea válida.")
    return {"codigo_empleado": codigo, "mensaje": "Registro exitoso"}


@router.get("/me")
async def get_me(user: dict = Depends(get_current_user)):
    return user
