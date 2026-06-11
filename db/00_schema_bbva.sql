-- ============================================================
-- SCRIPT 00 — Schema Base BBVA
-- App Móvil BBVA Fuerza de Ventas · v2.0 (Documento HU/RF)
-- ============================================================
-- EJECUTAR: 1ro de 7
-- DB: bd_appbanco_bbva_ventas
-- ============================================================
-- TABLAS: agencias, asesores_negocio, clientes, creditos,
--          creditos_preaprobados, perfiles_clientes,
--          movimientos_mensuales, features_scoring, scores_crediticios
-- ============================================================

-- ── Limpieza segura ───────────────────────────────────────
DROP TABLE IF EXISTS public.solicitudes_notas_internas CASCADE;
DROP TABLE IF EXISTS public.alertas_cartera           CASCADE;
DROP TABLE IF EXISTS public.acciones_cobranza          CASCADE;
DROP TABLE IF EXISTS public.consultas_buro             CASCADE;
DROP TABLE IF EXISTS public.solicitudes_documentos     CASCADE;
DROP TABLE IF EXISTS public.solicitudes_credito        CASCADE;
DROP TABLE IF EXISTS public.cartera_diaria            CASCADE;
DROP TABLE IF EXISTS public.creditos_preaprobados      CASCADE;
DROP TABLE IF EXISTS public.creditos                   CASCADE;
DROP TABLE IF EXISTS public.scores_crediticios         CASCADE;
DROP TABLE IF EXISTS public.features_scoring           CASCADE;
DROP TABLE IF EXISTS public.movimientos_mensuales      CASCADE;
DROP TABLE IF EXISTS public.perfiles_clientes          CASCADE;
DROP TABLE IF EXISTS public.clientes                   CASCADE;
DROP TABLE IF EXISTS public.asesores_negocio           CASCADE;
DROP TABLE IF EXISTS public.agencias                   CASCADE;
DROP TABLE IF EXISTS public.usuarios_app               CASCADE;
DROP TABLE IF EXISTS public.fichas_campo               CASCADE;
DROP TABLE IF EXISTS public.metas_ejecutivos           CASCADE;
DROP TABLE IF EXISTS public.rutas_planificadas         CASCADE;
DROP TABLE IF EXISTS public.sucursales_bbva            CASCADE;

