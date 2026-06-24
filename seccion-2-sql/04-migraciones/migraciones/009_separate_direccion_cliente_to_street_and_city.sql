ALTER TABLE cliente
  ADD COLUMN calle TEXT,
  ADD COLUMN ciudad TEXT;

UPDATE cliente
SET calle = split_part(direccion, ',', 1),
    ciudad = split_part(direccion, ',', 2);

ALTER TABLE cliente DROP COLUMN direccion;
