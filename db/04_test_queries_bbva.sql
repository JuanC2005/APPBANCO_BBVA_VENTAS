-- ============================================================
-- SCRIPT 04 — Tests y Consultas de Validación BBVA
-- App Móvil BBVA Fuerza de Ventas · v1.0
-- ============================================================
-- EJECUTAR: 5to de 5 (después de 03_seed_demo_bbva.sql)
-- TIEMPO ESTIMADO: < 5 segundos
-- DB: bd_appbanco_bbva_ventas
-- ============================================================

-- ════════════════════════════════════════════════════════════
-- TEST 1 — Distribución de scores BBVA
-- ════════════════════════════════════════════════════════════
SELECT
  sc.segmento,
  COUNT(*) AS clientes,
  ROUND(AVG(sc.score), 1) AS score_promedio,
  MIN(sc.score) AS score_min,
  MAX(sc.score) AS score_max,
  ROUND(AVG(sc.monto_max_sugerido)) AS monto_max_prom
FROM public.scores_crediticios sc
GROUP BY sc.segmento
ORDER BY sc.segmento;

-- Detalle por cliente
SELECT
  pc.nombres || ' ' || pc.apellidos  AS cliente,
  pc.tipo_negocio,
  pc.zona_negocio,
  pc.ingreso_mensual_est,
  pc.deuda_actual,
  sc.score,
  sc.segmento,
  sc.recomendacion,
  sc.monto_max_sugerido
FROM public.scores_crediticios sc
JOIN public.perfiles_clientes pc ON pc.user_id = sc.user_id
ORDER BY sc.score DESC;

-- ════════════════════════════════════════════════════════════
-- TEST 2 — Simular llamada desde la app móvil
-- evaluar_credito_campo(ficha_id, monto, plazo)
-- ════════════════════════════════════════════════════════════

-- CASO A: Rosa Condori — S/ 8,000 a 12 meses
SELECT 'Rosa Condori — S/ 8,000 / 12 meses' AS caso,
  public.evaluar_credito_campo(
    'eeeeeeee-0001-0001-0001-000000000001'::UUID,
    8000, 12
  ) AS resultado_json;

-- CASO B: Juan Huanca — S/ 25,000 a 18 meses
SELECT 'Juan Huanca — S/ 25,000 / 18 meses' AS caso,
  public.evaluar_credito_campo(
    'eeeeeeee-0001-0001-0001-000000000002'::UUID,
    25000, 18
  ) AS resultado_json;

-- CASO C: Flora Ayala — S/ 5,000 a 12 meses
SELECT 'Flora Ayala — S/ 5,000 / 12 meses' AS caso,
  public.evaluar_credito_campo(
    'eeeeeeee-0001-0001-0001-000000000004'::UUID,
    5000, 12
  ) AS resultado_json;

-- CASO D: Efraín Ramos — S/ 18,000 a 24 meses
SELECT 'Efraín Ramos — S/ 18,000 / 24 meses' AS caso,
  public.evaluar_credito_campo(
    'eeeeeeee-0001-0001-0001-000000000005'::UUID,
    18000, 24
  ) AS resultado_json;

-- ════════════════════════════════════════════════════════════
-- TEST 3 — Vista Agenda del Ejecutivo BBVA
-- (Jessica Quispe — EJE-001)
-- ════════════════════════════════════════════════════════════
SELECT
  ejecutivo,
  tipo_visita,
  cliente,
  negocio_nombre,
  distrito,
  monto_solicitado,
  score_obtenido,
  segmento,
  estado_ficha,
  CASE WHEN creada_offline THEN '📴 offline' ELSE '🌐 online' END AS modo_captura
FROM public.vw_agenda_ejecutivo
WHERE ejecutivo_id = 'bbbbbbbb-0001-0001-0001-000000000002'
ORDER BY fecha_visita DESC;

-- ════════════════════════════════════════════════════════════
-- TEST 4 — Embudo de Colocación BBVA (Dashboard)
-- ════════════════════════════════════════════════════════════
SELECT
  ejecutivo,
  fichas_total,
  completadas,
  pre_aprobados,
  aprobados,
  desembolsados,
  TO_CHAR(monto_desembolsado,'FM999,990.00') AS monto_soles
FROM public.vw_embudo_colocacion_bbva;

-- ════════════════════════════════════════════════════════════
-- TEST 5 — Renovaciones pendientes BBVA
-- ════════════════════════════════════════════════════════════
SELECT
  cliente,
  tipo_negocio,
  zona_negocio,
  score,
  segmento,
  TO_CHAR(monto_max_sugerido, 'FM999,990') AS monto_max_soles,
  recomendacion,
  estado_credito,
  ejecutivo_asignado,
  vigente_hasta
