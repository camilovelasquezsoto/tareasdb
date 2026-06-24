from datetime import date, datetime
import os
from pony.orm import *

# Nombre del archivo SQLite local
DB_FILENAME = 'db_modelos.db'

# Eliminar base de datos previa si existe para recrear limpia
if os.path.exists(DB_FILENAME):
    os.remove(DB_FILENAME)

# Inicialización de la base de datos
db = Database()
# Usamos un archivo local en vez de memoria para poder inspeccionarlo en VS Code
db.bind(provider='sqlite', filename=DB_FILENAME, create_db=True)

# =====================================================================
# 📌 1. SISTEMA DE GESTIÓN DE BIBLIOTECA
# =====================================================================
class UsuarioBiblioteca(db.Entity):
    id_usuario = PrimaryKey(int, auto=True)
    nombre = Required(str)
    direccion = Required(str)
    prestamos = Set('Prestamo')

class Libro(db.Entity):
    codigo_libro = PrimaryKey(str)
    titulo = Required(str)
    autor = Required(str)
    prestamos = Set('Prestamo')

class Prestamo(db.Entity):
    id_prestamo = PrimaryKey(int, auto=True)
    fecha_prestamo = Required(date)
    fecha_devolucion = Optional(date)
    usuario = Required(UsuarioBiblioteca)
    libro = Required(Libro)


# =====================================================================
# 📌 2. PLATAFORMA DE COMPRAS EN LÍNEA
# =====================================================================
class ClienteTienda(db.Entity):
    id_cliente = PrimaryKey(int, auto=True)
    pedidos = Set('Pedido')

class CategoriaProducto(db.Entity):
    id_categoria = PrimaryKey(int, auto=True)
    nombre = Required(str)
    productos = Set('ProductoTienda')

class ProductoTienda(db.Entity):
    id_producto = PrimaryKey(int, auto=True)
    nombre = Required(str)
    descripcion = Optional(str)
    precio = Required(float)
    categoria = Required(CategoriaProducto)
    detalles_pedido = Set('DetallePedido')

class Pedido(db.Entity):
    id_pedido = PrimaryKey(int, auto=True)
    fecha_compra = Required(date)
    estado = Required(str)
    total = Required(float)
    cliente = Required(ClienteTienda)
    detalles_pedido = Set('DetallePedido')

class DetallePedido(db.Entity):
    pedido = Required(Pedido)
    producto = Required(ProductoTienda)
    PrimaryKey(pedido, producto)  # Clave primaria compuesta
    cantidad = Required(int)


# =====================================================================
# 📌 3. GESTIÓN DE HOSPITAL
# =====================================================================
class Paciente(db.Entity):
    num_historia_clinica = PrimaryKey(str)
    nombre = Required(str)
    fecha_nacimiento = Required(date)
    direccion = Required(str)
    citas = Set('Cita')

class Doctor(db.Entity):
    id_doctor = PrimaryKey(int, auto=True)
    nombre = Required(str)
    especialidad = Required(str)
    num_licencia = Required(str)
    citas = Set('Cita')

class Cita(db.Entity):
    id_cita = PrimaryKey(int, auto=True)
    fecha = Required(date)
    hora = Required(str)  # Representado como string HH:MM
    diagnostico = Optional(str)
    paciente = Required(Paciente)
    doctor = Required(Doctor)


# =====================================================================
# 📌 4. RED SOCIAL
# =====================================================================
class UsuarioRedSocial(db.Entity):
    id_usuario = PrimaryKey(int, auto=True)
    nombre = Required(str)
    correo = Required(str, unique=True)
    fecha_nacimiento = Required(date)
    
    # Relación auto-referencial simétrica/asimétrica para amigos
    amigos = Set('UsuarioRedSocial', reverse='amigos')
    publicaciones = Set('Publicacion')
    likes_dados = Set('Publicacion', reverse='likes')

class Publicacion(db.Entity):
    id_publicacion = PrimaryKey(int, auto=True)
    contenido = Required(str)
    fecha_hora = Required(datetime)
    autor = Required(UsuarioRedSocial)
    likes = Set(UsuarioRedSocial, reverse='likes_dados')


