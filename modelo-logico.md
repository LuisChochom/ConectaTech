erDiagram
    SEDE {
        int id_sede PK
        varchar nombre
        varchar ciudad
        varchar direccion
    }

    SALA {
        int id_sala PK
        int id_sede FK
        varchar nombre
        int capacidad
    }

    EDICION {
        int id_edicion PK
        int id_sede FK
        varchar nombre
        smallint anio
        date fecha_inicio
        date fecha_fin
        varchar modalidad
        varchar estado
    }

    PERSONA {
        int id_persona PK
        varchar nombre_completo
        varchar correo UK
        varchar pais
    }

    PARTICIPACION_EDICION {
        int id_participacion PK
        int id_persona FK
        int id_edicion FK
    }

    ASISTENTE {
        int id_participacion PK, FK
        varchar tipo_acreditacion
    }

    PONENTE {
        int id_participacion PK, FK
        text biografia
    }

    SESION {
        int id_sesion PK
        int id_edicion FK
        int id_sala FK
        varchar titulo
        text resumen
        date fecha
        time hora_inicio
        time hora_fin
        varchar url_transmision
        varchar tipo_sesion
    }

    CHARLA {
        int id_sesion PK, FK
        int minutos_preguntas
    }

    TALLER {
        int id_sesion PK, FK
        int cupo_maximo
        text requisitos_materiales
    }

    SESION_PRERREQUISITO {
        int id_sesion PK, FK
        int id_prerrequisito PK, FK
    }

    INSCRIPCION_SESION {
        int id_inscripcion PK
        int id_participacion FK
        int id_sesion FK
        timestamptz fecha_registro
        varchar estado
        boolean asistio
    }

    ASIGNACION_PONENTE {
        int id_sesion PK, FK
        int id_participacion PK, FK
        varchar rol_ponente
        int orden_presentacion
    }

    EMPRESA {
        int id_empresa PK
        varchar nombre_comercial UK
        varchar sitio_web
    }

    ACUERDO_PATROCINIO {
        int id_acuerdo PK
        int id_empresa FK
        int id_edicion FK
        varchar categoria
        numeric monto
        date fecha_confirmacion
    }

    SEDE ||--o{ SALA : "has"
    SEDE ||--o{ EDICION : "hosts"
    EDICION ||--o{ SESION : "contains"
    SALA ||--o{ SESION : "hosts_session"
    EDICION ||--o{ PARTICIPACION_EDICION : "admits"
    PERSONA ||--o{ PARTICIPACION_EDICION : "subscribes"
    PARTICIPACION_EDICION ||--o| ASISTENTE : "is_attendee"
    PARTICIPACION_EDICION ||--o| PONENTE : "is_speaker"
    SESION ||--o| CHARLA : "specializes_to"
    SESION ||--o| TALLER : "specializes_to"
    SESION ||--o{ SESION_PRERREQUISITO : "origin"
    SESION ||--o{ SESION_PRERREQUISITO : "dependency"
    ASISTENTE ||--o{ INSCRIPCION_SESION : "enrolls"
    SESION ||--o{ INSCRIPCION_SESION : "accepts"
    PONENTE ||--o{ ASIGNACION_PONENTE : "speaks_in"
    SESION ||--o{ ASIGNACION_PONENTE : "has_speaker"
    EMPRESA ||--o{ ACUERDO_PATROCINIO : "funds"
    EDICION ||--o{ ACUERDO_PATROCINIO : "receives_funds"