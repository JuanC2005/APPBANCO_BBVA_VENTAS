from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.database import get_supabase, supabase_execute
from app.core.security import decode_access_token

security_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
):
    payload = decode_access_token(credentials.credentials)
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido o expirado")

    asesor_id: str | None = payload.get("sub")
    if asesor_id is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token malformado")

    supabase = get_supabase()
    response = await supabase_execute(
        supabase.table("asesores_negocio").select("*").eq("id", asesor_id)
    )
    if not response.data:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Asesor no encontrado")

    user = response.data[0]
    user.pop("password_hash", None)
    return user


async def get_current_cliente(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
):
    payload = decode_access_token(credentials.credentials)
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido o expirado")
    if payload.get("tipo") != "cliente":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Se requiere token de cliente")

    clientes_app_id = payload.get("sub")
    cliente_id = payload.get("cliente_id")
    if not clientes_app_id or not cliente_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token malformado")

    supabase = get_supabase()
    response = await supabase_execute(
        supabase.table("clientes_app").select("*, cliente:clientes(*)").eq("id", clientes_app_id)
    )
    if not response.data:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Cliente no encontrado")

    user = response.data[0]
    user.pop("password_hash", None)
    return user


async def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(HTTPBearer(auto_error=False)),
):
    if credentials is None:
        return None
    payload = decode_access_token(credentials.credentials)
    if payload is None:
        return None
    asesor_id: str | None = payload.get("sub")
    if asesor_id is None:
        return None

    supabase = get_supabase()
    response = await supabase_execute(
        supabase.table("asesores_negocio").select("*").eq("id", asesor_id)
    )
    if not response.data:
        return None
    user = response.data[0]
    user.pop("password_hash", None)
    return user
