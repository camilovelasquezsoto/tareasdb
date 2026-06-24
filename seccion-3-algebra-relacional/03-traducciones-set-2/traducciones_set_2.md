# Traducción SQL ↔ Álgebra Relacional (Set 2)

Soluciones al segundo set ampliado de práctica de traducción bidireccional sobre los 4 mini-esquemas (Sailors, Suppliers, Employees y Appointments).

---

## 1. SQL → Álgebra Relacional

### 1.1 Colores de los botes reservados por Albert.
*   **SQL:**
    ```sql
    SELECT DISTINCT b.color
    FROM sailors s
    JOIN reserves r ON r.sid = s.sid
    JOIN boats b ON b.bid = r.bid
    WHERE s.sname = 'Albert';
    ```
*   **Álgebra Relacional:**
    $$\pi_{color}(\sigma_{sname='Albert'}(sailors) \bowtie reserves \bowtie boats)$$

### 1.2 sid de marineros con rating $\ge 8$ o que reservaron el bote 103.
*   **SQL:**
    ```sql
    SELECT sid FROM sailors WHERE rating >= 8
    UNION
    SELECT sid FROM reserves WHERE bid = 103;
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{rating \ge 8}(sailors)) \cup \pi_{sid}(\sigma_{bid=103}(reserves))$$

### 1.3 Nombres de marineros que no reservaron un bote rojo.
*   **SQL:**
    ```sql
    SELECT s.sname
    FROM sailors s
    WHERE s.sid NOT IN (
      SELECT r.sid FROM reserves r JOIN boats b ON b.bid = r.bid
      WHERE b.color = 'red'
    );
    ```
*   **Álgebra Relacional:**
    $$\pi_{sname}(sailors) - \pi_{sname}(sailors \bowtie reserves \bowtie \sigma_{color='red'}(boats))$$

### 1.4 sid de marineros con edad > 20 que no reservaron un bote rojo.
*   **SQL:**
    ```sql
    SELECT s.sid
    FROM sailors s
    WHERE s.age > 20
      AND s.sid NOT IN (
        SELECT r.sid FROM reserves r JOIN boats b ON b.bid = r.bid
        WHERE b.color = 'red'
      );
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{age>20}(sailors)) - \pi_{sid}(reserves \bowtie \sigma_{color='red'}(boats))$$

### 1.5 Nombres de marineros que reservaron al menos dos botes distintos.
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM sailors s
    JOIN reserves r1 ON r1.sid = s.sid
    JOIN reserves r2 ON r2.sid = s.sid
    WHERE r1.bid <> r2.bid;
    ```
*   **Álgebra Relacional:**
    $$\pi_{s.sname}\left( \sigma_{r1.bid \neq r2.bid}( \rho_{s}(sailors) \bowtie_{s.sid=r1.sid} \rho_{r1}(reserves) \bowtie_{s.sid=r2.sid} \rho_{r2}(reserves) ) \right)$$

### 1.6 Nombres de marineros que reservaron todos los botes.
*   **SQL:**
    ```sql
    SELECT s.sname
    FROM sailors s
    WHERE NOT EXISTS (
      SELECT 1 FROM boats b
      WHERE NOT EXISTS (
        SELECT 1 FROM reserves r WHERE r.sid = s.sid AND r.bid = b.bid
      )
    );
    ```
*   **Álgebra Relacional:**
    $$\pi_{sname}\left( sailors \bowtie (\pi_{sid, bid}(reserves) \div \pi_{bid}(boats)) \right)$$

### 1.7 Nombres de marineros que reservaron todos los botes llamados *BigBoat*.
*   **SQL:**
    ```sql
    SELECT s.sname
    FROM sailors s
    WHERE NOT EXISTS (
      SELECT 1 FROM boats b
      WHERE b.bname = 'BigBoat'
        AND NOT EXISTS (
          SELECT 1 FROM reserves r WHERE r.sid = s.sid AND r.bid = b.bid
        )
    );
    ```
*   **Álgebra Relacional:**
    $$\pi_{sname}\left( sailors \bowtie (\pi_{sid, bid}(reserves) \div \pi_{bid}(\sigma_{bname='BigBoat'}(boats))) \right)$$

### 1.8 Nombres de proveedores que suministran alguna parte roja.
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM suppliers s
    JOIN catalog c ON c.sid = s.sid
    JOIN parts p ON p.pid = c.pid
    WHERE p.color = 'red';
    ```
