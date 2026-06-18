from datetime import datetime, timezone

from app.core.database import supabase, supabase_execute
from app.schemas.campana import CampanaCreate, CampanaResponse


class CampanaRepository:
    async def obtener_activas(self, asesor_id: str) -> list[CampanaResponse]:
        response = await supabase_execute(
            supabase.table("campanas")
            .select("*, campanas_asesores!inner(*)")
            .eq("campanas_asesores.asesor_id", asesor_id)
            .eq("activa", True)
            .order("created_at", desc=True)
        )
        return [CampanaResponse.model_validate(c) for c in response.data]

    async def obtener_todas(self) -> list[CampanaResponse]:
        response = await supabase_execute(
            supabase.table("campanas").select("*").order("created_at", desc=True)
        )
        return [CampanaResponse.model_validate(c) for c in response.data]

    async def crear(self, req: CampanaCreate, creado_por: str) -> CampanaResponse:
        resp = await supabase_execute(
            supabase.table("campanas").insert({
                "titulo": req.titulo,
                "descripcion": req.descripcion,
                "tipo": req.tipo,
                "producto_objetivo": req.producto_objetivo,
                "monto_min": req.monto_min,
                "monto_max": req.monto_max,
                "creado_por": creado_por,
            })
        )
        return CampanaResponse.model_validate(resp.data[0])

    async def marcar_leida(self, campana_id: str, asesor_id: str) -> bool:
        existing = await supabase_execute(
            supabase.table("campanas_asesores")
            .select("*")
            .eq("campana_id", campana_id)
            .eq("asesor_id", asesor_id)
        )
        if existing.data:
            await supabase_execute(
                supabase.table("campanas_asesores")
                .update({"leida": True, "leida_at": datetime.now(timezone.utc).isoformat()})
                .eq("campana_id", campana_id)
                .eq("asesor_id", asesor_id)
            )
        else:
            await supabase_execute(
                supabase.table("campanas_asesores").insert({
                    "campana_id": campana_id,
                    "asesor_id": asesor_id,
                    "leida": True,
                })
            )
        return True

    async def toggle_activa(self, campana_id: str, activa: bool) -> bool:
        resp = await supabase_execute(
            supabase.table("campanas")
            .update({"activa": activa, "updated_at": datetime.now(timezone.utc).isoformat()})
            .eq("id", campana_id)
        )
        return len(resp.data) > 0
