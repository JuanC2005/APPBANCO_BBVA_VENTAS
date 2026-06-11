-- ============================================================
-- SCRIPT 07 — Vincular asesores con usuarios Supabase Auth
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 7mo (último) — DESPUÉS de crear usuarios en
--   Supabase Dashboard > Authentication > Users
-- ============================================================
-- INSTRUCCIONES:
-- 1. Ir a Supabase Dashboard → Authentication → Users
-- 2. Crear usuarios con estos mismos emails:
--      admin@bbva.pe          (ADM-001)
--      jessica.quispe@bbva.pe (EJE-001)
--      mario.ccanto@bbva.pe   (EJE-002)
--      lucia.palomino@bbva.pe (EJE-003)
--      david.asto@bbva.pe     (EJE-004)
-- 3. Ejecutar este script para vincular automáticamente
-- ============================================================

UPDATE public.asesores_negocio an
SET user_id = au.id
FROM auth.users au
WHERE au.email = an.email
  AND an.user_id IS NULL;

-- Verificar resultados
SELECT an.codigo_empleado, an.nombres, an.apellidos, an.email,
       CASE WHEN an.user_id IS NOT NULL THEN '✅ Vinculado' ELSE '❌ Sin vincular' END AS estado
FROM public.asesores_negocio an
ORDER BY an.codigo_empleado;

-- ============================================================
-- FIN — 07_link_auth_users.sql
-- ============================================================