*   **Álgebra Relacional:**
    $$\pi_{sname}(\sigma_{color='red'}(parts) \bowtie catalog \bowtie suppliers)$$

### 1.9 sid de proveedores que suministran alguna parte roja o verde.
*   **SQL:**
    ```sql
    SELECT DISTINCT c.sid
    FROM catalog c JOIN parts p ON p.pid = c.pid
    WHERE p.color IN ('red','green');
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{color='red' \,\vee\, color='green'}(parts) \bowtie catalog)$$

### 1.10 sid de proveedores que suministran una parte roja o están en *21 George Street*.
*   **SQL:**
    ```sql
    SELECT c.sid FROM catalog c JOIN parts p ON p.pid=c.pid WHERE p.color='red'
    UNION
    SELECT sid FROM suppliers WHERE address = '21 George Street';
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{color='red'}(parts) \bowtie catalog) \cup \pi_{sid}(\sigma_{address='21 George Street'}(suppliers))$$

### 1.11 sid de proveedores que suministran alguna parte roja y alguna verde.
*   **SQL:**
    ```sql
    SELECT sid FROM catalog c JOIN parts p ON p.pid=c.pid WHERE p.color='red'
    INTERSECT
    SELECT sid FROM catalog c JOIN parts p ON p.pid=c.pid WHERE p.color='green';
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{color='red'}(parts) \bowtie catalog) \cap \pi_{sid}(\sigma_{color='green'}(parts) \bowtie catalog)$$

### 1.12 Pares de sid tales que el primero cobra más que el segundo por la misma parte.
*   **SQL:**
    ```sql
    SELECT c1.sid AS sid_caro, c2.sid AS sid_barato
    FROM catalog c1
    JOIN catalog c2 ON c1.pid = c2.pid AND c1.cost > c2.cost;
    ```
*   **Álgebra Relacional:**
    $$\pi_{c1.sid, c2.sid}\left( \rho_{c1}(catalog) \bowtie_{c1.pid=c2.pid \,\wedge\, c1.cost>c2.cost} \rho_{c2}(catalog) \right)$$

### 1.13 sid de proveedores que suministran solo partes rojas.
*   **SQL:**
    ```sql
    SELECT sid FROM suppliers
    EXCEPT
    SELECT c.sid FROM catalog c JOIN parts p ON p.pid=c.pid WHERE p.color <> 'red';
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid}(suppliers) - \pi_{sid}(catalog \bowtie \sigma_{color \neq 'red'}(parts))$$

### 1.14 sid de proveedores que suministran todas las partes.
*   **SQL:**
    ```sql
    SELECT c.sid
    FROM catalog c
    GROUP BY c.sid
    HAVING COUNT(DISTINCT c.pid) = (SELECT COUNT(*) FROM parts);
    ```
*   **Álgebra Relacional:**
    $$\pi_{sid, pid}(catalog) \div \pi_{pid}(parts)$$

### 1.15 Nombres y salarios de jefes que tienen algún empleado con salario > 100.
*   **SQL:**
    ```sql
    SELECT DISTINCT b.name, b.salary
    FROM employees b
    JOIN supervises sv ON sv.boss = b.number
    JOIN employees e ON e.number = sv.employee
    WHERE e.salary > 100;
    ```
*   **Álgebra Relacional:**
    $$\pi_{b.name, b.salary}\left( \sigma_{e.salary>100}( \rho_{b}(employees) \bowtie_{b.number=sv.boss} \rho_{sv}(supervises) \bowtie_{sv.employee=e.number} \rho_{e}(employees) ) \right)$$

### 1.16 Pares (jefe, empleado) donde el empleado gana más que su jefe.
*   **SQL:**
    ```sql
    SELECT b.name AS jefe, e.name AS empleado
    FROM supervises sv
    JOIN employees b ON b.number = sv.boss
    JOIN employees e ON e.number = sv.employee
    WHERE e.salary > b.salary;
    ```
*   **Álgebra Relacional:**
    $$\pi_{b.name, e.name}\left( \sigma_{e.salary>b.salary}( supervises \bowtie_{boss=b.number} \rho_{b}(employees) \bowtie_{employee=e.number} \rho_{e}(employees) ) \right)$$

