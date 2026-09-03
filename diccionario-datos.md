# Diccionario de Datos: ConectaTech

### 1. EDICION
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_edicion` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria subrogada. |
| `nombre` | `VARCHAR(100)` | NO | | Nombre formal del congreso. |
| `anio` | `SMALLINT` | NO | CHECK (anio >= 2020) | Año de realización. |
| `fecha_inicio` | `DATE` | NO | | Fecha de inauguración. |
| `fecha_fin` | `DATE` | NO | | Fecha de clausura. |
| `modalidad` | `VARCHAR(15)` | NO | CHECK IN ('PRESENCIAL', 'VIRTUAL', 'HIBRIDA') | Tipo de evento. |
| `estado` | `VARCHAR(20)` | NO | DEFAULT 'PLANIFICACION' | Estado operativo. |
| `id_sede` | `INT` | SÍ | FK -> SEDE(id_sede) | Sede física (nulo si es virtual). |

### 2. SEDE
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sede` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria. |
| `nombre` | `VARCHAR(100)` | NO | | Nombre del centro o campus. |
| `ciudad` | `VARCHAR(80)` | NO | | Ciudad de ubicación. |
| `direccion` | `VARCHAR(200)` | NO | | Dirección física. |

### 3. SALA
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sala` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria. |
| `id_sede` | `INT` | NO | FK -> SEDE(id_sede) | Sede a la que pertenece. |
| `nombre` | `VARCHAR(50)` | NO | | Nombre o número de sala/lab. |
| `capacidad` | `INT` | NO | CHECK (capacidad > 0) | Aforo físico máximo. |

### 4. PERSONA
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_persona` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria. |
| `nombre_completo` | `VARCHAR(120)` | NO | | Nombre y apellidos. |
| `correo` | `VARCHAR(150)` | NO | UNIQUE | Correo electrónico principal. |
| `pais` | `VARCHAR(60)` | NO | | País de origen/residencia. |

### 5. PARTICIPACION_EDICION
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_participacion` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria subrogada. |
| `id_persona` | `INT` | NO | FK -> PERSONA | Identificador de persona. |
| `id_edicion` | `INT` | NO | FK -> EDICION | Identificador de edición. |
| *Restricción* | | | UNIQUE(id_persona, id_edicion) | Un registro por individuo y edición. |

### 6. ASISTENTE (Subtipo Solapado)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_participacion` | `INT` | NO | PK, FK -> PARTICIPACION_EDICION | Hereda PK de la participación. |
| `tipo_acreditacion` | `VARCHAR(30)` | NO | CHECK IN ('ESTUDIANTE', 'PROFESIONAL', 'VIP') | Nivel de pase. |

### 7. PONENTE (Subtipo Solapado)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_participacion` | `INT` | NO | PK, FK -> PARTICIPACION_EDICION | Hereda PK de la participación. |
| `biografia` | `TEXT` | NO | | Resumen de trayectoria técnica. |

### 8. SESION
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sesion` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria. |
| `id_edicion` | `INT` | NO | FK -> EDICION | Edición que la contiene. |
| `id_sala` | `INT` | SÍ | FK -> SALA | Sala asignada (nulo si virtual). |
| `titulo` | `VARCHAR(150)` | NO | | Nombre de la sesión. |
| `resumen` | `TEXT` | NO | | Sinopsis técnica. |
| `fecha` | `DATE` | NO | | Fecha programada. |
| `hora_inicio` | `TIME` | NO | | Hora inicial. |
| `hora_fin` | `TIME` | NO | | Hora final. |
| `url_transmision`| `VARCHAR(255)` | SÍ | | Enlace a streaming (virtual/híbrida). |
| `tipo_sesion` | `VARCHAR(10)` | NO | CHECK IN ('CHARLA', 'TALLER') | Discriminador de subtipo. |

### 9. CHARLA (Subtipo Disjunto)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sesion` | `INT` | NO | PK, FK -> SESION | Clave primaria/foránea. |
| `minutos_preguntas`| `INT` | NO | CHECK (minutos_preguntas BETWEEN 0 AND 60) | Minutos reservados para Q&A. |

### 10. TALLER (Subtipo Disjunto)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sesion` | `INT` | NO | PK, FK -> SESION | Clave primaria/foránea. |
| `cupo_maximo` | `INT` | NO | CHECK (cupo_maximo > 0) | Límite de computadoras/asistentes. |
| `requisitos_materiales`| `TEXT` | NO | | Software, IDEs, SDKs requeridos. |

### 11. SESION_PRERREQUISITO (Recursiva N:M)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sesion` | `INT` | NO | PK, FK -> SESION | Sesión objetivo. |
| `id_prerrequisito` | `INT` | NO | PK, FK -> SESION | Sesión requerida previa. |
| *Restricción* | | | CHECK (id_sesion != id_prerrequisito) | Prohíbe autorreferencia. |

### 12. INSCRIPCION_SESION (Asociativa)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_inscripcion` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave subrogada. |
| `id_participacion`| `INT` | NO | FK -> ASISTENTE | Asistente acreditado. |
| `id_sesion` | `INT` | NO | FK -> SESION | Sesión elegida. |
| `fecha_registro`| `TIMESTAMPTZ` | NO | DEFAULT CURRENT_TIMESTAMP | Momento de la reserva. |
| `estado` | `VARCHAR(20)` | NO | CHECK IN ('CONFIRMADA', 'CANCELADA', 'EN_ESPERA') | Estado del cupo. |
| `asistio` | `BOOLEAN` | NO | DEFAULT FALSE | Asistencia confirmada. |
| *Restricción* | | | UNIQUE(id_participacion, id_sesion) | Impide doble inscripción. |

### 13. ASIGNACION_PONENTE (Asociativa)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_sesion` | `INT` | NO | PK, FK -> SESION | Sesión técnica. |
| `id_participacion`| `INT` | NO | PK, FK -> PONENTE | Ponente asignado. |
| `rol_ponente` | `VARCHAR(50)` | NO | DEFAULT 'ORADOR_PRINCIPAL' | Rol en tarima. |
| `orden_presentacion`| `INT` | NO | CHECK (orden_presentacion >= 1) | Turno en el estrado. |

### 14. EMPRESA
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_empresa` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave primaria. |
| `nombre_comercial`| `VARCHAR(100)` | NO | UNIQUE | Nombre corporativo. |
| `sitio_web` | `VARCHAR(150)` | SÍ | | Dominio web. |

### 15. ACUERDO_PATROCINIO (Asociativa)
| Columna | Tipo | Nulo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `id_acuerdo` | `INT GENERATED ALWAYS AS IDENTITY` | NO | PK | Clave subrogada. |
| `id_empresa` | `INT` | NO | FK -> EMPRESA | Empresa aliada. |
| `id_edicion` | `INT` | NO | FK -> EDICION | Edición patrocinada. |
| `categoria` | `VARCHAR(20)` | NO | CHECK IN ('PLATINUM', 'GOLD', 'SILVER', 'BRONZE') | Nivel de patrocinio. |
| `monto` | `NUMERIC(12,2)` | NO | CHECK (monto > 0) | Fondos otorgados. |
| `fecha_confirmacion`| `DATE` | NO | | Fecha de firma del convenio. |
| *Restricción* | | | UNIQUE(id_empresa, id_edicion) | Un único acuerdo activo por edición. |