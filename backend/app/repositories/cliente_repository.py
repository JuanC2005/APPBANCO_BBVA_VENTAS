from app.core.database import supabase, supabase_execute
from app.schemas.cliente import (
    ClienteResponse, CreditoResponse, ScoreResponse,
    PreaprobadoResponse, MovimientoMensualResponse,
    PerfilClienteResponse, ClienteDetailResponse,
)


class ClienteRepository:
    async def obtener_cliente(self, cliente_id: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("clientes").select("*").eq("id", cliente_id)
        )
        return response.data[0] if response.data else None

    async def obtener_detalle(self, cliente_id: str) -> ClienteDetailResponse | None:
        cl = await self.obtener_cliente(cliente_id)
        if not cl:
            return None

        creditos_resp = await supabase_execute(
            supabase.table("creditos")
            .select("*")
            .eq("cliente_id", cliente_id)
            .order("fecha_desembolso", desc=True)
        )
        creditos = [CreditoResponse.model_validate(c) for c in creditos_resp.data]

        score_resp = await supabase_execute(
            supabase.table("scores_crediticios").select("*").eq("cliente_id", cliente_id)
        )
        score = ScoreResponse.model_validate(score_resp.data[0]) if score_resp.data else None

        preap_resp = await supabase_execute(
            supabase.table("creditos_preaprobados")
            .select("*")
            .eq("cliente_id", cliente_id)
            .eq("vigente", True)
            .order("monto_maximo", desc=True)
            .limit(1)
        )
        preaprobado = PreaprobadoResponse.model_validate(preap_resp.data[0]) if preap_resp.data else None

        mov_resp = await supabase_execute(
            supabase.table("movimientos_mensuales")
            .select("*")
            .eq("cliente_id", cliente_id)
            .order("periodo")
        )
        movimientos = [MovimientoMensualResponse.model_validate(m) for m in mov_resp.data]

        perfil_resp = await supabase_execute(
            supabase.table("perfiles_clientes").select("*").eq("cliente_id", cliente_id)
        )
        perfil = PerfilClienteResponse.model_validate(perfil_resp.data[0]) if perfil_resp.data else None

        return ClienteDetailResponse(
            cliente=ClienteResponse.model_validate(cl),
            creditos=creditos,
            score=score,
            preaprobado=preaprobado,
            movimientos=movimientos,
            perfil=perfil,
        )

    async def buscar_por_documento(self, numero_documento: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("clientes").select("*").eq("numero_documento", numero_documento)
        )
        return response.data[0] if response.data else None