### 1.17 Nombres de empleados que no tienen jefe.
*   **SQL:**
    ```sql
    SELECT name FROM employees
    WHERE number NOT IN (SELECT employee FROM supervises);
    ```
*   **Álgebra Relacional:**
    $$\pi_{name}\left( employees \bowtie_{number=x} \rho_{x}( \pi_{number}(employees) - \pi_{employee}(supervises) ) \right)$$

### 1.18 Hora de cita y nombre del cliente para las citas de Giuliano el 2026-02-14.
*   **SQL:**
    ```sql
    SELECT c.name, a.atime
    FROM appointments a
    JOIN staff s ON s.sid = a.sid
    JOIN clients c ON c.cid = a.cid
    WHERE a.adate = DATE '2026-02-14' AND s.name = 'Giuliano';
    ```
*   **Álgebra Relacional:**
    $$\pi_{c.name, a.atime}\left( \sigma_{a.adate='2026-02-14' \,\wedge\, s.name='Giuliano'}( \rho_{a}(appointments) \bowtie_{a.sid=s.sid} \rho_{s}(staff) \bowtie_{a.cid=c.cid} \rho_{c}(clients) ) \right)$$

### 1.19 Servicios que han sido solicitados al menos una vez.
*   **SQL:**
    ```sql
    SELECT DISTINCT service FROM appointments;
    ```
*   **Álgebra Relacional:**
    $$\pi_{service}(appointments)$$

### 1.20 Clientes (nombre y teléfono) que nunca tomaron el servicio manicure.
*   **SQL:**
    ```sql
    SELECT c.name, c.phone
    FROM clients c
    WHERE c.cid NOT IN (SELECT cid FROM appointments WHERE service = 'manicure');
    ```
*   **Álgebra Relacional:**
    $$\pi_{name, phone}(clients) - \pi_{name, phone}(clients \bowtie \sigma_{service='manicure'}(appointments))$$

---

## 2. Álgebra Relacional → SQL

### 2.1 $\pi_{sid}\bigl(\sigma_{rating > 7}(sailors)\bigr)$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors WHERE rating > 7;
    ```

### 2.2 $\pi_{sname}\bigl(\sigma_{age \ge 18 \,\wedge\, age \le 25}(sailors)\bigr)$
*   **SQL:**
    ```sql
    SELECT sname FROM sailors WHERE age BETWEEN 18 AND 25;
    ```

### 2.3 $\pi_{sname}\bigl(sailors \bowtie reserves \bowtie \sigma_{color='red'}(boats)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM sailors s
    JOIN reserves r ON r.sid = s.sid
    JOIN boats b ON b.bid = r.bid
    WHERE b.color = 'red';
    ```

### 2.4 $\pi_{s1.sid}\bigl(\rho_{s1}(sailors) \bowtie_{s1.rating > s2.rating} \rho_{s2}(\sigma_{sname='Bob'}(sailors))\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT s1.sid
    FROM sailors s1 
    JOIN sailors s2 ON s1.rating > s2.rating
    WHERE s2.sname = 'Bob';
    ```

### 2.5 $\pi_{sid}(sailors) - \pi_{s1.sid}\bigl(\rho_{s1}(sailors) \bowtie_{s1.rating < s2.rating} \rho_{s2}(sailors)\bigr)$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors
    WHERE rating = (SELECT MAX(rating) FROM sailors);
    ```

### 2.6 $\pi_{pname}\bigl(\sigma_{color='red'}(parts)\bigr)$
*   **SQL:**
    ```sql
    SELECT pname FROM parts WHERE color = 'red';
    ```

### 2.7 $\pi_{cost}\bigl(\sigma_{color='red' \,\vee\, color='green'}(parts) \bowtie catalog\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT c.cost
    FROM catalog c 
    JOIN parts p ON p.pid = c.pid
    WHERE p.color IN ('red','green');
    ```

### 2.8 $\pi_{sid}\bigl(\sigma_{color='red' \,\vee\, color='green'}(parts) \bowtie catalog\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT c.sid
    FROM catalog c 
    JOIN parts p ON p.pid = c.pid
    WHERE p.color IN ('red','green');
    ```

