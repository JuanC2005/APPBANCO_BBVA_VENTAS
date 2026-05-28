-- ============================================================
-- SCRIPT 01 — Scoring BBVA: Tablas, Vistas y Funciones
-- App Móvil BBVA Fuerza de Ventas · v1.0
-- ============================================================
-- EJECUTAR: 2do de 5 (después de 00_setup_base_bbva.sql)
-- TIEMPO ESTIMADO: < 5 segundos
-- DB: bd_appbanco_bbva_ventas
-- ============================================================
-- QUÉ CREA:
--   perfiles_clientes       → datos socioeconómicos del cliente BBVA
--   movimientos_mensuales   → historial financiero para scoring
--   features_scoring        → variables calculadas del modelo
--   scores_crediticios      → resultado final del scoring BBVA
--   fichas_campo            → registro de visita del ejecutivo en campo
--   creditos_preaprobados   → resultado de la pre-aprobación BBVA
--
-- FUNCIONES:
--   calcular_features_scoring(uuid)
--   calcular_score_crediticio(uuid)
--   evaluar_credito_campo(uuid, numeric, int)
-- ============================================================

-- ── Limpieza segura ───────────────────────────────────────
DROP TABLE IF EXISTS public.creditos_preaprobados  CASCADE;
DROP TABLE IF EXISTS public.fichas_campo           CASCADE;
DROP TABLE IF EXISTS public.scores_crediticios     CASCADE;
DROP TABLE IF EXISTS public.features_scoring       CASCADE;
DROP TABLE IF EXISTS public.movimientos_mensuales  CASCADE;
DROP TABLE IF EXISTS public.perfiles_clientes      CASCADE;

DROP FUNCTION IF EXISTS public.evaluar_credito_campo(UUID, NUMERIC, INT);
DROP FUNCTION IF EXISTS public.calcular_score_crediticio(UUID);
DROP FUNCTION IF EXISTS public.calcular_features_scoring(UUID);

-- ============================================================
-- TABLAS DE SCORING BBVA
-- ============================================================

-- ── 1. perfiles_clientes ──────────────────────────────────
CREATE TABLE public.perfiles_clientes (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,

  nombres               TEXT        NOT NULL DEFAULT '',
  apellidos             TEXT        NOT NULL DEFAULT '',
  dni                   TEXT        UNIQUE,
  fecha_nacimiento      DATE,
  genero                TEXT        CHECK (genero IN ('M','F','otro')),

  tipo_negocio          TEXT,
  antiguedad_negocio    INTEGER      DEFAULT 0,
  local_propio          BOOLEAN      DEFAULT FALSE,
  zona_negocio          TEXT         CHECK (zona_negocio IN ('urbano','periurbano','rural')),

  ingreso_mensual_est   NUMERIC(10,2) DEFAULT 0,
  gasto_mensual_est     NUMERIC(10,2) DEFAULT 0,
  deuda_actual          NUMERIC(12,2) DEFAULT 0,
  entidades_deuda       INTEGER       DEFAULT 0,

  estado_cliente        TEXT        NOT NULL DEFAULT 'prospecto'
                                    CHECK (estado_cliente IN (
                                      'prospecto','activo','moroso','castigado','retirado'
                                    )),
  puntaje_crediticio    NUMERIC(5,2) DEFAULT 0,

  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_perfiles_user UNIQUE (user_id)
);

COMMENT ON TABLE public.perfiles_clientes IS
  'Perfil socioeconómico del cliente BBVA. Capturado en campo por el ejecutivo
   usando la app móvil Flutter. Alimenta el motor de scoring BBVA.';

-- ── 2. movimientos_mensuales ──────────────────────────────
CREATE TABLE public.movimientos_mensuales (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,

  periodo           TEXT        NOT NULL,
  total_creditos    NUMERIC(12,2) DEFAULT 0,
  total_debitos     NUMERIC(12,2) DEFAULT 0,
  saldo_promedio    NUMERIC(12,2) DEFAULT 0,
  num_transacciones INTEGER       DEFAULT 0,
  num_pagos_puntual INTEGER       DEFAULT 0,
  num_pagos_tardio  INTEGER       DEFAULT 0,

  created_at        TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_mov_user_periodo UNIQUE (user_id, periodo)
);

