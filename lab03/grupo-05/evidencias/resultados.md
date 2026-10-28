# Evidencias de la Parte B — Grupo 05

Ejecución local del 27-10-2026 sobre una base en memoria, con `01_esquema.sql` seguido de `COMMIT;`, `02_datos.sql`, `03_consultas.sql` y `05_pruebas.sql`. Motor: PGlite 0.5.12, que informó `PostgreSQL 18.6 ... wasm32-unknown-emscripten`. La versión de entrega es PostgreSQL 16; la corrida en esa versión sigue pendiente. `04_rutinas.sql` estaba vacío durante esta verificación y no se atribuyen resultados a rutinas.

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

La captura de esta salida en PostgreSQL 16 y las evidencias de las rutinas quedan pendientes de la integración final del equipo.