-- ============================================================
-- 1. AGENCIAS — Red BBVA
-- ============================================================
CREATE TABLE public.agencias (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo            TEXT        NOT NULL UNIQUE,
  nombre            TEXT        NOT NULL,
  tipo              TEXT        NOT NULL DEFAULT 'agencia'
                                CHECK (tipo IN ('agencia','oficina_especial','ventanilla','banca_empresas')),
  departamento      TEXT        NOT NULL DEFAULT 'Junín',
  provincia         TEXT        NOT NULL DEFAULT 'Huancayo',
  distrito          TEXT        NOT NULL,
  direccion         TEXT,
  lat               NUMERIC(10,7),
  lng               NUMERIC(10,7),
  region            TEXT        DEFAULT 'Centro',
  activa            BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. ASESORES_NEGOCIO — Ejecutivos BBVA con perfiles
-- ============================================================
CREATE TABLE public.asesores_negocio (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID,
  codigo_empleado   TEXT        NOT NULL UNIQUE,
  nombres           TEXT        NOT NULL DEFAULT '',
  apellidos         TEXT        NOT NULL DEFAULT '',
  email             TEXT,
  agencia_id        UUID        NOT NULL REFERENCES public.agencias(id),
  especialidad      TEXT        DEFAULT 'microempresa'
                                CHECK (especialidad IN ('microempresa','pequena_empresa','agropecuario','consumo','hipotecario','banca_empresas')),
  perfil            TEXT        NOT NULL DEFAULT 'operador'
                                CHECK (perfil IN ('operador','super_operador','supervisor','administrador')),
  zona_asignada     TEXT,
  token_fcm         TEXT,
  activo            BOOLEAN     NOT NULL DEFAULT TRUE,

  meta_visitas_mes  INTEGER     DEFAULT 80,
  meta_creditos_mes INTEGER     DEFAULT 25,
  meta_monto_mes    NUMERIC(12,2) DEFAULT 200000,
  visitas_mes_actual   INTEGER  DEFAULT 0,
  creditos_mes_actual  INTEGER  DEFAULT 0,
  monto_mes_actual     NUMERIC(12,2) DEFAULT 0,

  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. CLIENTES — Tabla central de clientes BBVA
-- ============================================================
CREATE TABLE public.clientes (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_documento        VARCHAR(15) NOT NULL UNIQUE,
  tipo_documento          VARCHAR(5)  NOT NULL DEFAULT 'DNI'
                                      CHECK (tipo_documento IN ('DNI','RUC','CE')),
  nombres                 VARCHAR(100) NOT NULL DEFAULT '',
  apellidos               VARCHAR(100) NOT NULL DEFAULT '',
  fecha_nacimiento        DATE,
  estado_civil            VARCHAR(15) CHECK (estado_civil IN ('Soltero','Casado','Conviviente','Divorciado','Viudo')),
  genero                  TEXT        CHECK (genero IN ('M','F','otro')),
  telefono                VARCHAR(15),
  email                   VARCHAR(100),
  direccion               TEXT,
  tipo_negocio            VARCHAR(30),
  nombre_negocio          VARCHAR(100),
  antiguedad_negocio_meses INTEGER   DEFAULT 0,
  ingresos_estimados      NUMERIC(12,2) DEFAULT 0,
  gastos_mensuales        NUMERIC(12,2) DEFAULT 0,
  deuda_actual            NUMERIC(12,2) DEFAULT 0,
  entidades_deuda         INTEGER     DEFAULT 0,
  lat                     NUMERIC(10,7),
  lng                     NUMERIC(10,7),
  calificacion_sbs        VARCHAR(15) DEFAULT 'Normal'
                          CHECK (calificacion_sbs IN ('Normal','CPP','Deficiente','Dudoso','Perdida','Sin_Historial')),
  estado_cliente          TEXT        NOT NULL DEFAULT 'activo'
                          CHECK (estado_cliente IN ('activo','moroso','castigado','retirado','prospecto')),
  created_at              TIMESTAMPTZ DEFAULT NOW(),
  updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. CREDITOS — Historial crediticio
-- ============================================================
CREATE TABLE public.creditos (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id          UUID        NOT NULL REFERENCES public.clientes(id),
  asesor_id           UUID        REFERENCES public.asesores_negocio(id),
  agencia_id          UUID        REFERENCES public.agencias(id),
  producto            VARCHAR(30) NOT NULL DEFAULT 'credito_negocios'
                      CHECK (producto IN ('credito_negocios','credito_efectivo','credito_agropecuario','leasing','tarjeta_credito','hipotecario')),
  monto_desembolsado  NUMERIC(12,2) NOT NULL DEFAULT 0,
  plazo_meses         INTEGER     NOT NULL DEFAULT 12,
  tea                 NUMERIC(5,2) DEFAULT 18.0,
  cuotas_totales      INTEGER     DEFAULT 12,
  cuotas_pagadas      INTEGER     DEFAULT 0,
  cuotas_mora         INTEGER     DEFAULT 0,
  saldo_actual        NUMERIC(12,2) DEFAULT 0,
  fecha_desembolso    DATE,
  fecha_vencimiento   DATE,
  estado              TEXT        NOT NULL DEFAULT 'vigente'
                      CHECK (estado IN ('vigente','vencido','castigado','pagado')),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. CREDITOS_PREAPROBADOS — Ofertas de scoring
-- ============================================================
CREATE TABLE public.creditos_preaprobados (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id            UUID        NOT NULL REFERENCES public.clientes(id),
  asesor_id             UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  monto_maximo          NUMERIC(12,2) NOT NULL,
  plazo_sugerido_meses  INTEGER     NOT NULL DEFAULT 12,
  tea_referencial       NUMERIC(5,2) DEFAULT 15.0,
  score_confianza       INTEGER     DEFAULT 0,
  vigente               BOOLEAN     NOT NULL DEFAULT TRUE,
  fecha_calculo         DATE        DEFAULT CURRENT_DATE,
  fecha_vencimiento     DATE        DEFAULT (CURRENT_DATE + INTERVAL '30 days'),
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 6. PERFILES_CLIENTES — Datos socioeconomicos detallados
-- ============================================================
CREATE TABLE public.perfiles_clientes (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id            UUID        NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  tipo_negocio          TEXT,
  antiguedad_negocio    INTEGER     DEFAULT 0,
  local_propio          BOOLEAN     DEFAULT FALSE,
  zona_negocio          TEXT        CHECK (zona_negocio IN ('urbano','periurbano','rural')),
  ingreso_mensual_est   NUMERIC(10,2) DEFAULT 0,
  gasto_mensual_est     NUMERIC(10,2) DEFAULT 0,
  patrimonio_estimado   NUMERIC(12,2) DEFAULT 0,
  puntaje_crediticio    NUMERIC(5,2) DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_perfiles_cliente UNIQUE (cliente_id)
);

-- ============================================================
-- 7. MOVIMIENTOS_MENSUALES — Historial financiero
-- ============================================================
CREATE TABLE public.movimientos_mensuales (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id        UUID        NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  periodo           TEXT        NOT NULL,
  total_creditos    NUMERIC(12,2) DEFAULT 0,
  total_debitos     NUMERIC(12,2) DEFAULT 0,
  saldo_promedio    NUMERIC(12,2) DEFAULT 0,
  num_transacciones INTEGER     DEFAULT 0,
  num_pagos_puntual INTEGER     DEFAULT 0,
  num_pagos_tardio  INTEGER     DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_mov_cliente_periodo UNIQUE (cliente_id, periodo)
);

-- ============================================================
-- 8. FEATURES_SCORING — Variables del modelo
-- ============================================================
CREATE TABLE public.features_scoring (
  id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id                UUID        NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  promedio_saldo_3m         NUMERIC(12,2) DEFAULT 0,
  variabilidad_saldo        NUMERIC(8,4)  DEFAULT 0,
  ratio_credito_debito      NUMERIC(8,4)  DEFAULT 0,
  frecuencia_transacciones  NUMERIC(6,2)  DEFAULT 0,
  porcentaje_pagos_puntual  NUMERIC(5,2)  DEFAULT 0,
  ratio_deuda_ingreso       NUMERIC(8,4)  DEFAULT 0,
  capacidad_pago            NUMERIC(10,2) DEFAULT 0,
  antiguedad_meses          INTEGER       DEFAULT 0,
  calculado_at              TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_features_cliente UNIQUE (cliente_id)
);

-- ============================================================
-- 9. SCORES_CREDITICIOS — Resultado del scoring
-- ============================================================
CREATE TABLE public.scores_crediticios (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id          UUID        NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  score               NUMERIC(5,2) NOT NULL DEFAULT 0,
  segmento            TEXT        NOT NULL DEFAULT 'C'
                      CHECK (segmento IN ('A','B','C','D','E')),
  recomendacion       TEXT        NOT NULL DEFAULT 'evaluar_presencial',
  monto_max_sugerido  NUMERIC(12,2) DEFAULT 0,
  nivel_confianza     INTEGER     DEFAULT 0,
  modelo_version      TEXT        DEFAULT 'v2.0_bbva',
  calculado_at        TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_score_cliente UNIQUE (cliente_id)
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_asesores_agencia   ON public.asesores_negocio(agencia_id);
CREATE INDEX idx_asesores_perfil    ON public.asesores_negocio(perfil);
CREATE INDEX idx_creditos_cliente   ON public.creditos(cliente_id);
CREATE INDEX idx_creditos_estado    ON public.creditos(estado);
CREATE INDEX idx_preaprobados_cliente ON public.creditos_preaprobados(cliente_id);
CREATE INDEX idx_preaprobados_vigente ON public.creditos_preaprobados(vigente);
CREATE INDEX idx_perfiles_cliente   ON public.perfiles_clientes(cliente_id);
CREATE INDEX idx_mov_cliente_periodo ON public.movimientos_mensuales(cliente_id, periodo);
CREATE INDEX idx_scores_cliente     ON public.scores_crediticios(cliente_id);

-- ============================================================
-- FIN — 00_schema_bbva.sql
-- Siguiente: 01_cartera_solicitudes.sql
-- ============================================================
