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

    async def _fetch_solicitudes(self, asesor_id: str) -> list[dict]:
        """Fetch solicitudes from 3 sources and merge into unified rows."""
        # 1. cartera_diaria — visitas diarias del asesor
        cartera_resp = await supabase_execute(
            supabase.table("cartera_diaria")
            .select("*, clientes(*)")
            .eq("asesor_id", asesor_id)
            .order("score_prioridad")
        )

        # 2. solicitudes asignadas a este asesor (no en cartera)
        sol_asignadas_resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*, clientes(*)")
            .eq("asesor_id", asesor_id)
            .not_.in_("estado", ["borrador", "rechazado", "desembolsado"])
            .order("created_at", desc=True)
        )

        # 3. solicitudes pendientes (sin asesor, canal=cliente, estado=enviado)
        sol_pendientes_resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*, clientes(*)")
            .is_("asesor_id", "null")
            .eq("canal", "cliente")
            .eq("estado", "enviado")
            .order("created_at", desc=True)
        )

        cliente_ids_in_cartera = {r["cliente_id"] for r in cartera_resp.data}

        rows = []
        for c in cartera_resp.data:
            rows.append(self._cartera_to_row(c, "visita"))
        for s in sol_asignadas_resp.data:
            if s["cliente_id"] not in cliente_ids_in_cartera:
                rows.append(self._solicitud_to_row(s, "solicitud_asignada"))
        for s in sol_pendientes_resp.data:
            cid = s["cliente_id"]
            if cid not in cliente_ids_in_cartera and cid not in {r["cliente_id"] for r in sol_asignadas_resp.data}:
                rows.append(self._solicitud_to_row(s, "solicitud_pendiente"))

        rows.sort(key=lambda r: r.get("score_prioridad", 0) or 0, reverse=True)
        return rows

    def _cartera_to_row(self, c: dict, tipo_origen: str) -> dict:
        cl = c.get("clientes") or {}
        return {
            "id": c["id"],
            "solicitud_id": None,
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
            "tipo_origen": tipo_origen,
        }

    def _solicitud_to_row(self, s: dict, tipo_origen: str) -> dict:
        cl = s.get("clientes") or {}
        return {
            "id": s["id"],
            "solicitud_id": s["id"],
            "asesor_id": s.get("asesor_id"),
            "cliente_id": s["cliente_id"],
            "cliente_nombre": f"{cl.get('nombres', '')} {cl.get('apellidos', '')}",
            "numero_documento": cl.get("numero_documento", ""),
            "calificacion_sbs": cl.get("calificacion_sbs", ""),
            "score_crediticio": 0,
            "lat": cl.get("lat"),
            "lng": cl.get("lng"),
            "tipo_gestion": "NUEVA_SOLICITUD",
            "prioridad": "alta",
            "monto_referencial": float(s["monto_solicitado"]) if s.get("monto_solicitado") else None,
            "estado_visita": "pendiente",
            "resultado_visita": None,
            "lat_visita": s.get("lat_captura"),
            "lng_visita": s.get("lng_captura"),
            "fecha_asignacion": str(s.get("created_at", ""))[:10],
            "tipo_origen": tipo_origen,
        }

    async def obtener_cartera_completa(self, asesor_id: str, tipo_gestion: str | None = None) -> list[dict]:
        if tipo_gestion == "NUEVA_SOLICITUD":
            rows = await self._fetch_solicitudes(asesor_id)
            rows = [r for r in rows if r["tipo_origen"] != "visita" or r.get("tipo_gestion") == "NUEVA_SOLICITUD"]
        else:
            rows = await self._fetch_solicitudes(asesor_id)

        for r in rows:
            print(f"[DEBUG cartera] row: id={r['id'][:8]}.. tipo_origen={r['tipo_origen']} cliente={r['cliente_nombre']}")
        print(f"[DEBUG cartera] TOTAL filas para asesor {asesor_id[:8]} (tipo={tipo_gestion}): {len(rows)}")
        return rows
