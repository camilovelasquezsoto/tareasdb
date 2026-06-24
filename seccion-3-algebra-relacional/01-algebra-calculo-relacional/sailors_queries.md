# Álgebra y Cálculo Relacional: Sailors-Boats-Reserves

Resolución de las consultas en Álgebra Relacional, Cálculo Relacional de Tuplas (CRT) y SQL.

---

## 1. Selección, proyección y unión

### 1.1 Encontrar los colores de los botes reservados por el marinero llamado Albert.
*   **Álgebra Relacional:**
    $$\pi_{color}(\sigma_{sname='Albert'}(Sailors) \bowtie Reserves \bowtie Boats)$$
*   **Cálculo Relacional de Tuplas (CRT):**
    $$\{ T \ | \ \exists B \in Boats \ (T.color = B.color \ \wedge \ \exists R \in Reserves \ (R.bid = B.bid \ \wedge \ \exists S \in Sailors \ (S.sid = R.sid \ \wedge \ S.sname = 'Albert')))\} $$
*   **SQL:**
    ```sql
    SELECT DISTINCT b.color
    FROM sailors s
    JOIN reserves r ON s.sid = r.sid
    JOIN boats b ON r.bid = b.bid
    WHERE s.sname = 'Albert';
    ```

### 1.2 Encontrar los sid de marineros que tengan rating $\ge 8$ o que hayan reservado el bote 103.
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{rating \ge 8}(Sailors)) \cup \pi_{sid}(\sigma_{bid=103}(Reserves))$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sid = S.sid \ \wedge \ S.rating \ge 8) \ \vee \ \exists R \in Reserves \ (T.sid = R.sid \ \wedge \ R.bid = 103) \} $$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors WHERE rating >= 8
    UNION
    SELECT sid FROM reserves WHERE bid = 103;
    ```

---

## 2. Diferencia y negación

### 2.1 Encontrar los nombres de marineros que no han reservado un bote rojo.
*   **Álgebra Relacional:**
    $$\pi_{sname}(Sailors) - \pi_{sname}(Sailors \bowtie Reserves \bowtie \sigma_{color='red'}(Boats))$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ \neg \exists R \in Reserves \ (R.sid = S.sid \ \wedge \ \exists B \in Boats \ (B.bid = R.bid \ \wedge \ B.color = 'red'))) \} $$
*   **SQL (EXCEPT):**
    ```sql
    SELECT sname FROM sailors
    EXCEPT
    SELECT s.sname
    FROM sailors s
    JOIN reserves r ON s.sid = r.sid
    JOIN boats b ON r.bid = b.bid
    WHERE b.color = 'red';
    ```
*   **SQL (LEFT JOIN ... IS NULL):**
    ```sql
    SELECT s.sname
    FROM sailors s
    LEFT JOIN (
        SELECT DISTINCT r.sid
        FROM reserves r
        JOIN boats b ON r.bid = b.bid
        WHERE b.color = 'red'
    ) r_rojo ON s.sid = r_rojo.sid
    WHERE r_rojo.sid IS NULL;
    ```

### 2.2 Encontrar los sid de marineros con edad mayor a 20 que no han reservado un bote rojo.
*   **Álgebra Relacional:**
    $$\pi_{sid}(\sigma_{age > 20}(Sailors)) - \pi_{sid}(Reserves \bowtie \sigma_{color='red'}(Boats))$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sid = S.sid \ \wedge \ S.age > 20 \ \wedge \ \neg \exists R \in Reserves \ (R.sid = S.sid \ \wedge \ \exists B \in Boats \ (B.bid = R.bid \ \wedge \ B.color = 'red'))) \} $$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors WHERE age > 20
    EXCEPT
    SELECT r.sid
    FROM reserves r
    JOIN boats b ON r.bid = b.bid
    WHERE b.color = 'red';
    ```

---

## 3. Autoreferencia con renombrado ($\rho$)

### 3.1 Encontrar los nombres de marineros que han reservado al menos dos botes distintos.
*   **Álgebra Relacional:**
    $$\pi_{sname}\left( Sailors \bowtie \pi_{sid} \left( \sigma_{r1.bid \neq r2.bid} ( \rho_{r1}(Reserves) \bowtie_{r1.sid = r2.sid} \rho_{r2}(Reserves) ) \right) \right)$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ \exists R1 \in Reserves \ (R1.sid = S.sid \ \wedge \ \exists R2 \in Reserves \ (R2.sid = S.sid \ \wedge \ R1.bid \neq R2.bid))) \} $$
*   **SQL:**
    ```sql
    SELECT DISTINCT s.sname
    FROM sailors s
    JOIN reserves r1 ON s.sid = r1.sid
    JOIN reserves r2 ON s.sid = r2.sid
    WHERE r1.bid <> r2.bid;
    ```

### 3.2 Encontrar los sid de marineros cuyo rating es mejor que el de algún marinero llamado Bob.
*   **Álgebra Relacional:**
    $$\pi_{s1.sid} \left( \rho_{s1}(Sailors) \bowtie_{s1.rating > s2.rating} \rho_{s2}(\sigma_{sname='Bob'}(Sailors)) \right)$$
*   **CRT:**
    $$\{ T \ | \ \exists S1 \in Sailors \ (T.sid = S1.sid \ \wedge \ \exists S2 \in Sailors \ (S2.sname = 'Bob' \ \wedge \ S1.rating > S2.rating)) \} $$
