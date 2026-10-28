# Laboratorio 3 — Grupo 01

¡Hola! Bienvenidos al repositorio del **Grupo 01** para el Laboratorio 3 del curso IC-4301 · Bases de Datos I.


_______________________________________________________________________________________________________________

# A1. Trazabilidad entre el modelo lógico y el diseño físico

## 1. Fragmento del modelo lógico utilizado

El subsistema seleccionado corresponde al proceso de **Atención Médica Efectiva, Diagnóstico Clínico y Prescripción Terapéutica** de la Clínica Los Robles, definido a partir de los macroprocesos PR-04 y PR-05 del Proyecto 1.

Este subsistema comprende seis relaciones del modelo lógico original, que permiten registrar las consultas realizadas, las observaciones clínicas versionadas, los diagnósticos identificados y los tratamientos prescritos.

**Relaciones seleccionadas:**

1. **CONSULTA** (`id_consulta`, `id_paciente`, `id_medico`, `id_cita`, `fecha_hora_inicio`, `motivo_clinico`, `resumen_general`).

2. **OBSERVACION_CLINICA** (`id_consulta`, `consecutivo_observacion`, `num_version`, `contenido_observacion`, `fecha_hora_registro`, `es_vigente`).

3. **DIAGNOSTICO** (`codigo_diagnostico`, `descripcion_diagnostico`).

4. **CONSULTA_DIAGNOSTICO_NM** (`id_consulta`, `codigo_diagnostico`, `tipo_categoria`, `condicion`).

5. **TRATAMIENTO** (`id_tratamiento`, `id_consulta`, `id_tratamiento_sustituido`, `tipo_tratamiento`, `instrucciones`, `fecha_inicio_prevista`, `fecha_fin_prevista`, `estado_actual`, `dosis`, `frecuencia`, `cantidad_sesiones`).

6. **TRATAMIENTO_DIAGNOSTICO_NM** (`id_tratamiento`, `codigo_diagnostico`).

**Cardinalidades conservadas:**

- CONSULTA → OBSERVACION_CLINICA: 1:N.
- CONSULTA → TRATAMIENTO: 1:N.
- CONSULTA ↔ DIAGNOSTICO: N:M, mediante CONSULTA_DIAGNOSTICO_NM.
- TRATAMIENTO ↔ DIAGNOSTICO: N:M, mediante TRATAMIENTO_DIAGNOSTICO_NM.
- TRATAMIENTO → TRATAMIENTO: relación recursiva 1:1 opcional, para registrar sustituciones.

Además, CONSULTA conserva sus referencias obligatorias a PACIENTE y MEDICO y su referencia opcional a CITA, según las reglas RN-16 y RN-17.

## 2. Matriz de trazabilidad lógico-física

La siguiente matriz establece la correspondencia entre las relaciones del Proyecto 1 y las tablas previstas para PostgreSQL.

**Convenciones:** PK = clave primaria; FK = clave foránea; NN = NOT NULL; UQ = UNIQUE; CK = CHECK.

| Relación lógica | Tabla física | Clave primaria | Claves foráneas | Restricciones relevantes | Justificación de cambios |
|---|---|---|---|---|---|
| CONSULTA | `consulta` | `id_consulta` | `id_paciente` → PACIENTE; `id_medico` → MEDICO; `id_cita` → CITA | NN para paciente, médico, fecha de inicio, motivo y resumen. `id_cita` admite NULL y es UQ. | Se conserva la estructura del Proyecto 1. Las referencias externas requieren tablas de soporte para implementar sus FK. |
| OBSERVACION_CLINICA | `observacion_clinica` | (`id_consulta`, `consecutivo_observacion`, `num_version`) | `id_consulta` → CONSULTA | NN en atributos obligatorios; CK `num_version >= 1`. Control de una sola versión vigente por observación. | Se mantiene la PK compuesta y el versionado histórico definido en RN-19 y S-13. Se propone reforzar la unicidad de la versión vigente. |
| DIAGNOSTICO | `diagnostico` | `codigo_diagnostico` | Ninguna | NN en código y descripción. Código único mediante PK. | Sin cambios estructurales. Se conserva el catálogo estandarizado de diagnósticos. |
| CONSULTA_DIAGNOSTICO_NM | `consulta_diagnostico_nm` | (`id_consulta`, `codigo_diagnostico`) | `id_consulta` → CONSULTA; `codigo_diagnostico` → DIAGNOSTICO | NN en ambas FK, `tipo_categoria` y `condicion`. CK de los dominios permitidos. | Sin cambios. Materializa la relación N:M y conserva la clasificación clínica de cada diagnóstico. |
| TRATAMIENTO | `tratamiento` | `id_tratamiento` | `id_consulta` → CONSULTA; `id_tratamiento_sustituido` → TRATAMIENTO | NN en consulta, tipo, instrucciones, inicio previsto y estado. UQ y NULL permitidos en la FK recursiva. CK de fechas, tipos y estados. | Sin cambios de cardinalidad. Se conserva la sustitución 1:1 opcional y las fechas incorporadas en la versión corregida del Proyecto 1. |
| TRATAMIENTO_DIAGNOSTICO_NM | `tratamiento_diagnostico_nm` | (`id_tratamiento`, `codigo_diagnostico`) | `id_tratamiento` → TRATAMIENTO; `codigo_diagnostico` → DIAGNOSTICO | Ambas FK son NN. La PK compuesta impide duplicar la asociación. | Sin cambios. Materializa la relación N:M entre tratamientos y diagnósticos. |

