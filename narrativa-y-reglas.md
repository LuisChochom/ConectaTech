# Análisis de Dominio: Congreso ConectaTech

## 1. Hechos Explícitos de la Narrativa
1. ConectaTech organiza ediciones presenciales, virtuales e híbridas por año y ciudad.
2. Cada edición presencial o híbrida requiere una sede con salas; las virtuales emplean plataformas de streaming.
3. Una sala posee nombre y capacidad, impidiendo la superposición temporal de sesiones.
4. Las personas se registran con nombre, correo electrónico y país.
5. En una edición, una persona puede participar como asistente, ponente o ambos (al menos uno).
6. Los asistentes seleccionan una acreditación; los ponentes registran una biografía.
7. Las sesiones tienen título, resumen, fecha, hora inicial y final, clasificándose como charla o taller.
8. Las charlas indican minutos de preguntas; los talleres definen cupo y lista de materiales requeridos.
9. Existen sesiones que exigen prerrequisitos de sesiones previas, sin admitir autorreferencia.
10. Un asistente puede inscribirse a múltiples sesiones; la inscripción guarda fecha, estado y asistencia.
11. Múltiples ponentes pueden intervenir en una sesión con orden de aparición y rol.
12. Las empresas patrocinadoras suscriben convenios con categoría, aporte financiero y fecha de confirmación.

## 2. Supuestos Adoptados
1. El congreso orienta su agenda a tecnologías de software (cursos y conferencias de Python, Rust, Go, TypeScript, C++, etc.).
2. Toda sesión pertenece unívocamente a una edición del congreso.
3. Las horas iniciales y finales de una sesión deben pertenecer a la misma fecha calendarizada y mantener coherencia temporal (`hora_fin > hora_inicio`).
4. Para sesiones netamente virtuales, la sala física es nula, requiriendo un URL de transmisión.

## 3. Decisiones Propias de Modelado
1. **Jerarquía de Sesiones (Disjunta y Total):** Implementada mediante tabla por subclase (`CHARLA` y `TALLER`), donde la PK es foránea hacia `SESION`.
2. **Jerarquía de Roles de Participación (Solapada y Total):** Modelada mediante registro de inscripción por edición (`PARTICIPACION_EDICION`) y dos tablas hijas opcionales (`ASISTENTE` y `PONENTE`) vinculadas 1:1 con la participación, asegurando que un individuo posea al menos uno de los dos roles mediante un constraint trigger o validación relacional.
3. **Restricción de Superposición de Salas:** Implementada en PostgreSQL mediante la extensión `btree_gist` y una restricción `EXCLUDE USING gist` sobre el identificador de sala y el rango temporal `tsrange`.

## 4. Catálogo de Reglas de Negocio (RN)
* **RN-01 (Fechas de Edición):** La fecha final de una edición no puede ser previa a su fecha de apertura.
* **RN-02 (Rango Horario de Sesión):** La hora final de una sesión debe ser estrictamente posterior a la hora inicial.
* **RN-03 (Exclusión de Salas):** Una sala física no puede albergar dos sesiones simultáneas en un mismo intervalo de tiempo.
* **RN-04 (No Autorreferencia de Prerrequisito):** Una sesión no puede ser prerrequisito directo de sí misma (`id_sesion != id_prerrequisito`).
* **RN-05 (Unicidad de Inscripción):** Un asistente solo puede inscribirse una vez por sesión (`UNIQUE(id_asistente, id_sesion)`).
* **RN-06 (Orden de Ponencia):** El orden de presentación de un ponente en una sesión debe ser un entero positivo (`orden_presentacion >= 1`).
* **RN-07 (Acuerdo Único de Patrocinio):** Una empresa únicamente puede registrar un acuerdo formal activo por edición (`UNIQUE(id_empresa, id_edicion)`).
* **RN-08 (Tiempo de Preguntas):** Las charlas deben asignar entre 0 y 60 minutos para preguntas de los participantes.
* **RN-09 (Cupo de Taller):** El cupo de un taller de programación debe ser un entero positivo (`cupo_maximo > 0`).
* **RN-10 (Monto de Patrocinio):** El monto financiero de patrocinio debe ser estrictamente positivo (`monto > 0`).
* **RN-11 (Participación Obligatoria):** Toda persona registrada en una edición debe ser especializada como asistente, ponente o ambos.
* **RN-12 (Integridad de Modalidad):** Sesiones presenciales exigen sala asignada; sesiones puramente virtuales exigen enlace de streaming.