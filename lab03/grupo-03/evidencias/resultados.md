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


---

## Verificación local de Felipe — Rutinas y pruebas P01–P09

### Alcance y procedencia de la evidencia

Esta sección complementa las evidencias anteriores de Santiago, que se conservan íntegramente. Las menciones anteriores a pruebas pendientes corresponden al estado documentado en aquella verificación.

Felipe Salazar González ejecutó las rutinas y pruebas en su entorno local y confirmó que «todo salio correctamente». Para P01–P03 también compartió la salida de consola con los avisos de éxito. Para P04–P09 se registra su confirmación general, sin presentar como transcripción una salida individual no adjuntada.

Las sentencias y precondiciones siguientes se contrastaron con los archivos locales `04_rutinas.sql` y `05_pruebas.sql`. Al revisar la rama remota `grupo-03` antes de esta actualización, solo estaban publicados los scripts `01_esquema.sql`, `02_datos.sql` y `03_consultas.sql`. Por tanto, esta sección documenta la ejecución local reportada; no acredita todavía una ejecución integral desde los archivos publicados en GitHub ni una nueva ejecución por quien redacta esta documentación.

### Entorno y precondiciones generales

- PostgreSQL mediante la imagen Docker `postgres:17`, contenedor `bd1-lab03`.
- Base de datos `lab03_grupo03`, usuario `bd1`, cliente `psql` y terminal PowerShell.
- Esquema y datos iniciales cargados mediante `01_esquema.sql` y `02_datos.sql`.
- Funciones y procedimiento creados mediante el archivo local `04_rutinas.sql`.
- Datos iniciales sin modificaciones persistentes que alteren las precondiciones de cada prueba.
- Las instrucciones SQL se ejecutan dentro de `psql`; PowerShell se utiliza para invocar Docker.

El comando de ejecución reportado fue:

```powershell
docker exec bd1-lab03 psql -U bd1 -d lab03_grupo03 -v ON_ERROR_STOP=1 -f /tmp/lab03_sql/05_pruebas.sql
```

Los bloques de `05_pruebas.sql` comprueban los resultados y emiten `RAISE NOTICE` al aprobar. Las pruebas negativas capturan la excepción esperada; una excepción distinta o un resultado inesperado provoca el fallo. P03, P07 y P08 emplean `SAVEPOINT` y `ROLLBACK TO SAVEPOINT` para deshacer los cambios de prueba antes de `COMMIT`.

Las sentencias que se muestran a continuación son las operaciones centrales y consultas de comprobación. Los controles automáticos completos se encuentran en el script local. Las inserciones negativas de P04–P06 y la llamada negativa de P09 producirán un error esperado si se ejecutan aisladamente, fuera de sus bloques de manejo de excepciones.

### P01 — Cálculo de créditos obligatorios

**Precondición:** existe la versión 102 con sus seis cursos obligatorios y los créditos de los datos iniciales.

**SQL:**

```sql
SELECT fn_creditos_obligatorios_plan(102);
```

**Resultado esperado:** `22` créditos; los cursos optativos no se incluyen.

**Resultado observado:** Felipe compartió el aviso `P01 EXITOSA: 22 creditos obligatorios`.

**Conclusión:** la función calculó el total esperado para la versión 102.

### P02 — Clasificación de requisitos

**Precondición:** `UH-BDAT1` pertenece a la versión 102 y tiene un requisito previo y dos correquisitos.

**SQL:**

```sql
SELECT fn_tipo_requisitos_curso('UH-BDAT1', 102);
```

**Resultado esperado:** `Requisitos previos y correquisitos`.

**Resultado observado:** Felipe compartió el aviso `P02 EXITOSA: Requisitos previos y correquisitos`.

**Conclusión:** la función reconoció correctamente la coexistencia de ambos tipos de requisitos.

### P03 — Inserción válida mediante el procedimiento

**Precondición:** existen el curso `UH-RED1` y la versión 101, pero esa participación todavía no está registrada.

**SQL:**

```sql
BEGIN;
SAVEPOINT prueba_p03;

CALL sp_agregar_curso_plan('UH-RED1', 101, 'Optativo', '4');

SELECT codigo_curso, id_version_plan, tipo_participacion,
       nivel_o_periodo_recomendado
FROM participacion_plan
WHERE codigo_curso = 'UH-RED1' AND id_version_plan = 101;

ROLLBACK TO SAVEPOINT prueba_p03;
COMMIT;
```

**Resultado esperado:** se inserta temporalmente la participación como `Optativo`, con nivel `4`; después de revertir, la participación deja de existir.

**Resultado observado:** Felipe compartió `P03 EXITOSA: curso agregado correctamente` y la finalización con `ROLLBACK` y `COMMIT`. El bloque automático verifica la existencia de la participación optativa antes de revertirla.