# =====================================================================
# 📌 5. SISTEMA DE GESTIÓN UNIVERSITARIA
# =====================================================================
class EstudianteUniversitario(db.Entity):
    num_matricula = PrimaryKey(str)
    nombre = Required(str)
    correo = Required(str)
    inscripciones = Set('InscripcionCurso')

class Profesor(db.Entity):
    id_profesor = PrimaryKey(int, auto=True)
    nombre = Required(str)
    departamento = Required(str)
    cursos = Set('Curso')

class Curso(db.Entity):
    codigo_curso = PrimaryKey(str)
    nombre = Required(str)
    creditos = Required(int)
    profesor = Optional(Profesor)
    inscripciones = Set('InscripcionCurso')

class InscripcionCurso(db.Entity):
    estudiante = Required(EstudianteUniversitario)
    curso = Required(Curso)
    PrimaryKey(estudiante, curso)
    calificacion = Optional(float)


# =====================================================================
# 📌 6. SISTEMA DE RESERVAS DE HOTEL
# =====================================================================
class Habitacion(db.Entity):
    numero = PrimaryKey(int)
    tipo = Required(str)  # Individual, doble, suite
    precio_noche = Required(float)
    reservas = Set('Reserva')

class Huesped(db.Entity):
    id_huesped = PrimaryKey(str)  # Número de identificación
    nombre = Required(str)
    telefono = Required(str)
    correo = Required(str)
    reservas = Set('Reserva')

class Reserva(db.Entity):
    id_reserva = PrimaryKey(int, auto=True)
    check_in = Required(date)
    check_out = Required(date)
    costo_total = Required(float)
    habitacion = Required(Habitacion)
    huesped = Required(Huesped)


# =====================================================================
# 📌 7. PLATAFORMA DE STREAMING DE MÚSICA
# =====================================================================
class UsuarioStreaming(db.Entity):
    id_usuario = PrimaryKey(int, auto=True)
    nombre = Required(str)
    correo = Required(str, unique=True)
    tipo_suscripcion = Required(str)  # Gratuita o Premium
    listas = Set('ListaReproduccion')

class Cancion(db.Entity):
    id_cancion = PrimaryKey(int, auto=True)
    titulo = Required(str)
    artista = Required(str)
    album = Required(str)
    duracion = Required(int)  # En segundos
    en_listas = Set('DetalleListaCancion')

class ListaReproduccion(db.Entity):
    id_lista = PrimaryKey(int, auto=True)
    nombre = Required(str)
    usuario = Required(UsuarioStreaming)
    canciones = Set('DetalleListaCancion')

class DetalleListaCancion(db.Entity):
    lista = Required(ListaReproduccion)
    cancion = Required(Cancion)
    PrimaryKey(lista, cancion)
    fecha_agregada = Required(date)
    reproducciones = Required(int, default=0)


# =====================================================================
# 📌 8. GESTIÓN DE VETERINARIA
# =====================================================================
class DuenoMascota(db.Entity):
    id_dueno = PrimaryKey(str)
    nombre = Required(str)
    telefono = Required(str)
    direccion = Required(str)
    mascotas = Set('Mascota')

class Mascota(db.Entity):
    id_mascota = PrimaryKey(int, auto=True)
    nombre = Required(str)
    especie = Required(str)
    raza = Required(str)
    edad = Required(int)
    dueno = Required(DuenoMascota)
    consultas = Set('ConsultaVeterinaria')

class Veterinario(db.Entity):
    id_veterinario = PrimaryKey(int, auto=True)
    nombre = Required(str)
    consultas = Set('ConsultaVeterinaria')

class ConsultaVeterinaria(db.Entity):
    id_consulta = PrimaryKey(int, auto=True)
    fecha = Required(date)
    hora = Required(str)
    motivo = Required(str)
    tratamiento = Optional(str)
    mascota = Required(Mascota)
    veterinario = Required(Veterinario)


