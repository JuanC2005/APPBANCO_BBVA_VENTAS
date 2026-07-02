import asyncio

from app.core.database import supabase, supabase_auth, supabase_execute
from app.core.security import create_access_token
from app.schemas.auth import LoginRequest, RegisterRequest


class AuthRepository:
    async def login(self, req: LoginRequest) -> dict | None:
        try:
            auth_response = await asyncio.to_thread(
                supabase_auth.auth.sign_in_with_password,
                {"email": req.email, "password": req.password},
            )
        except Exception:
            return None

        if not auth_response.user:
            return None

        response = await supabase_execute(
            supabase.table("asesores_negocio").select("*").eq("user_id", auth_response.user.id)
        )
        if not response.data:
            return None

        asesor = response.data[0]
        token = create_access_token({
            "sub": asesor["id"],
            "email": asesor["email"],
            "perfil": asesor.get("perfil", "asesor"),
        })

        return {
            "access_token": token,
            "token_type": "bearer",
            "asesor": asesor,
        }

    async def register(self, req: RegisterRequest) -> str | None:
        agencia_resp = await supabase_execute(
            supabase.table("agencias").select("id").eq("id", req.agencia_id).eq("activa", True)
        )
        if not agencia_resp.data:
            return None

        try:
            auth_response = await asyncio.to_thread(
                supabase_auth.auth.admin.create_user,
                {
                    "email": req.email,
                    "password": req.password,
                    "email_confirm": True,
                },
            )
        except Exception:
            return None

        if not auth_response.user:
            return None

        import uuid
        codigo = f"FV{uuid.uuid4().hex[:8].upper()}"
        asesor_data = {
            "user_id": auth_response.user.id,
            "codigo_empleado": codigo,
            "email": req.email,
            "nombres": req.nombres,
            "apellidos": req.apellidos,
            "telefono": req.telefono or "",
            "agencia_id": req.agencia_id,
            "perfil": "operador",
            "especialidad": "microempresa",
            "activo": True,
        }
        resp = await supabase_execute(
            supabase.table("asesores_negocio").insert(asesor_data)
        )
        if not resp.data:
            try:
                await asyncio.to_thread(supabase_auth.auth.admin.delete_user, auth_response.user.id)
            except Exception:
                pass
            return None
        return codigo

    async def get_profile(self, asesor_id: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("asesores_negocio").select("*").eq("id", asesor_id)
        )
        return response.data[0] if response.data else None

    async def get_asesor_by_codigo(self, codigo: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("asesores_negocio").select("*").eq("codigo_empleado", codigo)
        )
        return response.data[0] if response.data else None
