from app.core.database import supabase, supabase_execute
from app.schemas.buro import BuroConsultaRequest, BuroConsultaResponse, BuroHistorialResponse


class BuroRepository:
    async def consultar(self, asesor_id: str, req: BuroConsultaRequest) -> BuroConsultaResponse:
        cliente_resp = await supabase_execute(
            supabase.table("clientes")
            .select("*, scores_crediticios(*)")
            .eq("id", req.cliente_id)
        )
        cliente = cliente_resp.data[0] if cliente_resp.data else {}
        score_data = (cliente.get("scores_crediticios") or [{}])[0] if cliente else {}

        resultado = {
            "score": score_data.get("score", 0),
            "calificacion_sbs": cliente.get("calificacion_sbs", "Sin_Historial"),
            "entidades_con_deuda": cliente.get("entidades_deuda", 0),
            "deuda_total_pen": float(cliente.get("deuda_actual", 0)),
            "mayor_deuda": 0,
            "dias_mayor_mora": 0,
            "en_lista_negra": False,
            "protestos": "Ninguno",
            "recomendacion": "Cliente con buen historial crediticio" if cliente.get("calificacion_sbs") in ("Normal", "CPP") else "Evaluar presencial",
        }

        await supabase_execute(
            supabase.table("consultas_buro").insert({
                "asesor_id": asesor_id,
                "cliente_id": req.cliente_id,
                "dni_consultado": req.dni,
                "calificacion_sbs": resultado["calificacion_sbs"],
                "entidades_con_deuda": resultado["entidades_con_deuda"],
                "deuda_total_pen": resultado["deuda_total_pen"],
                "resultado_json": resultado,
                "firma_consentimiento_base64": req.firma_consentimiento_base64,
            })
        )

        return BuroConsultaResponse(
            calificacion_sbs=resultado["calificacion_sbs"],
            entidades_con_deuda=resultado["entidades_con_deuda"],
            deuda_total_pen=resultado["deuda_total_pen"],
            mayor_deuda=0,
            dias_mayor_mora=0,
            en_lista_negra=False,
            resultado_json=resultado,
        )

    async def historial(self, cliente_id: str) -> list[BuroHistorialResponse]:
        response = await supabase_execute(
            supabase.table("consultas_buro")
            .select("*")
            .eq("cliente_id", cliente_id)
            .order("created_at", desc=True)
            .limit(5)
        )
        return [BuroHistorialResponse.model_validate(c) for c in response.data]
