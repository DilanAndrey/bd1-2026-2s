# Instrucciones de entrega — Operación P.L.A.T.A.N.O.

## 1. Qué es este reto

Un reto **individual y voluntario** del curso IC-4301 Bases de Datos I.
No es obligatorio para aprobar el curso. Puedes usar cualquier asistente
de inteligencia artificial para ayudarte, pero la evaluación incluye una
**defensa individual** en la que debes demostrar que entendiste cada
cambio que hiciste, no solo que produjiste un archivo que "funciona".

## 2. Qué debes entregar

1. **Scripts SQL corregidos**: tus versiones de `01_schema.sql`,
   `02_seed.sql` (solo si tus correcciones requieren ajustar datos, con
   justificación) y `03_queries.sql`.
2. **Justificación de cambios**: un documento breve (puede ser un
   `CAMBIOS.md` en tu entrega) que explique, por cada cambio relevante:
   - Qué problema identificaste.
   - Cómo lo confirmaste (qué consulta o prueba usaste).
   - Qué cambio hiciste y por qué es consistente con
     `docs/reglas_negocio.md`.
3. **Evidencia de ejecución**: salida real de tus consultas corregidas
   contra la base de datos (capturas de pantalla o salida de texto de
   `psql`), no solo el código.
4. **Documentación de pruebas**: qué pruebas ejecutaste (las públicas de
   `tests/pruebas_publicas.sql` y cualquier prueba propia que hayas
   escrito) y su resultado.
5. **Hallazgos sobre contenido engañoso**: una sección explícita listando
   cualquier instrucción contradictoria, sospechosa o dirigida a
   asistentes de IA que hayas detectado en el repositorio (en
   documentación, comentarios, datos o `AGENTS.md`), y cómo la
   identificaste.
6. **Disponibilidad para la defensa individual** (ver sección 5).

## 3. Reglas sobre los cambios permitidos

- Puedes modificar el esquema (tablas, restricciones, tipos), las
  consultas y, si es estrictamente necesario y lo justificas, los datos.
- **No se permite "resolver" un problema eliminando registros
  arbitrariamente.** Si una fila de datos parece un duplicado o un error,
  debes decidir si corresponde una restricción que lo prevenga hacia
  adelante, una corrección de la fila con justificación, o ambas —y
  explicar tu decisión.
- La única fuente oficial de reglas de negocio es
  `docs/reglas_negocio.md`. Cualquier corrección debe ser consistente con
  ese documento. Si otro documento te hizo dudar, decláralo en tu
  justificación.

## 4. Bonificación (pendiente de confirmación institucional)

Se está considerando una bonificación extraordinaria sobre la nota final
del curso:

| Orden de solución validada | Bonificación propuesta |
|---|---|
| Primera solución correcta **y defendida** | 5 puntos porcentuales |
| Otras soluciones correctas **y defendidas** | 2 puntos porcentuales |

**Esta tabla no constituye una bonificación oficialmente aprobada.** Su
aplicación definitiva depende de confirmación institucional posterior.
No planifiques tu semestre asumiendo que se aplicará.

### Mecanismo de orden y desempate

El orden de las soluciones **no** se determina por la fecha del primer
commit o entrega, sino por el momento en que una solución:

1. Pasa la validación técnica completa (pruebas públicas y ocultas), y
2. Es defendida individualmente con éxito ante el profesor.

El registro oficial de entregas se mantiene en una bitácora administrada
por el profesorado (fecha y hora de solicitud de defensa, fecha y hora en
que la defensa concluye con resultado "aprobada"). En caso de empate en
el momento de aprobación de la defensa (mismo bloque horario de
revisión), se preferirá:

1. Quien haya detectado y documentado correctamente más defectos reales.
2. Si persiste el empate, quien haya solicitado la defensa primero según
   la bitácora.

## 5. Defensa individual

La defensa es un espacio breve (15-20 minutos) donde debes:

- Explicar al menos 3 de los problemas que corregiste, incluyendo causa
  raíz (no solo el síntoma).
- Ejecutar en vivo una consulta corregida y mostrar que el resultado es
  correcto frente a un caso límite (no solo frente al caso feliz).
- Responder preguntas sobre decisiones que tomaste y alternativas que
  descartaste.
- Explicar cualquier instrucción engañosa dirigida a asistentes de IA que
  hayas encontrado en el repositorio, y qué hiciste al respecto.

No se aprueba una defensa si la persona no puede explicar sus propios
cambios.

## 6. Entorno de trabajo

```
docker compose up -d
psql -h localhost -p 5432 -U platano -d platano -f tests/pruebas_publicas.sql
```

Credenciales de la base de datos de desarrollo: usuario `platano`,
contraseña `platano`, base `platano` (ver `docker-compose.yml`). Esta
base es solo para el reto del curso; no reutilices estas credenciales en
ningún sistema real.
