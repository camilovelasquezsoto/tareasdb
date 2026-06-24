-- =====================================================================
-- 📌 1. MODELADO DE TABLAS
-- =====================================================================

-- Tabla de jugadores
CREATE TABLE jugador (
    id_jugador SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    elo INTEGER NOT NULL DEFAULT 1200 CHECK (elo >= 0)
);

-- Tabla de partidos
CREATE TABLE partido (
    id_partido SERIAL PRIMARY KEY,
    id_ganador INTEGER NOT NULL REFERENCES jugador(id_jugador) ON DELETE CASCADE,
    id_perdedor INTEGER NOT NULL REFERENCES jugador(id_jugador) ON DELETE CASCADE,
    fecha_partido DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_jugadores CHECK (id_ganador <> id_perdedor)
);

-- Tabla de historial/auditoría de ELO
CREATE TABLE elo_historial (
    id_historial SERIAL PRIMARY KEY,
    id_jugador INTEGER NOT NULL REFERENCES jugador(id_jugador) ON DELETE CASCADE,
    elo_anterior INTEGER NOT NULL,
    elo_nuevo INTEGER NOT NULL,
    cambio INTEGER NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================================
-- 📌 2. FUNCIÓN DE AUDITORÍA
-- =====================================================================

CREATE OR REPLACE FUNCTION auditar_elo()
RETURNS TRIGGER AS $$
DECLARE
    v_cambio INTEGER;
    v_motivo VARCHAR(255);
BEGIN
    -- Detectar si el valor de ELO cambió
    IF OLD.elo <> NEW.elo THEN
        -- Calcular la diferencia
        v_cambio := NEW.elo - OLD.elo;
        
        -- Definir el motivo según sea ganancia o pérdida
        IF v_cambio > 0 THEN
            v_motivo := 'Ganó un partido. Incremento de ' || v_cambio || ' puntos de ELO.';
        ELSE
            v_motivo := 'Perdió un partido. Decremento de ' || ABS(v_cambio) || ' puntos de ELO.';
        END IF;

        -- Insertar el registro de auditoría
        INSERT INTO elo_historial (id_jugador, elo_anterior, elo_nuevo, cambio, motivo)
        VALUES (NEW.id_jugador, OLD.elo, NEW.elo, v_cambio, v_motivo);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- =====================================================================
-- 📌 3. TRIGGER DE AUDITORÍA
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_auditar_elo
AFTER UPDATE OF elo ON jugador
FOR EACH ROW
EXECUTE FUNCTION auditar_elo();


-- =====================================================================
-- 📌 4. SIMULACIÓN DE PRUEBA
-- =====================================================================

-- 4.1 Insertar jugadores de prueba
INSERT INTO jugador (nombre, elo) VALUES ('Carlos Alcaraz', 1600);
INSERT INTO jugador (nombre, elo) VALUES ('Jannik Sinner', 1620);

-- 4.2 Simular que Alcaraz gana a Sinner
INSERT INTO partido (id_ganador, id_perdedor) VALUES (1, 2);

-- 4.3 Actualizar el ELO (Simulación manual de la actualización post-partido)
-- Alcaraz gana +15 de ELO
UPDATE jugador SET elo = elo + 15 WHERE id_jugador = 1;
-- Sinner pierde -15 de ELO
UPDATE jugador SET elo = elo - 15 WHERE id_jugador = 2;

-- 4.4 Verificar los resultados en la auditoría
SELECT * FROM elo_historial;
