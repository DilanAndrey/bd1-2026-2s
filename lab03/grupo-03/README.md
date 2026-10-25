# Laboratorio 03 — Universidad Horizonte

- **Curso:** IC-4301 — Bases de Datos I
- **Grupo:** 03
- **Integrantes:** Santiago Víquez Zamora y Felipe Salazar González

## 1. Proceso implementado

Se seleccionó el subsistema de gestión curricular de Universidad Horizonte, derivado del modelo relacional del Proyecto 1.

El subsistema permite registrar carreras, escuelas, cursos, versiones de planes de estudio, la participación de cursos en cada versión y los requisitos previos o correquisitos establecidos para ellos.

Se implementan seis tablas relacionadas. Quedan fuera del alcance operativo la matrícula de estudiantes, los resultados académicos, los reconocimientos de cursos y la comprobación individual del cumplimiento de requisitos.

## 2. Fragmento del modelo lógico

El fragmento seleccionado está compuesto por las siguientes relaciones:

```text
ESCUELA(
    id_escuela PK
)

CARRERA(
    id_carrera PK
)

CURSO(
    codigo_institucional PK,
    nombre,
    cantidad_creditos,
    id_escuela FK
)

VERSION_PLAN_ESTUDIOS(
    id_version_plan PK,
    vigencia,
    id_carrera FK
)

PARTICIPACION_PLAN(
    codigo_curso PK/FK,
    id_version_plan PK/FK,
    tipo_participacion,
    nivel_o_periodo_recomendado
)

REQUISITO_CURSO(
    id_version_plan PK/FK,
    codigo_curso_objetivo PK/FK,
    codigo_curso_exigido PK/FK,
    tipo_requisito PK
)
```

Las asociaciones conservadas son:

- Una escuela administra múltiples cursos; cada curso pertenece a una escuela.
- Una carrera puede tener múltiples versiones de plan; cada versión pertenece a una carrera.
- Un curso puede participar en múltiples versiones y una versión puede contener múltiples cursos. Esta asociación se materializa mediante `participacion_plan`.
- Los requisitos y correquisitos se definen para una versión del plan y relacionan un curso objetivo con un curso exigido.

## 3. Matriz de trazabilidad

| Relación lógica | Tabla física | Clave primaria | Claves foráneas | Restricciones relevantes | Justificación de cambios |
|---|---|---|---|---|---|
| ESCUELA | `escuela` | `id_escuela` | — | Identificador obligatorio y único | Se representa el identificador provisional como `INTEGER`. |
| CARRERA | `carrera` | `id_carrera` | — | Identificador obligatorio y único | Se representa el identificador provisional como `INTEGER`. |
| CURSO | `curso` | `codigo_institucional` | `id_escuela` → `escuela` | Nombre, créditos y escuela obligatorios | Se utilizan `TEXT` para código y nombre e `INTEGER` para créditos. |
| VERSION_PLAN_ESTUDIOS | `version_plan_estudios` | `id_version_plan` | `id_carrera` → `carrera` | Vigencia y carrera obligatorias | La vigencia se conserva provisionalmente como `TEXT`. |
| PARTICIPACION_PLAN | `participacion_plan` | (`codigo_curso`, `id_version_plan`) | `codigo_curso` → `curso`; `id_version_plan` → `version_plan_estudios` | Tipo obligatorio; valores `Obligatorio` y `Optativo` | La clave compuesta conserva una participación por curso y versión. La ubicación recomendada se representa mediante `TEXT` nullable. |
| REQUISITO_CURSO | `requisito_curso` | (`id_version_plan`, `codigo_curso_objetivo`, `codigo_curso_exigido`, `tipo_requisito`) | `id_version_plan` → `version_plan_estudios`; ambos códigos → `curso` | Tipo obligatorio; valores `Requisito previo` y `Correquisito` | Se conservan los roles diferenciados de curso objetivo y curso exigido, así como la clave compuesta del modelo relacional. |

## 4. Decisiones de diseño físico

Se utilizaron identificadores `INTEGER` para las entidades cuyos identificadores internos quedaron provisionales en el Proyecto 1. Los códigos institucionales de cursos se representan mediante `TEXT`, ya que contienen caracteres alfanuméricos.

Se utilizan claves primarias y foráneas para garantizar identidad e integridad referencial. Los atributos definidos como obligatorios se implementan mediante `NOT NULL`, y los dominios cerrados mediante `CHECK`.

La clave primaria de `participacion_plan` permite distinguir un mismo curso en diferentes versiones. La clave primaria de `requisito_curso` permite registrar múltiples cursos exigidos, diferenciando requisitos previos y correquisitos.

Las siguientes decisiones son provisionales:

- **Vigencia:** `TEXT NOT NULL`, porque el Proyecto 1 no establece una representación temporal concreta. No se verifica automáticamente la validez de los periodos.
- **Nivel o periodo recomendado:** `TEXT` nullable, porque el Proyecto 1 mantiene sin resolver su formato y obligatoriedad.
- **Cantidad de créditos:** `INTEGER NOT NULL`, interpretando la cantidad como un valor entero. El modelo original no establece un rango numérico ni precisa el tratamiento de créditos fraccionarios.

No se añadieron índices independientes de los creados por las claves primarias, restricciones `UNIQUE` adicionales, valores predeterminados ni eliminación en cascada, al no existir una necesidad documentada para ellos.

