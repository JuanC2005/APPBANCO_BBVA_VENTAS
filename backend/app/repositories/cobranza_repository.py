from datetime import datetime, timezone

from app.core.database import supabase, supabase_execute
from app.schemas.cobranza import ClienteMoraResponse, AccionCobranzaCreate, AccionCobranzaResponse


class CobranzaRepository:
    async def listar_mora(self, asesor_id: str) -> list[ClienteMoraResponse]:
        response = await supabase_execute(
            supabase.table("creditos")
            .select("*, clientes(*)")
            .eq("asesor_id", asesor_id)
            .in_("estado", ["vencido", "castigado"])
            .order("fecha_vencimiento")
        )
        rows = []
        hoy = datetime.now(timezone.utc).date()
        for credito in response.data:
            cl = credito.get("clientes") or {}
            venc_str = credito.get("fecha_vencimiento")
            venc = datetime.fromisoformat(venc_str).date() if venc_str else None
            dias_mora = (hoy - venc).days if venc else 0
            rows.append(ClienteMoraResponse(
                cliente_id=credito["cliente_id"],
                cliente_nombre=f"{cl.get('nombres', '')} {cl.get('apellidos', '')}",
                numero_documento=cl.get("numero_documento", ""),
                credito_id=credito["id"],
                deuda=float(credito.get("saldo_actual", 0)),
                dias_mora=max(dias_mora, 0),
                direccion=cl.get("direccion", ""),
                lat=float(cl["lat"]) if cl.get("lat") else None,
                lng=float(cl["lng"]) if cl.get("lng") else None,
            ))
        return rows

    async def registrar_accion(self, asesor_id: str, req: AccionCobranzaCreate) -> bool:
        resp = await supabase_execute(
            supabase.table("acciones_cobranza").insert({
                "asesor_id": asesor_id,
                "cliente_id": req.cliente_id,
                "credito_id": req.credito_id,
                "tipo_gestion": req.tipo_gestion,
                "resultado": req.resultado,
                "monto_pagado": req.monto_pagado,
                "monto_comprometido": req.monto_comprometido,
                "fecha_compromiso": req.fecha_compromiso.isoformat() if req.fecha_compromiso else None,
                "observaciones": req.observaciones,
                "lat": req.lat,
                "lng": req.lng,
            })
        )
        return len(resp.data) > 0

    async def historial_acciones(self, cliente_id: str) -> list[AccionCobranzaResponse]:
        response = await supabase_execute(
            supabase.table("acciones_cobranza")
            .select("*")
            .eq("cliente_id", cliente_id)
            .order("created_at", desc=True)
            .limit(10)
        )
        return [AccionCobranzaResponse.model_validate(a) for a in response.data]
