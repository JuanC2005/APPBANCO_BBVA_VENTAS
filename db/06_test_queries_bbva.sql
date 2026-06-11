-- ============================================================
-- SCRIPT 06 — Tests de Validación BBVA v2.0
-- App Móvil BBVA Fuerza de Ventas
-- ============================================================
-- EJECUTAR: Opcional (validación)
-- ============================================================

-- TEST 1: Distribución de scores
SELECT segmento, COUNT(*), ROUND(AVG(score),1) AS avg_score,
  MIN(score), MAX(score), ROUND(AVG(monto_max_sugerido)) AS avg_monto
FROM public.scores_crediticios GROUP BY segmento ORDER BY segmento;

-- TEST 2: Cartera de hoy con prioridad
SELECT cl.nombres||' '||cl.apellidos AS cliente, cd.tipo_gestion,
  cd.prioridad, cd.score_prioridad, cd.estado_visita
FROM public.cartera_diaria cd
JOIN public.clientes cl ON cl.id = cd.cliente_id
WHERE cd.fecha_asignacion = CURRENT_DATE
ORDER BY cd.score_prioridad DESC;

-- TEST 3: Simular scoring
SELECT 'Cliente Rosa Condori' AS caso,
  public.calcular_score_crediticio('cccccccc-0001-0001-0001-000000000001') AS score;

SELECT 'Cliente Efraín Ramos' AS caso,
  public.calcular_score_crediticio('cccccccc-0001-0001-0001-000000000006') AS score;

-- TEST 4: Resumen de validación
SELECT 'Agencias' AS metrica, COUNT(*)::TEXT FROM public.agencias
UNION ALL SELECT 'Asesores activos', COUNT(*)::TEXT FROM public.asesores_negocio WHERE activo
UNION ALL SELECT 'Clientes', COUNT(*)::TEXT FROM public.clientes
UNION ALL SELECT 'Créditos', COUNT(*)::TEXT FROM public.creditos
UNION ALL SELECT 'Pre-aprobados vigentes', COUNT(*)::TEXT FROM public.creditos_preaprobados WHERE vigente
UNION ALL SELECT 'Cartera hoy', COUNT(*)::TEXT FROM public.cartera_diaria WHERE fecha_asignacion = CURRENT_DATE
UNION ALL SELECT 'Scores calculados', COUNT(*)::TEXT FROM public.scores_crediticios
ORDER BY metrica;

-- TEST 5: Pre-aprobados vigentes
SELECT * FROM public.vw_renovaciones_pendientes_bbva LIMIT 10;

-- ============================================================
-- FIN — 06_test_queries_bbva.sql
-- ============================================================
