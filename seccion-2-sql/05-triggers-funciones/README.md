# Tarea 05: Triggers y Funciones

Implementación de lógica de negocio del lado de la base de datos (PostgreSQL) para auditoría de rating (ELO) de jugadores.

## Requisitos de Entrega
*   Esquema de tablas: `jugador`, `partido` y `elo_historial`.
*   Función PL/pgSQL `auditar_elo()` que reaccione a la inserción de nuevos partidos y actualice/audite el ELO de los jugadores involucrados.
*   Trigger configurado sobre la tabla `partido` para invocar automáticamente la función anterior.
*   Enunciado guía: [14-triggers-funciones](https://github.com/Awerito/db-ejemplos/tree/master/14-triggers-funciones)

*Coloca tus archivos de esquema, funciones y triggers aquí.*
