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