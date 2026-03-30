/* =====================================================================================================
   [ES] AVISO IMPORTANTE – NOMBRES FICTICIOS Y USO PEDAGÓGICO ÚNICAMENTE
   -----------------------------------------------------------------------------------------------------
   Los nombres, rutas, entidades, tablas, columnas y ejemplos utilizados en este script son TOTALMENTE 
   FICTICIOS. Cualquier parecido con personas, empresas, bases de datos o entornos reales es pura 
   coincidencia.
   Este script se proporciona EXCLUSIVAMENTE con fines pedagógicos y demostrativos. 
   NO debe ejecutarse en ambientes de producción bajo ninguna circunstancia.
   No se garantiza que este script evite alteraciones, inserciones, eliminaciones o modificaciones de 
   datos en sistemas reales. El autor no asume responsabilidad por el uso indebido del contenido.
   =====================================================================================================
   [EN] IMPORTANT NOTICE – FICTIONAL NAMES AND EDUCATIONAL USE ONLY
   -----------------------------------------------------------------------------------------------------
   The names, paths, entities, tables, columns, and examples used in this script are COMPLETELY 
   FICTIONAL. Any resemblance to real persons, companies, databases, or environments is purely 
   coincidental.
   This script is provided SOLELY for educational and demonstration purposes. 
   It MUST NOT be executed in production environments under any circumstances.
   There is no guarantee that this script will prevent alteration, insertion, deletion, or modification 
   of data in real systems. The author assumes no responsibility for misuse of this content.
   ===================================================================================================== */
   
/* ============================================================
   ES: 1. LIMPIEZA (solo para pruebas)
   EN: 1. CLEANUP (for testing purposes)
   ============================================================ */
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS Cliente;

/* ============================================================
   ES: 2. TABLA MAESTRO: Cliente
   EN: 2. MASTER TABLE: Cliente
   ============================================================ */
CREATE TABLE Cliente (
    Cedula INT PRIMARY KEY,     -- ES: Clave primaria / EN: Primary key
    Nombre VARCHAR(100) NOT NULL
);

/* ============================================================
   ES: 3. TABLA DETALLE: Pedido
   EN: 3. DETAIL TABLE: Pedido
   ============================================================ */
/*
   ES: IMPORTANTE: Solo debe quedar UNA de estas tres definiciones activas.
   EN: IMPORTANT: Only ONE of these three definitions must remain active.
*/

/* ============================================================
   CASO 1: RESTRICT (por defecto)
   CASE 1: RESTRICT (default behavior)
   ------------------------------------------------------------
   ES: - No permite borrar un Cliente si tiene Pedidos.
   EN: - Does not allow deleting a Cliente if it has Pedidos.

   ES: - No permite insertar un Pedido con Cedula inexistente.
   EN: - Does not allow inserting a Pedido with a non‑existent Cedula.

   ES: - No permite actualizar la PK si hay dependencias.
   EN: - Does not allow updating the PK if dependencies exist.
   ============================================================ */

CREATE TABLE Pedido (
    Pedido INT PRIMARY KEY,
    Cedula INT NOT NULL,
    Fecha DATE NOT NULL,
    FOREIGN KEY (Cedula) REFERENCES Cliente(Cedula)
    -- ES: RESTRICT es el comportamiento por defecto
    -- EN: RESTRICT is the default behavior
);

-- ES: FIN DEL CASO 1
-- EN: END OF CASE 1
-- ============================================================

/* ============================================================
   CASO 2: CASCADE
   CASE 2: CASCADE
   ------------------------------------------------------------
   ES: - Si se borra un Cliente → se borran sus Pedidos.
   EN: - If a Cliente is deleted → its Pedidos are deleted.

   ES: - Si se actualiza la PK → se actualiza en Pedido.
   EN: - If the PK is updated → it updates in Pedido.
   ============================================================ */

