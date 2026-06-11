-- ============================================================
-- SCRIPT 02 — Scoring BBVA: Funciones y Vistas
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 3ro de 7 (despues de 01_cartera_solicitudes.sql)
-- ============================================================

-- ── Limpieza de funciones ─────────────────────────────────
DROP FUNCTION IF EXISTS public.calcular_score_crediticio(UUID);
DROP FUNCTION IF EXISTS public.calcular_features_scoring(UUID);
DROP FUNCTION IF EXISTS public.calcular_prioridad_cartera(UUID, DATE);
DROP VIEW IF EXISTS public.vw_cartera_completa;
DROP VIEW IF EXISTS public.vw_scores_detalle;
DROP VIEW IF EXISTS public.vw_renovaciones_pendientes_bbva;

-- ============================================================
-- FUNCION 1: calcular_features_scoring(cliente_id)
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_features_scoring(p_cliente_id UUID)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
  v_ingreso    NUMERIC(12,2);
  v_gasto      NUMERIC(12,2);
  v_deuda      NUMERIC(12,2);
  v_antiguedad INTEGER;
BEGIN
  SELECT COALESCE(AVG(saldo_promedio), 0) INTO v_ingreso
  FROM public.movimientos_mensuales
  WHERE cliente_id = p_cliente_id AND periodo >= TO_CHAR(NOW() - INTERVAL '3 months', 'YYYY-MM');

  SELECT COALESCE(ingresos_estimados, 0), COALESCE(gastos_mensuales, 0),
         COALESCE(deuda_actual, 0), COALESCE(antiguedad_negocio_meses, 0)
  INTO v_ingreso, v_gasto, v_deuda, v_antiguedad
  FROM public.clientes WHERE id = p_cliente_id;

  INSERT INTO public.features_scoring (cliente_id, promedio_saldo_3m, capacidad_pago, antiguedad_meses, calculado_at)
  VALUES (p_cliente_id, v_ingreso, GREATEST(v_ingreso - v_gasto, 0), v_antiguedad, NOW())
  ON CONFLICT (cliente_id) DO UPDATE SET
    promedio_saldo_3m = EXCLUDED.promedio_saldo_3m,
    capacidad_pago    = EXCLUDED.capacidad_pago,
    antiguedad_meses  = EXCLUDED.antiguedad_meses,
    calculado_at      = NOW();
END;
$$;

-- ============================================================
-- FUNCION 2: calcular_score_crediticio(cliente_id)
-- Motor de scoring por reglas BBVA v2.0
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_score_crediticio(p_cliente_id UUID)
RETURNS NUMERIC(5,2)
LANGUAGE plpgsql AS $$
DECLARE
  v_score     NUMERIC(5,2) := 0;
  v_segmento  TEXT;
  v_monto_max NUMERIC(12,2);
  f           public.features_scoring%ROWTYPE;
  c           public.clientes%ROWTYPE;
