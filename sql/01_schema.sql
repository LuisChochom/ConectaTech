-- Extensión requerida para índices GiST en tipos escalares y rangos
CREATE EXTENSION IF NOT EXISTS btree_gist;

DROP TABLE IF EXISTS ACUERDO_PATROCINIO CASCADE;
DROP TABLE IF EXISTS EMPRESA CASCADE;
DROP TABLE IF EXISTS ASIGNACION_PONENTE CASCADE;
DROP TABLE IF EXISTS INSCRIPCION_SESION CASCADE;
DROP TABLE IF EXISTS SESION_PRERREQUISITO CASCADE;
DROP TABLE IF EXISTS TALLER CASCADE;
DROP TABLE IF EXISTS CHARLA CASCADE;
DROP TABLE IF EXISTS SESION CASCADE;
DROP TABLE IF EXISTS PONENTE CASCADE;
DROP TABLE IF EXISTS ASISTENTE CASCADE;
DROP TABLE IF EXISTS PARTICIPACION_EDICION CASCADE;
DROP TABLE IF EXISTS PERSONA CASCADE;
DROP TABLE IF EXISTS SALA CASCADE;
DROP TABLE IF EXISTS EDICION CASCADE;
DROP TABLE IF EXISTS SEDE CASCADE;

CREATE TABLE SEDE (
    id_sede INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    direccion VARCHAR(200) NOT NULL
);

CREATE TABLE SALA (
    id_sala INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_sede INT NOT NULL REFERENCES SEDE(id_sede) ON DELETE RESTRICT,
    nombre VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0),
    CONSTRAINT uq_sala_sede UNIQUE (id_sede, nombre)
);

CREATE TABLE EDICION (
    id_edicion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    anio SMALLINT NOT NULL CHECK (anio >= 2020),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    modalidad VARCHAR(15) NOT NULL CHECK (modalidad IN ('PRESENCIAL', 'VIRTUAL', 'HIBRIDA')),
    estado VARCHAR(20) NOT NULL DEFAULT 'PLANIFICACION' CHECK (estado IN ('PLANIFICACION', 'ABIERTA', 'EN_CURSO', 'CONCLUIDA', 'CANCELADA')),
    id_sede INT REFERENCES SEDE(id_sede) ON DELETE SET NULL,
    CONSTRAINT chk_edicion_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_edicion_sede_modalidad CHECK (
        (modalidad = 'VIRTUAL' AND id_sede IS NULL) OR 
        (modalidad IN ('PRESENCIAL', 'HIBRIDA') AND id_sede IS NOT NULL)
    )
);

CREATE TABLE PERSONA (
    id_persona INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    pais VARCHAR(60) NOT NULL
);

CREATE TABLE PARTICIPACION_EDICION (
    id_participacion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_persona INT NOT NULL REFERENCES PERSONA(id_persona) ON DELETE CASCADE,
    id_edicion INT NOT NULL REFERENCES EDICION(id_edicion) ON DELETE CASCADE,
    CONSTRAINT uq_persona_edicion UNIQUE (id_persona, id_edicion)
);

-- Subtipos de Participación (Jerarquía Solapada)
CREATE TABLE ASISTENTE (
    id_participacion INT PRIMARY KEY REFERENCES PARTICIPACION_EDICION(id_participacion) ON DELETE CASCADE,
    tipo_acreditacion VARCHAR(30) NOT NULL CHECK (tipo_acreditacion IN ('ESTUDIANTE', 'PROFESIONAL', 'VIP'))
);

CREATE TABLE PONENTE (
    id_participacion INT PRIMARY KEY REFERENCES PARTICIPACION_EDICION(id_participacion) ON DELETE CASCADE,
    biografia TEXT NOT NULL CHECK (length(trim(biografia)) >= 10)
);

