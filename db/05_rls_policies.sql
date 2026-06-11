-- ============================================================
-- SCRIPT 05 — RLS Policies Supabase BBVA
-- App Móvil BBVA Fuerza de Ventas · v2.0
-- ============================================================
-- EJECUTAR: Opcional (solo si usas Supabase con RLS)
-- ============================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.agencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.asesores_negocio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creditos_preaprobados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cartera_diaria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_credito ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consultas_buro ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acciones_cobranza ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertas_cartera ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes_notas_internas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fichas_campo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfiles_clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scores_crediticios ENABLE ROW LEVEL SECURITY;

-- ── Helper: obtener asesor_id desde auth.uid() ─────────────
CREATE OR REPLACE FUNCTION public.auth_asesor_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
  SELECT id FROM public.asesores_negocio WHERE user_id = auth.uid();
$$;

-- ── Helper: obtener agencia_id del asesor autenticado ──────
CREATE OR REPLACE FUNCTION public.auth_agencia_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
  SELECT agencia_id FROM public.asesores_negocio WHERE user_id = auth.uid();
$$;

-- ── Helper: obtener perfil del asesor autenticado ──────────
CREATE OR REPLACE FUNCTION public.auth_perfil()
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT perfil FROM public.asesores_negocio WHERE user_id = auth.uid();
$$;

-- ============================================================
-- POLICIES: CARTERA_DIARIA
-- ============================================================
CREATE POLICY "Operador: propia cartera" ON public.cartera_diaria
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Supervisor: cartera de su agencia" ON public.cartera_diaria
  FOR SELECT USING (
    auth_perfil() IN ('supervisor','administrador')
    AND agencia_id = auth_agencia_id()
  );
CREATE POLICY "Admin: toda la cartera" ON public.cartera_diaria
  FOR ALL USING (auth_perfil() = 'administrador');

-- ============================================================
-- POLICIES: CLIENTES
-- ============================================================
CREATE POLICY "Operador: clientes propios" ON public.clientes
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.cartera_diaria WHERE cliente_id = clientes.id AND asesor_id = auth_asesor_id())
  );
CREATE POLICY "Supervisor: clientes de su agencia" ON public.clientes
  FOR SELECT USING (
    auth_perfil() IN ('supervisor','administrador')
    AND EXISTS (SELECT 1 FROM public.cartera_diaria cd
      JOIN public.asesores_negocio an ON an.id = cd.asesor_id
      WHERE cd.cliente_id = clientes.id AND an.agencia_id = auth_agencia_id())
  );
CREATE POLICY "Admin: todos los clientes" ON public.clientes
  FOR ALL USING (auth_perfil() = 'administrador');

-- ============================================================
-- POLICIES: SOLICITUDES_CREDITO
-- ============================================================
CREATE POLICY "Operador: propias solicitudes" ON public.solicitudes_credito
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Supervisor: solicitudes de agencia" ON public.solicitudes_credito
  FOR SELECT USING (
    auth_perfil() IN ('supervisor','administrador')
    AND agencia_id = auth_agencia_id()
  );
CREATE POLICY "Admin: todas" ON public.solicitudes_credito
  FOR ALL USING (auth_perfil() = 'administrador');

-- ============================================================
-- POLICIES: RESTO DE TABLAS (operador solo propio, supervisor agencia, admin todo)
-- ============================================================

-- CREDITOS
CREATE POLICY "Operador: creditos propios" ON public.creditos
  FOR SELECT USING (asesor_id = auth_asesor_id());
CREATE POLICY "Admin: todos los creditos" ON public.creditos
  FOR ALL USING (auth_perfil() = 'administrador');

-- CREDITOS_PREAPROBADOS
CREATE POLICY "Operador: preaprobados propios" ON public.creditos_preaprobados
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Admin: todos" ON public.creditos_preaprobados
  FOR ALL USING (auth_perfil() = 'administrador');

-- CONSULTAS_BURO
CREATE POLICY "Operador: propias consultas" ON public.consultas_buro
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Admin: todas" ON public.consultas_buro
  FOR ALL USING (auth_perfil() = 'administrador');

-- ACCIONES_COBRANZA
CREATE POLICY "Operador: propias acciones" ON public.acciones_cobranza
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Admin: todas" ON public.acciones_cobranza
  FOR ALL USING (auth_perfil() = 'administrador');

-- ALERTAS_CARTERA
CREATE POLICY "Operador: propias alertas" ON public.alertas_cartera
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Admin: todas" ON public.alertas_cartera
  FOR ALL USING (auth_perfil() = 'administrador');

-- SOLICITUDES_NOTAS_INTERNAS
CREATE POLICY "Operador: propias notas" ON public.solicitudes_notas_internas
  FOR ALL USING (asesor_id = auth_asesor_id());
CREATE POLICY "Supervisor: notas de agencia" ON public.solicitudes_notas_internas
  FOR SELECT USING (
    auth_perfil() IN ('supervisor','administrador')
    AND EXISTS (SELECT 1 FROM public.solicitudes_credito sc
      JOIN public.asesores_negocio an ON an.id = sc.asesor_id
      WHERE sc.id = solicitud_id AND an.agencia_id = auth_agencia_id())
  );

-- ASESORES_NEGOCIO (solo lectura para operadores)
CREATE POLICY "Lectura propia" ON public.asesores_negocio
  FOR SELECT USING (user_id = auth.uid() OR auth_perfil() IN ('supervisor','administrador'));
CREATE POLICY "Admin: gestion asesores" ON public.asesores_negocio
  FOR ALL USING (auth_perfil() = 'administrador');

-- AGENCIAS (lectura para todos, escritura solo admin)
CREATE POLICY "Lectura agencias" ON public.agencias
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin: gestion agencias" ON public.agencias
  FOR ALL USING (auth_perfil() = 'administrador');

-- ============================================================
-- FIN — 05_rls_policies.sql
-- ============================================================
