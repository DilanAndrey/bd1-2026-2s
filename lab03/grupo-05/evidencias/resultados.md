# Evidencias de consultas y pruebas — Grupo 05

Ejecución local del 27-10-2026 sobre una base en memoria, con `01_esquema.sql`, `02_datos.sql`, `03_consultas.sql` y `05_pruebas.sql`. Motor: PGlite 0.5.12, que informó `PostgreSQL 18.6 ... wasm32-unknown-emscripten`. La versión de entrega es PostgreSQL 16; la corrida en esa versión sigue pendiente. `04_rutinas.sql` estaba vacío durante esa verificación inicial; los resultados de las rutinas que se documentan más adelante corresponden a pruebas posteriores en PostgreSQL 16 mediante pgAdmin. El esquema incluye ahora `COMMIT;`, necesario para ejecutarlo en una conexión `psql` distinta de los demás archivos.

Tras añadir `COMMIT;`, se repitió la secuencia con una base persistente y una conexión nueva por archivo, como hace el workflow: `01_esquema.sql` → `02_datos.sql` → `04_rutinas.sql` → `03_consultas.sql` → `05_pruebas.sql`. Antes de `02_datos.sql`, `to_regclass('public.persona')` devolvió `persona`. Los cinco archivos se ejecutaron; Q01–Q03 devolvieron 3, 3 y 5 filas y P01–P08 registraron los ocho resultados esperados. Esta comprobación también usó PGlite; falta repetirla en el PostgreSQL 16 de CI.

## Consultas

**Q01 — Historial de Luna.** Esperado: una evaluación inicial sin diagnóstico y dos revisiones; Otitis cambia de PROVISIONAL a DESCARTADO. Observado:

| id_evaluacion | fecha | tipo | veterinario | diagnósticos |
| ---: | --- | --- | --- | --- |
| 1 | 2026-09-01 | INICIAL | NULL | Sin diagnóstico |
| 2 | 2026-09-03 | REVISION_VETERINARIA | Profesional veterinario ficticio A | Dermatitis (CONFIRMADO), Otitis (PROVISIONAL) |
| 3 | 2026-09-17 | REVISION_VETERINARIA | Profesional veterinario ficticio A | Dermatitis (CONFIRMADO), Otitis (DESCARTADO) |

Conclusión: coincide con lo esperado. La consulta usa varias tablas y conserva la evaluación inicial sin diagnóstico mediante `LEFT JOIN`.

**Q02 — Aplicaciones pendientes al 27-10-2026.** Esperado: tres pendientes, una vencida. Observado:

| animal | tipo | fecha planificada | situación |
| --- | --- | --- | --- |
| HS-001 Luna | TRATAMIENTO | 2026-10-10 | VENCIDA |
| HS-003 Nube | CONTROL_POSTERIOR | 2026-11-03 | PROGRAMADA |
| HS-002 Milo | VACUNA | 2026-11-05 | PROGRAMADA |

Conclusión: coincide con lo esperado. Las tres aplicaciones realizadas no aparecen.

**Q03 — Revisiones y registros confirmados.** Esperado y observado:

| animal | revisiones | registros confirmados |
| --- | ---: | ---: |
| HS-001 Luna | 2 | 2 |
| HS-002 Milo | 1 | 1 |
| HS-003 Nube | 1 | 0 |
| HS-004 Sol | 0 | 0 |
| HS-005 Menta | 0 | 0 |

Conclusión: coincide con lo esperado. Se cuentan apariciones confirmadas por revisión; el mismo diagnóstico en dos revisiones cuenta dos veces.

## Pruebas de integridad

Las sentencias completas, los valores y el control de errores están en [05_pruebas.sql](../sql/05_pruebas.sql). La salida final del script registró ocho conclusiones `Cumple`. Cada prueba se ejecutó dentro de una transacción que se revirtió al final.

