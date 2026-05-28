-- ============================================================
-- SCRIPT 00 — Setup Base BBVA (PostgreSQL / Supabase)
-- App Móvil BBVA Fuerza de Ventas · v1.0
-- ============================================================
-- EJECUTAR: 1ro de 5
-- TIEMPO ESTIMADO: < 3 segundos
-- DB: bd_appbanco_bbva_ventas
-- ============================================================
-- DIFERENCIA vs FieldIQ:
--   • Tablas adaptadas para BBVA
--   • Nombres: usuarios_app, cuentas_bbva, solicitudes_credito
--   • Productos y marcas BBVA
-- ============================================================
-- QUÉ CREA:
--   usuarios_app          → usuarios del sistema (ejecutivos, admin, clientes)
--   cuentas_bbva          → cuentas bancarias BBVA
--   transacciones         → historial transaccional
--   pagos_servicios       → pago de servicios básicos
--   solicitudes_credito   → solicitudes de crédito BBVA
--   cuentas_ahorro        → cuentas de ahorro con meta
-- ============================================================

-- ── 0. Limpieza segura (orden inverso a FK) ───────────────
DROP TABLE IF EXISTS public.solicitudes_credito  CASCADE;
DROP TABLE IF EXISTS public.cuentas_ahorro       CASCADE;
DROP TABLE IF EXISTS public.pagos_servicios      CASCADE;
DROP TABLE IF EXISTS public.transacciones        CASCADE;
DROP TABLE IF EXISTS public.cuentas_bbva         CASCADE;
DROP TABLE IF EXISTS public.usuarios_app         CASCADE;

-- ============================================================
-- 1. usuarios_app — Reemplaza auth.users de Supabase
-- ============================================================
CREATE TABLE public.usuarios_app (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  email          TEXT        NOT NULL UNIQUE,
  nombre         TEXT        NOT NULL,
  apellido       TEXT        NOT NULL,
  password_hash  TEXT        NOT NULL DEFAULT 'demo_hash',
  rol            TEXT        NOT NULL DEFAULT 'cliente'
                             CHECK (rol IN ('cliente','ejecutivo','admin')),
  activo         BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.usuarios_app IS
  'Usuarios del sistema BBVA Fuerza de Ventas.
   Roles: cliente (solicitante), ejecutivo (app móvil FV), admin (backoffice).';

-- ============================================================
-- 2. cuentas_bbva — Cuentas bancarias BBVA
-- ============================================================
CREATE TABLE public.cuentas_bbva (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  tipo           TEXT        NOT NULL CHECK (tipo IN ('corriente','ahorro','nomina')),
  numero_cuenta  TEXT        NOT NULL UNIQUE,
  saldo          NUMERIC(12,2) NOT NULL DEFAULT 0,
  moneda         TEXT        NOT NULL DEFAULT 'PEN',
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.cuentas_bbva IS
  'Cuentas BBVA de los clientes. Tipos: corriente, ahorro, nómina.';

-- ============================================================
-- 3. transacciones — Historial de movimientos
-- ============================================================
CREATE TABLE public.transacciones (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  cuenta_id      UUID        REFERENCES public.cuentas_bbva(id) ON DELETE SET NULL,
  tipo           TEXT        NOT NULL CHECK (tipo IN ('debito','credito')),
  descripcion    TEXT        NOT NULL,
  monto          NUMERIC(12,2) NOT NULL,
  fecha          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. pagos_servicios — Pago de servicios (BBVA)
-- ============================================================
CREATE TABLE public.pagos_servicios (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  servicio         TEXT        NOT NULL CHECK (servicio IN ('agua','luz','cable','telefono','gas','internet')),
  numero_contrato  TEXT        NOT NULL,
  monto            NUMERIC(10,2) NOT NULL,
  estado           TEXT        NOT NULL DEFAULT 'completado',
  fecha            TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. solicitudes_credito — Solicitudes de crédito BBVA
-- ============================================================
CREATE TABLE public.solicitudes_credito (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  monto           NUMERIC(12,2) NOT NULL,
  plazo_meses     INTEGER     NOT NULL,
  tasa_anual      NUMERIC(5,2) NOT NULL,
  cuota_mensual   NUMERIC(10,2) NOT NULL,
  producto        TEXT        DEFAULT 'credito_negocios'
                              CHECK (producto IN (
                                'credito_negocios','credito_efectivo',
                                'leasing','tarjeta_credito','hipotecario'
                              )),
  proposito       TEXT,
  estado          TEXT        NOT NULL DEFAULT 'pendiente'
                              CHECK (estado IN ('pendiente','aprobado','rechazado','desembolsado')),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.solicitudes_credito IS
  'Solicitudes de crédito BBVA. Productos: Crédito Negocios, Crédito Efectivo, Leasing, etc.';

-- ============================================================
-- 6. cuentas_ahorro — Cuentas de ahorro con meta BBVA
-- ============================================================
CREATE TABLE public.cuentas_ahorro (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,
  saldo           NUMERIC(12,2) NOT NULL DEFAULT 0,
  meta_ahorro     NUMERIC(12,2) NOT NULL DEFAULT 10000,
  tasa_interes    NUMERIC(5,2) NOT NULL DEFAULT 2.5,
  fecha_apertura  DATE        DEFAULT CURRENT_DATE
);

-- ============================================================
-- Índices de rendimiento
-- ============================================================
CREATE INDEX idx_cuentas_user        ON public.cuentas_bbva(user_id);
CREATE INDEX idx_transacciones_user  ON public.transacciones(user_id);
CREATE INDEX idx_transacciones_fecha ON public.transacciones(fecha);
CREATE INDEX idx_pagos_user          ON public.pagos_servicios(user_id);
CREATE INDEX idx_solicitudes_user    ON public.solicitudes_credito(user_id);
CREATE INDEX idx_solicitudes_estado  ON public.solicitudes_credito(estado);

-- ============================================================
-- Verificación
-- ============================================================
SELECT
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns c
   WHERE c.table_name = t.table_name AND c.table_schema = 'public') AS columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN (
    'usuarios_app','cuentas_bbva','transacciones',
    'pagos_servicios','solicitudes_credito','cuentas_ahorro'
  )
ORDER BY table_name;

-- ============================================================
-- FIN — 00_setup_base_bbva.sql · v1.0
-- DB: bd_appbanco_bbva_ventas
-- Siguiente: ejecutar 01_scoring_bbva.sql
-- ============================================================
