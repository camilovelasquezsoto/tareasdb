# Traducción SQL ↔ Álgebra Relacional (Set 1)

Soluciones a la práctica de traducción cruzada entre SQL y Álgebra Relacional sobre el esquema de agencia de viajes.

---

## 1. SQL → Álgebra Relacional

### 1.1 Vuelos cuyo destino es *New Delhi*.
*   **SQL:**
    ```sql
    SELECT * FROM flight WHERE dest = 'New Delhi';
    ```
*   **Álgebra Relacional:**
    $$\sigma_{dest='New Delhi'}(flight)$$

### 1.2 Nombres de pasajeros con al menos una reserva.
*   **SQL:**
    ```sql
    SELECT DISTINCT p.pname
    FROM passenger p
    JOIN booking b ON b.pid = p.pid;
    ```
*   **Álgebra Relacional:**
    $$\pi_{pname}(passenger \bowtie booking)$$

### 1.3 Vuelos que operan a las 16:00 tanto el 2020-12-01 como el 2020-12-02.
*   **SQL:**
    ```sql
    SELECT * FROM flight WHERE fdate = DATE '2020-12-01' AND time = '16:00'
    INTERSECT
    SELECT * FROM flight WHERE fdate = DATE '2020-12-02' AND time = '16:00';
    ```
*   **Álgebra Relacional:**
    $$\sigma_{fdate='2020-12-01' \,\wedge\, time='16:00'}(flight) \cap \sigma_{fdate='2020-12-02' \,\wedge\, time='16:00'}(flight)$$

### 1.4 Pasajeros sin reservas (pid y nombre).
*   **SQL:**
    ```sql
    SELECT p.pid, p.pname
    FROM passenger p
    WHERE p.pid NOT IN (SELECT pid FROM booking);
    ```
*   **Álgebra Relacional:**
    $$\pi_{pid, pname}\left( (\pi_{pid}(passenger) - \pi_{pid}(booking)) \bowtie passenger \right)$$

### 1.5 Pasajeros masculinos asociados a la agencia 'Jet'.
*   **SQL:**
    ```sql
    SELECT DISTINCT p.pid, p.pname, p.pcity
    FROM passenger p
    JOIN booking b ON b.pid = p.pid
    JOIN agency a ON a.aid = b.aid
    WHERE p.pgender = 'Male' AND a.aname = 'Jet';
    ```
*   **Álgebra Relacional:**
    $$\pi_{pid, pname, pcity}\left( \sigma_{pgender='Male' \,\wedge\, aname='Jet'}(passenger \bowtie booking \bowtie agency) \right)$$

---

## 2. Álgebra Relacional → SQL

### 2.1 $\sigma_{src='Chennai' \,\wedge\, dest='New Delhi'}(flight)$
*   **SQL:**
    ```sql
    SELECT *
    FROM flight
    WHERE src = 'Chennai' AND dest = 'New Delhi';
    ```

### 2.2 $\pi_{fid}\bigl(\sigma_{pid=123}(booking) \bowtie \sigma_{dest='Chennai'}(flight)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT b.fid
    FROM booking b
    JOIN flight f ON f.fid = b.fid
    WHERE b.pid = 123 AND f.dest = 'Chennai';
    ```

### 2.3 $\pi_{aname}\bigl(agency \bowtie_{agency.acity = passenger.pcity} \sigma_{pid=123}(passenger)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT a.aname
    FROM agency a
    JOIN passenger p ON a.acity = p.pcity
    WHERE p.pid = 123;
    ```

### 2.4 $\bigl(\sigma_{fdate='2020-12-01' \,\wedge\, time='16:00'}(flight)\bigr) \cup \bigl(\sigma_{fdate='2020-12-02' \,\wedge\, time='16:00'}(flight)\bigr)$
*   **SQL:**
    ```sql
    SELECT * FROM flight WHERE fdate = DATE '2020-12-01' AND time = '16:00'
    UNION
    SELECT * FROM flight WHERE fdate = DATE '2020-12-02' AND time = '16:00';
    ```

### 2.5 $\pi_{aname}(agency) - \pi_{aname}\bigl(agency \bowtie \sigma_{pid=123}(booking)\bigr)$
*   **SQL:**
    ```sql
    SELECT aname FROM agency
    EXCEPT
    SELECT a.aname
    FROM agency a
    JOIN booking b ON b.aid = a.aid
    WHERE b.pid = 123;
    ```

---

## 💬 Reflexión Final

1.  **¿Qué información se pierde al traducir SQL a álgebra relacional clásica?**
    *   **Duplicados:** El álgebra relacional asume conjuntos puros (donde no hay duplicados). SQL trabaja con multiconjuntos (permite duplicados a menos que se use `DISTINCT`).
    *   **Ordenamiento:** Operadores como `ORDER BY` no existen en el álgebra relacional, ya que los conjuntos no tienen un orden inherente.
    *   **Agregación y Agrupación:** `GROUP BY`, `SUM`, `COUNT`, `AVG` no forman parte del álgebra relacional pura clásica (aunque existen extensiones como el operador de agregación $\mathcal{G}$).
    *   **Valores Nulos:** El álgebra relacional se basa en lógica bivalente (verdadero/falso), mientras que SQL implementa lógica trivalente debido al soporte de `NULL`.

2.  **¿Qué patrón de SQL traduce naturalmente a cada operador del álgebra?**
    *   $\sigma$ (Selección) traduce a la cláusula `WHERE`.
    *   $\pi$ (Proyección) traduce a la lista de columnas en el `SELECT` (idealmente con `DISTINCT`).
    *   $\bowtie$ (Join) traduce a las cláusulas `JOIN ... ON` o a comas en el `FROM`.
    *   $-$ (Diferencia) traduce a `EXCEPT` o subconsultas con `NOT IN` / `NOT EXISTS`.
    *   $\cap$ (Intersección) traduce a `INTERSECT`.

3.  **En la traducción álgebra → SQL, ¿cuándo conviene usar cada alternativa?**
    *   `JOIN ... ON` es ideal cuando necesitamos proyectar o relacionar columnas de ambas tablas.
    *   Subconsultas con `IN` / `NOT IN` convienen cuando la tabla externa solo filtra por presencia/ausencia de un atributo y no necesitamos recuperar columnas de la tabla interna.
    *   `EXCEPT` y `NOT EXISTS` son los más seguros para la diferencia de conjuntos, especialmente `NOT EXISTS` que evita problemas lógicos causados por valores `NULL` que romperían un `NOT IN`.