## 3. Justificación de las decisiones de diseño físico

La transformación del modelo lógico al físico mantiene los nombres, identificadores y cardinalidades definidos en el Proyecto 1.

Las decisiones principales son:

**Conservación de las claves compuestas.** Las tablas OBSERVACION_CLINICA, CONSULTA_DIAGNOSTICO_NM y TRATAMIENTO_DIAGNOSTICO_NM mantienen sus identificadores originales, evitando introducir claves artificiales innecesarias.

**Integridad de las relaciones.** Las asociaciones 1:N se representan mediante claves foráneas, mientras que las relaciones N:M se materializan mediante las tablas asociativas correspondientes.

**Versionado clínico.** OBSERVACION_CLINICA conserva `num_version` y `es_vigente`, de acuerdo con RN-19 y S-13. Se propone utilizar un índice único parcial para impedir que una misma observación tenga más de una versión marcada como vigente. Esta medida complementa el modelo lógico sin modificar su cardinalidad.

**Sustitución de tratamientos.** TRATAMIENTO conserva `id_tratamiento_sustituido` como clave foránea recursiva, opcional y única, de acuerdo con RN-26. Esto permite identificar la indicación anterior sin sobrescribirla.

**Restricciones de dominio.** Los valores permitidos para categorías diagnósticas, condiciones, tipos de tratamiento y estados se conservarán mediante restricciones CHECK de PostgreSQL, siguiendo las reglas RN-20, RN-25, RN-26 y el supuesto S-16.

## 4. Dependencias externas y limitaciones

El subsistema clínico depende de las relaciones PACIENTE, MEDICO y CITA, pertenecientes a otros procesos de la clínica.

Para conservar la integridad referencial en PostgreSQL, será necesario incorporar las estructuras externas mínimas que permitan definir estas referencias, o ampliar el alcance del esquema físico. Cualquier simplificación de dichas estructuras deberá quedar documentada.

Las seis relaciones seleccionadas constituyen el núcleo funcional del laboratorio. Las estructuras externas que se incorporen actuarán únicamente como soporte de las dependencias del proceso clínico, sin desarrollar la totalidad de los módulos de admisión, personal médico y agendamiento.

De esta manera, se mantiene la trazabilidad entre el diseño lógico original y su implementación física, identificando las restricciones verificables y las limitaciones propias del subsistema seleccionado.



























## B1. Datos representativos (7 puntos)

### Descripción de la carga de datos

Para comprobar el funcionamiento del subsistema de Atención Médica Efectiva, Diagnóstico Clínico y Prescripción Terapéutica de la Clínica Los Robles, se elaboró el archivo `02_datos.sql`, que contiene un conjunto de 24 registros ficticios distribuidos entre las seis tablas seleccionadas del modelo lógico del Proyecto 1.

Los datos fueron diseñados para representar situaciones habituales del proceso de atención médica, respetando los identificadores, atributos, relaciones y restricciones definidos en el esquema físico `01_esquema.sql`.

La carga de datos permite representar consultas médicas, diagnósticos, observaciones clínicas versionadas, tratamientos prescritos y asociaciones entre las diferentes entidades, proporcionando una base para desarrollar las consultas de negocio y las pruebas de integridad de los siguientes apartados del laboratorio.

