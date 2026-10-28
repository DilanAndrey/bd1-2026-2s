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

La [evidencia de consultas, pruebas y rutinas](evidencias/resultados.md) reúne los resultados identificados de Q01–Q03 y P01–P08, así como las ejecuciones de las funciones y procedimientos almacenados. Para ejecutar sobre PostgreSQL 16, usar una base vacía y el orden `01_esquema.sql` → `02_datos.sql` → `04_rutinas.sql` → `03_consultas.sql` → `05_pruebas.sql`. Cada archivo se puede ejecutar en una conexión `psql` independiente: `01_esquema.sql` confirma su propia transacción. Para repetir la carga desde cero, recrear la base de laboratorio.

### Límites de estas pruebas

La ejecución de consultas y pruebas documentada por el equipo se hizo en PostgreSQL embebido PGlite 0.5.12 (motor PostgreSQL 18.6); **falta repetir integralmente Q01–Q03 y P01–P08 en PostgreSQL 16**, versión declarada para la entrega. Las rutinas de la sección siguiente sí se ejecutaron individualmente en pgAdmin con PostgreSQL 16. Las pruebas verifican las restricciones que hoy existen en el esquema; no demuestran que todas las reglas del proyecto ya estén implementadas. En particular, el esquema permite una revisión veterinaria sin veterinario ni todos los campos clínicos exigidos por RN-10, y no incluye la relación `INDICACION_DIAGNOSTICO` del modelo lógico. Esos puntos siguen pendientes de resolver en el esquema. Los resultados de las rutinas se documentan a continuación y en `evidencias/resultados.md`; las capturas de pantalla todavía deben adjuntarse si se requieren como evidencia visual. Los videos individuales aún deben incorporarse.


## Rutinas almacenadas 

El archivo [04_rutinas.sql](sql/04_rutinas.sql) contiene dos funciones PL/pgSQL y dos procedimientos almacenados desarrollados para el subsistema de salud y tratamientos de Huellas Seguras. Se probaron individualmente en **pgAdmin 4 conectado a PostgreSQL 16**, sobre la base `huellas_seguras_lab3` después de ejecutar `01_esquema.sql` y `02_datos.sql`. Estas pruebas no sustituyen la ejecución integrada de todos los scripts desde cero.

### Funciones de consulta

| Rutina | Parámetro | Resultado / regla | Prueba observada |
| --- | --- | --- | --- |
| `contar_revisiones_animal(p_codigo_animal VARCHAR)` | Código interno del animal | Retorna `INTEGER` con el número de evaluaciones cuyo `tipo_evaluacion` es `REVISION_VETERINARIA`. | `SELECT contar_revisiones_animal('HS-001');` devolvió **2**. |
| `estado_aplicacion(p_id_aplicacion INTEGER)` | Identificador de aplicación | Retorna `REALIZADA` si existe `fecha_real`; en otro caso, `VENCIDA` si `fecha_planificada < CURRENT_DATE`; de lo contrario, `PROGRAMADA`. Si el ID no existe, lanza una excepción. | `SELECT estado_aplicacion(2);` devolvió **VENCIDA** el 28-10-2026. |

Ejemplos de ejecución:

```sql
SELECT contar_revisiones_animal('HS-001');
SELECT estado_aplicacion(2);
```

**Nota:** el estado calculado depende de `CURRENT_DATE`; una aplicación programada puede pasar a vencida al avanzar la fecha del servidor. La primera función devuelve cero cuando no hay revisiones, incluso si el código consultado no corresponde a un animal existente.

### Procedimiento de registro y validaciones

`registrar_aplicacion(p_id_aplicacion INTEGER, p_fecha_real DATE, p_responsable_id INTEGER, p_observaciones TEXT)` actualiza una aplicación pendiente. Comprueba que exista, bloquea la fila con `FOR UPDATE`, impide registrar dos veces la misma aplicación y exige fecha, responsable y observaciones no vacías. La relación de clave foránea con `persona`, cuando está definida en el esquema, complementa la validación del responsable.

**Prueba exitosa observada:** se llamó al procedimiento para la aplicación 4, con fecha `2026-10-28`, responsable 3 y observaciones. La consulta posterior mostró los cuatro valores actualizados. La prueba se realizó dentro de una transacción y se ejecutó `ROLLBACK` para conservar los datos originales.

```sql
BEGIN;
CALL registrar_aplicacion(4, DATE '2026-10-28', 3, 'Aplicación realizada correctamente');
SELECT id_aplicacion, fecha_real, responsable_id, observaciones
FROM aplicacion_indicacion
WHERE id_aplicacion = 4;
ROLLBACK;
```

**Prueba rechazada observada:** al enviar `NULL` como responsable, PostgreSQL devolvió `ERROR: Debe indicar fecha, responsable y observaciones` (`SQLSTATE P0001`). La excepción es el resultado esperado.

```sql
CALL registrar_aplicacion(
    4, DATE '2026-10-28', NULL, 'Aplicación realizada sin responsable'
);
```

### Reporte de aplicaciones pendientes mediante tabla temporal

`generar_reporte_pendientes()` utiliza `CREATE TEMP TABLE ... ON COMMIT PRESERVE ROWS` para generar `reporte_pendientes` con el código y nombre del animal, descripción de la indicación, fecha planificada y estado calculado. Solo incluye aplicaciones sin `fecha_real`. Antes de crearla, elimina la tabla temporal anterior de la misma sesión, si existe.

```sql
CALL generar_reporte_pendientes();
SELECT * FROM reporte_pendientes ORDER BY fecha_planificada;
```

**Resultado observado en PostgreSQL 16 el 28-10-2026:**

| Código | Animal | Fecha planificada | Estado |
| --- | --- | --- | --- |
| HS-001 | Luna | 2026-10-10 | VENCIDA |
| HS-003 | Nube | 2026-11-03 | PROGRAMADA |
| HS-002 | Milo | 2026-11-05 | PROGRAMADA |

**Comparación con SQL directo.** Se ejecutó una consulta `SELECT` con los mismos `JOIN`, filtro `fecha_real IS NULL` y expresión `CASE`, obteniendo las mismas tres filas. El SQL directo es más simple para una consulta puntual y refleja los datos actuales en cada ejecución. La tabla temporal permite reutilizar el resultado dentro de la sesión sin repetir los `JOIN`, pero consume recursos temporales y representa una instantánea que debe regenerarse si cambian los datos. No se midió una mejora de rendimiento.

```sql
SELECT a.codigo_interno, a.nombre AS nombre_animal,
       i.descripcion AS indicacion, ap.fecha_planificada,
       CASE WHEN ap.fecha_planificada < CURRENT_DATE
            THEN 'VENCIDA' ELSE 'PROGRAMADA' END AS estado
FROM aplicacion_indicacion ap
JOIN indicacion i ON ap.indicacion_id = i.id_indicacion
JOIN evaluacion_salud e ON i.evaluacion_id = e.id_evaluacion
JOIN animal a ON e.animal_codigo = a.codigo_interno
WHERE ap.fecha_real IS NULL
ORDER BY ap.fecha_planificada;
```

La tabla temporal es **local a la sesión**: el `CALL` y el `SELECT` posterior deben ejecutarse en la misma conexión. `ON COMMIT PRESERVE ROWS` conserva sus filas tras un `COMMIT`, pero la tabla desaparece al finalizar la sesión.


