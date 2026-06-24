# Sección 2: SQL

Esta sección agrupa todo lo referente al diseño e implementación física de bases de datos utilizando sentencias SQL en dialecto PostgreSQL (DDL, DML, Migraciones, Triggers y Funciones).

## Tareas y Ejercicios

### [01. Creación de Tablas (DDL)](./01-creacion-tablas/README.md)
*   **Contenido:** Definición del esquema físico (`modelo.sql`) mediante sentencias CREATE TABLE, PK, FK y restricciones de integridad.
*   **Enunciado guía:** [07-sql-creacion-tablas](https://github.com/Awerito/db-ejemplos/tree/master/07-sql-creacion-tablas)

### [02. CRUD y Vistas](./02-crud/README.md)
*   **Contenido:** Consultas SQL básicas (SELECT, INSERT, UPDATE, DELETE) y la creación de `vista_global_academica`.
*   **Enunciado guía:** [08-sql-crud](https://github.com/Awerito/db-ejemplos/tree/master/08-sql-crud)

### [03. CRUD Biblioteca](./03-crud-biblioteca/README.md)
*   **Contenido:** Ejercicios de consultas DML sobre la base de datos de biblioteca, incluyendo `vista_global_biblioteca`.
*   **Enunciado guía:** [09-sql-biblioteca](https://github.com/Awerito/db-ejemplos/tree/master/09-sql-biblioteca)

### [04. Migraciones](./04-migraciones/README.md)
*   **Contenido:** Secuencia ordenada de migraciones (001 a 009) con sus respectivos scripts de rollback (down) y el registro en la tabla `schema_migrations`.
*   **Enunciado guía:** [13-migrations](https://github.com/Awerito/db-ejemplos/tree/master/13-migrations)

### [05. Triggers y Funciones](./05-triggers-funciones/README.md)
*   **Contenido:** Creación del disparador y función PL/pgSQL `auditar_elo()` para auditar el rating de los jugadores de ajedrez tras un partido.
*   **Enunciado guía:** [14-triggers-funciones](https://github.com/Awerito/db-ejemplos/tree/master/14-triggers-funciones)
