# Evidencias de ejecución — Laboratorio 03

## Entorno de verificación

- Motor: PostgreSQL 17.11.
- Base de prueba: `ci_grupo_03`.
- Usuario: `ci_runner`, sin privilegios de superusuario.
- Ejecución mediante `psql` dentro de Docker.

## A2 — Creación del esquema

**Resultado esperado:** creación de seis tablas sin errores.

**Resultado observado:** seis instrucciones `CREATE TABLE`, seguidas de `COMMIT`.

**Conclusión:** el script `01_esquema.sql` se ejecutó correctamente sobre una base vacía.

## B1 — Carga de datos

| Tabla | Registros insertados |
|---|---:|
| `escuela` | 2 |
| `carrera` | 2 |
| `curso` | 8 |
| `version_plan_estudios` | 3 |
| `participacion_plan` | 16 |
| `requisito_curso` | 10 |
| **Total** | **41** |

**Resultado observado:** todas las inserciones finalizaron correctamente y la transacción confirmó los cambios mediante `COMMIT`.

## B2 — Consultas

### Q01 — Cursos de una versión del plan

**Pregunta:** ¿Qué cursos componen la versión 102 y cuál es su tipo de participación?

**Resultado esperado y observado:** siete cursos, seis obligatorios y uno optativo.

| Código | Tipo | Nivel |
|---|---|---|
| UH-MAT1 | Obligatorio | 1 |
| UH-PROG1 | Obligatorio | 1 |
| UH-PROG2 | Obligatorio | 2 |
| UH-ALG1 | Obligatorio | 3 |
| UH-BDAT1 | Obligatorio | 3 |
| UH-EST1 | Obligatorio | 3 |
| UH-RED1 | Optativo | 4 |

### Q02 — Requisitos de un curso

**Pregunta:** ¿Qué requisitos previos y correquisitos tiene UH-BDAT1 en la versión 102?

**Resultado esperado y observado:**

| Curso exigido | Tipo |
|---|---|
| UH-EST1 | Correquisito |
| UH-MAT1 | Correquisito |
| UH-PROG2 | Requisito previo |

Se obtuvieron tres registros.

### Q03 — Distribución de cursos por versión

**Pregunta:** ¿Cuántos cursos obligatorios y optativos tiene cada versión del plan?

**Resultado esperado y observado:**

| Versión | Obligatorios | Optativos |
|---|---:|---:|
| 101 | 5 | 1 |
| 102 | 6 | 1 |
| 201 | 2 | 1 |

La consulta devolvió seis agrupaciones, correspondientes a las combinaciones de versión y tipo de participación existentes.

## A3 — Reproducibilidad

Se crearon una base de datos independiente y un usuario sin privilegios de superusuario. Sobre esa base se ejecutaron correctamente:

1. `01_esquema.sql`
2. `02_datos.sql`
3. `03_consultas.sql`

**Conclusión:** se verificó la ejecución reproducible de los tres scripts disponibles. La comprobación integral queda pendiente de incorporar `04_rutinas.sql` y `05_pruebas.sql`.

## Pruebas de integridad y rutinas

Pendientes de incorporar y verificar tras implementar `04_rutinas.sql` y `05_pruebas.sql`.