# =====================================================================
# 📌 9. PLATAFORMA DE CUROS EN LÍNEA
# =====================================================================
class EstudiantePlataforma(db.Entity):
    id_estudiante = PrimaryKey(int, auto=True)
    nombre = Required(str)
    inscripciones = Set('InscripcionPlataforma')

class CursoPlataforma(db.Entity):
    id_curso = PrimaryKey(int, auto=True)
    nombre = Required(str)
    descripcion = Required(str)
    instructor = Required(str)
    inscripciones = Set('InscripcionPlataforma')

class InscripcionPlataforma(db.Entity):
    estudiante = Required(EstudiantePlataforma)
    curso = Required(CursoPlataforma)
    PrimaryKey(estudiante, curso)
    fecha_inscripcion = Required(date)
    calificacion = Optional(float)


# =====================================================================
# 📌 10. SISTEMA DE GESTIÓN DE RESTAURANTES
# =====================================================================
class Mesa(db.Entity):
    numero_mesa = PrimaryKey(int)
    capacidad = Required(int)
    reservas = Set('ReservaMesa')

class ClienteRestaurante(db.Entity):
    id_cliente = PrimaryKey(int, auto=True)
    nombre = Required(str)
    reservas = Set('ReservaMesa')

class ReservaMesa(db.Entity):
    id_reserva = PrimaryKey(int, auto=True)
    fecha = Required(date)
    hora = Required(str)
    mesa = Required(Mesa)
    cliente = Required(ClienteRestaurante)

class Plato(db.Entity):
    id_plato = PrimaryKey(int, auto=True)
    nombre = Required(str)
    precio = Required(float)
    categoria = Required(str)
    en_pedidos = Set('DetallePedidoRestaurante')

class PedidoRestaurante(db.Entity):
    id_pedido = PrimaryKey(int, auto=True)
    total_cuenta = Required(float)
    platos = Set('DetallePedidoRestaurante')

class DetallePedidoRestaurante(db.Entity):
    pedido = Required(PedidoRestaurante)
    plato = Required(Plato)
    PrimaryKey(pedido, plato)
    cantidad = Required(int)


# =====================================================================
# 📌 11. PLATAFORMA DE ALQUILER DE VEHÍCULOS
# =====================================================================
class Vehiculo(db.Entity):
    placa = PrimaryKey(str)
    marca = Required(str)
    modelo = Required(str)
    tarifa_dia = Required(float)
    alquileres = Set('Alquiler')

class ClienteAlquiler(db.Entity):
    num_licencia = PrimaryKey(str)
    nombre = Required(str)
    direccion = Required(str)
    telefono = Required(str)
    alquileres = Set('Alquiler')

class Alquiler(db.Entity):
    id_alquiler = PrimaryKey(int, auto=True)
    fecha_inicio = Required(date)
    fecha_finalizacion = Required(date)
    costo_total = Required(float)
    vehiculo = Required(Vehiculo)
    cliente = Required(ClienteAlquiler)


# =====================================================================
# 📌 12. SISTEMA DE GESTIÓN DE INVENTARIO
# =====================================================================
class ProductoInventario(db.Entity):
    codigo = PrimaryKey(str)
    nombre = Required(str)
    descripcion = Optional(str)
    cantidad_stock = Required(int)
    entregas = Set('EntregaProveedor')

class Proveedor(db.Entity):
    id_proveedor = PrimaryKey(int, auto=True)
    nombre = Required(str)
    telefono = Required(str)
    direccion = Required(str)
    entregas = Set('EntregaProveedor')

class EntregaProveedor(db.Entity):
    producto = Required(ProductoInventario)
    proveedor = Required(Proveedor)
    PrimaryKey(producto, proveedor)
    fecha = Required(date)
    cantidad = Required(int)


# Generación de las tablas correspondientes en la Base de Datos
db.generate_mapping(create_tables=True)
print(f"¡Base de datos SQLite '{DB_FILENAME}' creada exitosamente con todos los modelos!")
