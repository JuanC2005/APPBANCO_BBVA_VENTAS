from datetime import datetime, timezone

from app.core.database import supabase, supabase_execute
from app.schemas.cartera import CarteraVisitaResponse, VisitaUpdateRequest, FichaCampoCreate


class CarteraRepository:
    async def obtener_cartera(self, asesor_id: str) -> list[CarteraVisitaResponse]:
        response = await supabase_execute(
            supabase.table("cartera_diaria")
            .select("*")
            .eq("asesor_id", asesor_id)
            .order("score_prioridad")
        )
        return [CarteraVisitaResponse.model_validate(v) for v in response.data]

    async def registrar_visita(self, visita_id: str, req: VisitaUpdateRequest) -> bool:
        resp = await supabase_execute(
            supabase.table("cartera_diaria")
            .update({
                "estado_visita": "visitado",
                "resultado_visita": req.resultado_visita,
                "observacion_visita": req.observacion_visita,
                "lat_visita": req.lat_visita,
                "lng_visita": req.lng_visita,
                "timestamp_visita": datetime.now(timezone.utc).isoformat(),
            })
            .eq("id", visita_id)
        )
        return len(resp.data) > 0

    async def crear_ficha_campo(self, asesor_id: str, req: FichaCampoCreate) -> str | None:
        resp = await supabase_execute(
            supabase.table("fichas_campo").insert({
                "asesor_id": asesor_id,
                "cliente_id": req.cliente_id,
                "tipo_visita": req.tipo_visita,
                "latitud": req.latitud,
                "longitud": req.longitud,
                "distrito": req.distrito,
                "resultado": req.resultado,
                "observaciones": req.observaciones,
            })
        )
        if resp.data:
            return resp.data[0]["id"]
        return None

    async def obtener_cartera_completa(self, asesor_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cartera_diaria")
            .select("*, clientes(*)")
            .eq("asesor_id", asesor_id)
            .order("score_prioridad")
        )
        rows = []
        for c in response.data:
            cl = c.get("clientes") or {}
            rows.append({
                "id": c["id"],
                "asesor_id": c["asesor_id"],
                "cliente_id": c["cliente_id"],
                "cliente_nombre": f"{cl.get('nombres', '')} {cl.get('apellidos', '')}",
                "numero_documento": cl.get("numero_documento", ""),
                "calificacion_sbs": cl.get("calificacion_sbs", ""),
                "score_crediticio": 0,
                "lat": cl.get("lat"),
                "lng": cl.get("lng"),
                "tipo_gestion": c.get("tipo_gestion", ""),
                "prioridad": c.get("prioridad", 0),
                "monto_referencial": float(c["monto_referencial"]) if c.get("monto_referencial") else None,
                "estado_visita": c.get("estado_visita", ""),
                "resultado_visita": c.get("resultado_visita", ""),
                "lat_visita": c.get("lat_visita"),
                "lng_visita": c.get("lng_visita"),
                "fecha_asignacion": str(c.get("fecha_asignacion", "")),
            })
        return rows
