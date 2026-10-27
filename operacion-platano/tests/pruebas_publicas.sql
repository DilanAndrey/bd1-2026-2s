-- ============================================================================
-- OPERACIÓN P.L.A.T.A.N.O. — Pruebas públicas
--
-- Cómo usarlas:
--   psql -h localhost -U platano -d platano -f tests/pruebas_publicas.sql
--
-- Cada bloque imprime una etiqueta y luego ejecuta una consulta. Para los
-- bloques marcados "debe ser VACÍO", una tabla de resultados vacía
-- significa que esa regla se cumple. Para los bloques marcados "valor
-- esperado", se indica explícitamente qué resultado deberías obtener.
--
-- Estas pruebas son un punto de partida, no la validación completa del
-- reto: cubren las verificaciones estructurales descritas en
-- docs/reglas_negocio.md, sección 8. Hay comportamientos incorrectos que
-- estas pruebas NO detectan a propósito; identificar esos casos adicionales
-- es parte del trabajo que debes documentar en tu entrega.
-- ============================================================================

\echo '--- PRUEBA 1: carnets duplicados en ESTUDIANTE (debe ser VACÍO) ---'
SELECT carnet, COUNT(*) AS repeticiones
FROM estudiante
GROUP BY carnet
HAVING COUNT(*) > 1;

\echo '--- PRUEBA 2: cédulas duplicadas en PROFESOR (debe ser VACÍO) ---'
SELECT cedula, COUNT(*) AS repeticiones
FROM profesor
GROUP BY cedula
HAVING COUNT(*) > 1;

\echo '--- PRUEBA 3: matrículas duplicadas, mismo estudiante y grupo (debe ser VACÍO) ---'
SELECT id_estudiante, id_grupo, COUNT(*) AS repeticiones
FROM matricula
GROUP BY id_estudiante, id_grupo
HAVING COUNT(*) > 1;

\echo '--- PRUEBA 4: cursos con menos de 1 crédito (debe ser VACÍO) ---'
SELECT id_curso, codigo, nombre, creditos
FROM curso
WHERE creditos < 1;

\echo '--- PRUEBA 5: notas fuera del rango 0-100 (debe ser VACÍO) ---'
SELECT id_matricula, id_estudiante, id_grupo, nota
FROM matricula
WHERE nota IS NOT NULL AND (nota < 0 OR nota > 100);

\echo '--- PRUEBA 6: cursos que son requisito de sí mismos (debe ser VACÍO) ---'
SELECT id_requisito, id_curso, id_curso_requisito
FROM requisito
WHERE id_curso = id_curso_requisito;

\echo '--- PRUEBA 7: estudiantes sin carrera asignada (debe ser VACÍO) ---'
SELECT id_estudiante, carnet, nombre
FROM estudiante
WHERE id_carrera IS NULL;

\echo '--- PRUEBA 8: existencia de las 8 tablas del modelo (valor esperado: 8) ---'
SELECT COUNT(*) AS cantidad_tablas
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('carrera','estudiante','profesor','curso','grupo',
                      'matricula','requisito','auditoria');

\echo '--- PRUEBA 9: aprobación en el umbral exacto (valor esperado: carnet 2021001 presente) ---'
-- El carnet 2021001 tiene nota = 70.0 en el curso INF-2001 (Bases de Datos I).
-- Según la regla oficial (reglas_negocio.md, sección 5), nota = 70 APRUEBA.
-- Si tu consulta de "aprobados" no incluye este carnet, no implementa
-- correctamente la regla de aprobación.
SELECT e.carnet, e.nombre, m.nota
FROM matricula m
JOIN grupo g ON g.id_grupo = m.id_grupo
JOIN curso cu ON cu.id_curso = g.id_curso
JOIN estudiante e ON e.id_estudiante = m.id_estudiante
WHERE cu.codigo = 'INF-2001'
  AND m.nota >= 70
ORDER BY e.nombre;

\echo '--- PRUEBA 10: cursos sin ningún grupo registrado (informativo, no es un error) ---'
-- Esta prueba no valida una regla de negocio por sí sola. Úsala para
-- confirmar que tus reportes de catálogo de cursos SÍ consideran estos
-- cursos cuando corresponda (ver docs/reglas_negocio.md, sección 3).
SELECT cu.codigo, cu.nombre
FROM curso cu
LEFT JOIN grupo g ON g.id_curso = cu.id_curso
WHERE g.id_grupo IS NULL;

-- ============================================================================
-- Fin de pruebas_publicas.sql
-- ============================================================================
