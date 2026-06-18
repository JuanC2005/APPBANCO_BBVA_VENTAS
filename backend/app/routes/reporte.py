from fastapi import APIRouter, Depends

from app.core.database import supabase, supabase_execute
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/reportes", tags=["reportes"])


@router.get("/productividad")
async def reporte_productividad(
    user: dict = Depends(get_current_user),
):
    response = await supabase_execute(
        supabase.table("solicitudes_credito")
        .select("id", count="exact")
        .eq("asesor_id", user["id"])
    )
    total_solicitudes = response.count if hasattr(response, "count") else len(response.data)
    return {
        "visitas_mes_actual": user.get("visitas_mes_actual", 0),
        "creditos_mes_actual": user.get("creditos_mes_actual", 0),
        "monto_mes_actual": float(user.get("monto_mes_actual", 0)),
        "total_solicitudes": total_solicitudes,
    }


@router.get("/supervisor/monitor")
async def monitor_supervisor(
    user: dict = Depends(get_current_user),
):
    response = await supabase_execute(
        supabase.table("asesores_negocio")
        .select("id, codigo_empleado, nombres, apellidos, visitas_mes_actual, creditos_mes_actual, monto_mes_actual")
        .eq("agencia_id", user["agencia_id"])
        .eq("activo", True)
    )
    rows = []
    for r in response.data:
        rows.append({
            "id": r["id"],
            "codigo_empleado": r.get("codigo_empleado", ""),
            "nombres": r.get("nombres", ""),
            "apellidos": r.get("apellidos", ""),
            "visitas_mes_actual": r.get("visitas_mes_actual") or 0,
            "creditos_mes_actual": r.get("creditos_mes_actual") or 0,
            "monto_mes_actual": float(r.get("monto_mes_actual") or 0),
        })
    return rows
