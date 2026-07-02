import asyncio
import hashlib
import uuid

from app.core.database import supabase, supabase_execute
from app.core.security import create_access_token
from app.schemas.homebanking import (
    ClienteAppLoginRequest,
    ClienteAppPerfilResponse,
    CuentaAhorroResponse,
    MovimientoResponse,
    CreditoClienteResponse,
    CuotaCronogramaResponse,
    TarjetaResponse,
    NotificacionClienteResponse,
)


class HomebankingRepository:
    async def login(self, req: ClienteAppLoginRequest) -> dict | None:
        response = await supabase_execute(
            supabase.table("clientes")
            .select("*")
            .eq("numero_documento", req.numero_documento)
        )
        if not response.data:
            return None

        cliente = response.data[0]

        app_user_resp = await supabase_execute(
            supabase.table("clientes_app")
            .select("*")
            .eq("cliente_id", cliente["id"])
        )

        password_hash = hashlib.sha256(req.password.encode()).hexdigest()

        if app_user_resp.data:
            app_user = app_user_resp.data[0]
            if app_user.get("password_hash") != password_hash:
                return None
            if not app_user.get("activo", True):
                return None
            clientes_app_id = app_user["id"]
        else:
            clientes_app_id = str(uuid.uuid4())
            new_user = {
                "id": clientes_app_id,
                "cliente_id": cliente["id"],
                "password_hash": password_hash,
                "activo": True,
            }
            insert_resp = await supabase_execute(
                supabase.table("clientes_app").insert(new_user)
            )
            if not insert_resp.data:
                return None

        await supabase_execute(
            supabase.table("clientes_app")
            .update({"ultimo_acceso": "now()"})
            .eq("id", clientes_app_id)
        )

        token = create_access_token({
            "sub": clientes_app_id,
            "cliente_id": cliente["id"],
            "tipo": "cliente",
            "numero_documento": cliente["numero_documento"],
        })

        return {
            "access_token": token,
            "token_type": "bearer",
            "cliente": cliente,
        }

    async def registrar_cliente(self, req) -> dict | None:
        existe = await supabase_execute(
            supabase.table("clientes")
            .select("id")
            .eq("numero_documento", req.numero_documento)
        )
        if existe.data:
            return None

        cliente_id = str(uuid.uuid4())
        cliente_data = {
            "id": cliente_id,
            "numero_documento": req.numero_documento,
            "tipo_documento": req.tipo_documento,
            "nombres": req.nombres,
            "apellidos": req.apellidos,
            "telefono": req.telefono,
            "email": req.email,
        }
        resp = await supabase_execute(
            supabase.table("clientes").insert(cliente_data)
        )
        if not resp.data:
            return None

        password_hash = hashlib.sha256(req.password.encode()).hexdigest()
        clientes_app_id = str(uuid.uuid4())
        app_user_data = {
            "id": clientes_app_id,
            "cliente_id": cliente_id,
            "password_hash": password_hash,
            "activo": True,
        }
        resp_app = await supabase_execute(
            supabase.table("clientes_app").insert(app_user_data)
        )
        if not resp_app.data:
            return None

        import random
        n1 = random.randint(1000, 9999)
        n2 = random.randint(1000, 9999)
        n3 = random.randint(1000, 9999)
        numero_cuenta = f"0011-{n1}-{n2}-{n3}"
        cuenta_data = {
            "cliente_id": cliente_id,
            "numero_cuenta": numero_cuenta,
            "tipo_cuenta": "ahorros",
            "moneda": "PEN",
            "saldo_actual": 0,
            "estado": "activa",
        }
        resp_cuenta = await supabase_execute(
            supabase.table("cr_cuentas_ahorro").insert(cuenta_data)
        )
        if not resp_cuenta.data:
            return None

        token = create_access_token({
            "sub": clientes_app_id,
            "cliente_id": cliente_id,
            "tipo": "cliente",
            "numero_documento": req.numero_documento,
        })

        return {
            "access_token": token,
            "token_type": "bearer",
            "cliente": resp.data[0],
            "cuenta": resp_cuenta.data[0],
        }

    async def get_profile(self, clientes_app_id: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("clientes_app")
            .select("*, cliente:clientes(*)")
            .eq("id", clientes_app_id)
        )
        if not response.data:
            return None
        data = response.data[0]
        data.pop("password_hash", None)
        return data.get("cliente", data)

    async def get_cuentas(self, cliente_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .select("*")
            .eq("cliente_id", cliente_id)
            .eq("estado", "activa")
            .order("fecha_apertura", desc=True)
        )
        return response.data or []

    async def get_movimientos(self, cuenta_id: str, cliente_id: str, limite: int = 20) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cr_movimientos")
            .select("*")
            .eq("cuenta_id", cuenta_id)
            .eq("cliente_id", cliente_id)
            .order("fecha_operacion", desc=True)
            .limit(limite)
        )
        return response.data or []

    async def get_creditos(self, cliente_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("creditos")
            .select("*")
            .eq("cliente_id", cliente_id)
            .in_("estado", ["vigente", "vencido"])
            .order("fecha_desembolso", desc=True)
        )
        return response.data or []

    async def get_cronograma(self, credito_id: str, cliente_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cr_cronograma_cuotas")
            .select("*")
            .eq("credito_id", credito_id)
            .eq("cliente_id", cliente_id)
            .order("nro_cuota")
        )
        return response.data or []

    async def get_tarjetas(self, cliente_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cr_tarjetas")
            .select("*")
            .eq("cliente_id", cliente_id)
            .in_("estado", ["activa", "bloqueada"])
            .order("fecha_vencimiento", desc=True)
        )
        return response.data or []

    async def get_notificaciones(self, cliente_id: str, limite: int = 20) -> list[dict]:
        response = await supabase_execute(
            supabase.table("cr_notificaciones_cliente")
            .select("*")
            .eq("cliente_id", cliente_id)
            .order("created_at", desc=True)
            .limit(limite)
        )
        return response.data or []

    async def marcar_notificacion_leida(self, notificacion_id: str, cliente_id: str) -> bool:
        response = await supabase_execute(
            supabase.table("cr_notificaciones_cliente")
            .update({"leida": True})
            .eq("id", notificacion_id)
            .eq("cliente_id", cliente_id)
        )
        return bool(response.data)

    async def marcar_todas_notificaciones_leidas(self, cliente_id: str) -> bool:
        response = await supabase_execute(
            supabase.table("cr_notificaciones_cliente")
            .update({"leida": True})
            .eq("cliente_id", cliente_id)
            .eq("leida", False)
        )
        return True

    async def realizar_transferencia(
        self, cuenta_origen_id: str, cliente_id: str,
        cuenta_destino: str, monto: float, descripcion: str = ""
    ) -> dict | None:
        cuenta_resp = await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .select("*")
            .eq("id", cuenta_origen_id)
            .eq("cliente_id", cliente_id)
        )
        if not cuenta_resp.data:
            return None

        cuenta = cuenta_resp.data[0]
        if cuenta["saldo_actual"] < monto:
            return None

        nuevo_saldo = cuenta["saldo_actual"] - monto

        await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .update({"saldo_actual": nuevo_saldo})
            .eq("id", cuenta_origen_id)
        )

        mov_data = {
            "cuenta_id": cuenta_origen_id,
            "cliente_id": cliente_id,
            "tipo_movimiento": "transferencia",
            "monto": monto,
            "moneda": cuenta["moneda"],
            "saldo_anterior": cuenta["saldo_actual"],
            "saldo_posterior": nuevo_saldo,
            "descripcion": descripcion or f"Transferencia a {cuenta_destino}",
            "referencia": cuenta_destino,
            "fecha_operacion": "CURRENT_DATE",
        }
        await supabase_execute(
            supabase.table("cr_movimientos").insert(mov_data)
        )

        return {
            "mensaje": "Transferencia realizada con éxito",
            "nuevo_saldo": nuevo_saldo,
        }

    async def pagar_cuota(
        self, credito_id: str, cliente_id: str,
        monto: float, cuenta_origen_id: str
    ) -> dict | None:
        cuenta_resp = await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .select("*")
            .eq("id", cuenta_origen_id)
            .eq("cliente_id", cliente_id)
        )
        if not cuenta_resp.data:
            return {"error": "Cuenta no encontrada"}
        if cuenta_resp.data[0]["saldo_actual"] < monto:
            return {"error": "Saldo insuficiente"}

        cuota_resp = await supabase_execute(
            supabase.table("cr_cronograma_cuotas")
            .select("*")
            .eq("credito_id", credito_id)
            .eq("cliente_id", cliente_id)
            .eq("estado", "pendiente")
            .order("nro_cuota")
            .limit(1)
        )
        if not cuota_resp.data:
            return {"error": "No hay cuotas pendientes"}

        cuota = cuota_resp.data[0]
        cuenta = cuenta_resp.data[0]
        nuevo_saldo = cuenta["saldo_actual"] - monto

        await supabase_execute(
            supabase.table("cr_cuentas_ahorro")
            .update({"saldo_actual": nuevo_saldo})
            .eq("id", cuenta_origen_id)
        )

        await supabase_execute(
            supabase.table("cr_cronograma_cuotas")
            .update({
                "estado": "pagada",
                "fecha_pago": "CURRENT_DATE",
            })
            .eq("id", cuota["id"])
        )

        mov_data = {
            "cuenta_id": cuenta_origen_id,
            "cliente_id": cliente_id,
            "tipo_movimiento": "pago",
            "monto": monto,
            "moneda": cuenta["moneda"],
            "saldo_anterior": cuenta["saldo_actual"],
            "saldo_posterior": nuevo_saldo,
            "descripcion": f"Pago cuota N°{cuota['nro_cuota']} - Crédito {credito_id[:8]}",
            "fecha_operacion": "CURRENT_DATE",
        }
        await supabase_execute(
            supabase.table("cr_movimientos").insert(mov_data)
        )

        return {
            "mensaje": f"Cuota N°{cuota['nro_cuota']} pagada con éxito",
            "nuevo_saldo": nuevo_saldo,
        }

    async def get_todas_cuentas_con_movimientos(self, cliente_id: str) -> list[dict]:
        cuentas = await self.get_cuentas(cliente_id)
        result = []
        for c in cuentas:
            movs = await self.get_movimientos(c["id"], cliente_id, limite=5)
            result.append({
                "cuenta": c,
                "ultimos_movimientos": movs,
            })
        return result

    # ── Solicitud desde App Clientes ────────────────────

    async def crear_solicitud_cliente(self, cliente_id: str, monto: float, plazo: int,
                                       tea: float, cuota_estimada: float,
                                       destino: str, garantia: str, con_seguro: bool,
                                       numero_expediente: str,
                                       lat_captura: float | None = None,
                                       lng_captura: float | None = None) -> dict | None:
        solicitud_id = str(uuid.uuid4())
        data = {
            "id": solicitud_id,
            "numero_expediente": numero_expediente,
            "cliente_id": cliente_id,
            "asesor_id": None,
            "tipo_negocio": None,
            "nombre_negocio": None,
            "monto_solicitado": monto,
            "plazo_meses": plazo,
            "moneda": "PEN",
            "tipo_cuota": "mensual",
            "garantia": garantia,
            "destino_credito": destino,
            "cuota_estimada": cuota_estimada,
            "tea_referencial": tea,
            "canal": "cliente",
            "con_seguro": con_seguro,
            "estado": "enviado",
            "pendiente_sync": False,
            "lat_captura": lat_captura,
            "lng_captura": lng_captura,
        }
        resp = await supabase_execute(
            supabase.table("solicitudes_credito").insert(data)
        )
        if not resp.data:
            return None
        return resp.data[0]

    async def listar_solicitudes_cliente(self, cliente_id: str) -> list[dict]:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*")
            .eq("cliente_id", cliente_id)
            .eq("canal", "cliente")
            .order("created_at", desc=True)
        )
        return response.data or []

    async def actualizar_ubicacion_solicitud(self, solicitud_id: str, cliente_id: str,
                                               lat: float, lng: float) -> bool:
        resp = await supabase_execute(
            supabase.table("solicitudes_credito")
            .update({"lat_captura": lat, "lng_captura": lng, "updated_at": "now()"})
            .eq("id", solicitud_id)
            .eq("cliente_id", cliente_id)
        )
        return len(resp.data) > 0

    async def obtener_solicitud_cliente(self, solicitud_id: str, cliente_id: str) -> dict | None:
        response = await supabase_execute(
            supabase.table("solicitudes_credito")
            .select("*")
            .eq("id", solicitud_id)
            .eq("cliente_id", cliente_id)
        )
        return response.data[0] if response.data else None