*   **SQL:**
    ```sql
    SELECT DISTINCT s1.sid
    FROM sailors s1
    JOIN sailors s2 ON s2.sname = 'Bob'
    WHERE s1.rating > s2.rating;
    ```

### 3.3 Encontrar los sid de marineros cuyo rating es mejor que el de todos los marineros llamados Bob.
*   **Álgebra Relacional:**
    $$\pi_{sid}(Sailors) - \pi_{s1.sid} \left( \rho_{s1}(Sailors) \bowtie_{s1.rating \le s2.rating} \rho_{s2}(\sigma_{sname='Bob'}(Sailors)) \right)$$
*   **CRT:**
    $$\{ T \ | \ \exists S1 \in Sailors \ (T.sid = S1.sid \ \wedge \ \forall S2 \in Sailors \ (S2.sname = 'Bob' \ \implies \ S1.rating > S2.rating)) \} $$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors
    WHERE rating > ALL (SELECT rating FROM sailors WHERE sname = 'Bob');
    ```

---

## 4. División ($\div$)

### 4.1 Encontrar los nombres de marineros que han reservado todos los botes.
*   **Álgebra Relacional:**
    $$\pi_{sname}\left( Sailors \bowtie (\pi_{sid, bid}(Reserves) \div \pi_{bid}(Boats)) \right)$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ \forall B \in Boats \ (\exists R \in Reserves \ (R.sid = S.sid \ \wedge \ R.bid = B.bid))) \} $$
*   **SQL (Doble NOT EXISTS):**
    ```sql
    SELECT s.sname
    FROM sailors s
    WHERE NOT EXISTS (
        SELECT * FROM boats b
        WHERE NOT EXISTS (
            SELECT * FROM reserves r
            WHERE r.sid = s.sid AND r.bid = b.bid
        )
    );
    ```

### 4.2 Encontrar los nombres de marineros que han reservado todos los botes llamados BigBoat.
*   **Álgebra Relacional:**
    $$\pi_{sname}\left( Sailors \bowtie (\pi_{sid, bid}(Reserves) \div \pi_{bid}(\sigma_{bname='BigBoat'}(Boats))) \right)$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ \forall B \in Boats \ (B.bname = 'BigBoat' \ \implies \ \exists R \in Reserves \ (R.sid = S.sid \ \wedge \ R.bid = B.bid))) \} $$
*   **SQL (GROUP BY ... HAVING):**
    ```sql
    SELECT s.sname
    FROM sailors s
    JOIN reserves r ON s.sid = r.sid
    JOIN boats b ON r.bid = b.bid
    WHERE b.bname = 'BigBoat'
    GROUP BY s.sid, s.sname
    HAVING COUNT(DISTINCT b.bid) = (SELECT COUNT(*) FROM boats WHERE bname = 'BigBoat');
    ```

### 4.3 Encontrar los nombres de marineros que han reservado todos los botes que han sido reservados por marineros con menor rating que ellos.
*   **Álgebra Relacional:**
    $$\text{Representable mediante el operador de división condicionada.}$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ \forall B \in Boats \ (\exists R1 \in Reserves \ \exists S1 \in Sailors \ (R1.sid = S1.sid \ \wedge \ R1.bid = B.bid \ \wedge \ S1.rating < S.rating) \ \implies \ \exists R2 \in Reserves \ (R2.sid = S.sid \ \wedge \ R2.bid = B.bid))) \} $$
*   **SQL:**
    ```sql
    SELECT s.sname
    FROM sailors s
    WHERE NOT EXISTS (
        SELECT r1.bid
        FROM reserves r1
        JOIN sailors s1 ON r1.sid = s1.sid
        WHERE s1.rating < s.rating
          AND NOT EXISTS (
              SELECT *
              FROM reserves r2
              WHERE r2.sid = s.sid AND r2.bid = r1.bid
          )
    );
    ```

---

## 5. Máximo / mínimo sin agregados

### 5.1 Encontrar los sid de marineros con el rating más alto, sin usar MAX ni ORDER BY ... LIMIT.
*   **Álgebra Relacional:**
    $$\pi_{sid}(Sailors) - \pi_{s1.sid}(\rho_{s1}(Sailors) \bowtie_{s1.rating < s2.rating} \rho_{s2}(Sailors))$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sid = S.sid \ \wedge \ \neg \exists S2 \in Sailors \ (S2.rating > S.rating)) \} $$
*   **SQL:**
    ```sql
    SELECT sid FROM sailors
    WHERE sid NOT IN (
        SELECT s1.sid
        FROM sailors s1
        JOIN sailors s2 ON s1.rating < s2.rating
    );
    ```

### 5.2 Encontrar el nombre y la edad del marinero más viejo, sin usar MAX ni ORDER BY ... LIMIT.
*   **Álgebra Relacional:**
    $$\pi_{sname, age}(Sailors) - \pi_{s1.sname, s1.age}(\rho_{s1}(Sailors) \bowtie_{s1.age < s2.age} \rho_{s2}(Sailors))$$
*   **CRT:**
    $$\{ T \ | \ \exists S \in Sailors \ (T.sname = S.sname \ \wedge \ T.age = S.age \ \wedge \ \neg \exists S2 \in Sailors \ (S2.age > S.age)) \} $$
*   **SQL:**
    ```sql
    SELECT sname, age FROM sailors
    WHERE sid NOT IN (
        SELECT s1.sid
        FROM sailors s1
        JOIN sailors s2 ON s1.age < s2.age
    );
    ```