BEGIN
  PERFORM public.calcular_features_scoring(p_cliente_id);

  SELECT * INTO f FROM public.features_scoring WHERE cliente_id = p_cliente_id;
  SELECT * INTO c FROM public.clientes WHERE id = p_cliente_id;

  IF NOT FOUND THEN RETURN 0; END IF;

  -- Capacidad de pago (max 35 pts)
  v_score := v_score + CASE
    WHEN f.capacidad_pago >= 3000 THEN 35
    WHEN f.capacidad_pago >= 1500 THEN 28
    WHEN f.capacidad_pago >= 800  THEN 20
    WHEN f.capacidad_pago >= 400  THEN 12
    WHEN f.capacidad_pago >= 100  THEN 5
    ELSE 0
  END;

  -- Antiguedad (max 15 pts)
  v_score := v_score + CASE
    WHEN f.antiguedad_meses >= 60 THEN 15
    WHEN f.antiguedad_meses >= 36 THEN 12
    WHEN f.antiguedad_meses >= 24 THEN 9
    WHEN f.antiguedad_meses >= 12 THEN 6
    WHEN f.antiguedad_meses >= 6  THEN 3
    ELSE 0
  END;

  -- Saldo promedio (max 20 pts)
  v_score := v_score + CASE
    WHEN f.promedio_saldo_3m >= 5000 THEN 20
    WHEN f.promedio_saldo_3m >= 2000 THEN 15
    WHEN f.promedio_saldo_3m >= 1000 THEN 10
    WHEN f.promedio_saldo_3m >= 500  THEN 5
    ELSE 0
  END;

  -- Calificacion SBS (max 30 pts)
  v_score := v_score + CASE c.calificacion_sbs
    WHEN 'Normal'        THEN 30
    WHEN 'CPP'           THEN 15
    WHEN 'Deficiente'    THEN 5
    WHEN 'Dudoso'        THEN 0
    WHEN 'Perdida'       THEN 0
    WHEN 'Sin_Historial' THEN 20
    ELSE 0
  END;

  v_score := ROUND(LEAST(v_score, 100), 2);

  SELECT CASE
    WHEN v_score >= 85 THEN 'A'
    WHEN v_score >= 70 THEN 'B'
    WHEN v_score >= 50 THEN 'C'
    WHEN v_score >= 30 THEN 'D'
    ELSE 'E'
  END INTO v_segmento;

  SELECT CASE
    WHEN v_score >= 85 THEN ROUND(f.capacidad_pago * 12 * 0.7, 0)
    WHEN v_score >= 70 THEN ROUND(f.capacidad_pago * 12 * 0.5, 0)
    WHEN v_score >= 50 THEN ROUND(f.capacidad_pago * 12 * 0.3, 0)
    ELSE 0
  END INTO v_monto_max;

  INSERT INTO public.scores_crediticios (cliente_id, score, segmento, monto_max_sugerido, nivel_confianza, modelo_version, calculado_at)
  VALUES (p_cliente_id, v_score, v_segmento, v_monto_max, ROUND(v_score)::INT, 'v2.0_bbva', NOW())
  ON CONFLICT (cliente_id) DO UPDATE SET
    score = EXCLUDED.score, segmento = EXCLUDED.segmento,
    monto_max_sugerido = EXCLUDED.monto_max_sugerido,
    nivel_confianza = EXCLUDED.nivel_confianza,
    calculado_at = NOW();

  UPDATE public.perfiles_clientes SET puntaje_crediticio = v_score, updated_at = NOW()
  WHERE cliente_id = p_cliente_id;

  RETURN v_score;
END;
$$;

