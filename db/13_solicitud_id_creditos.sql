-- Migration: Add solicitud_id to creditos for idempotency
ALTER TABLE creditos ADD COLUMN IF NOT EXISTS solicitud_id UUID UNIQUE REFERENCES solicitudes_credito(id);

-- Clean up duplicate créditos (those without cronograma cuotas)
DELETE FROM creditos 
WHERE id NOT IN (
  SELECT DISTINCT credito_id FROM cr_cronograma_cuotas
);

-- Reset estado for Caso 1 so we can test again
UPDATE solicitudes_credito 
SET estado = 'recibido_comite', updated_at = NOW()
WHERE id = 'b82a9726-9d9c-4c88-b0be-c161cb2e6613';
