-- ============================================================
-- SCRIPT 08 — Función registrar_asesor (SECURITY DEFINER)
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: 8vo — DESPUÉS de 07_link_auth_users.sql
-- ============================================================

ALTER TABLE public.asesores_negocio ADD COLUMN IF NOT EXISTS telefono TEXT;

CREATE OR REPLACE FUNCTION public.registrar_asesor(
  p_user_id UUID,
  p_email TEXT,
  p_nombres TEXT,
  p_apellidos TEXT,
  p_telefono TEXT,
  p_agencia_id UUID
) RETURNS TEXT
  SECURITY DEFINER
  LANGUAGE plpgsql
  AS $$
DECLARE
  v_codigo TEXT;
  v_next_num INTEGER;
BEGIN
  SELECT COALESCE(
    (SELECT MAX(CAST(SUBSTRING(codigo_empleado FROM 5) AS INTEGER))
     FROM public.asesores_negocio
     WHERE codigo_empleado ~ '^USR-\d{3}$'),
    0
  ) + 1 INTO v_next_num;

  v_codigo := 'USR-' || LPAD(v_next_num::TEXT, 3, '0');

  INSERT INTO public.asesores_negocio
    (user_id, codigo_empleado, nombres, apellidos, email, telefono, agencia_id, perfil, activo)
  VALUES
    (p_user_id, v_codigo, p_nombres, p_apellidos, p_email, p_telefono, p_agencia_id, 'operador', true);

  RETURN v_codigo;
END;
$$;

-- ============================================================
-- FIN — 08_registrar_asesor.sql
-- ============================================================
