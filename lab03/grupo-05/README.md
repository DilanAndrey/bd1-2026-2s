# Laboratorio 3 — Grupo 05

¡Hola! Bienvenidos al repositorio del **Grupo 05** para el Laboratorio 3 del curso IC-4301 · Bases de Datos I.

## Matriz de Trazabilidad 
| Relación Lógica | Tabla Física (PostgreSQL) | Clave Primaria (PK) | Claves Foráneas (FK) | Restricciones Relevantes (NN, UNIQUE, CHECK) | Justificación de Cambios / Diseño |
| :--- | :---: | :---: | :--- | :--- | :--- |
| PERSONA | persona | id_persona | Ninguna | nombre_identificacion opcional | Tabla maestra simplificada para registrar veterinarios y responsables. |
| ANIMAL | animal | codigo_interno | Ninguna | especie NOT NULL; numero_microchip UNIQUE. | Entidad central del refugio; el código interno se mantiene como PK estable. |
| EVALUACION_SALUD | evaluacion_salud | id_evaluacion | animal_codigo (-> animal)<br>veterinario_id (-> persona) | tipo_evaluacion NOT NULL;<br>fecha_evaluacion NOT NULL. | Agrupa evaluación inicial y revisiones veterinarias; veterinario obligatorio si es revisión. |
| DIAGNOSTICO | diagnostico | id_diagnostico | Ninguna | nombre_estandarizado UNIQUE, NOT NULL. | Catálogo estandarizado de condiciones clínicas sin duplicados. |
| DIAGNOSTICO_REVISION | diagnostico_revision | (evaluacion_id, diagnostico_id) | evaluacion_id (-> evaluacion_salud) | estado_diagnostico NOT NULL (CHECK: provisional, confirmado, descartado). | Resuelve la relación M:N entre revisiones y diagnósticos, guardando el estado específico. |
| INDICACION | indicacion | id_indicacion | evaluacion_id (-> evaluacion_salud)<br>indicacion_sustituida_id (-> indicacion) | tipo_indicacion NOT NULL,<br>descripcion NOT NULL. | Órdenes médicas originadas en una revisión, con soporte para sustituciones. |
| APLICACION_INDICACION | aplicacion_indicacion | id_aplicacion | indicacion_id (-> indicacion)<br>responsable_id (-> persona) | fecha_planificada NOT NULL. | Separa lo planificado de lo ejecutado; si se registra fecha_real, se exigen observaciones y responsable. |

## Datos, consultas e integridad

El archivo [02_datos.sql](sql/02_datos.sql) carga datos totalmente ficticios: tres personas identificadas solo por roles de prueba, cinco animales, nueve evaluaciones (cinco iniciales y cuatro revisiones), cuatro diagnósticos, seis apariciones de diagnóstico, seis indicaciones y seis aplicaciones. Los casos cubren un animal con varias revisiones, diagnósticos confirmados, provisionales y descartados, reutilización de un diagnóstico, una indicación sustituida, aplicaciones realizadas y pendientes, una aplicación vencida y animales sin revisión posterior. Esto permite comprobar tanto relaciones como resultados distintos de las consultas.

Las consultas de [03_consultas.sql](sql/03_consultas.sql) responden estas preguntas con los datos cargados:

| ID | Pregunta | Resultado esperado |
| --- | --- | --- |
| Q01 | ¿Cuál es el historial clínico de Luna? | Tres evaluaciones; la inicial sin diagnóstico y Otitis de provisional a descartado. |
| Q02 | ¿Qué aplicaciones están pendientes al 27-10-2026? | Tres: HS-001 vencida y HS-003 y HS-002 programadas. |
| Q03 | ¿Cuántas revisiones y registros confirmados tiene cada animal? | HS-001: 2 y 2; HS-002: 1 y 1; HS-003: 1 y 0; HS-004 y HS-005: 0 y 0. |

[05_pruebas.sql](sql/05_pruebas.sql) contiene ocho pruebas identificadas: tres inserciones válidas y cinco rechazos por unicidad, clave foránea, rango, estado y obligatoriedad condicional. Cada prueba declara su precondición, sentencia y resultado esperado. El script captura los errores esperados, muestra el resultado observado con conclusión y termina con `ROLLBACK` para no conservar los registros de prueba.

La [evidencia de consultas y pruebas](evidencias/resultados.md) incluye los resultados identificados de Q01–Q03 y P01–P08. Para ejecutar sobre PostgreSQL 16, usar una base vacía y el orden `01_esquema.sql` → `02_datos.sql` → `04_rutinas.sql` → `03_consultas.sql` → `05_pruebas.sql`. Cada archivo se puede ejecutar en una conexión `psql` independiente: `01_esquema.sql` confirma su propia transacción. Para repetir la carga desde cero, recrear la base de laboratorio.

### Límites de estas pruebas

La ejecución documentada se hizo en PostgreSQL embebido PGlite 0.5.12 (motor PostgreSQL 18.6); falta repetirla en PostgreSQL 16, versión declarada para la entrega. Las pruebas verifican las restricciones que hoy existen en el esquema; no demuestran que todas las reglas del proyecto ya estén implementadas. En particular, el esquema permite una revisión veterinaria sin veterinario ni todos los campos clínicos exigidos por RN-10, y no incluye la relación `INDICACION_DIAGNOSTICO` del modelo lógico. Esos puntos siguen pendientes de resolver en el esquema. Los resultados de rutinas y los videos individuales se incorporarán cuando existan.
