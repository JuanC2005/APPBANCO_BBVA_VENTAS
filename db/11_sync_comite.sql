-- ============================================================
-- SCRIPT 11 — Sync Outbox + Comité + Canal Cliente
-- App Móvil BBVA Fuerza de Ventas + App Clientes · v2.0
-- ============================================================
-- EJECUTAR: después del 10_campanas_marketing.sql
-- ============================================================

-- 1. Hacer asesor_id nullable (solicitudes de cliente llegan sin asesor)
ALTER TABLE public.solicitudes_credito ALTER COLUMN asesor_id DROP NOT NULL;

-- 2. Columna canal: distingue origen de la solicitud
ALTER TABLE public.solicitudes_credito ADD COLUMN IF NOT EXISTS canal VARCHAR(10) DEFAULT 'asesor'
  CHECK (canal IN ('asesor', 'cliente'));

-- 3. Columna con_seguro: define TEA según tarifario
ALTER TABLE public.solicitudes_credito ADD COLUMN IF NOT EXISTS con_seguro BOOLEAN DEFAULT FALSE;

-- 4. Tabla sync_outbox — Cola de promoción al núcleo financiero
CREATE TABLE IF NOT EXISTS public.sync_outbox (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  solicitud_id      UUID        REFERENCES public.solicitudes_credito(id),
  tabla_destino     VARCHAR(50) NOT NULL,
  accion            VARCHAR(20) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
  payload_json      JSONB       NOT NULL,
  estado            VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                    CHECK (estado IN ('pendiente', 'procesado', 'error')),
  intentos          INTEGER     DEFAULT 0,
  error_msg         TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  processed_at      TIMESTAMPTZ
);

-- 5. Tabla sync_log — Auditoría de sincronización
CREATE TABLE IF NOT EXISTS public.sync_log (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_outbox_id    UUID        REFERENCES public.sync_outbox(id),
  estado            VARCHAR(20) NOT NULL,
  mensaje           TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Índices para sync_outbox
CREATE INDEX IF NOT EXISTS idx_sync_outbox_estado ON public.sync_outbox(estado);
CREATE INDEX IF NOT EXISTS idx_sync_outbox_solicitud ON public.sync_outbox(solicitud_id);
