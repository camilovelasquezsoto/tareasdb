CREATE TABLE descuento (
  id SERIAL PRIMARY KEY,
  producto_id INTEGER NOT NULL,
  porcentaje INTEGER NOT NULL CHECK (porcentaje >= 0 AND porcentaje <= 100),
  activo BOOLEAN DEFAULT true,
  FOREIGN KEY (producto_id) REFERENCES producto(id) ON DELETE CASCADE
);
