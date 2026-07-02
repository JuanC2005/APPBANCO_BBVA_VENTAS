import uuid
from datetime import datetime, timezone, date, timedelta

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
        current = await self.obtener(solicitud_id)
        if not current:
            return False
        if current.estado in ("recibido_comite", "en_evaluacion", "aprobado", "condicionado", "rechazado", "desembolsado"):
            return False
        nuevo_estado = "recibido_comite"
        resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({
                "estado": nuevo_estado,
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

    # ── Cliente-originated methods ──────────────────────

    async def listar_pendientes_sin_asesor(self) -> list[dict]:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*, clientes!left(*)")
            .is_("asesor_id", "null")
            .eq("canal", "cliente")
            .eq("estado", "enviado")
            .order("created_at", desc=True)
        )
        rows = []
        for r in response.data:
            cl = r.pop("clientes", {}) or {}
            r["cliente_nombre"] = f"{cl.get('nombres', '')} {cl.get('apellidos', '')}"
            r["numero_documento"] = cl.get("numero_documento", "")
            rows.append(r)
        return rows

    async def tomar_solicitud(self, solicitud_id: str, asesor_id: str) -> dict | None:
        solicitud_resp = await supabase_execute(
            supabase.table("solicitudes_credito").select("*").eq("id", solicitud_id)
        )
        if not solicitud_resp.data:
            return None

        solicitud = solicitud_resp.data[0]
        if solicitud.get("asesor_id") is not None:
            return None

        now = datetime.now(timezone.utc)
        await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({
                "asesor_id": asesor_id,
                "updated_at": now.isoformat(),
            })
            .eq("id", solicitud_id)
        )

        # Crear entrada en cartera_diaria
        agencia_resp = await supabase_execute(
            supabase.table("asesores_negocio")
            .select("agencia_id")
            .eq("id", asesor_id)
        )
        agencia_id = agencia_resp.data[0]["agencia_id"] if agencia_resp.data else None

        cartera_entry = {
            "asesor_id": asesor_id,
            "cliente_id": solicitud["cliente_id"],
            "agencia_id": agencia_id,
            "fecha_asignacion": now.date().isoformat(),
            "tipo_gestion": "NUEVA_SOLICITUD",
            "prioridad": "alta",
            "monto_referencial": solicitud["monto_solicitado"],
            "estado_visita": "pendiente",
            "lat_visita": solicitud.get("lat_captura"),
            "lng_visita": solicitud.get("lng_captura"),
        }
        await supabase_execute(supabase.table("cartera_diaria").insert(cartera_entry))

        return {"mensaje": "Solicitud asignada correctamente", "asesor_id": asesor_id}

    # ── Comité methods ──────────────────────────────────

    async def listar_para_comite(self) -> list[dict]:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*, clientes!inner(nombres, apellidos, numero_documento)")
            .in_("estado", ["recibido_comite", "en_evaluacion"])
            .order("updated_at", desc=True)
        )
        rows = []
        for r in response.data:
            cl = r.get("clientes") or {}
            rows.append({
                "id": r["id"],
                "numero_expediente": r.get("numero_expediente"),
                "cliente_nombre": f"{cl.get('nombres', '')} {cl.get('apellidos', '')}",
                "numero_documento": cl.get("numero_documento", ""),
                "monto_solicitado": float(r["monto_solicitado"]),
                "plazo_meses": r["plazo_meses"],
                "monto_aprobado": float(r["monto_aprobado"]) if r.get("monto_aprobado") else None,
                "estado": r["estado"],
                "canal": r.get("canal", "asesor"),
                "created_at": str(r.get("created_at", "")),
                "updated_at": str(r.get("updated_at", "")),
            })
        return rows

    async def actualizar_datos(self, solicitud_id: str, data: dict) -> bool:
        resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .update(data)
            .eq("id", solicitud_id)
        )
        return len(resp.data) > 0

    async def desembolsar(self, solicitud_id: str, monto_aprobado: float) -> dict | None:
        solicitud_resp = await supabase_execute(
            supabase.table("solicitudes_credito").select("*").eq("id", solicitud_id)
        )
        if not solicitud_resp.data:
            return None
        sol = solicitud_resp.data[0]

        # ── Idempotency guard: si ya está desembolsado, retornar crédito existente ──
        if sol.get("estado") == "desembolsado":
            existente = await supabase_execute(
                supabase.table("creditos").select("*").eq("solicitud_id", solicitud_id).limit(1)
            )
            if existente.data:
                ref = existente.data[0]
                cuotas_resp = await supabase_execute(
                    supabase.table("cr_cronograma_cuotas").select("nro_cuota").eq("credito_id", ref["id"])
                )
                return {
                    "credito_id": ref["id"],
                    "cuotas_generadas": len(cuotas_resp.data) if cuotas_resp.data else 0,
                }

        # ── Verificar si ya existe crédito vinculado a esta solicitud ──
        existente = await supabase_execute(
            supabase.table("creditos").select("*").eq("solicitud_id", solicitud_id).limit(1)
        )
        if existente.data:
            ref = existente.data[0]
            cuotas_resp = await supabase_execute(
                supabase.table("cr_cronograma_cuotas").select("nro_cuota").eq("credito_id", ref["id"])
            )
            return {
                "credito_id": ref["id"],
                "cuotas_generadas": len(cuotas_resp.data) if cuotas_resp.data else 0,
            }

        cliente_id = sol["cliente_id"]
        asesor_id = sol.get("asesor_id")
        plazo = sol["plazo_meses"]
        tea = float(sol.get("tea_referencial", 40.92))
        garantia = sol.get("garantia", "sin_garantia")

        hoy = date.today()

        # Crear crédito
        credito_id = str(uuid.uuid4())
        producto = "credito_negocios"
        if sol.get("garantia") == "vehicular":
            producto = "credito_negocios"

        credito_data = {
            "id": credito_id,
            "solicitud_id": solicitud_id,
            "cliente_id": cliente_id,
            "asesor_id": asesor_id,
            "producto": producto,
            "monto_desembolsado": monto_aprobado,
            "plazo_meses": plazo,
            "tea": tea,
            "cuotas_totales": plazo,
            "cuotas_pagadas": 0,
            "cuotas_mora": 0,
            "saldo_actual": monto_aprobado,
            "fecha_desembolso": hoy.isoformat(),
            "fecha_vencimiento": date(hoy.year + (hoy.month + plazo - 1) // 12, (hoy.month + plazo - 1) % 12 + 1, min(hoy.day, 28)).isoformat(),
            "estado": "vigente",
        }
        await supabase_execute(supabase.table("creditos").insert(credito_data))

        # Generar cronograma (fórmula francesa)
        tem = (1 + tea / 100) ** (1 / 12) - 1
        cuota_mensual = monto_aprobado * tem / (1 - (1 + tem) ** (-plazo)) if tem > 0 else monto_aprobado / plazo
        dia_pago = min(hoy.day, 28)
        saldo = monto_aprobado
        cuotas_generadas = 0

        for n in range(1, plazo + 1):
            interes = saldo * tem
            capital = cuota_mensual - interes
            if n == plazo:
                capital = saldo
                cuota_mensual = capital + interes
            saldo_nuevo = saldo - capital

            # Fecha de vencimiento: día de pago del mes siguiente
            mes_venc = hoy.month + n
            anio_venc = hoy.year + (mes_venc - 1) // 12
            mes_venc = (mes_venc - 1) % 12 + 1
            try:
                fecha_venc = date(anio_venc, mes_venc, dia_pago)
            except ValueError:
                fecha_venc = date(anio_venc, mes_venc, 1)

            cuota_data = {
                "id": str(uuid.uuid4()),
                "credito_id": credito_id,
                "cliente_id": cliente_id,
                "nro_cuota": n,
                "fecha_vencimiento": fecha_venc.isoformat(),
                "capital": round(capital, 2),
                "interes": round(interes, 2),
                "seguro": 0,
                "cuota_total": round(cuota_mensual, 2),
                "saldo": round(saldo_nuevo, 2),
                "estado": "pendiente",
            }
            await supabase_execute(supabase.table("cr_cronograma_cuotas").insert(cuota_data))
            saldo = saldo_nuevo
            cuotas_generadas += 1

        # Abonar a la primera cuenta de ahorro del cliente
        cuenta_resp = await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .select("*")
            .eq("cliente_id", cliente_id)
            .eq("estado", "activa")
            .limit(1)
        )
        if cuenta_resp.data:
            cuenta = cuenta_resp.data[0]
            nuevo_saldo = float(cuenta["saldo_actual"]) + monto_aprobado
            await supabase_execute(
                supabase.table("cr_cuentas_ahorro")
                .update({"saldo_actual": nuevo_saldo})
                .eq("id", cuenta["id"])
            )
            await supabase_execute(
                supabase.table("cr_movimientos").insert({
                    "cuenta_id": cuenta["id"],
                    "cliente_id": cliente_id,
                    "tipo_movimiento": "deposito",
                    "monto": monto_aprobado,
                    "moneda": "PEN",
                    "saldo_anterior": cuenta["saldo_actual"],
                    "saldo_posterior": nuevo_saldo,
                    "descripcion": f"Desembolso crédito - Exp. {sol.get('numero_expediente', '')}",
                    "fecha_operacion": hoy.isoformat(),
                })
            )

        # Notificación al cliente
        await supabase_execute(
            supabase.table("cr_notificaciones_cliente").insert({
                "id": str(uuid.uuid4()),
                "cliente_id": cliente_id,
                "tipo": "pago",
                "titulo": "¡Crédito desembolsado!",
                "mensaje": f"Su crédito de S/ {monto_aprobado:.2f} ha sido desembolsado. Revise su cronograma de pagos.",
                "leida": False,
                "created_at": datetime.now(timezone.utc).isoformat(),
            })
        )

        # Actualizar solicitud a desembolsado
        await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({
                "estado": "desembolsado",
                "monto_aprobado": monto_aprobado,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            })
            .eq("id", solicitud_id)
        )

        return {
            "credito_id": credito_id,
            "cuotas_generadas": cuotas_generadas,
        }

    # ── Sync methods ────────────────────────────────────

    async def insertar_sync_outbox(self, solicitud_id: str, tabla_destino: str, accion: str, payload: dict) -> bool:
        import json
        resp = await supabase_execute(
            supabase.table("sync_outbox").insert({
                "solicitud_id": solicitud_id,
                "tabla_destino": tabla_destino,
                "accion": accion,
                "payload_json": json.dumps(payload),
                "estado": "pendiente",
            })
        )
        return len(resp.data) > 0

    async def listar_sync_pendientes(self) -> list[dict]:
        response = await supabase_execute(
            supabase.table("sync_outbox")
            .select("*, solicitudes_credito!inner(numero_expediente)")
            .eq("estado", "pendiente")
            .order("created_at")
        )
        rows = []
        for r in response.data:
            sc = r.get("solicitudes_credito") or {}
            rows.append({
                "id": r["id"],
                "solicitud_id": r.get("solicitud_id"),
                "numero_expediente": sc.get("numero_expediente"),
                "tabla_destino": r["tabla_destino"],
                "accion": r["accion"],
                "payload_json": r.get("payload_json"),
                "intentos": r.get("intentos", 0),
                "created_at": str(r.get("created_at", "")),
            })
        return rows

    async def promover_sync(self) -> dict:
        response = await supabase_execute(
            supabase.table("sync_outbox")
            .select("*")
            .eq("estado", "pendiente")
            .order("created_at")
            .limit(50)
        )
        procesados = 0
        errores = 0
        now = datetime.now(timezone.utc).isoformat()

        for item in response.data:
            try:
                await supabase_execute(
                    supabase.table("sync_outbox")
                    .update({
                        "estado": "procesado",
                        "processed_at": now,
                    })
                    .eq("id", item["id"])
                )
                await supabase_execute(
                    supabase.table("sync_log").insert({
                        "sync_outbox_id": item["id"],
                        "estado": "procesado",
                        "mensaje": "Promovido al núcleo financiero (simulado)",
                    })
                )
                procesados += 1
            except Exception as e:
                await supabase_execute(
                    supabase.table("sync_outbox")
                    .update({
                        "estado": "error",
                        "error_msg": str(e),
                        "intentos": (item.get("intentos", 0) or 0) + 1,
                    })
                    .eq("id", item["id"])
                )
                errores += 1

        return {"procesados": procesados, "errores": errores}