### 2.9 $\pi_{sname}\Bigl(\pi_{sid}\bigl(\sigma_{color='red' \,\vee\, color='green'}(parts) \bowtie catalog\bigr) \bowtie suppliers\Bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM suppliers s
    JOIN catalog c ON c.sid = s.sid
    JOIN parts p ON p.pid = c.pid
    WHERE p.color IN ('red','green');
    ```

### 2.10 $\pi_{sname}\bigl(\sigma_{color='red'}(parts) \bowtie \sigma_{cost < 100}(catalog) \bowtie suppliers\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM suppliers s
    JOIN catalog c ON c.sid = s.sid
    JOIN parts p ON p.pid = c.pid
    WHERE p.color = 'red' AND c.cost < 100;
    ```

### 2.11 $\pi_{sname}(\sigma_{color='red'}(parts) \bowtie \sigma_{cost<100}(catalog) \bowtie suppliers) \cap \pi_{sname}(\sigma_{color='green'}(parts) \bowtie \sigma_{cost<100}(catalog) \bowtie suppliers)$
*   **SQL:**
    ```sql
    SELECT s.sname
    FROM suppliers s JOIN catalog c ON c.sid=s.sid JOIN parts p ON p.pid=c.pid
    WHERE p.color='red' AND c.cost<100
    INTERSECT
    SELECT s.sname
    FROM suppliers s JOIN catalog c ON c.sid=s.sid JOIN parts p ON p.pid=c.pid
    WHERE p.color='green' AND c.cost<100;
    ```

### 2.12 $\pi_{sid}(\sigma_{color='red'}(parts) \bowtie \sigma_{cost<100}(catalog)) \cap \pi_{sid}(\sigma_{color='green'}(parts) \bowtie \sigma_{cost<100}(catalog))$
*   **SQL:**
    ```sql
    SELECT c.sid FROM catalog c JOIN parts p ON p.pid=c.pid
    WHERE p.color='red' AND c.cost<100
    INTERSECT
    SELECT c.sid FROM catalog c JOIN parts p ON p.pid=c.pid
    WHERE p.color='green' AND c.cost<100;
    ```

### 2.13 $\pi_{sid}(suppliers) - \pi_{sid}(catalog)$
*   **SQL:**
    ```sql
    SELECT sid FROM suppliers
    EXCEPT
    SELECT sid FROM catalog;
    ```

### 2.14 $\bigl(\pi_{sid}(catalog) \times \pi_{pid}(parts)\bigr) - \pi_{sid,pid}(catalog)$
*   **SQL:**
    ```sql
    SELECT c.sid, p.pid
    FROM (SELECT DISTINCT sid FROM catalog) c CROSS JOIN parts p
    EXCEPT
    SELECT sid, pid FROM catalog;
    ```

### 2.15 $\pi_{name}\bigl(\sigma_{salary > 1000 \,\wedge\, age < 30}(employees)\bigr)$
*   **SQL:**
    ```sql
    SELECT name FROM employees WHERE salary > 1000 AND age < 30;
    ```

### 2.16 $\pi_{name}\bigl(\rho_{b}(employees) \bowtie_{b.number=sv.boss} \rho_{sv}(supervises)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT b.name
    FROM employees b JOIN supervises sv ON sv.boss = b.number;
    ```

### 2.17 $\pi_{number}(employees) - \pi_{boss}(supervises)$
*   **SQL:**
    ```sql
    SELECT number FROM employees
    EXCEPT
    SELECT boss FROM supervises;
    ```

### 2.18 $\pi_{name, phone}\bigl(clients \bowtie \sigma_{service='haircut'}(appointments)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT c.name, c.phone
    FROM clients c JOIN appointments a ON a.cid = c.cid
    WHERE a.service = 'haircut';
    ```

### 2.19 $\pi_{cid}(clients) - \pi_{cid}(appointments)$
*   **SQL:**
    ```sql
    SELECT cid FROM clients
    EXCEPT
    SELECT cid FROM appointments;
    ```

### 2.20 $\pi_{c.name, s.name}\bigl(\rho_{c}(clients) \bowtie_{c.cid=a.cid} \rho_{a}(appointments) \bowtie_{a.sid=s.sid} \rho_{s}(staff)\bigr)$
*   **SQL:**
    ```sql
    SELECT DISTINCT c.name AS cliente, s.name AS atendido_por
    FROM clients c
    JOIN appointments a ON a.cid = c.cid
    JOIN staff s ON s.sid = a.sid;
    ```
