from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.database import get_supabase, supabase_execute
from app.core.security import decode_access_token

security_scheme = HTTPBearer()


async def get_current_cliente(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
):
    payload = decode_access_token(credentials.credentials)
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido o expirado")

    cliente_id: str | None = payload.get("sub")
    if cliente_id is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token malformado")

    supabase = get_supabase()
    response = await supabase_execute(
        supabase.table("clientes_app").select("*, cliente:clientes(*)").eq("id", cliente_id)
    )
    if not response.data:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Cliente no encontrado")

    user = response.data[0]
    user.pop("password_hash", None)
    return user
