from fastapi import APIRouter, Depends

from app.core.database import supabase, supabase_execute

router = APIRouter(prefix="/agencias", tags=["agencias"])


@router.get("/")
async def listar_agencias():
    response = await supabase_execute(
        supabase.table("agencias").select("id, codigo, nombre").eq("activa", True).order("nombre")
    )
    return response.data
