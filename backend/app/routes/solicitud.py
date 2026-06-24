from fastapi import APIRouter, Depends, HTTPException, UploadFile, File

from app.core.dependencies import get_current_user
from app.repositories.solicitud_repository import SolicitudRepository
from app.schemas.solicitud import SolicitudCreate, SolicitudResponse, SolicitudDetailResponse

router = APIRouter(prefix="/solicitudes", tags=["solicitudes"])


@router.post("/", response_model=SolicitudResponse)
async def crear_solicitud(
    req: SolicitudCreate,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    return await repo.crear(user["id"], req)


@router.get("/", response_model=list[SolicitudResponse])
async def listar_solicitudes(
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    return await repo.listar_por_asesor(user["id"])


@router.get("/pendientes")
async def listar_pendientes(user: dict = Depends(get_current_user)):
    repo = SolicitudRepository()
    return await repo.listar_pendientes_sin_asesor()


@router.get("/{solicitud_id}", response_model=SolicitudDetailResponse)
async def obtener_solicitud(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    solicitud = await repo.obtener(solicitud_id)
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return solicitud


@router.post("/{solicitud_id}/enviar")
async def enviar_solicitud(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    ok = await repo.enviar(solicitud_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return {"mensaje": "Solicitud enviada"}


@router.put("/{solicitud_id}/estado")
async def actualizar_estado(
    solicitud_id: str,
    estado: str,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    ok = await repo.actualizar_estado(solicitud_id, estado)
    if not ok:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return {"mensaje": f"Estado actualizado a {estado}"}


@router.post("/{solicitud_id}/documentos")
async def subir_documento(
    solicitud_id: str,
    tipo_documento: str,
    archivo: UploadFile = File(...),
    user: dict = Depends(get_current_user),
):
    content = await archivo.read()
    import os, uuid
    upload_dir = f"uploads/{solicitud_id}"
    os.makedirs(upload_dir, exist_ok=True)
    ext = os.path.splitext(archivo.filename or ".jpg")[1]
    filename = f"{tipo_documento}_{uuid.uuid4().hex}{ext}"
    filepath = f"{upload_dir}/{filename}"
    with open(filepath, "wb") as f:
        f.write(content)
    url = f"/static/{solicitud_id}/{filename}"

    repo = SolicitudRepository()
    ok = await repo.subir_documento(solicitud_id, tipo_documento, url)
    if not ok:
        raise HTTPException(status_code=500, detail="Error al subir documento")
    return {"url": url, "mensaje": "Documento subido"}


@router.get("/{solicitud_id}/documentos")
async def listar_documentos(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    return await repo.listar_documentos(solicitud_id)


@router.put("/{solicitud_id}/tomar")
async def tomar_solicitud(
    solicitud_id: str,
    user: dict = Depends(get_current_user),
):
    repo = SolicitudRepository()
    result = await repo.tomar_solicitud(solicitud_id, user["id"])
    if not result:
        raise HTTPException(status_code=400, detail="No se pudo tomar la solicitud. Puede que ya tenga un asesor asignado.")
    return result
