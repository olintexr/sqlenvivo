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

-- This script is designed to run in Microsoft SQL Server.
-- I’m using T‑SQL features such as CTEs, ROW_NUMBER(), DATEADD(), and VALUES,
-- so everything here assumes a SQL Server environment.
-- Other SQL engines may require syntax adjustments.


-- If you spot an error or think something can be improved,
-- feel free to reach out to me on LinkedIn: Olinto Rodríguez Atencio.
-- I’m always happy to refine, clarify, or discuss SQL ideas.
-- Thanks for reading!

------------------------------------------------------------------------------------------------------------

-- CTE for the original log data.
-- Some users appear multiple times on the same date, and I did this on purpose:
-- I included repeated dates to simulate multiple login events on the same day.
-- These duplicates help me illustrate why I later need a DISTINCT step
-- before calculating streaks.
WITH cte_log AS (
    SELECT 
        usr,
        CAST(log_date AS DATE) AS log_date
    FROM (VALUES
        -- Alice
        ('Alice',  '2026-02-01'),
        ('Alice',  '2026-02-02'),
        ('Alice',  '2026-02-02'),
        ('Alice',  '2026-02-02'),
        ('Alice',  '2026-02-02'),
        ('Alice',  '2026-02-02'),
        ('Alice',  '2026-02-03'),
        ('Alice',  '2026-02-05'),
        ('Alice',  '2026-02-06'),
        ('Alice',  '2026-02-09'),

        -- John
        ('John',   '2026-02-01'),
        ('John',   '2026-02-02'),
        ('John',   '2026-02-04'),
        ('John',   '2026-02-05'),
        ('John',   '2026-02-07'),
        ('John',   '2026-02-08'),

        -- Mary
        ('Mary',   '2026-02-04'),
        ('Mary',   '2026-02-05'),
        ('Mary',   '2026-02-05'),
        ('Mary',   '2026-02-05'),
        ('Mary',   '2026-02-05'),
        ('Mary',   '2026-02-06'),

        -- Olinto
        ('Olinto', '2026-02-01'),
        ('Olinto', '2026-02-02'),
        ('Olinto', '2026-02-03'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-04'),
        ('Olinto', '2026-02-05'),
        ('Olinto', '2026-02-05'),
        ('Olinto', '2026-02-06'),
        ('Olinto', '2026-02-06'),
        ('Olinto', '2026-02-07'),
        ('Olinto', '2026-02-10'),
        ('Olinto', '2026-02-11'),
        ('Olinto', '2026-02-12'),
        ('Olinto', '2026-02-15'),
        ('Olinto', '2026-02-16'),
        ('Olinto', '2026-02-18')
    ) AS t(usr, log_date)
),

-- CTE to get distinct log entries.
-- A user may appear multiple times on the same date, so here I remove duplicates.
-- By keeping only one record per (usr, log_date), I make sure my streak logic
-- is based on unique calendar days rather than total login events.
cte_distinct AS (
    SELECT DISTINCT 
        usr, 
        log_date 
    FROM 
        cte_log
), 

-- CTE to calculate streaks using window functions.
-- I assign a sequential number to each date per user.
-- When dates are consecutive, the difference between the date and the row number
-- stays constant, which lets me detect streaks.
-- I could compute this in a separate CTE, but I prefer doing it here
-- because it keeps the logic compact and makes the final grouping step simpler.
cte_window AS (
    SELECT 
        usr, 
        log_date AS current_log_date, 

        -- Sequential number for each date per user.
        ROW_NUMBER() OVER (PARTITION BY usr ORDER BY log_date) AS days,

        -- Here I compute the theoretical start of the streak.
        -- If the user logs in on consecutive days, all those rows share
        -- the same streak_start value because the date–row_number offset stays constant.
        -- If there's a gap, that offset changes, giving me a new streak_start
        -- and therefore a new streak.
        DATEADD(
            DAY,
            -ROW_NUMBER() OVER (PARTITION BY usr ORDER BY log_date),
            log_date
        ) AS streak_start
    FROM
        cte_distinct
)

-- For each user and each streak_start anchor, I compute the actual streak.
-- The earliest date becomes the start_date, and the number of rows tells me
-- how long the streak is.
SELECT 
    usr, 
    MIN(current_log_date) AS start_date,
    COUNT(days) AS days
FROM 
    cte_window
GROUP BY 
    usr, 
    streak_start
-- I only keep streaks with at least 3 consecutive days.
HAVING 
    COUNT(days) >= 3
ORDER BY
    usr, 
    streak_start;
