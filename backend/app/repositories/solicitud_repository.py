from datetime import datetime, timezone

from app.core.database import supabase, supabase_execute
from app.schemas.solicitud import SolicitudCreate, SolicitudResponse, SolicitudDetailResponse


class SolicitudRepository:
    async def crear(self, asesor_id: str, req: SolicitudCreate) -> SolicitudResponse:
        resp = await supabase_execute(
            supabase.table("solicitudes_credito").insert({
                "asesor_id": asesor_id,
                "cliente_id": req.cliente_id,
                "agencia_id": req.agencia_id,
                "cartera_id": req.cartera_id,
                "tipo_negocio": req.tipo_negocio,
                "nombre_negocio": req.nombre_negocio,
                "actividad_economica": req.actividad_economica,
                "antiguedad_negocio_meses": req.antiguedad_negocio_meses,
                "tiene_conyuge": req.tiene_conyuge,
                "conyuge_json": req.conyuge_json,
                "tiene_garante": req.tiene_garante,
                "garante_json": req.garante_json,
                "ingresos_estimados": req.ingresos_estimados,
                "gastos_mensuales": req.gastos_mensuales,
                "patrimonio_estimado": req.patrimonio_estimado,
                "destino_credito": req.destino_credito,
                "monto_solicitado": req.monto_solicitado,
                "plazo_meses": req.plazo_meses,
                "moneda": req.moneda,
                "tipo_cuota": req.tipo_cuota,
                "garantia": req.garantia,
                "cuota_estimada": req.cuota_estimada,
                "tea_referencial": req.tea_referencial,
                "firma_cliente_base64": req.firma_cliente_base64,
                "lat_captura": req.lat_captura,
                "lng_captura": req.lng_captura,
                "estado": "borrador",
            })
        )
        return SolicitudResponse.model_validate(resp.data[0])

    async def listar_por_asesor(self, asesor_id: str) -> list[SolicitudResponse]:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*")
            .eq("asesor_id", asesor_id)
            .order("created_at", desc=True)
        )
        return [SolicitudResponse.model_validate(s) for s in response.data]

    async def listar_por_estado(self, asesor_id: str, estados: list[str]) -> list[SolicitudResponse]:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*")
            .eq("asesor_id", asesor_id)
            .in_("estado", estados)
            .order("created_at", desc=True)
        )
        return [SolicitudResponse.model_validate(s) for s in response.data]

    async def obtener(self, solicitud_id: str) -> SolicitudDetailResponse | None:
        response = await supabase_execute(
            supabase.table("solicitudes_credito").select("*").eq("id", solicitud_id)
        )
        if not response.data:
            return None
        return SolicitudDetailResponse.model_validate(response.data[0])

    async def enviar(self, solicitud_id: str) -> bool:
        resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({
                "estado": "enviado",
                "pendiente_sync": False,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            })
            .eq("id", solicitud_id)
        )
        return len(resp.data) > 0

    async def actualizar_estado(self, solicitud_id: str, estado: str) -> bool:
        resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({
                "estado": estado,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            })
            .eq("id", solicitud_id)
        )
        return len(resp.data) > 0

    async def subir_documento(self, solicitud_id: str, tipo_documento: str, url: str) -> bool:
        resp = await supabase_execute(
            supabase.table("solicitudes_documentos").insert({
                "solicitud_id": solicitud_id,
                "tipo_documento": tipo_documento,
                "url_documento": url,
                "estado": "LISTO",
            })
        )
        return len(resp.data) > 0

    async def listar_documentos(self, solicitud_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("solicitudes_documentos")
            .select("id, tipo_documento, url_documento, estado")
            .eq("solicitud_id", solicitud_id)
        )
        return response.data