-- ============================================================
-- FUNCION 3: calcular_prioridad_cartera(asesor_id, fecha)
-- Asigna score de prioridad (0-100) a cada cliente en cartera
-- ============================================================
CREATE OR REPLACE FUNCTION public.calcular_prioridad_cartera(
  p_asesor_id UUID, p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(cliente_id UUID, score_prioridad INTEGER, prioridad VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    GREATEST(LEAST(
      CASE WHEN cr.estado = 'vencido' THEN 40 + LEAST(cr.cuotas_mora * 5, 30) ELSE 0 END
      + CASE WHEN cp.monto_maximo > 5000 THEN 35 WHEN cp.monto_maximo > 0 THEN 20 ELSE 0 END
      + CASE WHEN cd.tipo_gestion = 'AMPLIACION' THEN 25 WHEN cd.tipo_gestion = 'SEGUIMIENTO' THEN 10 ELSE 5 END
    , 100), 0)::INTEGER,
    CASE
      WHEN cr.estado = 'vencido' OR cp.monto_maximo > 5000 THEN 'alta'
      WHEN cp.monto_maximo > 0 THEN 'media'
      ELSE 'normal'
    END
  FROM public.clientes c
  JOIN public.cartera_diaria cd ON cd.cliente_id = c.id AND cd.asesor_id = p_asesor_id AND cd.fecha_asignacion = p_fecha
  LEFT JOIN LATERAL (SELECT * FROM public.creditos WHERE cliente_id = c.id AND estado IN ('vigente','vencido') ORDER BY created_at DESC LIMIT 1) cr ON TRUE
  LEFT JOIN LATERAL (SELECT * FROM public.creditos_preaprobados WHERE cliente_id = c.id AND vigente = TRUE ORDER BY monto_maximo DESC LIMIT 1) cp ON TRUE
  ORDER BY 2 DESC;
END;
$$;

-- ============================================================
-- VISTA: vw_cartera_completa
-- ============================================================
CREATE OR REPLACE VIEW public.vw_cartera_completa AS
SELECT
  cd.id AS cartera_id, cd.asesor_id, cd.cliente_id, cd.fecha_asignacion,
  cd.tipo_gestion, cd.prioridad, cd.score_prioridad, cd.monto_referencial,
  cd.estado_visita, cd.resultado_visita, cd.observacion_visita,
  cd.timestamp_visita, cd.lat_visita, cd.lng_visita, cd.orden_manual,
  cl.nombres || ' ' || cl.apellidos AS cliente_nombre,
  cl.numero_documento, cl.tipo_negocio, cl.nombre_negocio,
  cl.telefono, cl.direccion, cl.lat, cl.lng,
  cl.calificacion_sbs, cl.estado_cliente,
  COALESCE(sc.score, 0) AS score_crediticio,
  COALESCE(sc.segmento, 'N/A') AS segmento,
  cp.monto_maximo AS monto_preaprobado, cp.plazo_sugerido_meses,
  ag.nombre AS agencia_nombre,
  an.nombres || ' ' || an.apellidos AS asesor_nombre
FROM public.cartera_diaria cd
JOIN public.clientes cl ON cl.id = cd.cliente_id
JOIN public.asesores_negocio an ON an.id = cd.asesor_id
JOIN public.agencias ag ON ag.id = cd.agencia_id
LEFT JOIN public.scores_crediticios sc ON sc.cliente_id = cd.cliente_id
LEFT JOIN LATERAL (
  SELECT * FROM public.creditos_preaprobados
  WHERE cliente_id = cd.cliente_id AND vigente = TRUE
  ORDER BY monto_maximo DESC LIMIT 1
) cp ON TRUE;

-- ============================================================
-- VISTA: vw_scores_detalle
-- ============================================================
CREATE OR REPLACE VIEW public.vw_scores_detalle AS
SELECT
  cl.nombres || ' ' || cl.apellidos AS cliente,
  cl.numero_documento, cl.tipo_negocio, cl.calificacion_sbs,
  sc.score, sc.segmento, sc.recomendacion, sc.monto_max_sugerido,
  sc.nivel_confianza, sc.calculado_at,
  cp.monto_maximo AS preaprobado_monto
FROM public.scores_crediticios sc
JOIN public.clientes cl ON cl.id = sc.cliente_id
LEFT JOIN public.creditos_preaprobados cp ON cp.cliente_id = sc.cliente_id AND cp.vigente = TRUE;

-- ============================================================
-- VISTA: vw_renovaciones_pendientes_bbva
-- ============================================================
CREATE OR REPLACE VIEW public.vw_renovaciones_pendientes_bbva AS
SELECT
  cl.nombres || ' ' || cl.apellidos AS cliente,
  cl.tipo_negocio, cl.calificacion_sbs,
  sc.score, sc.segmento, sc.monto_max_sugerido,
  cp.vigente, cp.fecha_vencimiento,
  an.nombres || ' ' || an.apellidos AS ejecutivo_asignado
FROM public.creditos_preaprobados cp
JOIN public.clientes cl ON cl.id = cp.cliente_id
JOIN public.scores_crediticios sc ON sc.cliente_id = cp.cliente_id
JOIN public.asesores_negocio an ON an.id = cp.asesor_id
WHERE cp.vigente = TRUE AND cp.fecha_vencimiento >= CURRENT_DATE
ORDER BY sc.score DESC;

-- ============================================================
-- FIN — 02_scoring_funciones_bbva.sql
-- Siguiente: 03_buro_cobranza.sql
-- ============================================================
