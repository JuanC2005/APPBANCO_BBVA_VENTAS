-- ============================================================
-- SCRIPT 10 — Campañas de Marketing + Notificaciones Push
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: Último (después de 00–09)
-- ============================================================
-- NUEVAS TABLAS: campanas, campanas_asesores, notificaciones_push
-- Dependencias: asesores_negocio (token_fcm)
-- ============================================================

-- ── Limpieza segura ─────────────────────────────────────────
DROP TABLE IF EXISTS public.notificaciones_push    CASCADE;
DROP TABLE IF EXISTS public.campanas_asesores      CASCADE;
DROP TABLE IF EXISTS public.campanas               CASCADE;

-- ============================================================
-- 1. CAMPANAS — Campañas de marketing / cobranza
-- ============================================================
CREATE TABLE public.campanas (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo              TEXT        NOT NULL,
  mensaje             TEXT        NOT NULL,
  tipo                TEXT        NOT NULL DEFAULT 'marketing'
                                  CHECK (tipo IN ('marketing','cobranza','capacitacion','informativa')),
  segmento_objetivo   TEXT        NOT NULL DEFAULT 'TODOS'
                                  CHECK (segmento_objetivo IN ('A','B','C','D','E','TODOS')),
  producto_sugerido   TEXT,
  fecha_inicio        DATE        NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin           DATE,
  activa              BOOLEAN     NOT NULL DEFAULT TRUE,
  creado_por          UUID        NOT NULL REFERENCES public.asesores_negocio(id),
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. CAMPANAS_ASESORES — Asignación / lectura por asesor
-- ============================================================
CREATE TABLE public.campanas_asesores (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  campana_id          UUID        NOT NULL REFERENCES public.campanas(id) ON DELETE CASCADE,
  asesor_id           UUID        NOT NULL REFERENCES public.asesores_negocio(id) ON DELETE CASCADE,
  leida               BOOLEAN     NOT NULL DEFAULT FALSE,
  leida_at            TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_campana_asesor UNIQUE (campana_id, asesor_id)
);

-- ============================================================
-- 3. NOTIFICACIONES_PUSH — Historial de pushes enviados
-- ============================================================
CREATE TABLE public.notificaciones_push (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  campana_id          UUID        REFERENCES public.campanas(id) ON DELETE SET NULL,
  asesor_id           UUID        NOT NULL REFERENCES public.asesores_negocio(id) ON DELETE CASCADE,
  titulo              TEXT        NOT NULL,
  cuerpo              TEXT        NOT NULL,
  leida               BOOLEAN     NOT NULL DEFAULT FALSE,
  enviada_at          TIMESTAMPTZ DEFAULT NOW(),
  leida_at            TIMESTAMPTZ
);

-- ============================================================
-- 4. VISTA: vw_campanas_activas_asesor
--    Campañas activas filtradas por segmento del asesor
-- ============================================================
CREATE OR REPLACE VIEW public.vw_campanas_activas_asesor AS
SELECT
  c.id,
  c.titulo,
  c.mensaje,
  c.tipo,
  c.segmento_objetivo,
  c.producto_sugerido,
  c.fecha_inicio,
  c.fecha_fin,
  c.created_at,
  ca.leida,
  ca.asesor_id
FROM campanas c
LEFT JOIN campanas_asesores ca ON ca.campana_id = c.id
WHERE c.activa = TRUE
  AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_DATE)
  AND (c.fecha_inicio <= CURRENT_DATE);

-- ============================================================
-- 5. FUNCIÓN: asignar_campana_asesores
--    Asigna una campaña a todos los asesores que tengan
--    clientes en el segmento objetivo
-- ============================================================
CREATE OR REPLACE FUNCTION public.asignar_campana_asesores(
  p_campana_id UUID
) RETURNS INTEGER AS $$
DECLARE
  v_segmento TEXT;
  v_count INTEGER;
BEGIN
  SELECT segmento_objetivo INTO v_segmento
  FROM campanas WHERE id = p_campana_id;

  IF v_segmento = 'TODOS' THEN
    INSERT INTO campanas_asesores (campana_id, asesor_id)
    SELECT p_campana_id, id FROM asesores_negocio WHERE activo = TRUE
    ON CONFLICT (campana_id, asesor_id) DO NOTHING;
    GET DIAGNOSTICS v_count = ROW_COUNT;
  ELSE
    INSERT INTO campanas_asesores (campana_id, asesor_id)
    SELECT DISTINCT p_campana_id, cd.asesor_id
    FROM scores_crediticios sc
    JOIN cartera_diaria cd ON cd.cliente_id = sc.cliente_id
    WHERE sc.segmento = v_segmento
      AND cd.fecha_asignacion = CURRENT_DATE
    ON CONFLICT (campana_id, asesor_id) DO NOTHING;
    GET DIAGNOSTICS v_count = ROW_COUNT;
  END IF;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 6. RLS POLICIES
-- ============================================================
ALTER TABLE public.campanas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campanas_asesores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones_push ENABLE ROW LEVEL SECURITY;

-- Administradores y supervisores pueden todo en campanas
CREATE POLICY "admins_full_campanas" ON public.campanas
  FOR ALL USING (
    EXISTS (SELECT 1 FROM asesores_negocio
            WHERE id = auth.uid() AND perfil IN ('administrador','supervisor'))
  );

-- Operadores solo lectura de campanas activas
CREATE POLICY "operadores_read_campanas" ON public.campanas
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM asesores_negocio
            WHERE id = auth.uid() AND perfil = 'operador')
  );

-- Lectura de asignaciones para el propio asesor
CREATE POLICY "asesor_read_own_assignments" ON public.campanas_asesores
  FOR SELECT USING (asesor_id = auth.uid());

-- Lectura de notificaciones para el propio asesor
CREATE POLICY "asesor_read_own_notifications" ON public.notificaciones_push
  FOR SELECT USING (asesor_id = auth.uid());