/*
CREATE TABLE Pedido (
    Pedido INT PRIMARY KEY,
    Cedula INT NOT NULL,
    Fecha DATE NOT NULL,
    FOREIGN KEY (Cedula) REFERENCES Cliente(Cedula)
        ON DELETE CASCADE   -- ES: Borrado en cascada / EN: Cascade delete
        ON UPDATE CASCADE   -- ES: Actualización en cascada / EN: Cascade update
);
*/

-- ES: FIN DEL CASO 2
-- EN: END OF CASE 2
-- ============================================================

/* ============================================================
   CASO 3: SET NULL
   CASE 3: SET NULL
   ------------------------------------------------------------
   ES: - Si se borra un Cliente → los Pedidos quedan con Cedula = NULL.
   EN: - If a Cliente is deleted → Pedidos get Cedula = NULL.

   ES: - Si se actualiza la PK → los Pedidos quedan con Cedula = NULL.
   EN: - If the PK is updated → Pedidos get Cedula = NULL.

   ES: - Cedula debe permitir NULL.
   EN: - Cedula must allow NULL.
   ============================================================ */

/*
CREATE TABLE Pedido (
    Pedido INT PRIMARY KEY,
    Cedula INT NULL,   -- ES: Debe permitir NULL / EN: Must allow NULL
    Fecha DATE NOT NULL,
    FOREIGN KEY (Cedula) REFERENCES Cliente(Cedula)
        ON DELETE SET NULL   -- ES: Dejar en NULL / EN: Set to NULL on delete
        ON UPDATE SET NULL   -- ES: Dejar en NULL / EN: Set to NULL on update
);
*/

-- ES: FIN DEL CASO 3
-- EN: END OF CASE 3
-- ============================================================

/* ============================================================
   4. INSERTANDO DATOS DE PRUEBA
   4. INSERTING TEST DATA
   ============================================================ */

INSERT INTO Cliente (Cedula, Nombre)
VALUES
  (1, 'Ana'),
  (2, 'Luis'),
  (3, 'María');

INSERT INTO Pedido (Pedido, Cedula, Fecha)
VALUES
  (101, 1, '2024-01-10'),
  (102, 1, '2024-01-12'),
  (103, 2, '2024-02-01');

/* ============================================================
   5. PRUEBAS DE INTEGRIDAD
   5. INTEGRITY TESTS
   ============================================================ */

-- ES: Insertar un pedido con cédula inexistente → ERROR
-- EN: Insert a pedido with non‑existent cedula → ERROR
-- INSERT INTO Pedido (Pedido, Cedula, Fecha) VALUES (201, 999, '2024-03-01');

-- ES: Borrar un cliente con pedidos asociados
-- EN: Delete a cliente with associated pedidos
-- RESTRICT → ERROR
-- CASCADE → borra también los pedidos / deletes pedidos too
-- SET NULL → pedidos quedan con Cedula = NULL / pedidos get Cedula = NULL
-- DELETE FROM Cliente WHERE Cedula = 1;

-- ES: Borrar un cliente sin pedidos → permitido
-- EN: Delete a cliente with no pedidos → allowed
-- INSERT INTO Cliente (Cedula, Nombre) VALUES (55, 'Luis');
-- DELETE FROM Cliente WHERE Cedula = 55;

-- ES: Actualizar la PK del cliente
-- EN: Update the client's PK

-- ES: RESTRICT → ERROR si existen pedidos que referencian esa Cedula;
--     permitido si NO hay filas dependientes.
-- EN: RESTRICT → ERROR if there are pedidos referencing that Cedula;
--     allowed if there are NO dependent rows.

-- ES: CASCADE → actualiza automáticamente la Cedula en Pedido.
-- EN: CASCADE → automatically updates Cedula in Pedido.

-- ES: SET NULL → pone Cedula = NULL en Pedido para las filas que referencian esa Cedula.
-- EN: SET NULL → sets Cedula = NULL in Pedido for rows referencing that Cedula.

-- ES: Ejemplo de intento de actualización de PK:
-- EN: Example of PK update attempt:
-- SELECT * FROM pedido
-- UPDATE Cliente SET Cedula = 10 WHERE Cedula = 1;
-- SELECT * FROM pedido

