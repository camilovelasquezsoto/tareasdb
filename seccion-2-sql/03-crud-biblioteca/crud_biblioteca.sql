-- =====================================================================
-- 📌 1. CONSULTAS (SELECT)
-- =====================================================================

-- 1.1 Obtener los usuarios con más préstamos retrasados.
SELECT u.id, u.nombre, COUNT(*) AS prestamos_retrasados
FROM prestamo p
JOIN usuario u ON p.usuarios = u.id
WHERE p.estado = 'retrasado'
GROUP BY u.id, u.nombre
ORDER BY prestamos_retrasados DESC;

-- 1.2 Libros con más de 1 autor.
SELECT l.id, l.titulo, COUNT(*) AS num_autores
FROM autor_libro al
JOIN libro l ON al.libro = l.id
GROUP BY l.id, l.titulo
HAVING COUNT(*) > 1;

-- 1.3 Total de multas por usuario.
SELECT u.id, u.nombre, COALESCE(SUM(m.monto), 0) AS total_multas
FROM usuario u
LEFT JOIN prestamo p ON p.usuarios = u.id
LEFT JOIN multa m ON m.prestamo_usuarios = p.usuarios AND m.prestamo_libros = p.libros
GROUP BY u.id, u.nombre;

-- 1.4 Libros por categoría y año de publicación.
SELECT c.nombre AS categoria, l.anio_publicacion, COUNT(*) AS total_libros
FROM libro l
JOIN categoria c ON l.categoria = c.id
GROUP BY c.nombre, l.anio_publicacion
ORDER BY c.nombre, l.anio_publicacion;

-- 1.5 Libros prestados en el año 2023.
SELECT DISTINCT l.id, l.titulo
FROM prestamo p
JOIN libro l ON p.libros = l.id
WHERE EXTRACT(YEAR FROM p.fecha_prestamo) = 2023;


-- =====================================================================
-- 📌 2. ACTUALIZACIONES (UPDATE)
-- =====================================================================

-- 2.1 Cambiar estado de préstamos a “retrasado” si la fecha de devolución es mayor a 15 días de la fecha préstamo.
-- (Asumiendo que fecha_devolucion es la fecha en que se devolvió físicamente, y si es nula, aún no se devuelve)
UPDATE prestamo
SET estado = 'retrasado'
WHERE fecha_devolucion IS NULL 
  AND (CURRENT_DATE - fecha_prestamo) > 15;

-- 2.2 Registrar devolución de un préstamo y cambiar el estado (ejemplo para un usuario y libro específicos).
UPDATE prestamo
SET fecha_devolucion = CURRENT_DATE,
    estado = 'devuelto'
WHERE usuarios = 1 AND libros = 2; -- Reemplazar con los IDs reales correspondientes

-- 2.3 Marcar multa como pagada (ejemplo para un id de multa específico).
UPDATE multa
SET estado = 'pagado'
WHERE id = 5; -- Reemplazar con el ID de la multa correspondiente


-- =====================================================================
-- 📌 3. ELIMINACIONES (DELETE)
-- =====================================================================

-- 3.1 Eliminar todos los préstamos devueltos hace más de 1 año.
-- Nota: Por integridad referencial, primero eliminamos las multas asociadas a esos préstamos.
DELETE FROM multa
WHERE (prestamo_usuarios, prestamo_libros) IN (
    SELECT usuarios, libros
    FROM prestamo
    WHERE estado = 'devuelto' AND fecha_devolucion < CURRENT_DATE - INTERVAL '1 year'
);

DELETE FROM prestamo
WHERE estado = 'devuelto' AND fecha_devolucion < CURRENT_DATE - INTERVAL '1 year';

-- 3.2 Eliminar libros sin autores asignados (JOIN con autor_libro).
DELETE FROM libro
WHERE id NOT IN (
    SELECT DISTINCT libro
    FROM autor_libro
);


-- =====================================================================
-- 📌 4. CREACIÓN DE VISTA UNIFICADA
-- =====================================================================

-- Define una vista llamada vista_global_biblioteca que integre la información de todas las tablas.
CREATE OR REPLACE VIEW vista_global_biblioteca AS
SELECT 
    u.id AS id_usuario,
    u.nombre AS nombre_usuario,
    l.id AS id_libro,
    l.titulo AS titulo_libro,
    l.anio_publicacion,
    c.nombre AS nombre_categoria,
    p.fecha_prestamo,
    p.fecha_devolucion,
    p.estado AS estado_prestamo,
    m.monto AS monto_multa,
    m.estado AS estado_multa,
    (
        SELECT STRING_AGG(a.nombre, ', ') 
        FROM autor_libro al 
        JOIN autor a ON al.autor = a.id 
        WHERE al.libro = l.id
    ) AS autores
FROM usuario u
LEFT JOIN prestamo p ON u.id = p.usuarios
LEFT JOIN libro l ON p.libros = l.id
LEFT JOIN categoria c ON l.categoria = c.id
LEFT JOIN multa m ON m.prestamo_usuarios = p.usuarios AND m.prestamo_libros = p.libros;