**Conclusión:** el procedimiento permitió la inserción válida y la transacción deshizo el cambio de prueba.

### P04 — Rechazo de una participación duplicada

**Precondición:** `UH-PROG1` ya pertenece a la versión 102.

**SQL:**

```sql
INSERT INTO participacion_plan
    (codigo_curso, id_version_plan, tipo_participacion)
VALUES ('UH-PROG1', 102, 'Obligatorio');
```

**Resultado esperado:** rechazo por `unique_violation` de la restricción `pk_participacion_plan`. El bloque comprueba el nombre de la restricción y emite `P04 EXITOSA: duplicado rechazado`.

**Resultado observado:** éxito reportado por Felipe dentro de su confirmación general de P01–P09; no se adjuntó una salida individual de P04.

**Conclusión:** según lo reportado, la clave primaria impidió registrar dos veces el mismo curso en la misma versión.

### P05 — Rechazo de un curso inexistente

**Precondición:** existe la versión 101 y no existe el curso `UH-INEXISTENTE`.

**SQL:**

```sql
INSERT INTO participacion_plan
    (codigo_curso, id_version_plan, tipo_participacion)
VALUES ('UH-INEXISTENTE', 101, 'Optativo');
```

**Resultado esperado:** rechazo por `foreign_key_violation` de `fk_participacion_curso`; aviso del bloque: `P05 EXITOSA: clave foranea rechazada`.

**Resultado observado:** éxito reportado por Felipe en la confirmación general, sin transcripción individual de P05.

**Conclusión:** según lo reportado, la clave foránea evitó una participación que apuntara a un curso inexistente.

### P06 — Rechazo de un tipo de participación inválido

**Precondición:** existen `UH-RED1` y la versión 101, y la participación no existe. P03 ya revirtió su inserción.

**SQL:**

```sql
INSERT INTO participacion_plan
    (codigo_curso, id_version_plan, tipo_participacion)
VALUES ('UH-RED1', 101, 'Electivo');
```

**Resultado esperado:** rechazo por `check_violation` de `ck_tipo_participacion`, ya que solo se admiten `Obligatorio` y `Optativo`; aviso del bloque: `P06 EXITOSA: tipo invalido rechazado`.

**Resultado observado:** éxito reportado por Felipe en la confirmación general, sin transcripción individual de P06.

**Conclusión:** según lo reportado, la restricción `CHECK` protegió el dominio del tipo de participación.

### P07 — Inserción válida de un requisito

**Precondición:** existen la versión 201 y los cursos `UH-EST1` y `UH-MAT1`; la relación indicada todavía no está registrada.

**SQL:**

```sql
BEGIN;
SAVEPOINT prueba_p07;

INSERT INTO requisito_curso
    (id_version_plan, codigo_curso_objetivo,
     codigo_curso_exigido, tipo_requisito)
VALUES (201, 'UH-EST1', 'UH-MAT1', 'Requisito previo');

SELECT *
FROM requisito_curso
WHERE id_version_plan = 201
  AND codigo_curso_objetivo = 'UH-EST1'
  AND codigo_curso_exigido = 'UH-MAT1'
  AND tipo_requisito = 'Requisito previo';

ROLLBACK TO SAVEPOINT prueba_p07;
COMMIT;
```

**Resultado esperado:** inserción y comprobación de una fila; aviso `P07 EXITOSA: requisito insertado`. La relación se elimina al revertir al punto de guardado.

**Resultado observado:** éxito reportado por Felipe en la confirmación general, sin transcripción individual de P07.

**Conclusión:** según lo reportado, se aceptó una relación válida conforme a las restricciones implementadas y se revirtió el cambio de prueba.

### P08 — Actualización válida de una participación

**Precondición:** `UH-RED1` figura como `Optativo` en la versión 102.

**SQL:**

```sql
BEGIN;
SAVEPOINT prueba_p08;

UPDATE participacion_plan
SET tipo_participacion = 'Obligatorio'
WHERE codigo_curso = 'UH-RED1' AND id_version_plan = 102;

SELECT tipo_participacion
FROM participacion_plan
WHERE codigo_curso = 'UH-RED1' AND id_version_plan = 102;

ROLLBACK TO SAVEPOINT prueba_p08;
COMMIT;
```

**Resultado esperado:** el tipo cambia temporalmente a `Obligatorio`; aviso `P08 EXITOSA: participacion actualizada`. Después de revertir, permanece como `Optativo`.

**Resultado observado:** éxito reportado por Felipe en la confirmación general, sin transcripción individual de P08.

**Conclusión:** según lo reportado, se permitió la actualización a un valor válido y se conservó el estado inicial mediante la reversión.

### P09 — Rechazo de duplicados desde el procedimiento