## 5. Datos de prueba

`02_datos.sql` incorpora información ficticia distribuida de la siguiente manera:

| Tabla | Registros |
|---|---:|
| `escuela` | 2 |
| `carrera` | 2 |
| `curso` | 8 |
| `version_plan_estudios` | 3 |
| `participacion_plan` | 16 |
| `requisito_curso` | 10 |
| **Total** | **41** |

Los datos permiten observar distintas versiones de una carrera, participación de un mismo curso en varios planes, variación de obligatoriedad y múltiples requisitos asociados a un curso.

Estos escenarios cubren las situaciones EV-02 y EV-03 documentadas en el análisis del Proyecto 1.

## 6. Consultas de negocio

El archivo `03_consultas.sql` contiene tres consultas:

| ID | Pregunta de negocio | Resultado esperado |
|---|---|---|
| Q01 | ¿Qué cursos componen la versión 102 del plan? | Siete cursos: seis obligatorios y uno optativo. |
| Q02 | ¿Qué requisitos tiene UH-BDAT1 en la versión 102? | Un requisito previo y dos correquisitos. |
| Q03 | ¿Cuántos cursos obligatorios y optativos tiene cada versión? | Versión 101: 5 y 1; versión 102: 6 y 1; versión 201: 2 y 1. |

Las consultas utilizan relaciones entre tablas y agregación mediante `COUNT` y `GROUP BY`.

Los resultados observados están registrados en [evidencias/resultados.md](evidencias/resultados.md).

## 7. Programación almacenada

**Pendiente de implementación y validación.**

Esta sección documentará las dos funciones, el procedimiento almacenado y la técnica procedimental adicional de `04_rutinas.sql`, incluyendo su propósito, parámetros, valores de retorno, reglas y ejemplos de ejecución.

## 8. Instrucciones de ejecución

### Requisitos

- Docker.
- Imagen `postgres:17`.
- Terminal PowerShell desde la raíz del repositorio.

### Preparación inicial

Crear una instancia local de PostgreSQL:

```powershell
docker run -d `
  --name bd1-lab03 `
  -e POSTGRES_USER=bd1 `
  -e POSTGRES_PASSWORD=bd1 `
  -e POSTGRES_DB=lab03_grupo03 `
  -v bd1_lab03_data:/var/lib/postgresql/data `
  postgres:17
```

Si el contenedor ya existe y está detenido, puede iniciarse mediante:

```powershell
docker start bd1-lab03
```

### Ejecutar los scripts

Desde la raíz del repositorio:

```powershell
docker cp .\lab03\grupo-03\sql bd1-lab03:/tmp/lab03_sql
```

Ejecutar en este orden:

```powershell
docker exec bd1-lab03 psql -X -v ON_ERROR_STOP=1 -U bd1 -d lab03_grupo03 -f /tmp/lab03_sql/01_esquema.sql

docker exec bd1-lab03 psql -X -v ON_ERROR_STOP=1 -U bd1 -d lab03_grupo03 -f /tmp/lab03_sql/02_datos.sql

docker exec bd1-lab03 psql -X -v ON_ERROR_STOP=1 -U bd1 -d lab03_grupo03 -f /tmp/lab03_sql/04_rutinas.sql

docker exec bd1-lab03 psql -X -v ON_ERROR_STOP=1 -U bd1 -d lab03_grupo03 -f /tmp/lab03_sql/03_consultas.sql

docker exec bd1-lab03 psql -X -v ON_ERROR_STOP=0 -U bd1 -d lab03_grupo03 -f /tmp/lab03_sql/05_pruebas.sql
```

La ejecución completa requiere que los cinco scripts estén implementados.

Los scripts de creación y carga están diseñados para ejecutarse una vez sobre una base vacía. Para repetir íntegramente el proceso debe utilizarse una nueva base de datos de laboratorio; no deben ejecutarse sobre una base que ya contenga las mismas tablas y registros.

### Reproducibilidad verificada

Se ejecutaron `01_esquema.sql`, `02_datos.sql` y `03_consultas.sql` sobre PostgreSQL 17.11 en una base independiente, utilizando el usuario `ci_runner`, sin privilegios de superusuario.

Los tres scripts se ejecutaron correctamente. La validación integral queda pendiente de incorporar las rutinas y las pruebas de integridad.

## 9. Limitaciones

Este subsistema registra los requisitos y correquisitos de cada versión del plan, pero no determina si un estudiante concreto puede matricular un curso.

Las reglas RN-06 y RN-18 requieren información de solicitudes de matrícula, resultados académicos y reconocimientos que no pertenece al fragmento seleccionado.

Asimismo, las representaciones físicas provisionales de `vigencia` y `nivel_o_periodo_recomendado` no permiten validar todas las propiedades temporales o académicas que podrían definirse posteriormente.

## 10. Evidencias

Los resultados de ejecución se documentan en [evidencias/resultados.md](evidencias/resultados.md).

Las evidencias de las rutinas y las seis pruebas de integridad se incorporarán después de su implementación.

## 11. Defensa individual

Los enlaces a los videos individuales se incorporarán antes de la entrega.

- **Santiago Víquez Zamora:** pendiente.
- **Felipe Salazar González:** pendiente.