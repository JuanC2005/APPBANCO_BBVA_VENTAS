-- ============================================================
-- SCRIPT 02 — Sucursales BBVA y Ejecutivos de Negocio
-- App Móvil BBVA Fuerza de Ventas · v1.0
-- ============================================================
-- EJECUTAR: 3ro de 5 (después de 01_scoring_bbva.sql)
-- TIEMPO ESTIMADO: < 3 segundos
-- DB: bd_appbanco_bbva_ventas
-- ============================================================
-- QUÉ CREA:
--   sucursales_bbva       → sucursales y puntos de atención BBVA
--   ejecutivos_negocio    → ejecutivos con referencia a usuarios_app
--   metas_ejecutivos      → metas mensuales por ejecutivo
--   rutas_planificadas    → rutas de visita del día
-- ============================================================

-- ── Limpieza segura ───────────────────────────────────────
DROP TABLE IF EXISTS public.rutas_planificadas      CASCADE;
DROP TABLE IF EXISTS public.metas_ejecutivos        CASCADE;
DROP TABLE IF EXISTS public.ejecutivos_negocio      CASCADE;
DROP TABLE IF EXISTS public.sucursales_bbva         CASCADE;

-- ============================================================
-- 1. sucursales_bbva — Red de agencias BBVA
-- ============================================================
CREATE TABLE public.sucursales_bbva (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo            TEXT        NOT NULL UNIQUE,
  nombre            TEXT        NOT NULL,
  tipo              TEXT        NOT NULL DEFAULT 'agencia'
                                CHECK (tipo IN ('agencia','oficina_especial','ventanilla','banca_empresas')),

  departamento      TEXT        NOT NULL DEFAULT 'Junín',
  provincia         TEXT        NOT NULL DEFAULT 'Huancayo',
  distrito          TEXT        NOT NULL,
  direccion         TEXT,
  latitud           NUMERIC(10,7),
  longitud          NUMERIC(10,7),

  activa            BOOLEAN     NOT NULL DEFAULT TRUE,
  gerente_nombre    TEXT,
  telefono          TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.sucursales_bbva IS
  'Red de sucursales BBVA. Referencia para asignar ejecutivos a una zona geográfica.';

-- ============================================================
-- 2. ejecutivos_negocio — Ejecutivos BBVA Fuerza de Ventas
-- ============================================================
CREATE TABLE public.ejecutivos_negocio (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id           UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  sucursal_id       UUID        NOT NULL REFERENCES public.sucursales_bbva(id),

  codigo_ejecutivo  TEXT        NOT NULL UNIQUE,
  especialidad      TEXT        DEFAULT 'microempresa'
                                CHECK (especialidad IN (
                                  'microempresa','pequena_empresa',
                                  'agropecuario','consumo','hipotecario','banca_empresas'
                                )),
  zona_asignada     TEXT,
  activo            BOOLEAN     NOT NULL DEFAULT TRUE,

  meta_visitas_mes  INTEGER     DEFAULT 80,
  meta_creditos_mes INTEGER     DEFAULT 25,
  meta_monto_mes    NUMERIC(12,2) DEFAULT 150000,

  visitas_mes_actual   INTEGER  DEFAULT 0,
  creditos_mes_actual  INTEGER  DEFAULT 0,
  monto_mes_actual     NUMERIC(12,2) DEFAULT 0,

  created_at        TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_ejecutivos_user UNIQUE (user_id)
);

COMMENT ON TABLE public.ejecutivos_negocio IS
  'Perfil del ejecutivo BBVA de negocios (oficial de crédito).
   user_id vincula con usuarios_app para autenticación en la app.';

-- ============================================================
-- 3. metas_ejecutivos — Histórico de metas mensuales
-- ============================================================
CREATE TABLE public.metas_ejecutivos (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ejecutivo_id    UUID        NOT NULL REFERENCES public.ejecutivos_negocio(id),
  periodo         TEXT        NOT NULL,

  meta_visitas    INTEGER     DEFAULT 80,
  meta_creditos   INTEGER     DEFAULT 25,
  meta_monto      NUMERIC(12,2) DEFAULT 150000,

  real_visitas    INTEGER     DEFAULT 0,
  real_creditos   INTEGER     DEFAULT 0,
  real_monto      NUMERIC(12,2) DEFAULT 0,

  pct_visitas     NUMERIC(5,2) GENERATED ALWAYS AS (
    CASE WHEN meta_visitas = 0 THEN 0
         ELSE ROUND(real_visitas * 100.0 / meta_visitas, 2)
    END
  ) STORED,
  pct_creditos    NUMERIC(5,2) GENERATED ALWAYS AS (
    CASE WHEN meta_creditos = 0 THEN 0
         ELSE ROUND(real_creditos * 100.0 / meta_creditos, 2)
    END
  ) STORED,
  pct_monto       NUMERIC(5,2) GENERATED ALWAYS AS (
    CASE WHEN meta_monto = 0 THEN 0
         ELSE ROUND(real_monto * 100.0 / meta_monto, 2)
    END
  ) STORED,

  created_at      TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_metas_ejecutivo_periodo UNIQUE (ejecutivo_id, periodo)
);

-- ============================================================
-- 4. rutas_planificadas — Planificación diaria de visitas
-- ============================================================
CREATE TABLE public.rutas_planificadas (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ejecutivo_id     UUID        NOT NULL REFERENCES public.ejecutivos_negocio(id),
  fecha_ruta       DATE        NOT NULL DEFAULT CURRENT_DATE,

  cliente_user_id  UUID        REFERENCES public.usuarios_app(id),
  prospecto_nombre TEXT,
  prospecto_dir    TEXT,

  latitud_cliente  NUMERIC(10,7),
  longitud_cliente NUMERIC(10,7),
  referencia_dir   TEXT,

  tipo_visita      TEXT        NOT NULL DEFAULT 'renovacion'
                               CHECK (tipo_visita IN (
                                 'renovacion','prospeccion',
                                 'seguimiento','cobranza'
                               )),
  monto_estimado   NUMERIC(12,2) DEFAULT 0,
  hora_sugerida    TIME,

  estado           TEXT        NOT NULL DEFAULT 'pendiente'
                               CHECK (estado IN (
                                 'pendiente','en_ruta',
                                 'visitado','reagendar','cancelado'
                               )),
  ficha_generada_id UUID       REFERENCES public.fichas_campo(id),

  cargado_automatico BOOLEAN   DEFAULT TRUE,
  cargado_at         TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.rutas_planificadas IS
  'Lista de clientes para visitar cada día del ejecutivo BBVA.
   Se pobla automáticamente desde vw_renovaciones_pendientes_bbva cada mañana.';

-- ============================================================
-- Índices
-- ============================================================
CREATE INDEX idx_ejecutivos_sucursal  ON public.ejecutivos_negocio(sucursal_id);
CREATE INDEX idx_ejecutivos_user      ON public.ejecutivos_negocio(user_id);
CREATE INDEX idx_metas_ejecutivo      ON public.metas_ejecutivos(ejecutivo_id, periodo);
CREATE INDEX idx_rutas_ejecutivo_fecha ON public.rutas_planificadas(ejecutivo_id, fecha_ruta);
CREATE INDEX idx_rutas_estado         ON public.rutas_planificadas(estado);

-- ============================================================
-- Vista: Dashboard del ejecutivo BBVA
-- ============================================================
CREATE OR REPLACE VIEW public.vw_dashboard_ejecutivo AS
SELECT
  en.id              AS ejecutivo_id,
  en.codigo_ejecutivo,
  ua.nombre || ' ' || ua.apellido  AS ejecutivo_nombre,
  sb.nombre          AS sucursal,
  en.especialidad,
  en.zona_asignada,

  en.meta_visitas_mes,
  en.meta_creditos_mes,
  en.meta_monto_mes,

  en.visitas_mes_actual,
  en.creditos_mes_actual,
  en.monto_mes_actual,

  ROUND(en.visitas_mes_actual * 100.0 / NULLIF(en.meta_visitas_mes, 0), 1)
    AS pct_visitas,
  ROUND(en.creditos_mes_actual * 100.0 / NULLIF(en.meta_creditos_mes, 0), 1)
    AS pct_creditos,
  ROUND(en.monto_mes_actual * 100.0 / NULLIF(en.meta_monto_mes, 0), 1)
    AS pct_monto,

  (SELECT COUNT(*) FROM public.rutas_planificadas rp
   WHERE rp.ejecutivo_id = en.id AND rp.fecha_ruta = CURRENT_DATE)
    AS visitas_hoy_total,
  (SELECT COUNT(*) FROM public.rutas_planificadas rp
   WHERE rp.ejecutivo_id = en.id AND rp.fecha_ruta = CURRENT_DATE
     AND rp.estado = 'visitado')
    AS visitas_hoy_completadas,
  (SELECT COUNT(*) FROM public.rutas_planificadas rp
   WHERE rp.ejecutivo_id = en.id AND rp.fecha_ruta = CURRENT_DATE
     AND rp.estado = 'pendiente')
    AS visitas_hoy_pendientes

FROM public.ejecutivos_negocio en
JOIN public.usuarios_app ua     ON ua.id = en.user_id
JOIN public.sucursales_bbva sb  ON sb.id = en.sucursal_id
WHERE en.activo = TRUE;

-- ============================================================
-- Verificación
-- ============================================================
SELECT table_name, 'OK' AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'sucursales_bbva','ejecutivos_negocio',
    'metas_ejecutivos','rutas_planificadas'
  )
ORDER BY table_name;

-- ============================================================
-- FIN — 02_sucursales_ejecutivos_bbva.sql · v1.0
-- Siguiente: ejecutar 03_seed_demo_bbva.sql
-- ============================================================