### Distribución de los datos

| Tabla | Cantidad de registros | Propósito |
|---|---:|---|
| `diagnostico` | 3 | Registrar un catálogo de diagnósticos médicos estandarizados. |
| `consulta` | 3 | Representar consultas programadas, urgencias y consultas de control. |
| `observacion_clinica` | 5 | Demostrar el registro de observaciones y la conservación de versiones anteriores. |
| `consulta_diagnostico_nm` | 4 | Asociar diagnósticos con consultas y establecer su categoría y condición clínica. |
| `tratamiento` | 4 | Registrar indicaciones terapéuticas, fechas previstas, estados y sustituciones. |
| `tratamiento_diagnostico_nm` | 5 | Representar la relación muchos a muchos entre tratamientos y diagnósticos. |
| **Total** | **24** | **Conjunto de datos representativo del subproceso clínico.** |

### Escenarios de negocio representados

**1. Consultas médicas programadas y atención de urgencia (RN-16 y RN-17).**

Se prepararon tres consultas que representan diferentes situaciones de atención: una consulta programada por síntomas respiratorios, una atención de urgencia sin cita previa y una consulta posterior de control.

La consulta de urgencia utiliza un valor `NULL` en el campo `id_cita`, demostrando que una atención médica puede realizarse sin una cita programada. Las tres consultas conservan identificadores de paciente y médico responsable, conforme a las reglas del modelo.

**2. Registro y corrección de observaciones clínicas (RN-19 y S-13).**

Se incluyeron cinco registros de observaciones clínicas, entre los cuales se encuentran dos versiones de una misma observación perteneciente a la consulta 5001.

La primera versión permanece almacenada con `es_vigente = FALSE`, mientras que la versión corregida se identifica con `es_vigente = TRUE`. Esto permite representar la conservación del historial clínico sin eliminar la anotación original.

**3. Clasificación de diagnósticos médicos (RN-20).**

Se registraron tres diagnósticos del catálogo y cuatro asociaciones entre consultas y diagnósticos.

Estas asociaciones incluyen diagnósticos principales y secundarios, así como condiciones confirmadas y presuntivas. Además, una misma consulta presenta varios diagnósticos y un diagnóstico aparece en distintas consultas, demostrando la relación muchos a muchos establecida en el modelo lógico.

**4. Prescripción y sustitución de tratamientos (RN-21, RN-25 y RN-26).**

Se prepararon cuatro tratamientos con diferentes tipos, estados, instrucciones y fechas previstas.

Entre ellos, el tratamiento 7002 sustituye al tratamiento 7001 mediante el atributo `id_tratamiento_sustituido`. Ambos registros se conservan para representar la trazabilidad de las indicaciones terapéuticas.

También se incluyen tratamientos con fechas de finalización definidas y otros sin fecha de finalización, así como atributos opcionales de dosis, frecuencia y cantidad de sesiones.

**5. Asociación entre tratamientos y diagnósticos (RN-21).**

Se incorporaron cinco registros en `tratamiento_diagnostico_nm`, permitiendo relacionar un tratamiento con varios diagnósticos y un diagnóstico con distintos tratamientos.

Por ejemplo, el tratamiento 7001 se relaciona con los diagnósticos J06.9 y R50.9, mientras que J06.9 aparece asociado con los tratamientos 7001, 7002 y 7003.

Esto permite representar la cardinalidad muchos a muchos definida en el Proyecto 1.

### Justificación de la suficiencia de los datos

El conjunto de 24 registros se considera suficiente para los objetivos del laboratorio porque incorpora diferentes escenarios clínicos y permite observar el comportamiento de las relaciones entre las seis tablas, sin necesidad de generar grandes cantidades de información repetitiva.

Los registros permiten comprobar las relaciones uno a muchos entre consultas, observaciones y tratamientos, así como las relaciones muchos a muchos entre consultas, diagnósticos y tratamientos.

Asimismo, se incluyen valores opcionales, diferentes estados clínicos, observaciones con múltiples versiones y tratamientos vinculados mediante una relación recursiva.

Los registros se prepararon respetando las claves primarias y los valores permitidos por las restricciones declaradas en el esquema. Los identificadores externos de pacientes, médicos y citas se mantienen conforme al alcance reducido documentado para el laboratorio; su existencia no queda verificada mediante claves foráneas en el esquema proporcionado.

