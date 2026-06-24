# Conversión a Modelo Relacional (MR)

A continuación se presenta la conversión a Modelo Relacional de 6 sistemas seleccionados a partir de los modelos de Pony ORM.

---

## 1. SISTEMA DE GESTIÓN DE BIBLIOTECA

TABLA: UsuarioBiblioteca
- id_usuario (PK)
- nombre
- direccion

TABLA: Libro
- codigo_libro (PK)
- titulo
- autor

TABLA: Prestamo
- id_prestamo (PK)
- fecha_prestamo
- fecha_devolucion
- usuario_id (FK -> UsuarioBiblioteca)
- libro_codigo (FK -> Libro)

---

## 2. PLATAFORMA DE COMPRAS EN LÍNEA

TABLA: ClienteTienda
- id_cliente (PK)

TABLA: CategoriaProducto
- id_categoria (PK)
- nombre

TABLA: ProductoTienda
- id_producto (PK)
- nombre
- precio
- categoria_id (FK -> CategoriaProducto)

TABLA: Pedido
- id_pedido (PK)
- fecha_compra
- cliente_id (FK -> ClienteTienda)

TABLA: DetallePedido
- pedido_id (PK, FK -> Pedido)
- producto_id (PK, FK -> ProductoTienda)
- cantidad

---

## 3. GESTIÓN DE HOSPITAL

TABLA: Paciente
- num_historia_clinica (PK)
- nombre

TABLA: Doctor
- id_doctor (PK)
- nombre
- especialidad

TABLA: Cita
- id_cita (PK)
- fecha
- paciente_id (FK -> Paciente)
- doctor_id (FK -> Doctor)

---

## 4. RED SOCIAL

TABLA: UsuarioRedSocial
- id_usuario (PK)
- nombre

TABLA: Publicacion
- id_publicacion (PK)
- contenido
- autor_id (FK -> UsuarioRedSocial)

TABLA: AmigoRedSocial
- usuario_id (PK, FK -> UsuarioRedSocial)
- amigo_id (PK, FK -> UsuarioRedSocial)

---

## 5. SISTEMA DE GESTIÓN UNIVERSITARIA

TABLA: EstudianteUniversitario
- num_matricula (PK)
- nombre

TABLA: Profesor
- id_profesor (PK)
- nombre

TABLA: Curso
- codigo_curso (PK)
- nombre
- profesor_id (FK -> Profesor)

TABLA: InscripcionCurso
- estudiante_matricula (PK, FK -> EstudianteUniversitario)
- curso_codigo (PK, FK -> Curso)
- calificacion

---

## 6. SISTEMA DE RESERVAS DE HOTEL

TABLA: Habitacion
- numero (PK)
- tipo
- precio_noche

TABLA: Huesped
- id_huesped (PK)
- nombre

TABLA: Reserva
- id_reserva (PK)
- check_in
- habitacion_numero (FK -> Habitacion)
- huesped_id (FK -> Huesped)

---


