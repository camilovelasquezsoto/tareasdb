-- 1. Tabla Profesor (Maestra)
CREATE TABLE profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(50) NOT NULL
);

-- 2. Tabla Sala (Maestra)
CREATE TABLE sala (
    id_sala SERIAL PRIMARY KEY,
    codigo_sala VARCHAR(10) NOT NULL UNIQUE,
    capacidad INTEGER NOT NULL CHECK (capacidad > 0)
);

-- 3. Tabla Alumno (Maestra)
CREATE TABLE alumno (
    id_alumno SERIAL PRIMARY KEY,
    num_matricula VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Tabla Curso (Depende de Profesor y Sala)
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    codigo_curso VARCHAR(15) NOT NULL UNIQUE,
    nombre_curso VARCHAR(100) NOT NULL,
    id_profesor INTEGER REFERENCES profesor(id_profesor) ON DELETE RESTRICT,
    id_sala INTEGER REFERENCES sala(id_sala) ON DELETE SET NULL
);

-- 5. Tabla Alumno_Curso (Intermedia - PK Compuesta)
CREATE TABLE alumno_curso (
    id_alumno INTEGER REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    id_curso INTEGER REFERENCES curso(id_curso) ON DELETE CASCADE,
    calificacion_final DECIMAL(3,2) CHECK (calificacion_final BETWEEN 1.0 AND 7.0),
    PRIMARY KEY (id_alumno, id_curso)
);

-- 6. Tabla Horario (Depende de Curso - PK Compuesta)
CREATE TABLE horario (
    id_curso INTEGER REFERENCES curso(id_curso) ON DELETE CASCADE,
    dia VARCHAR(10) NOT NULL CHECK (dia IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado')),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    PRIMARY KEY (id_curso, dia, hora_inicio),
    CONSTRAINT chk_horas CHECK (hora_fin > hora_inicio)
);