| ID | Precondición | Sentencia ejecutada | Esperado | Observado | Conclusión |
| --- | --- | --- | --- | --- | --- |
| P01 | PRB-001 no existe. | Insertar PRB-001 y evaluación inicial 9001 sin datos clínicos. | ACEPTADO | ACEPTADO | Cumple: el tipo inicial admite esos campos ausentes. |
| P02 | Diagnóstico 1 y revisión 5 existen; pareja (5,1) ausente. | Insertar `(5,1,'PROVISIONAL')` en `diagnostico_revision`. | ACEPTADO | ACEPTADO | Cumple: el catálogo se reutiliza. |
| P03 | Indicación 4, responsable 3 existen; aplicación 9001 ausente. | Insertar aplicación realizada con fecha, responsable y observación. | ACEPTADO | ACEPTADO | Cumple: están los datos requeridos. |
| P04 | HS-001 usa `MC-HS-001`. | Insertar PRB-004 con `MC-HS-001`. | RECHAZADO | `unique_violation` | Cumple RN-03: microchip único. |
| P05 | PRB-INEXISTENTE no existe. | Insertar evaluación 9002 de PRB-INEXISTENTE. | RECHAZADO | `foreign_key_violation` | Cumple: la evaluación exige animal existente. |
| P06 | PRB-006 no existe. | Insertar PRB-006 con `edad_estimada = -1`. | RECHAZADO | `check_violation` | Cumple: edad no negativa. |
| P07 | Revisión 5 y diagnóstico 2 existen; pareja (5,2) ausente. | Insertar `(5,2,'INVALIDO')` en `diagnostico_revision`. | RECHAZADO | `check_violation` | Cumple RN-11: estado permitido. |
| P08 | Indicación 4 existe; aplicación 9002 ausente. | Insertar aplicación realizada sin responsable. | RECHAZADO | `check_violation` | Cumple RN-13: responsable requerido. |

## Funciones y procedimientos almacenados

Las siguientes pruebas se realizaron posteriormente en **PostgreSQL 16**, desde **pgAdmin 4**, sobre la base `huellas_seguras_lab3`, después de ejecutar `01_esquema.sql`, `02_datos.sql` y crear las rutinas definidas en [04_rutinas.sql](../sql/04_rutinas.sql). Los resultados indicados corresponden a las ejecuciones comprobadas; aún se deben adjuntar las capturas de pantalla al repositorio.

### Conteo de revisiones veterinarias

La función `contar_revisiones_animal(codigo)` cuenta únicamente las evaluaciones de tipo `REVISION_VETERINARIA` asociadas al animal indicado.

```sql
SELECT contar_revisiones_animal('HS-001');
```

| Animal | Resultado esperado | Resultado observado | Conclusión |
| --- | ---: | ---: | --- |
| HS-001 (Luna) | 2 | 2 | Cumple: Luna tiene dos revisiones veterinarias. |

### Estado de una aplicación

La función `estado_aplicacion(id)` devuelve `REALIZADA` si existe una fecha real; de lo contrario, `VENCIDA` cuando la fecha planificada es anterior a `CURRENT_DATE`, o `PROGRAMADA` en los demás casos.

```sql
SELECT estado_aplicacion(2);
```

| Aplicación | Resultado esperado | Resultado observado | Conclusión |
| --- | --- | --- | --- |
| 2 | VENCIDA | VENCIDA | Cumple: la aplicación sigue pendiente y su fecha planificada (2026-10-10) ya pasó. |

**Consideración:** los estados calculados mediante `CURRENT_DATE` dependen del día en que se ejecute la consulta.

### Registro de una aplicación realizada

El procedimiento `registrar_aplicacion` permite registrar la fecha efectiva, el responsable y las observaciones de una aplicación pendiente. Valida la existencia de la aplicación, impide registrar nuevamente una ya realizada y exige los tres datos obligatorios.

**Prueba aceptada.** Se ejecutó dentro de una transacción para no modificar permanentemente los datos de ejemplo:

```sql
BEGIN;

CALL registrar_aplicacion(
    4,
    DATE '2026-10-28',
    3,
    'Aplicación realizada correctamente'
);

SELECT id_aplicacion, fecha_real, responsable_id, observaciones
FROM aplicacion_indicacion
WHERE id_aplicacion = 4;

ROLLBACK;
```

