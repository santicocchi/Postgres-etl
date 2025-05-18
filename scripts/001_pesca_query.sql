\c postgres

/* --- CONSULTAS PERSONALIZADAS --- */

-- Ejemplo: Total de captura por provincia
SELECT
  p.nombre AS provincia,
  SUM(pe.captura) AS total_captura
FROM public.pesca pe
JOIN public.departamento d ON pe.departamento_id = d.id
JOIN public.provincia p ON d.provincia_id = p.id
GROUP BY p.nombre
ORDER BY total_captura DESC;
/*
-- Ejemplo: Topo 3 de especies más capturadas por provincia y departamento
*/
SELECT
  p.nombre AS provincia,
  d.nombre AS departamento,
  pe.especie,
  SUM(pe.captura) AS total_captura
FROM public.pesca pe
JOIN public.departamento d ON pe.departamento_id = d.id
JOIN public.provincia p ON d.provincia_id = p.id
GROUP BY p.nombre, d.nombre, pe.especie
ORDER BY total_captura DESC
LIMIT 3;
/* */
-- Ejemplo: Especie más capturada por provincia
SELECT
  p.nombre AS provincia,
  pe.especie,
  SUM(pe.captura) AS total_captura
FROM public.pesca pe
JOIN public.departamento d ON pe.departamento_id = d.id
JOIN public.provincia p ON d.provincia_id = p.id
GROUP BY p.nombre, pe.especie
ORDER BY total_captura DESC
LIMIT 1;