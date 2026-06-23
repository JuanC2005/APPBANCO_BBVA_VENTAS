from fastapi import APIRouter
from app.routes.auth import router as auth_router
from app.routes.agencia import router as agencia_router
from app.routes.cartera import router as cartera_router
from app.routes.cliente import router as cliente_router
from app.routes.solicitud import router as solicitud_router
from app.routes.buro import router as buro_router
from app.routes.cobranza import router as cobranza_router
from app.routes.campana import router as campana_router
from app.routes.reporte import router as reporte_router
from app.routes.homebanking import router as homebanking_router
from app.routes.homebanking_solicitudes import router as homebanking_solicitudes_router
from app.routes.comite import router as comite_router
from app.routes.sync import router as sync_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth_router)
api_router.include_router(agencia_router)
api_router.include_router(cartera_router)
api_router.include_router(cliente_router)
api_router.include_router(solicitud_router)
api_router.include_router(buro_router)
api_router.include_router(cobranza_router)
api_router.include_router(campana_router)
api_router.include_router(reporte_router)
api_router.include_router(homebanking_router)
api_router.include_router(homebanking_solicitudes_router)
api_router.include_router(comite_router)
api_router.include_router(sync_router)
