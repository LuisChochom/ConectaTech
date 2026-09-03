-- 1. Sedes
INSERT INTO SEDE (nombre, ciudad, direccion) VALUES
('Campus Central de Tecnología', 'Guatemala', 'Avenida Las Américas 14-20, Zona 13'),
('Centro de Convenciones del Pacífico', 'Retalhuleu', 'Km 180 Carretera al Pacífico');

-- 2. Salas
INSERT INTO SALA (id_sede, nombre, capacidad) VALUES
(1, 'Laboratorio Turing (Sistemas)', 30),
(1, 'Auditórium Ada Lovelace', 120),
(2, 'Laboratorio von Neumann', 25);

-- 3. Ediciones
INSERT INTO EDICION (nombre, anio, fecha_inicio, fecha_fin, modalidad, estado, id_sede) VALUES
('ConectaTech Dev Summit 2026', 2026, '2026-10-15', '2026-10-17', 'HIBRIDA', 'ABIERTA', 1),
('ConectaTech Cloud & Backend 2026', 2026, '2026-11-20', '2026-11-21', 'PRESENCIAL', 'PLANIFICACION', 2);

-- 4. Personas (6 Personas)
INSERT INTO PERSONA (nombre_completo, correo, pais) VALUES
('Carlos Morales Gómez', 'cmorales@techmail.com', 'Guatemala'),
('Elena Rostova Petrov', 'erostova@devglobal.org', 'Estonia'),
('David Alejandro Ruiz', 'druiz@backendpro.io', 'Colombia'),
('Lucía Fernanda Méndez', 'lmendez@datascience.gt', 'Guatemala'),
('Marcos Aurelio Soto', 'msoto@kerneldev.net', 'México'),
('Sofía Nicole Valenzuela', 'svalenzuela@rustaceans.org', 'Chile');

-- 5. Participaciones por Edición
INSERT INTO PARTICIPACION_EDICION (id_persona, id_edicion) VALUES
(1, 1), -- ID 1: Carlos (Edición 1)
(2, 1), -- ID 2: Elena (Edición 1)
(3, 1), -- ID 3: David (Edición 1)
(4, 1), -- ID 4: Lucía (Edición 1)
(5, 1), -- ID 5: Marcos (Edición 1)
(6, 1); -- ID 6: Sofía (Edición 1)

-- 6. Especialización de Roles: Asistentes y Ponentes (Demostrando solapamiento en ID 3)
INSERT INTO ASISTENTE (id_participacion, tipo_acreditacion) VALUES
(1, 'PROFESIONAL'),
(3, 'VIP'),          -- David es Asistente...
(4, 'ESTUDIANTE'),
(5, 'PROFESIONAL');

INSERT INTO PONENTE (id_participacion, biografia) VALUES
(2, 'Staff Software Engineer con 12 años optimizando runtimes y arquitecturas concurrentes en Rust.'),
(3, 'Consultor Senior de Arquitectura Cloud y Microservicios distribuidos en Go y Docker.'), -- ...y también Ponente (Solapado)
(6, 'Core Developer especializada en compiladores y sistemas operativos de alto rendimiento.');

