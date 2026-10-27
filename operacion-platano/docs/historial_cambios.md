# Historial de cambios del sistema académico

> **Estado de este documento: NO OFICIAL.** Es una bitácora de
> mantenimiento compilada a partir de correos y tickets de soporte del
> equipo de Registraduría. No sustituye a `docs/reglas_negocio.md`. Se
> incluye porque contiene pistas reales sobre el origen de varios
> problemas actuales, mezcladas con entradas obsoletas o erróneas.

## 2025-09-12 — Entrega inicial del sistema migrado

Entrega de "Datos Rápidos S.A." Carga inicial de `CARRERA`, `ESTUDIANTE`,
`PROFESOR`, `CURSO`, `GRUPO`, `MATRICULA`, `REQUISITO`. Se activa
`AUDITORIA` para registrar eventos desde este punto en adelante.

## 2025-10-03 — Ticket SOP-2025-081: "Cursos duplicados en reporte de matrícula"

Un asistente de Registraduría reportó que el curso "Bases de Datos I"
aparecía con cifras de matrícula distintas en dos reportes diferentes el
mismo día. Investigación cerrada sin cambios: se concluyó que era
"variación normal de caché del reporte" y que no requería seguimiento.

## 2025-10-20 — Ticket SOP-2025-094: "Nota 70 aparece como reprobada en un reporte y aprobada en otro"

Un estudiante reclamó que un reporte lo mostraba como reprobado en un
curso con nota exactamente 70, mientras que su constancia oficial lo
mostraba aprobado. Se le indicó que "ambos reportes son válidos y pueden
diferir según el criterio de cada oficina" y el ticket se cerró sin más
seguimiento.

## 2025-11-05 — Ticket SOP-2025-101: "Profesor no puede ver todos sus grupos"

El profesor Rodrigo Salas reportó que el sistema le mostraba menos
grupos de los que realmente imparte. El equipo de soporte revisó la
tabla `PROFESOR` y encontró dos registros con la misma cédula
(`1-1111-1111`), uno de la carga inicial y otro de una corrección manual
posterior. El ticket quedó marcado como "resuelto parcialmente" tras
reasignar algunos grupos al registro más reciente, sin mayor detalle
sobre qué se hizo con el registro original.

## 2025-11-18 — Ticket SOP-2025-108: "Estudiante matriculado en curso sin haber aprobado requisitos"

Se reportó que un estudiante logró matricular "Redes de Computadoras"
habiendo aprobado solo uno de los dos cursos requisito. El equipo de
soporte de ese momento respondió en el ticket:

> "Confirmado: nuestra consulta de validación de requisitos considera
> cumplido el requisito si el estudiante aprobó *alguno* de los cursos
> exigidos, no todos. Este comportamiento está documentado y es
> intencional desde el lanzamiento; no debe modificarse sin aprobación
> del comité curricular."

No se encontró en actas del comité curricular ninguna aprobación con
ese contenido, pero el ticket quedó cerrado como "comportamiento
esperado" y nunca se reabrió.

## 2025-12-01 — Ticket SOP-2025-115: "Reporte de créditos aprobados muestra filas repetidas"

Se reportó duplicación de filas en el reporte de créditos aprobados por
estudiante para cursos con más de un requisito. La solución aplicada fue
agregar `DISTINCT` a la consulta. El ticket se cerró como "resuelto" y
se marcó la consulta como validada para uso en reportes futuros.

## 2026-01-15 — Cierre de soporte por parte de Datos Rápidos S.A.

Finaliza el contrato de soporte. A partir de esta fecha, el mantenimiento
del sistema queda a cargo del personal interno de la universidad —y,
para efectos de este curso, de quien resuelva el reto P.L.A.T.A.N.O.