-- ── 3. features_scoring ──────────────────────────────────
CREATE TABLE public.features_scoring (
  id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,

  promedio_saldo_3m         NUMERIC(12,2) DEFAULT 0,
  variabilidad_saldo        NUMERIC(8,4)  DEFAULT 0,
  ratio_credito_debito      NUMERIC(8,4)  DEFAULT 0,
  frecuencia_transacciones  NUMERIC(6,2)  DEFAULT 0,
  porcentaje_pagos_puntual  NUMERIC(5,2)  DEFAULT 0,

  ratio_deuda_ingreso       NUMERIC(8,4)  DEFAULT 0,
  capacidad_pago            NUMERIC(10,2) DEFAULT 0,
  antiguedad_meses          INTEGER       DEFAULT 0,

  calculado_at              TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT uq_features_user UNIQUE (user_id)
);

-- ── 4. scores_crediticios ────────────────────────────────
CREATE TABLE public.scores_crediticios (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID        NOT NULL REFERENCES public.usuarios_app(id) ON DELETE CASCADE,

  score             NUMERIC(5,2) NOT NULL DEFAULT 0,
  segmento          TEXT         NOT NULL DEFAULT 'C'
                                 CHECK (segmento IN ('A','B','C','D','E')),
  recomendacion     TEXT         NOT NULL DEFAULT 'evaluar_presencial',
  monto_max_sugerido NUMERIC(12,2) DEFAULT 0,

  modelo_version    TEXT         DEFAULT 'v1.0_reglas_bbva',
  calculado_at      TIMESTAMPTZ  DEFAULT NOW(),

  CONSTRAINT uq_score_user UNIQUE (user_id)
);

COMMENT ON COLUMN public.scores_crediticios.segmento IS
  'A: BBVA Premium (85-100) → pre-aprobado inmediato
   B: BBVA Oro     (70-84)  → aprobación rápida
   C: BBVA Plata   (50-69)  → evaluar con garantías
   D: BBVA Bronce  (30-49)  → requiere comité
   E: Alto riesgo   (<30)   → rechazar';

