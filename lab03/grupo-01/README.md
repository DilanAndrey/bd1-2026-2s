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