FROM public.vw_renovaciones_pendientes_bbva
LIMIT 10;

-- ════════════════════════════════════════════════════════════
-- TEST 6 — Query para Power BI (Dashboard BBVA)
-- ════════════════════════════════════════════════════════════
-- Colocaciones por ejecutivo y sucursal
SELECT
  sb.nombre AS sucursal,
  ua.nombre || ' ' || ua.apellido AS ejecutivo,
  en.especialidad,
  me.periodo,
  me.meta_visitas, me.real_visitas, me.pct_visitas,
  me.meta_creditos, me.real_creditos, me.pct_creditos,
  TO_CHAR(me.meta_monto, 'FM999,990') AS meta_monto_soles,
  TO_CHAR(me.real_monto, 'FM999,990') AS real_monto_soles,
  me.pct_monto
FROM public.metas_ejecutivos me
JOIN public.ejecutivos_negocio en ON en.id = me.ejecutivo_id
JOIN public.usuarios_app ua       ON ua.id = en.user_id
JOIN public.sucursales_bbva sb    ON sb.id = en.sucursal_id
ORDER BY me.pct_monto DESC;

-- Score por zona (mapa de calor Power BI)
SELECT
  pc.zona_negocio,
  pc.tipo_negocio,
  COUNT(*) AS clientes,
  ROUND(AVG(sc.score), 1) AS score_promedio,
  COUNT(*) FILTER (WHERE sc.segmento IN ('A','B')) AS clientes_premium,
  ROUND(AVG(sc.monto_max_sugerido)) AS monto_potencial_prom
FROM public.scores_crediticios sc
JOIN public.perfiles_clientes pc ON pc.user_id = sc.user_id
GROUP BY pc.zona_negocio, pc.tipo_negocio
ORDER BY score_promedio DESC;

-- ════════════════════════════════════════════════════════════
-- TEST 7 — Validar fórmula de cuota (sistema francés)
-- ════════════════════════════════════════════════════════════
SELECT
  pc.nombres || ' ' || pc.apellidos AS cliente,
  cp.monto_preaprobado,
  cp.plazo_meses,
  cp.tasa_mensual || '%' AS TEM,
  cp.cuota_estimada       AS cuota_calculada_SQL,
  ROUND(
    cp.monto_preaprobado
    * ((cp.tasa_mensual/100) * POWER(1 + cp.tasa_mensual/100, cp.plazo_meses))
    / (POWER(1 + cp.tasa_mensual/100, cp.plazo_meses) - 1)
  , 2) AS cuota_verificacion,
  cp.score_aprobacion,
  cp.producto_bbva,
  cp.estado,
  cp.vigente_hasta
FROM public.creditos_preaprobados cp
JOIN public.perfiles_clientes pc ON pc.user_id = cp.cliente_user_id
ORDER BY cp.score_aprobacion DESC;

-- ════════════════════════════════════════════════════════════
-- RESUMEN DE VALIDACIÓN
-- ════════════════════════════════════════════════════════════
WITH resumen AS (
  SELECT 'Usuarios totales'         AS metrica, COUNT(*)::TEXT AS valor FROM public.usuarios_app
  UNION ALL SELECT 'Ejecutivos activos',   COUNT(*)::TEXT FROM public.ejecutivos_negocio WHERE activo
  UNION ALL SELECT 'Sucursales activas',   COUNT(*)::TEXT FROM public.sucursales_bbva WHERE activa
  UNION ALL SELECT 'Clientes con perfil',  COUNT(*)::TEXT FROM public.perfiles_clientes
  UNION ALL SELECT 'Clientes con score',   COUNT(*)::TEXT FROM public.scores_crediticios
  UNION ALL SELECT 'Fichas de campo',      COUNT(*)::TEXT FROM public.fichas_campo
  UNION ALL SELECT 'Fichas offline sync',  COUNT(*)::TEXT FROM public.fichas_campo WHERE creada_offline
  UNION ALL SELECT 'Pre-aprobados',        COUNT(*)::TEXT FROM public.creditos_preaprobados
  UNION ALL SELECT 'Rutas hoy',            COUNT(*)::TEXT FROM public.rutas_planificadas WHERE fecha_ruta = CURRENT_DATE
  UNION ALL SELECT 'Movim. históricos',    COUNT(*)::TEXT FROM public.movimientos_mensuales
)
SELECT metrica, valor FROM resumen;

-- ============================================================
-- FIN — 04_test_queries_bbva.sql · v1.0
--
-- ✅ Si todos los tests retornan filas: BD lista para la app móvil BBVA
-- 📱 Conectar desde Supabase usando credentials del proyecto
--    Host: provisto por Supabase  |  DB: bd_appbanco_bbva_ventas
-- ============================================================
