-- ============================================================
-- SCRIPT 01 — Cartera, Solicitudes y Documentos BBVA
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 2do de 7 (después de 00_schema_bbva.sql)
-- ============================================================

-- ============================================================
-- 10. CARTERA_DIARIA — Asignacion diaria de visitas
-- ============================================================
CREATE TABLE public.cartera_diaria (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  asesor_id           UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id          UUID        NOT NULL REFERENCES public.clientes(id),
  agencia_id          UUID        REFERENCES public.agencias(id),
  fecha_asignacion    DATE        NOT NULL DEFAULT CURRENT_DATE,
  tipo_gestion        VARCHAR(30) NOT NULL DEFAULT 'RENOVACION'
                      CHECK (tipo_gestion IN (
                        'RENOVACION','AMPLIACION','NUEVA_SOLICITUD',
                        'SEGUIMIENTO','RECUPERACION_MORA','DESERTOR'
                      )),
  prioridad           VARCHAR(10) DEFAULT 'normal'
                      CHECK (prioridad IN ('alta','media','normal')),
  score_prioridad     INTEGER     DEFAULT 0,
  monto_referencial   NUMERIC(12,2) DEFAULT 0,
  estado_visita       VARCHAR(20) DEFAULT 'pendiente'
                      CHECK (estado_visita IN (
                        'pendiente','visitado','no_encontrado','reagendado','negocio_cerrado'
                      )),
  resultado_visita    VARCHAR(30),
  observacion_visita  TEXT,
  timestamp_visita    TIMESTAMPTZ,
  lat_visita          NUMERIC(10,7),
  lng_visita          NUMERIC(10,7),
  orden_manual        INTEGER     DEFAULT 999,
  pendiente_sync      BOOLEAN     DEFAULT FALSE,
  created_at          TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_cartera_diaria UNIQUE (asesor_id, cliente_id, fecha_asignacion)
);

-- ============================================================
-- 11. SOLICITUDES_CREDITO — Solicitudes de credito BBVA
-- ============================================================
CREATE TABLE public.solicitudes_credito (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_expediente     VARCHAR(20) UNIQUE,
  asesor_id             UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id            UUID        NOT NULL REFERENCES public.clientes(id),
  agencia_id            UUID        REFERENCES public.agencias(id),
  cartera_id            UUID        REFERENCES public.cartera_diaria(id),

  -- Paso 1: Datos del solicitante
  tipo_negocio          VARCHAR(30),
  nombre_negocio        VARCHAR(100),
  actividad_economica   VARCHAR(10),
  antiguedad_negocio_meses INTEGER DEFAULT 0,
  tiene_conyuge         BOOLEAN     DEFAULT FALSE,
  conyuge_json          JSONB,
  tiene_garante         BOOLEAN     DEFAULT FALSE,
  garante_json          JSONB,

  -- Paso 2: Datos del negocio y destino
  ingresos_estimados    NUMERIC(12,2) DEFAULT 0,
  gastos_mensuales      NUMERIC(12,2) DEFAULT 0,
  patrimonio_estimado   NUMERIC(12,2) DEFAULT 0,
  destino_credito       TEXT,

  -- Paso 3: Condiciones del credito
  monto_solicitado      NUMERIC(12,2) NOT NULL,
  plazo_meses           INTEGER     NOT NULL DEFAULT 12,
  moneda                VARCHAR(3)  DEFAULT 'PEN',
  tipo_cuota            VARCHAR(10) DEFAULT 'mensual'
                        CHECK (tipo_cuota IN ('mensual','quincenal','semanal')),
  garantia              VARCHAR(20) DEFAULT 'sin_garantia'
                        CHECK (garantia IN ('sin_garantia','aval','hipotecaria','prendaria')),
  cuota_estimada        NUMERIC(10,2) DEFAULT 0,
  tea_referencial       NUMERIC(5,2) DEFAULT 15.0,

  -- Paso 4: Confirmacion y firma
  firma_cliente_base64  TEXT,

  -- Estado y seguimiento
  estado                VARCHAR(30) NOT NULL DEFAULT 'borrador'
                        CHECK (estado IN (
                          'borrador','enviado','recibido_comite','en_evaluacion',
                          'aprobado','condicionado','rechazado','desembolsado'
                        )),
  monto_aprobado        NUMERIC(12,2),
  motivo_rechazo        TEXT,
  condicion_adicional   TEXT,
  analista_asignado     VARCHAR(100),

  -- Geolocalizacion
  lat_captura           NUMERIC(10,7),
  lng_captura           NUMERIC(10,7),

  -- Offline
  pendiente_sync        BOOLEAN     DEFAULT FALSE,

  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 12. SOLICITUDES_DOCUMENTOS — Documentos adjuntos
-- ============================================================
CREATE TABLE public.solicitudes_documentos (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  solicitud_id      UUID        NOT NULL REFERENCES public.solicitudes_credito(id) ON DELETE CASCADE,
  tipo_documento    VARCHAR(30) NOT NULL,
  url_documento     TEXT,
  estado            VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE'
                    CHECK (estado IN ('LISTO','PENDIENTE','OBLIGATORIO')),
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 13. FICHAS_CAMPO — Respaldo de visitas offline
-- ============================================================
CREATE TABLE public.fichas_campo (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  asesor_id           UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  cliente_id          UUID        REFERENCES public.clientes(id),
  cartera_id          UUID        REFERENCES public.cartera_diaria(id),
  tipo_visita         TEXT        NOT NULL DEFAULT 'prospeccion'
                      CHECK (tipo_visita IN ('prospeccion','renovacion','seguimiento','cobranza')),
  latitud             NUMERIC(10,7),
  longitud            NUMERIC(10,7),
  distrito            TEXT,
  resultado           TEXT,
  observaciones       TEXT,
  creada_offline      BOOLEAN     DEFAULT FALSE,
  sincronizada_at     TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_cartera_asesor_fecha ON public.cartera_diaria(asesor_id, fecha_asignacion);
CREATE INDEX idx_cartera_estado       ON public.cartera_diaria(estado_visita);
CREATE INDEX idx_cartera_prioridad    ON public.cartera_diaria(score_prioridad DESC);
CREATE INDEX idx_solicitudes_asesor   ON public.solicitudes_credito(asesor_id);
CREATE INDEX idx_solicitudes_estado   ON public.solicitudes_credito(estado);
CREATE INDEX idx_solicitudes_cliente  ON public.solicitudes_credito(cliente_id);
CREATE INDEX idx_documentos_solicitud ON public.solicitudes_documentos(solicitud_id);
CREATE INDEX idx_fichas_asesor        ON public.fichas_campo(asesor_id);

-- ============================================================
-- FIN — 01_cartera_solicitudes.sql
-- Siguiente: 02_scoring_funciones_bbva.sql
-- ============================================================