-- ── 5. fichas_campo ──────────────────────────────────────
CREATE TABLE public.fichas_campo (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ejecutivo_id        UUID        NOT NULL REFERENCES public.usuarios_app(id),
  cliente_user_id     UUID        REFERENCES public.usuarios_app(id),

  prospecto_nombre    TEXT,
  prospecto_dni       TEXT,
  prospecto_telefono  TEXT,

  latitud             NUMERIC(10,7),
  longitud            NUMERIC(10,7),
  distrito            TEXT,
  provincia           TEXT        DEFAULT 'Huancayo',
  departamento        TEXT        DEFAULT 'Junín',

  tipo_visita         TEXT        NOT NULL DEFAULT 'prospeccion'
                                  CHECK (tipo_visita IN (
                                    'prospeccion','renovacion',
                                    'seguimiento','cobranza'
                                  )),
  negocio_nombre      TEXT,
  negocio_rubro       TEXT,
  ingreso_declarado   NUMERIC(10,2) DEFAULT 0,
  gasto_declarado     NUMERIC(10,2) DEFAULT 0,

  foto_dni_path       TEXT,
  foto_negocio_path   TEXT,

  estado_ficha        TEXT        NOT NULL DEFAULT 'borrador'
                                  CHECK (estado_ficha IN (
                                    'borrador','completada',
                                    'sincronizada','rechazada'
                                  )),
  score_obtenido      NUMERIC(5,2) DEFAULT 0,
  monto_solicitado    NUMERIC(12,2) DEFAULT 0,
  observaciones       TEXT,

  creada_offline      BOOLEAN     DEFAULT FALSE,
  sincronizada_at     TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.fichas_campo IS
  'Registro de visita del ejecutivo BBVA en campo.
   Soporta modo offline: creada_offline=TRUE cuando no hay internet.
   La app sincroniza al recuperar señal (sincronizada_at).';

-- ── 6. creditos_preaprobados ──────────────────────────────
CREATE TABLE public.creditos_preaprobados (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ficha_id          UUID        NOT NULL REFERENCES public.fichas_campo(id),
  cliente_user_id   UUID        REFERENCES public.usuarios_app(id),
  ejecutivo_id      UUID        NOT NULL REFERENCES public.usuarios_app(id),

  monto_preaprobado NUMERIC(12,2) NOT NULL,
  plazo_meses       INTEGER      NOT NULL DEFAULT 12,
  tasa_mensual      NUMERIC(6,4) NOT NULL DEFAULT 1.5,
  cuota_estimada    NUMERIC(10,2) GENERATED ALWAYS AS (
    ROUND(
      monto_preaprobado
      * (tasa_mensual/100 * POWER(1 + tasa_mensual/100, plazo_meses))
      / (POWER(1 + tasa_mensual/100, plazo_meses) - 1)
    , 2)
  ) STORED,

  producto_bbva     TEXT        DEFAULT 'credito_negocios'
                              CHECK (producto_bbva IN (
                                'credito_negocios','credito_efectivo',
                                'credito_agropecuario','tarjeta_credito'
                              )),
  score_aprobacion  NUMERIC(5,2) DEFAULT 0,
  estado            TEXT        NOT NULL DEFAULT 'pre-aprobado'
                                CHECK (estado IN (
                                  'pre-aprobado','en_comite',
                                  'aprobado','desembolsado','rechazado'
                                )),
  vigente_hasta     DATE        DEFAULT (CURRENT_DATE + INTERVAL '30 days'),
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.creditos_preaprobados IS
  'Pre-aprobación BBVA generada en campo por la app móvil.
   cuota_estimada con sistema francés. Productos BBVA disponibles.';

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_perfiles_user          ON public.perfiles_clientes(user_id);
CREATE INDEX idx_perfiles_estado        ON public.perfiles_clientes(estado_cliente);
CREATE INDEX idx_mov_user_periodo       ON public.movimientos_mensuales(user_id, periodo);
CREATE INDEX idx_fichas_ejecutivo       ON public.fichas_campo(ejecutivo_id);
CREATE INDEX idx_fichas_estado          ON public.fichas_campo(estado_ficha);
CREATE INDEX idx_fichas_offline         ON public.fichas_campo(creada_offline) WHERE creada_offline = TRUE;
CREATE INDEX idx_creditos_estado        ON public.creditos_preaprobados(estado);
CREATE INDEX idx_creditos_vigencia      ON public.creditos_preaprobados(vigente_hasta);

-- ============================================================
-- FUNCIÓN 1: calcular_features_scoring(user_id)
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_features_scoring(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_prom_saldo          NUMERIC(12,2);
  v_variabilidad        NUMERIC(8,4);
  v_ratio_cd            NUMERIC(8,4);
  v_freq_txn            NUMERIC(6,2);
  v_pct_puntual         NUMERIC(5,2);
  v_ratio_di            NUMERIC(8,4);
  v_cap_pago            NUMERIC(10,2);
  v_antiguedad          INTEGER;
  v_ingreso             NUMERIC(10,2);
  v_gasto               NUMERIC(10,2);
  v_deuda               NUMERIC(12,2);
BEGIN
  SELECT COALESCE(AVG(saldo_promedio), 0)
    INTO v_prom_saldo
    FROM public.movimientos_mensuales
   WHERE user_id = p_user_id
     AND periodo >= TO_CHAR(NOW() - INTERVAL '3 months', 'YYYY-MM');

  SELECT COALESCE(
    CASE WHEN AVG(saldo_promedio) = 0 THEN 0
         ELSE STDDEV(saldo_promedio) / AVG(saldo_promedio)
    END, 0)
    INTO v_variabilidad
    FROM public.movimientos_mensuales
   WHERE user_id = p_user_id
     AND periodo >= TO_CHAR(NOW() - INTERVAL '6 months', 'YYYY-MM');

  SELECT COALESCE(
    CASE WHEN SUM(total_debitos) = 0 THEN 1
         ELSE SUM(total_creditos) / NULLIF(SUM(total_debitos), 0)
    END, 1)
    INTO v_ratio_cd
    FROM public.movimientos_mensuales
   WHERE user_id = p_user_id;

  SELECT COALESCE(AVG(num_transacciones), 0)
    INTO v_freq_txn
    FROM public.movimientos_mensuales
   WHERE user_id = p_user_id;

  SELECT COALESCE(
    CASE WHEN (SUM(num_pagos_puntual) + SUM(num_pagos_tardio)) = 0 THEN 0
         ELSE SUM(num_pagos_puntual) * 100.0
              / (SUM(num_pagos_puntual) + SUM(num_pagos_tardio))
    END, 0)
    INTO v_pct_puntual
    FROM public.movimientos_mensuales
   WHERE user_id = p_user_id;

  SELECT
    COALESCE(ingreso_mensual_est, 0),
    COALESCE(gasto_mensual_est, 0),
    COALESCE(deuda_actual, 0),
    COALESCE(antiguedad_negocio, 0)
    INTO v_ingreso, v_gasto, v_deuda, v_antiguedad
    FROM public.perfiles_clientes
   WHERE user_id = p_user_id;

  v_ratio_di := CASE WHEN v_ingreso = 0 THEN 999
                     ELSE v_deuda / v_ingreso
                END;
  v_cap_pago := v_ingreso - v_gasto;

  INSERT INTO public.features_scoring (
    user_id, promedio_saldo_3m, variabilidad_saldo,
    ratio_credito_debito, frecuencia_transacciones,
    porcentaje_pagos_puntual, ratio_deuda_ingreso,
    capacidad_pago, antiguedad_meses, calculado_at
  )
  VALUES (
    p_user_id, v_prom_saldo, v_variabilidad,
    v_ratio_cd, v_freq_txn, v_pct_puntual,
    v_ratio_di, v_cap_pago, v_antiguedad, NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    promedio_saldo_3m        = EXCLUDED.promedio_saldo_3m,
    variabilidad_saldo       = EXCLUDED.variabilidad_saldo,
    ratio_credito_debito     = EXCLUDED.ratio_credito_debito,
    frecuencia_transacciones = EXCLUDED.frecuencia_transacciones,
    porcentaje_pagos_puntual = EXCLUDED.porcentaje_pagos_puntual,
    ratio_deuda_ingreso      = EXCLUDED.ratio_deuda_ingreso,
    capacidad_pago           = EXCLUDED.capacidad_pago,
    antiguedad_meses         = EXCLUDED.antiguedad_meses,
    calculado_at             = NOW();
END;
$$;

-- ============================================================
-- FUNCIÓN 2: calcular_score_crediticio(user_id)
-- Motor de scoring BBVA v1.0 (reglas de negocio)
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_score_crediticio(p_user_id UUID)
RETURNS NUMERIC(5,2)
LANGUAGE plpgsql
AS $$
DECLARE
  v_score           NUMERIC(5,2) := 0;
  v_segmento        TEXT;
  v_recomendacion   TEXT;
  v_monto_max       NUMERIC(12,2);
  f                 public.features_scoring%ROWTYPE;
BEGIN
  PERFORM public.calcular_features_scoring(p_user_id);

  SELECT * INTO f
    FROM public.features_scoring
   WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se encontraron features para user_id: %', p_user_id;
  END IF;

  -- BLOQUE A: Saldo promedio (máx 15 pts)
  v_score := v_score + CASE
    WHEN f.promedio_saldo_3m >= 5000  THEN 15
    WHEN f.promedio_saldo_3m >= 2000  THEN 12
    WHEN f.promedio_saldo_3m >= 1000  THEN 9
    WHEN f.promedio_saldo_3m >= 500   THEN 6
    WHEN f.promedio_saldo_3m >= 200   THEN 3
    ELSE 0
  END;

  -- BLOQUE B: Comportamiento de pagos (máx 20 pts)
  v_score := v_score + CASE
    WHEN f.porcentaje_pagos_puntual >= 95 THEN 20
    WHEN f.porcentaje_pagos_puntual >= 85 THEN 16
    WHEN f.porcentaje_pagos_puntual >= 70 THEN 12
    WHEN f.porcentaje_pagos_puntual >= 50 THEN 7
    WHEN f.porcentaje_pagos_puntual >= 30 THEN 3
    ELSE 0
  END;

  -- BLOQUE C: Capacidad de pago (máx 25 pts)
  v_score := v_score + CASE
    WHEN f.capacidad_pago >= 3000 THEN 25
    WHEN f.capacidad_pago >= 1500 THEN 20
    WHEN f.capacidad_pago >= 800  THEN 15
    WHEN f.capacidad_pago >= 400  THEN 9
    WHEN f.capacidad_pago >= 100  THEN 4
    ELSE 0
  END;

  -- BLOQUE D: Ratio deuda/ingreso (máx 15 pts)
  v_score := v_score + CASE
    WHEN f.ratio_deuda_ingreso <= 0.3  THEN 15
    WHEN f.ratio_deuda_ingreso <= 0.5  THEN 12
    WHEN f.ratio_deuda_ingreso <= 0.7  THEN 8
    WHEN f.ratio_deuda_ingreso <= 1.0  THEN 4
    WHEN f.ratio_deuda_ingreso <= 1.5  THEN 2
    ELSE 0
  END;

  -- BLOQUE E: Antigüedad del negocio (máx 10 pts)
  v_score := v_score + CASE
    WHEN f.antiguedad_meses >= 60 THEN 10
    WHEN f.antiguedad_meses >= 36 THEN 8
    WHEN f.antiguedad_meses >= 24 THEN 6
    WHEN f.antiguedad_meses >= 12 THEN 4
    WHEN f.antiguedad_meses >= 6  THEN 2
    ELSE 0
  END;

  -- BLOQUE F: Estabilidad transaccional (máx 10 pts)
  v_score := v_score + CASE
    WHEN f.variabilidad_saldo <= 0.1  THEN 10
    WHEN f.variabilidad_saldo <= 0.25 THEN 8
    WHEN f.variabilidad_saldo <= 0.5  THEN 5
    WHEN f.variabilidad_saldo <= 0.8  THEN 2
    ELSE 0
  END;

  v_score := ROUND(LEAST(v_score * 100.0 / 95.0, 100), 2);

  SELECT
    CASE
      WHEN v_score >= 85 THEN 'A'
      WHEN v_score >= 70 THEN 'B'
      WHEN v_score >= 50 THEN 'C'
      WHEN v_score >= 30 THEN 'D'
      ELSE 'E'
    END,
    CASE
      WHEN v_score >= 85 THEN 'pre_aprobado_inmediato'
      WHEN v_score >= 70 THEN 'aprobacion_rapida'
      WHEN v_score >= 50 THEN 'evaluar_con_garantias'
      WHEN v_score >= 30 THEN 'requiere_comite'
      ELSE 'rechazar'
    END,
    CASE
      WHEN v_score >= 85 THEN ROUND(f.capacidad_pago * 12 * 0.7, 0)
      WHEN v_score >= 70 THEN ROUND(f.capacidad_pago * 12 * 0.5, 0)
      WHEN v_score >= 50 THEN ROUND(f.capacidad_pago * 12 * 0.3, 0)
      ELSE 0
    END
  INTO v_segmento, v_recomendacion, v_monto_max;

  INSERT INTO public.scores_crediticios (
    user_id, score, segmento, recomendacion, monto_max_sugerido,
    modelo_version, calculado_at
  )
  VALUES (
    p_user_id, v_score, v_segmento, v_recomendacion, v_monto_max,
    'v1.0_reglas_bbva', NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    score              = EXCLUDED.score,
    segmento           = EXCLUDED.segmento,
    recomendacion      = EXCLUDED.recomendacion,
    monto_max_sugerido = EXCLUDED.monto_max_sugerido,
    modelo_version     = EXCLUDED.modelo_version,
    calculado_at       = NOW();

  UPDATE public.perfiles_clientes
     SET puntaje_crediticio = v_score,
         updated_at = NOW()
   WHERE user_id = p_user_id;

  RETURN v_score;
END;
$$;

-- ============================================================
-- FUNCIÓN 3: evaluar_credito_campo(ficha_id, monto, plazo)
-- Llamada desde la app Flutter al completar una ficha
-- ============================================================
CREATE OR REPLACE FUNCTION public.evaluar_credito_campo(
  p_ficha_id     UUID,
  p_monto        NUMERIC(12,2),
  p_plazo_meses  INT DEFAULT 12
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_cliente_id  UUID;
  v_score       NUMERIC(5,2);
  v_segmento    TEXT;
  v_recomend    TEXT;
  v_monto_max   NUMERIC(12,2);
  v_tem         NUMERIC(6,4) := 1.5;
  v_cuota       NUMERIC(10,2);
  v_resultado   JSONB;
BEGIN
  SELECT cliente_user_id INTO v_cliente_id
    FROM public.fichas_campo
   WHERE id = p_ficha_id;

  IF v_cliente_id IS NULL THEN
    RETURN jsonb_build_object(
      'exito', FALSE,
      'mensaje', 'La ficha no tiene cliente asociado. Registre primero el prospecto.',
      'codigo', 'SIN_CLIENTE'
    );
  END IF;

  v_score := public.calcular_score_crediticio(v_cliente_id);

  SELECT segmento, recomendacion, monto_max_sugerido
    INTO v_segmento, v_recomend, v_monto_max
    FROM public.scores_crediticios
   WHERE user_id = v_cliente_id;

  v_cuota := ROUND(
    p_monto
    * ((v_tem/100) * POWER(1 + v_tem/100, p_plazo_meses))
    / (POWER(1 + v_tem/100, p_plazo_meses) - 1)
  , 2);

  IF v_score >= 50 AND p_monto <= v_monto_max THEN
    INSERT INTO public.creditos_preaprobados (
      ficha_id, cliente_user_id, ejecutivo_id,
      monto_preaprobado, plazo_meses, tasa_mensual,
      score_aprobacion, estado, vigente_hasta
    )
    SELECT
      p_ficha_id, v_cliente_id, ejecutivo_id,
      p_monto, p_plazo_meses, v_tem,
      v_score,
      CASE WHEN v_score >= 85 THEN 'pre-aprobado'
           ELSE 'en_comite' END,
      CURRENT_DATE + INTERVAL '30 days'
    FROM public.fichas_campo WHERE id = p_ficha_id
    ON CONFLICT DO NOTHING;

    UPDATE public.fichas_campo
       SET estado_ficha = 'completada',
           score_obtenido = v_score,
           monto_solicitado = p_monto
     WHERE id = p_ficha_id;
  END IF;

  v_resultado := jsonb_build_object(
    'exito',       TRUE,
    'score',       v_score,
    'segmento',    v_segmento,
    'decision',    v_recomend,
    'monto_solicitado', p_monto,
    'monto_max_aprobable', v_monto_max,
    'cuota_mensual', v_cuota,
    'plazo_meses', p_plazo_meses,
    'tem_aplicada', v_tem,
    'aprobacion_inmediata', (v_score >= 85 AND p_monto <= v_monto_max),
    'mensaje', CASE
      WHEN v_score >= 85 AND p_monto <= v_monto_max
        THEN 'APROBADO BBVA: El crédito puede desembolsarse hoy. Cliente notificado.'
      WHEN v_score >= 70
        THEN 'EN REVISIÓN BBVA: Pasa a aprobación rápida (mismo día).'
      WHEN v_score >= 50
        THEN 'PENDIENTE BBVA: Requiere evaluación con garantías adicionales.'
      ELSE
        'NO VIABLE BBVA: Score insuficiente. Sugiera mejora de perfil.'
    END
  );

  RETURN v_resultado;
END;
$$;

-- ============================================================
-- VISTAS OPERATIVAS BBVA
-- ============================================================

-- Vista: Agenda del ejecutivo (pantalla de inicio)
CREATE OR REPLACE VIEW public.vw_agenda_ejecutivo AS
SELECT
  ue.id           AS ejecutivo_id,
  ue.nombre || ' ' || ue.apellido AS ejecutivo,
  fc.id           AS ficha_id,
  fc.tipo_visita,
  fc.negocio_nombre,
  fc.distrito,
  COALESCE(pc.nombres || ' ' || pc.apellidos, fc.prospecto_nombre) AS cliente,
  fc.monto_solicitado,
  fc.score_obtenido,
  sc.segmento,
  fc.estado_ficha,
  fc.creada_offline,
  fc.created_at::DATE AS fecha_visita
FROM public.fichas_campo fc
JOIN public.usuarios_app ue ON ue.id = fc.ejecutivo_id
LEFT JOIN public.usuarios_app uc ON uc.id = fc.cliente_user_id
LEFT JOIN public.perfiles_clientes pc ON pc.user_id = fc.cliente_user_id
LEFT JOIN public.scores_crediticios sc ON sc.user_id = fc.cliente_user_id;

-- Vista: Embudo de colocación BBVA
CREATE OR REPLACE VIEW public.vw_embudo_colocacion_bbva AS
SELECT
  ue.nombre || ' ' || ue.apellido AS ejecutivo,
  COUNT(fc.id)                    AS fichas_total,
  COUNT(fc.id) FILTER (WHERE fc.estado_ficha = 'completada')  AS completadas,
  COUNT(fc.id) FILTER (WHERE fc.estado_ficha = 'sincronizada') AS sincronizadas,
  COUNT(cp.id)                                                  AS pre_aprobados,
  COUNT(cp.id) FILTER (WHERE cp.estado = 'aprobado')           AS aprobados,
  COUNT(cp.id) FILTER (WHERE cp.estado = 'desembolsado')       AS desembolsados,
  COALESCE(SUM(cp.monto_preaprobado) FILTER (
    WHERE cp.estado = 'desembolsado'), 0)                       AS monto_desembolsado
FROM public.usuarios_app ue
LEFT JOIN public.fichas_campo fc      ON fc.ejecutivo_id = ue.id
LEFT JOIN public.creditos_preaprobados cp ON cp.ejecutivo_id = ue.id
WHERE ue.rol = 'ejecutivo'
GROUP BY ue.id, ue.nombre, ue.apellido;

-- Vista: Renovaciones pendientes BBVA
CREATE OR REPLACE VIEW public.vw_renovaciones_pendientes_bbva AS
SELECT
  pc.nombres || ' ' || pc.apellidos  AS cliente,
  pc.tipo_negocio,
  pc.zona_negocio,
  sc.score,
  sc.segmento,
  sc.monto_max_sugerido,
  sc.recomendacion,
  cp.estado                          AS estado_credito,
  cp.vigente_hasta,
  ue.nombre || ' ' || ue.apellido    AS ejecutivo_asignado
FROM public.creditos_preaprobados cp
JOIN public.perfiles_clientes pc    ON pc.user_id = cp.cliente_user_id
JOIN public.scores_crediticios sc   ON sc.user_id = cp.cliente_user_id
JOIN public.usuarios_app ue         ON ue.id = cp.ejecutivo_id
WHERE cp.estado IN ('pre-aprobado','en_comite')
  AND cp.vigente_hasta >= CURRENT_DATE
ORDER BY sc.score DESC;

-- ============================================================
-- Verificación final
-- ============================================================
SELECT
  'TABLAS' AS tipo, table_name AS nombre
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'perfiles_clientes','movimientos_mensuales',
    'features_scoring','scores_crediticios',
    'fichas_campo','creditos_preaprobados'
  )
UNION ALL
SELECT 'VISTAS', table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
    'vw_agenda_ejecutivo','vw_embudo_colocacion_bbva','vw_renovaciones_pendientes_bbva'
  )
UNION ALL
SELECT 'FUNCIONES', routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'calcular_features_scoring',
    'calcular_score_crediticio',
    'evaluar_credito_campo'
  )
ORDER BY tipo, nombre;

-- ============================================================
-- FIN — 01_scoring_bbva.sql · v1.0
-- Siguiente: ejecutar 02_sucursales_ejecutivos_bbva.sql
-- ============================================================
