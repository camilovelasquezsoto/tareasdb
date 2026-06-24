-- =====================================================================
-- 📌 1. CONSULTAS (SELECT)
-- =====================================================================

-- 1.1 Listar todos los alumnos (id y nombre) de la tabla alumno.
SELECT id_alumno, nombre 
FROM alumno;

-- 1.2 Mostrar todos los cursos junto al nombre de su profesor.
SELECT c.nombre_curso, p.nombre AS nombre_profesor
FROM curso c
LEFT JOIN profesor p ON c.id_profesor = p.id_profesor;

-- 1.3 Para un alumno dado (ej: id = 1), recuperar los nombres de los cursos en los que está inscrito.
SELECT c.nombre_curso
FROM alumno_curso ac
JOIN curso c ON ac.id_curso = c.id_curso
WHERE ac.id_alumno = 1; -- Cambiar el id por el del alumno deseado

-- 1.4 Contar cuántos alumnos hay inscritos en cada curso.
SELECT c.nombre_curso, COUNT(ac.id_alumno) AS total_alumnos
FROM curso c
LEFT JOIN alumno_curso ac ON c.id_curso = ac.id_curso
GROUP BY c.id_curso, c.nombre_curso;

-- 1.5 Obtener el horario completo (día, hora inicio, hora fin y sala) del curso de “Programación”.
SELECT h.dia, h.hora_inicio, h.hora_fin, s.codigo_sala
FROM horario h
JOIN curso c ON h.id_curso = c.id_curso
LEFT JOIN sala s ON c.id_sala = s.id_sala
WHERE c.nombre_curso ILIKE 'Programación';

-- 1.6 Listar las salas que están libres los martes (es decir, aquellas que no aparecen en ningún horario para ‘Martes’).
SELECT id_sala, codigo_sala, capacidad
FROM sala
WHERE id_sala NOT IN (
    SELECT DISTINCT c.id_sala
    FROM horario h
    JOIN curso c ON h.id_curso = c.id_curso
    WHERE h.dia = 'Martes' AND c.id_sala IS NOT NULL
);


-- =====================================================================
-- 📌 2. ACTUALIZACIONES (UPDATE)
-- =====================================================================

-- 2.1 Cambiar el nombre de un alumno cuyo id = 10 a “Javier Díaz Fernández”.
UPDATE alumno
SET nombre = 'Javier Díaz Fernández'
WHERE id_alumno = 10;

-- 2.2 Aumentar en un 5 % la capacidad de todas las salas con capacidad menor a 30.
UPDATE sala
SET capacidad = ROUND(capacidad * 1.05)
WHERE capacidad < 30;

-- 2.3 Reasignar el curso con id = 6 para que esté a cargo del profesor con id = 3.
UPDATE curso
SET id_profesor = 3
WHERE id_curso = 6;

-- 2.4 Ajustar la hora de inicio de las clases de ‘Filosofía’ sumando 15 minutos.
UPDATE horario
SET hora_inicio = hora_inicio + INTERVAL '15 minutes',
    hora_fin = hora_fin + INTERVAL '15 minutes' -- Ajustamos hora_fin también para mantener la duración
WHERE id_curso IN (
    SELECT id_curso
    FROM curso
    WHERE nombre_curso ILIKE 'Filosofía'
);


-- =====================================================================
-- 📌 3. ELIMINACIONES (DELETE)
-- =====================================================================

-- 3.1 Borrar la inscripción del alumno con id = 4 para el curso con id = 8.
DELETE FROM alumno_curso
WHERE id_alumno = 4 AND id_curso = 8;

-- 3.2 Eliminar todos los horarios correspondientes al curso con id = 2.
DELETE FROM horario
WHERE id_curso = 2;

-- 3.3 Suprimir todos los cursos impartidos por el profesor con id = 5.
DELETE FROM curso
WHERE id_profesor = 5;


-- =====================================================================
-- 📌 4. CREACIÓN DE VISTA UNIFICADA
-- =====================================================================

-- Define una vista llamada vista_global_academica que integre la información de todas las tablas.
CREATE OR REPLACE VIEW vista_global_academica AS
SELECT 
    a.id_alumno,
    a.num_matricula,
    a.nombre AS nombre_alumno,
    a.correo AS correo_alumno,
    c.id_curso,
    c.codigo_curso,
    c.nombre_curso,
    ac.calificacion_final,
    p.id_profesor,
    p.nombre AS nombre_profesor,
    p.departamento AS departamento_profesor,
    s.id_sala,
    s.codigo_sala,
    s.capacidad AS capacidad_sala,
    h.dia AS dia_horario,
    h.hora_inicio,
    h.hora_fin
FROM alumno a
LEFT JOIN alumno_curso ac ON a.id_alumno = ac.id_alumno
LEFT JOIN curso c ON ac.id_curso = c.id_curso
LEFT JOIN profesor p ON c.id_profesor = p.id_profesor
LEFT JOIN sala s ON c.id_sala = s.id_sala
LEFT JOIN horario h ON c.id_curso = h.id_curso;
