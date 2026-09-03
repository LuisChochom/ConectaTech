-- CONSULTA 1: Programa detallado de sesiones con discriminación de subtipo, sede y sala
SELECT 
    e.nombre AS edicion,
    s.id_sesion,
    s.titulo,
    s.tipo_sesion,
    s.fecha,
    s.hora_inicio,
    s.hora_fin,
    COALESCE(sa.nombre, 'VIRTUAL / SIN SALA') AS sala,
    COALESCE(c.minutos_preguntas, 0) AS qna_minutos,
    COALESCE(t.cupo_maximo, 0) AS taller_cupo,
    COALESCE(t.requisitos_materiales, 'N/A') AS requisitos
FROM SESION s
JOIN EDICION e ON s.id_edicion = e.id_edicion
LEFT JOIN SALA sa ON s.id_sala = sa.id_sala
LEFT JOIN CHARLA c ON s.id_sesion = c.id_sesion
LEFT JOIN TALLER t ON s.id_sesion = t.id_sesion
ORDER BY s.fecha, s.hora_inicio;

-- CONSULTA 2: Ocupación y porcentaje de cupo en Talleres prácticos
SELECT 
    t.id_sesion,
    s.titulo AS taller,
    t.cupo_maximo,
    COUNT(i.id_inscripcion) AS total_inscritos,
    (t.cupo_maximo - COUNT(i.id_inscripcion)) AS cupos_disponibles,
    ROUND((COUNT(i.id_inscripcion)::numeric / t.cupo_maximo) * 100, 2) AS porcentaje_ocupacion
FROM TALLER t
JOIN SESION s ON t.id_sesion = s.id_sesion
LEFT JOIN INSCRIPCION_SESION i ON s.id_sesion = i.id_sesion AND i.estado = 'CONFIRMADA'
GROUP BY t.id_sesion, s.titulo, t.cupo_maximo;

-- CONSULTA 3: Participantes de doble rol (Demostración de Jerarquía Solapada: Asistente y Ponente)
SELECT 
    p.id_persona,
    p.nombre_completo,
    p.correo,
    e.nombre AS edicion,
    a.tipo_acreditacion,
    po.biografia
FROM PERSONA p
JOIN PARTICIPACION_EDICION pe ON p.id_persona = pe.id_persona
JOIN EDICION e ON pe.id_edicion = e.id_edicion
JOIN ASISTENTE a ON pe.id_participacion = a.id_participacion
JOIN PONENTE po ON pe.id_participacion = po.id_participacion;

-- CONSULTA 4: Árbol de Prerrequisitos de Programación (Relación Recursiva)
SELECT 
    s_obj.id_sesion AS id_sesion_avanzada,
    s_obj.titulo AS sesion_avanzada,
    s_req.id_sesion AS id_prerrequisito,
    s_req.titulo AS sesion_requerida_previa
FROM SESION_PRERREQUISITO sp
JOIN SESION s_obj ON sp.id_sesion = s_obj.id_sesion
JOIN SESION s_req ON sp.id_prerrequisito = s_req.id_sesion;

-- CONSULTA 5: Resumen de Patrocinios Corporativos por Edición
SELECT 
    e.nombre AS edicion,
    emp.nombre_comercial AS empresa,
    ap.categoria,
    TO_CHAR(ap.monto, 'L999,999.00') AS aporte_financiero,
    ap.fecha_confirmacion
FROM ACUERDO_PATROCINIO ap
JOIN EDICION e ON ap.id_edicion = e.id_edicion
JOIN EMPRESA emp ON ap.id_empresa = emp.id_empresa
ORDER BY ap.monto DESC;