erDiagram
    SEDE ||--o{ SALA : "alberga"
    SEDE ||--o{ EDICION : "aloja"
    EDICION ||--o{ SESION : "organiza"
    EDICION ||--o{ PARTICIPACION_EDICION : "registra"
    EDICION ||--o{ ACUERDO_PATROCINIO : "recibe"
    
    EMPRESA ||--o{ ACUERDO_PATROCINIO : "financia"

    SALA ||--o{ SESION : "alberga"

    PERSONA ||--o{ PARTICIPACION_EDICION : "participa"

    %% Jerarquia Solapada y Total: Una persona en una edicion es Asistente, Ponente o ambos
    PARTICIPACION_EDICION ||--o| ASISTENTE : "puede ser"
    PARTICIPACION_EDICION ||--o| PONENTE : "puede ser"

    %% Jerarquia Disjunta y Total: Una sesion es exactamente Charla o Taller
    SESION ||--o| CHARLA : "especializa como"
    SESION ||--o| TALLER : "especializa como"

    %% Relacion recursiva N:M para prerrequisitos tecnicos de programacion
    SESION ||--o{ SESION_PRERREQUISITO : "requiere previa"
    SESION ||--o{ SESION_PRERREQUISITO : "es base de"

    %% Entidades Asociativas
    ASISTENTE ||--o{ INSCRIPCION_SESION : "realiza"
    SESION ||--o{ INSCRIPCION_SESION : "admite"

    PONENTE ||--o{ ASIGNACION_PONENTE : "interviene"
    SESION ||--o{ ASIGNACION_PONENTE : "cuenta con"