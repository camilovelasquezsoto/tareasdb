ALTER TABLE cliente ADD COLUMN direccion TEXT;

UPDATE cliente
SET direccion = COALESCE(calle, '') || ',' || COALESCE(ciudad, '');

ALTER TABLE cliente
  DROP COLUMN calle,
  DROP COLUMN ciudad;