### Conclusión

La carga de datos propuesta para `02_datos.sql` proporciona un conjunto coherente y representativo del proceso clínico seleccionado de la Clínica Los Robles.

Los datos permiten ejemplificar las reglas de negocio RN-16, RN-17, RN-19, RN-20, RN-21, RN-25 y RN-26, y servirán como base para ejecutar las consultas de negocio del apartado B2 y las pruebas de integridad del apartado B3.

Toda la información utilizada es ficticia y tiene exclusivamente fines académicos, sin incluir datos personales reales de pacientes o profesionales médicos.

**Estado de validación:** los 24 registros corresponden a la carga preparada. Su inserción exitosa y los resultados observados deberán confirmarse mediante la ejecución de `02_datos.sql` en PostgreSQL.

## B2. Consultas de negocio (6 puntos)

### Descripción

Se elaboró el archivo `03_consultas.sql`, que contiene cuatro consultas SQL orientadas a responder preguntas relevantes para el proceso de Atención Médica Efectiva, Diagnóstico Clínico y Prescripción Terapéutica de la Clínica Los Robles.

Las consultas utilizan los datos ficticios preparados en `02_datos.sql` y permiten comprobar las relaciones entre consultas médicas, diagnósticos, tratamientos y observaciones clínicas.

### Q01. Diagnósticos registrados por consulta

**Pregunta de negocio:** ¿Qué diagnósticos se registraron en cada consulta médica?

**Regla relacionada:** RN-20.

Se utilizan operaciones `INNER JOIN` entre las tablas `consulta`, `consulta_diagnostico_nm` y `diagnostico` para obtener los diagnósticos asociados con cada atención, incluyendo su categoría y condición clínica.

**Resultado esperado:** cuatro asociaciones de diagnóstico correspondientes a las tres consultas registradas.

**Utilidad:** facilita revisar los diagnósticos establecidos durante cada consulta, diferenciando los principales de los secundarios y los confirmados de los presuntivos.

### Q02. Cantidad de diagnósticos por consulta

**Pregunta de negocio:** ¿Cuántos diagnósticos principales y secundarios tiene cada consulta médica?

**Regla relacionada:** RN-20.

Se utilizan las funciones de agregación `COUNT` y `SUM`, junto con `GROUP BY`, para contabilizar los diagnósticos asociados con cada consulta. Se emplea `LEFT JOIN` para incluir consultas que no tengan diagnósticos registrados.

**Resultado esperado:** la consulta 5001 tiene dos diagnósticos, mientras que las consultas 5002 y 5003 tienen uno cada una.

**Utilidad:** permite obtener un resumen de la cantidad y clasificación de los diagnósticos registrados en las atenciones médicas.

### Q03. Historial de sustitución de tratamientos

**Pregunta de negocio:** ¿Qué tratamientos han sustituido a otros y cuál es el estado registrado de ambos?

**Regla relacionada:** RN-26.

Se utiliza una operación `SELF JOIN` sobre la tabla `tratamiento`, aprovechando la clave foránea recursiva `id_tratamiento_sustituido` para recuperar el tratamiento anterior y el que lo reemplaza.

**Resultado esperado:** se identifica que el tratamiento 7002 sustituye al tratamiento 7001, conservando ambos registros y sus respectivos estados.

**Utilidad:** permite consultar la trazabilidad de las indicaciones terapéuticas sin perder el historial de los tratamientos sustituidos.

### Q04. Observaciones clínicas vigentes

**Pregunta de negocio:** ¿Cuáles son las versiones vigentes de las observaciones registradas en cada consulta?

**Reglas relacionadas:** RN-19 y S-13.

Se consulta la tabla `observacion_clinica`, utilizando el atributo `es_vigente` para filtrar las versiones identificadas como actuales.

**Resultado esperado:** cuatro observaciones vigentes. La observación 1 de la consulta 5001 se muestra en su segunda versión, conservándose la primera como información histórica.

**Utilidad:** facilita identificar las anotaciones clínicas actuales sin eliminar las versiones anteriores.

### Justificación de las consultas

Las cuatro consultas fueron seleccionadas porque responden a necesidades reales del subproceso clínico y permiten demostrar distintas técnicas de SQL.

Se incluyen consultas que combinan múltiples tablas, funciones de agregación, agrupamiento de resultados, una relación recursiva y filtrado de registros según su vigencia.