**Precondición:** `UH-PROG1` ya pertenece a la versión 102.

**SQL:**

```sql
CALL sp_agregar_curso_plan('UH-PROG1', 102, 'Obligatorio', '1');
```

**Resultado esperado:** el procedimiento lanza la excepción `El curso UH-PROG1 ya pertenece a la version 102`. El bloque comprueba ese mensaje exacto y emite `P09 EXITOSA: procedimiento rechazo duplicado`.

**Resultado observado:** éxito reportado por Felipe en la confirmación general, sin transcripción individual de P09.

**Conclusión:** según lo reportado, la validación del procedimiento rechazó la operación antes de insertar. P04 comprueba la protección de la clave primaria mediante un `INSERT` directo; P09 comprueba la validación explícita de la rutina.

### Comprobación complementaria — Cursor frente a STRING_AGG

**Precondiciones:** la función `fn_detalle_requisitos_cursor` está creada; `UH-BDAT1` y `UH-RED1` pertenecen a la versión 102.

**SQL con cursor:**

```sql
SELECT fn_detalle_requisitos_cursor('UH-BDAT1', 102);
SELECT fn_detalle_requisitos_cursor('UH-RED1', 102);
```

Para `UH-BDAT1`, el resultado esperado contiene estas líneas, con los requisitos previos primero y los códigos ordenados dentro de cada tipo:

```text
Requisito previo: Programacion Intermedia (UH-PROG2)
Correquisito: Estadistica Aplicada (UH-EST1)
Correquisito: Matematica Discreta (UH-MAT1)
```

Para `UH-RED1`, el resultado esperado es `Sin requisitos`.

**Consulta equivalente con agregación**, conservando la validación de pertenencia, el orden y el tratamiento del conjunto vacío:

```sql
WITH parametros AS (
    SELECT 'UH-BDAT1'::text AS codigo, 102::integer AS version
)
SELECT CASE
    WHEN NOT EXISTS (
        SELECT 1
        FROM participacion_plan AS p
        WHERE p.codigo_curso = x.codigo
          AND p.id_version_plan = x.version
    ) THEN 'El curso no pertenece al plan'
    ELSE COALESCE((
        SELECT STRING_AGG(
            FORMAT('%s: %s (%s)',
                   r.tipo_requisito, c.nombre, c.codigo_institucional),
            E'\n' ORDER BY
                CASE WHEN r.tipo_requisito = 'Requisito previo'
                     THEN 0 ELSE 1 END,
                c.codigo_institucional
        )
        FROM requisito_curso AS r
        JOIN curso AS c
          ON c.codigo_institucional = r.codigo_curso_exigido
        WHERE r.codigo_curso_objetivo = x.codigo
          AND r.id_version_plan = x.version
    ), 'Sin requisitos')
END AS detalle
FROM parametros AS x;
```

Para comprobar el caso sin requisitos se sustituye `UH-BDAT1` por `UH-RED1` en los parámetros. Esta consulta deja documentada una forma reproducible de la comparación; no se presenta como transcripción literal de la consulta anterior del chat.

**Resultado observado:** Felipe compartió la salida `Sin requisitos` para `fn_detalle_requisitos_cursor('UH-RED1', 102)` y confirmó que ambas alternativas daban los mismos resultados.

**Explicación y conclusión:** el cursor explícito de la función utiliza `OPEN`, `FETCH`, `EXIT WHEN NOT FOUND` y `CLOSE` para recorrer cada fila y construir el texto. Su propósito en el laboratorio es demostrar control procedimental. `STRING_AGG` expresa la concatenación como una operación de agregación y resulta más conciso para este caso. La equivalencia requiere aplicar los mismos filtros, formato, separador y orden, además de tratar la ausencia de filas y la falta de pertenencia al plan. La coincidencia reportada valida los casos comparados; no constituye una medición de rendimiento ni una prueba exhaustiva de todas las entradas.

### Conclusiones de la verificación de Felipe

- P01 y P02 produjeron los resultados funcionales esperados, con avisos de éxito compartidos.
- P03 permitió agregar una participación válida y deshizo el cambio al finalizar.
- Felipe reportó éxito en el conjunto P01–P09. P04–P06 cubren rechazos por clave primaria, clave foránea y `CHECK`; P07–P08 cubren cambios válidos; P09 cubre el rechazo de duplicados desde el procedimiento.
- El cursor produjo `Sin requisitos` en el caso mostrado y Felipe confirmó la coincidencia con la alternativa de agregación.
- La validación local complementa la evidencia previa de Santiago. La reproducibilidad integral desde GitHub sigue dependiendo de publicar los scripts locales de rutinas y pruebas; esta actualización solo agrega documentación a `evidencias/resultados.md`.
