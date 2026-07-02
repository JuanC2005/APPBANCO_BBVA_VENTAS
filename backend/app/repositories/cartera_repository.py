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

    async def obtener_cartera_completa(self, asesor_id: str, tipo_gestion: str | None = None) -> list[dict]:
        query = (
            supabase.table("cartera_diaria")
            .select("*, clientes(*)")
            .eq("asesor_id", asesor_id)
        )
        if tipo_gestion:
            query = query.eq("tipo_gestion", tipo_gestion)
        response = await supabase_execute(query.order("score_prioridad"))

        solicitud_estados: dict[str, str | None] = {}
        if tipo_gestion == "NUEVA_SOLICITUD":
            cliente_ids = [c["cliente_id"] for c in response.data]
            for cid in cliente_ids:
                sol_resp = await supabase_execute(
                    supabase.table("solicitudes_credito")
                    .select("estado")
                    .eq("cliente_id", cid)
                    .eq("canal", "cliente")
                    .order("created_at", desc=True)
                    .limit(1)
                )
                solicitud_estados[cid] = sol_resp.data[0]["estado"] if sol_resp.data else None

        rows = []
        for c in response.data:
            cl = c.get("clientes") or {}
            cid = c["cliente_id"]
            if tipo_gestion == "NUEVA_SOLICITUD":
                estado = solicitud_estados.get(cid)
                if estado is None or estado != "enviado":
                    continue

            row = {
                "id": c["id"],
                "asesor_id": c["asesor_id"],
                "cliente_id": cid,
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
            }
            print(f"[DEBUG cartera] row: id={row['id'][:8]}.. tipo={row['tipo_gestion']} lat_visita={row['lat_visita']} lng_visita={row['lng_visita']} lat={row['lat']} lng={row['lng']} resultado={row['resultado_visita']}")
            rows.append(row)
        print(f"[DEBUG cartera] TOTAL filas para asesor {asesor_id[:8]} (tipo={tipo_gestion}): {len(rows)}")
        return rows