En conjunto, permiten comprobar el uso de las relaciones y atributos definidos en el modelo lógico del Proyecto 1, complementando los escenarios de prueba establecidos en B1.

**Estado:** se documentan resultados esperados a partir de los datos preparados. Los resultados observados y las evidencias deberán incorporarse después de ejecutar los scripts en PostgreSQL.


## B3. Pruebas de integridad (7 puntos)

### Descripción

Para verificar la integridad de los datos del subsistema de Atención Médica Efectiva, Diagnóstico Clínico y Prescripción Terapéutica de la Clínica Los Robles, se elaboró el archivo `05_pruebas.sql`.

El archivo contiene ocho pruebas de integridad diseñadas a partir de las restricciones establecidas en `01_esquema.sql` y las reglas de negocio del Proyecto 1.

Se incluyen tres pruebas válidas y cinco pruebas inválidas, con el propósito de comprobar tanto la aceptación de operaciones correctas como el rechazo de registros que incumplen las restricciones definidas.

### Pruebas realizadas y resultados esperados

| ID | Precondición | Sentencia de prueba | Resultado esperado |
|---|---|---|---|
| P01 | El identificador 5099 está disponible. | `INSERT` en CONSULTA con `id_cita = NULL`. | Inserción aceptada. |
| P02 | Existe la consulta 5099, insertada en P01. | `INSERT` en OBSERVACION_CLINICA con versión 1. | Inserción aceptada. |
| P03 | Existe la consulta 5099 y el ID 7099 está disponible. | `INSERT` en TRATAMIENTO con fechas y sesiones válidas. | Inserción aceptada. |
| P04 | Existe el diagnóstico J00. | `INSERT` en DIAGNOSTICO con código duplicado. | Rechazo por clave primaria. |
| P05 | No existe la consulta 999999. | `INSERT` en OBSERVACION_CLINICA con referencia inexistente. | Rechazo por clave foránea. |
| P06 | Existe la consulta 5099. | `INSERT` en OBSERVACION_CLINICA con `num_version = 0`. | Rechazo por CHECK. |
| P07 | Existe la consulta 5099. | `INSERT` en TRATAMIENTO con estado `Activo`. | Rechazo por CHECK. |
| P08 | El identificador 5098 está disponible. | `INSERT` en CONSULTA con `id_medico = NULL`. | Rechazo por NOT NULL. |

Las sentencias completas están documentadas e identificadas dentro de `05_pruebas.sql`.

### Mecanismo de ejecución

Para evitar que los errores esperados interrumpan el conjunto de pruebas, se utilizan bloques PL/pgSQL con manejo de excepciones.

Cada operación se evalúa según el resultado esperado y se registra en una tabla temporal de resultados, indicando si la restricción correspondiente se cumplió.

El conjunto se ejecuta dentro de una transacción que finaliza con `ROLLBACK`, evitando modificar permanentemente los registros cargados mediante `02_datos.sql`.

### Restricciones verificadas

Las pruebas permiten evaluar la unicidad de identificadores, la integridad referencial, la obligatoriedad de atributos, los rangos permitidos y los dominios cerrados.

Se comprueban específicamente las restricciones `pk_diagnostico`, `fk_observacion_consulta`, `ck_observacion_version_positiva`, `ck_tratamiento_estado` y la obligatoriedad de `consulta.id_medico`.

Estas restricciones están relacionadas principalmente con las reglas RN-16, RN-17, RN-19, RN-20, RN-21, RN-25 y RN-26.

### Resultados observados

**Pendiente de completar después de ejecutar `05_pruebas.sql` en PostgreSQL.**

El resultado esperado es que las ocho pruebas cumplan sus condiciones: tres inserciones aceptadas y cinco operaciones rechazadas por las restricciones correspondientes.

Los resultados efectivamente observados, las conclusiones de cada prueba y las evidencias de ejecución deberán incorporarse después de realizar la ejecución.

### Conclusión

El conjunto de pruebas propuesto permite verificar que el esquema físico acepta datos coherentes y rechaza operaciones que incumplen las restricciones implementadas.

Además, el mecanismo de ejecución permite evaluar las pruebas individualmente sin detener el conjunto ante errores esperados y sin modificar permanentemente los datos representativos del apartado B1.

La ejecución y documentación de los resultados observados permitirá determinar el grado de cumplimiento de las reglas de integridad implementadas en PostgreSQL.