-- 7. Sesiones Técnicas (6 Sesiones)
INSERT INTO SESION (id_edicion, id_sala, titulo, resumen, fecha, hora_inicio, hora_fin, url_transmision, tipo_sesion) VALUES
-- Sesión 1: Charla presencial / híbrida
(1, 2, 'Fundamentos de Concurrencia en Go y Canales', 'Exploración de Goroutines, primitives de sincronización y pipelines eficientes.', '2026-10-15', '09:00:00', '10:30:00', 'https://stream.conectatech.org/go-concurrency', 'CHARLA'),
-- Sesión 2: Taller de programación
(1, 1, 'Taller Práctico: Creación de un Servidor Web en C++', 'Construcción paso a paso de un servidor HTTP/1.1 asíncrono con epoll y sockets POSIX.', '2026-10-15', '11:00:00', '14:00:00', NULL, 'TALLER'),
-- Sesión 3: Charla avanzada que requiere la Sesión 1
(1, 2, 'Patrones Avanzados de Microservicios con gRPC y Go', 'Diseño de contratos Protobuf de alto rendimiento y balanceo de carga L7.', '2026-10-15', '14:30:00', '16:00:00', 'https://stream.conectatech.org/grpc-go', 'CHARLA'),
-- Sesión 4: Taller avanzado en Rust
(1, 1, 'Taller: Metaprogramación con Macros Procedurales en Rust', 'Implementación de macros Derive personalizadas y manipulación del AST con Syn y Quote.', '2026-10-16', '09:00:00', '12:00:00', NULL, 'TALLER'),
-- Sesión 5: Charla técnica virtual
(1, NULL, 'Seguridad de Memoria y Runtimes Asíncronos', 'Análisis formal del borrow checker y modelos Tokio vs async-std.', '2026-10-16', '14:00:00', '15:30:00', 'https://stream.conectatech.org/rust-memory-safety', 'CHARLA'),
-- Sesión 6: Taller intensivo
(1, 1, 'Taller: Optimización de Consultas SQL y Particionado en PostgreSQL 18', 'Técnicas avanzadas de indexación GiST/GIN, CTEs materializadas y planes de ejecución.', '2026-10-16', '16:00:00', '18:30:00', NULL, 'TALLER');

-- 8. Subtipos de Sesión
INSERT INTO CHARLA (id_sesion, minutos_preguntas) VALUES
(1, 15),
(3, 20),
(5, 10);

INSERT INTO TALLER (id_sesion, cupo_maximo, requisitos_materiales) VALUES
(2, 25, 'Laptop con Linux x86_64, GCC 14+, GDB, Make y CMake instalados.'),
(4, 20, 'Rust toolchain estable 1.85+, rust-analyzer y VS Code o Neovim configurado.'),
(6, 30, 'Docker Compose y cliente psql instalados localmente.');

-- 9. Prerrequisitos de Sesiones (Recursiva N:M)
INSERT INTO SESION_PRERREQUISITO (id_sesion, id_prerrequisito) VALUES
(3, 1), -- Para tomar gRPC y Go (3), se requiere Concurrencia en Go (1)
(4, 5); -- Para tomar Taller Macros Rust (4), se requiere Seguridad de Memoria (5)

-- 10. Asignaciones de Ponentes (4 Asignaciones)
INSERT INTO ASIGNACION_PONENTE (id_sesion, id_participacion, rol_ponente, orden_presentacion) VALUES
(1, 3, 'ORADOR_PRINCIPAL', 1), -- David Ruiz expone Go Concurrency
(3, 3, 'ORADOR_PRINCIPAL', 1), -- David Ruiz expone gRPC en Go
(4, 2, 'ORADOR_PRINCIPAL', 1), -- Elena Rostova lidera Taller de Rust
(5, 6, 'ORADOR_PRINCIPAL', 1); -- Sofía Valenzuela expone Runtimes de Rust

-- 11. Inscripciones a Sesiones (8 Inscripciones)
INSERT INTO INSCRIPCION_SESION (id_participacion, id_sesion, estado, asistio) VALUES
(1, 1, 'CONFIRMADA', TRUE),
(1, 2, 'CONFIRMADA', TRUE),
(1, 3, 'CONFIRMADA', FALSE),
(3, 2, 'CONFIRMADA', TRUE),  -- David Ruiz asiste al taller de C++
(4, 1, 'CONFIRMADA', TRUE),
(4, 4, 'CONFIRMADA', TRUE),
(5, 2, 'CONFIRMADA', TRUE),
(5, 6, 'CONFIRMADA', FALSE);

-- 12. Empresas
INSERT INTO EMPRESA (nombre_comercial, sitio_web) VALUES
('JetBrains Tech Solutions', 'https://www.jetbrains.com'),
('Red Hat Enterprise Software', 'https://www.redhat.com'),
('Cloudflare Inc', 'https://www.cloudflare.com');

-- 13. Acuerdos de Patrocinio (3 Acuerdos)
INSERT INTO ACUERDO_PATROCINIO (id_empresa, id_edicion, categoria, monto, fecha_confirmacion) VALUES
(1, 1, 'PLATINUM', 15000.00, '2026-06-10'),
(2, 1, 'GOLD', 8500.00, '2026-07-01'),
(3, 1, 'SILVER', 4500.00, '2026-08-15');