| id_aplicacion | fecha_real | responsable_id | observaciones | Conclusión |
| ---: | --- | ---: | --- | --- |
| 4 | 2026-10-28 | 3 | Aplicación realizada correctamente | Cumple: el procedimiento registra los datos proporcionados. |

El `ROLLBACK` devuelve la aplicación a su estado original, de modo que las pruebas siguientes pueden utilizar el mismo conjunto de datos.

**Prueba rechazada.** Se intentó registrar la aplicación sin responsable:

```sql
CALL registrar_aplicacion(
    4,
    DATE '2026-10-28',
    NULL,
    'Aplicación realizada sin responsable'
);
```

| Resultado esperado | Resultado observado | Conclusión |
| --- | --- | --- |
| Rechazo por ausencia del responsable | `ERROR: Debe indicar fecha, responsable y observaciones` (`SQLSTATE P0001`) | Cumple: no se admite el registro incompleto. |

### Reporte temporal de aplicaciones pendientes

El procedimiento `generar_reporte_pendientes()` crea una **tabla temporal** llamada `reporte_pendientes` con las aplicaciones que aún no tienen `fecha_real`. El reporte reúne datos del animal, la indicación, la fecha planificada y el estado calculado. La tabla temporal está disponible en la sesión actual de PostgreSQL y se vuelve a generar al invocar el procedimiento.

```sql
CALL generar_reporte_pendientes();

SELECT *
FROM reporte_pendientes
ORDER BY fecha_planificada;
```

| codigo_interno | nombre_animal | fecha_planificada | estado |
| --- | --- | --- | --- |
| HS-001 | Luna | 2026-10-10 | VENCIDA |
| HS-003 | Nube | 2026-11-03 | PROGRAMADA |
| HS-002 | Milo | 2026-11-05 | PROGRAMADA |

**Resultado observado:** se obtuvieron tres filas, una vencida y dos programadas. La consulta también devuelve una columna `indicacion` con la descripción correspondiente. **Conclusión:** coincide con los datos pendientes cargados.

### Comparación con una consulta SQL directa

Para comprobar si la tabla temporal era indispensable, se ejecutó una consulta equivalente sin crear objetos temporales:

```sql
SELECT
    a.codigo_interno,
    a.nombre AS nombre_animal,
    i.descripcion AS indicacion,
    ap.fecha_planificada,
    CASE
        WHEN ap.fecha_planificada < CURRENT_DATE THEN 'VENCIDA'
        ELSE 'PROGRAMADA'
    END AS estado
FROM aplicacion_indicacion ap
JOIN indicacion i ON ap.indicacion_id = i.id_indicacion
JOIN evaluacion_salud e ON i.evaluacion_id = e.id_evaluacion
JOIN animal a ON e.animal_codigo = a.codigo_interno
WHERE ap.fecha_real IS NULL
ORDER BY ap.fecha_planificada;
```

**Resultado observado:** la consulta directa devolvió las mismas tres aplicaciones, con iguales fechas y estados. **Conclusión:** ambas alternativas producen el mismo reporte. La consulta directa es más sencilla para una lectura puntual; la tabla temporal permite conservar el resultado intermedio y consultarlo varias veces durante la misma sesión, aunque requiere creación y mantenimiento del objeto temporal.

## Evidencias pendientes de adjuntar

- Capturas de pgAdmin 4 con la ejecución y salida de las dos funciones.
- Capturas de la ejecución aceptada y del error esperado del procedimiento de registro.
- Capturas del reporte temporal y de la consulta SQL directa con resultados equivalentes.
- Resultado de una ejecución completa, desde una base vacía, de todos los archivos en PostgreSQL 16, incluidas las consultas y pruebas de integridad. Las pruebas de consultas e integridad documentadas arriba corresponden todavía a PGlite, mientras que las rutinas descritas en esta sección sí se probaron por separado en PostgreSQL 16.