CREATE TABLE SESION (
    id_sesion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_edicion INT NOT NULL REFERENCES EDICION(id_edicion) ON DELETE CASCADE,
    id_sala INT REFERENCES SALA(id_sala) ON DELETE RESTRICT,
    titulo VARCHAR(150) NOT NULL,
    resumen TEXT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    url_transmision VARCHAR(255),
    tipo_sesion VARCHAR(10) NOT NULL CHECK (tipo_sesion IN ('CHARLA', 'TALLER')),
    CONSTRAINT chk_sesion_horas CHECK (hora_fin > hora_inicio),
    -- Protección contra solapamiento temporal en la misma sala física
    CONSTRAINT ex_sala_horario_no_solapado EXCLUDE USING gist (
        id_sala WITH =,
        tsrange(
            (fecha + hora_inicio)::timestamp,
            (fecha + hora_fin)::timestamp,
            '[)'
        ) WITH &&
    ) WHERE (id_sala IS NOT NULL)
);

-- Subtipos de Sesión (Jerarquía Disjunta y Total)
CREATE TABLE CHARLA (
    id_sesion INT PRIMARY KEY REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    minutos_preguntas INT NOT NULL DEFAULT 10 CHECK (minutos_preguntas BETWEEN 0 AND 60)
);

CREATE TABLE TALLER (
    id_sesion INT PRIMARY KEY REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    cupo_maximo INT NOT NULL CHECK (cupo_maximo > 0),
    requisitos_materiales TEXT NOT NULL
);

-- Relación Recursiva N:M
CREATE TABLE SESION_PRERREQUISITO (
    id_sesion INT NOT NULL REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    id_prerrequisito INT NOT NULL REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    PRIMARY KEY (id_sesion, id_prerrequisito),
    CONSTRAINT chk_no_autorequisito CHECK (id_sesion <> id_prerrequisito)
);

-- Entidad Asociativa: Asistente a Sesión
CREATE TABLE INSCRIPCION_SESION (
    id_inscripcion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_participacion INT NOT NULL REFERENCES ASISTENTE(id_participacion) ON DELETE CASCADE,
    id_sesion INT NOT NULL REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADA' CHECK (estado IN ('CONFIRMADA', 'CANCELADA', 'EN_ESPERA')),
    asistio BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_asistente_sesion UNIQUE (id_participacion, id_sesion)
);

-- Entidad Asociativa: Ponente a Sesión
CREATE TABLE ASIGNACION_PONENTE (
    id_sesion INT NOT NULL REFERENCES SESION(id_sesion) ON DELETE CASCADE,
    id_participacion INT NOT NULL REFERENCES PONENTE(id_participacion) ON DELETE CASCADE,
    rol_ponente VARCHAR(50) NOT NULL DEFAULT 'ORADOR_PRINCIPAL' CHECK (rol_ponente IN ('ORADOR_PRINCIPAL', 'CO_DISERTANTE', 'MODERADOR')),
    orden_presentacion INT NOT NULL CHECK (orden_presentacion >= 1),
    PRIMARY KEY (id_sesion, id_participacion),
    CONSTRAINT uq_sesion_orden_ponente UNIQUE (id_sesion, orden_presentacion)
);

CREATE TABLE EMPRESA (
    id_empresa INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_comercial VARCHAR(100) NOT NULL UNIQUE,
    sitio_web VARCHAR(150)
);

-- Entidad Asociativa: Patrocinio por Edición
CREATE TABLE ACUERDO_PATROCINIO (
    id_acuerdo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa INT NOT NULL REFERENCES EMPRESA(id_empresa) ON DELETE RESTRICT,
    id_edicion INT NOT NULL REFERENCES EDICION(id_edicion) ON DELETE CASCADE,
    categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('PLATINUM', 'GOLD', 'SILVER', 'BRONZE')),
    monto NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
    fecha_confirmacion DATE NOT NULL,
    CONSTRAINT uq_empresa_edicion UNIQUE (id_empresa, id_edicion)
);