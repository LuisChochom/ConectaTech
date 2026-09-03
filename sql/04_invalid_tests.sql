-- ============================================================================
-- SUITE DE PRUEBAS: VALIDACIÓN DE RESTRICCIONES DE INTEGRIDAD
-- ============================================================================

-- CASO 1: Violación de Unicidad (Duplicado)
-- Intento: Inscribir dos veces al mismo asistente (participación 1) en la sesión 1
-- Restricción esperada: uq_asistente_sesion
-- Mensaje esperado: duplicate key value violates unique constraint "uq_asistente_sesion"
\echo '>>> EJECUTANDO CASO 1: Registro Duplicado...'
INSERT INTO INSCRIPCION_SESION (id_participacion, id_sesion, estado) 
VALUES (1, 1, 'CONFIRMADA');

-- CASO 2: Violación de Clave Foránea (FK Inexistente)
-- Intento: Insertar una sesión apuntando a una edición que no existe (id_edicion = 9999)
-- Restricción esperada: sesion_id_edicion_fkey
-- Mensaje esperado: insert or update on table "sesion" violates foreign key constraint "sesion_id_edicion_fkey"
\echo '>>> EJECUTANDO CASO 2: FK Inexistente...'
INSERT INTO SESION (id_edicion, id_sala, titulo, resumen, fecha, hora_inicio, hora_fin, tipo_sesion)
VALUES (9999, 1, 'Hacking Rust', 'Resumen', '2026-10-15', '10:00:00', '11:00:00', 'CHARLA');

-- CASO 3: Violación de Dominio / CHECK
-- Intento: Registrar un taller con cupo cero o negativo
-- Restricción esperada: taller_cupo_maximo_check
-- Mensaje esperado: new row for table "taller" violates check constraint "taller_cupo_maximo_check"
\echo '>>> EJECUTANDO CASO 3: Valor fuera de dominio (CHECK cupo > 0)...'
INSERT INTO TALLER (id_sesion, cupo_maximo, requisitos_materiales)
VALUES (1, -5, 'Laptop');

-- CASO 4: Dato Obligatorio Ausente (NOT NULL)
-- Intento: Registrar una persona sin nombre completo
-- Restricción esperada: persona_nombre_completo_not_null
-- Mensaje esperado: null value in column "nombre_completo" of relation "persona" violates not-null constraint
\echo '>>> EJECUTANDO CASO 4: Campo obligatorio ausente (NOT NULL)...'
INSERT INTO PERSONA (nombre_completo, correo, pais)
VALUES (NULL, 'sin_nombre@tech.com', 'Guatemala');

-- CASO 5: Autorrelación Inválida (Restricción Recursiva)
-- Intento: Asignar una sesión como prerrequisito de sí misma (id_sesion = 2 e id_prerrequisito = 2)
-- Restricción esperada: chk_no_autorequisito
-- Mensaje esperado: new row for table "sesion_prerrequisito" violates check constraint "chk_no_autorequisito"
\echo '>>> EJECUTANDO CASO 5: Autorrequisito inválido...'
INSERT INTO SESION_PRERREQUISITO (id_sesion, id_prerrequisito)
VALUES (2, 2);

-- CASO 6 (Adicional): Superposición Horaria de Sala (EXCLUDE USING gist)
-- Intento: Alojar una sesión en la Sala 2 el 2026-10-15 de 09:30 a 11:30 (colisiona con Sesión 1 que ocupa de 09:00 a 10:30)
-- Restricción esperada: ex_sala_horario_no_solapado
-- Mensaje esperado: conflicting key value violates exclusion constraint "ex_sala_horario_no_solapado"
\echo '>>> EJECUTANDO CASO 6: Solapamiento temporal en la misma sala...'
INSERT INTO SESION (id_edicion, id_sala, titulo, resumen, fecha, hora_inicio, hora_fin, tipo_sesion)
VALUES (1, 2, 'Colisión de Sala', 'Intento solapado', '2026-10-15', '09:30:00', '11:30:00', 'CHARLA');