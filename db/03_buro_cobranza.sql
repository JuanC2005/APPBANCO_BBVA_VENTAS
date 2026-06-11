-- ============================================================
-- SCRIPT 03 — Buró, Cobranza, Alertas y Notas BBVA
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 4to de 7 (después de 02_scoring_funciones_bbva.sql)
-- ============================================================

-- ============================================================
-- 14. CONSULTAS_BURO — Historial de consultas SBS
-- ============================================================
CREATE TABLE public.consultas_buro (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  asesor_id               UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id              UUID        NOT NULL REFERENCES public.clientes(id),
  dni_consultado          VARCHAR(15) NOT NULL,
  calificacion_sbs        VARCHAR(20),
  entidades_con_deuda     INTEGER     DEFAULT 0,
  deuda_total_pen         NUMERIC(12,2) DEFAULT 0,
  mayor_deuda             NUMERIC(12,2) DEFAULT 0,
  dias_mayor_mora         INTEGER     DEFAULT 0,
  resultado_json          JSONB,
  en_lista_negra          BOOLEAN     DEFAULT FALSE,
  motivo_bloqueo          TEXT,
  firma_consentimiento_base64 TEXT,
  solicitud_id            UUID        REFERENCES public.solicitudes_credito(id),
  created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 15. ACCIONES_COBRANZA — Gestion de cobranza en campo
-- ============================================================
CREATE TABLE public.acciones_cobranza (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  asesor_id           UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id          UUID        NOT NULL REFERENCES public.clientes(id),
  credito_id          UUID        REFERENCES public.creditos(id),
  tipo_gestion        VARCHAR(20) NOT NULL CHECK (tipo_gestion IN ('Visita','Llamada','Mensaje')),
  resultado           VARCHAR(30) NOT NULL CHECK (resultado IN (
                        'Compromiso de pago','Pago parcial','Sin contacto','Se niega a pagar','Cliente ausente'
                      )),
  monto_pagado        NUMERIC(12,2) DEFAULT 0,
  fecha_compromiso    DATE,
  monto_comprometido  NUMERIC(12,2) DEFAULT 0,
  observaciones       TEXT,
  lat                 NUMERIC(10,7),
  lng                 NUMERIC(10,7),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 16. ALERTAS_CARTERA — Alertas en tiempo real
-- ============================================================
CREATE TABLE public.alertas_cartera (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  credito_id      UUID        REFERENCES public.creditos(id),
  asesor_id       UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id      UUID        NOT NULL REFERENCES public.clientes(id),
  tipo_alerta     VARCHAR(30) NOT NULL CHECK (tipo_alerta IN (
                    'primer_dia_mora','mora_30d','mora_60d','pago_parcial','pago_total','desertor'
                  )),
  mensaje         TEXT        NOT NULL,
  leida           BOOLEAN     DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 17. SOLICITUDES_NOTAS_INTERNAS — Notas privadas
-- ============================================================
CREATE TABLE public.solicitudes_notas_internas (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  solicitud_id    UUID        NOT NULL REFERENCES public.solicitudes_credito(id) ON DELETE CASCADE,
  asesor_id       UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  contenido       TEXT        NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_buro_asesor        ON public.consultas_buro(asesor_id);
CREATE INDEX idx_buro_cliente       ON public.consultas_buro(cliente_id);
CREATE INDEX idx_buro_created       ON public.consultas_buro(created_at DESC);
CREATE INDEX idx_cobranza_asesor    ON public.acciones_cobranza(asesor_id);
CREATE INDEX idx_cobranza_cliente   ON public.acciones_cobranza(cliente_id);
CREATE INDEX idx_cobranza_fecha     ON public.acciones_cobranza(created_at DESC);
CREATE INDEX idx_alertas_asesor     ON public.alertas_cartera(asesor_id);
CREATE INDEX idx_alertas_leida      ON public.alertas_cartera(leida) WHERE leida = FALSE;
CREATE INDEX idx_notas_solicitud    ON public.solicitudes_notas_internas(solicitud_id);

-- ============================================================
-- FIN — 03_buro_cobranza.sql
-- Siguiente: 04_seed_demo_bbva.sql
-- ============================================================
