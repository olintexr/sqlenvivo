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

-- ============================================================
-- [EN] This script provides two queries: the incorrect solution 
--      and the correct solution. Both use the same CTE so the 
--      reader can run them separately and compare results.
--
-- [ES] Este script ofrece dos consultas: la solución incorrecta 
--      y la solución correcta. Ambas usan el mismo CTE para que 
--      la persona pueda ejecutarlas por separado y comparar 
--      los resultados.
--
--      Both queries include WHERE rn = 1 so the difference 
--      becomes obvious.
--
--      Ambas consultas incluyen WHERE rn = 1 para que la 
--      diferencia sea evidente.
-- ============================================================



-- ============================================================
-- [EN] INCORRECT QUERY (run this first)
-- [ES] CONSULTA INCORRECTA (ejecutar primero)
-- ============================================================

WITH daily_transactions AS (
    SELECT * FROM (
        VALUES
            (12, CAST('2024-01-01 00:45:00' AS DATETIME2), 'A1'),
            (12, CAST('2024-01-01 07:12:00' AS DATETIME2), 'A2'),
            (12, CAST('2024-01-01 14:37:00' AS DATETIME2), 'A3'),
            (12, CAST('2024-01-02 10:35:00' AS DATETIME2), 'B1'),
            (34, CAST('2024-01-01 09:10:00' AS DATETIME2), 'C1'),
            (34, CAST('2024-01-01 11:55:00' AS DATETIME2), 'C2')
    ) AS t(merchant_id, transaction_ts, transaction_id)
),

incorrect_solution AS (
    SELECT
        merchant_id,
        transaction_ts,
        transaction_id,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id, transaction_ts   -- [EN] Wrong: partitions by full timestamp
                                                       -- [ES] Incorrecto: particiona por timestamp completo
            ORDER BY transaction_ts
        ) AS rn
    FROM daily_transactions
)

SELECT
    merchant_id,
    transaction_ts,
    transaction_id
FROM incorrect_solution
WHERE rn = 1   -- [EN] Always returns all rows (wrong behavior)
               -- [ES] Siempre devuelve todas las filas (comportamiento incorrecto)
ORDER BY merchant_id, transaction_ts;

-- [EN] Problem:
-- Each timestamp is unique, so each row becomes its own partition.
-- ROW_NUMBER() always returns 1, giving a false sense of correctness.
--
-- [ES] Problema:
-- Cada timestamp es único, así que cada fila queda sola en su partición.
-- ROW_NUMBER() siempre devuelve 1, creando una falsa sensación de corrección.



-- ============================================================
-- [EN] CORRECT QUERY (run this after the incorrect one)
-- [ES] CONSULTA CORRECTA (ejecutar después de la incorrecta)
-- ============================================================

WITH daily_transactions AS (
    SELECT * FROM (
        VALUES
            (12, CAST('2024-01-01 00:45:00' AS DATETIME2), 'A1'),
            (12, CAST('2024-01-01 07:12:00' AS DATETIME2), 'A2'),
            (12, CAST('2024-01-01 14:37:00' AS DATETIME2), 'A3'),
            (12, CAST('2024-01-02 10:35:00' AS DATETIME2), 'B1'),
            (34, CAST('2024-01-01 09:10:00' AS DATETIME2), 'C1'),
            (34, CAST('2024-01-01 11:55:00' AS DATETIME2), 'C2')
    ) AS t(merchant_id, transaction_ts, transaction_id)
),

correct_solution AS (
    SELECT
        merchant_id,
        CAST(transaction_ts AS DATE) AS transaction_date,   -- [EN] Align granularity with analysis
                                                            -- [ES] Alinear la granularidad con el análisis
        transaction_ts,
        transaction_id,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id, CAST(transaction_ts AS DATE)   -- [EN] Correct: partition by day
                                                                     -- [ES] Correcto: particionar por día
            ORDER BY transaction_ts                                  -- [EN] Earliest timestamp wins
                                                                     -- [ES] Gana el timestamp más temprano
        ) AS rn
    FROM daily_transactions
)

SELECT
    merchant_id,
    transaction_date,
    transaction_id,
    transaction_ts
FROM correct_solution
WHERE rn = 1   -- [EN] Correct: returns only the earliest transaction per day
               -- [ES] Correcto: devuelve solo la transacción más temprana del día
ORDER BY merchant_id, transaction_date;

-- [EN] This query correctly returns the first transaction of each day per merchant.
-- [ES] Esta consulta devuelve correctamente la primera transacción del día por merchant.
