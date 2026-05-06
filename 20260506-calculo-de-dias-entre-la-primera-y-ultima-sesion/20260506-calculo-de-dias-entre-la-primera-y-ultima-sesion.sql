/* =====================================================================================================
   [ES] AVISO IMPORTANTE – NOMBRES FICTICIOS Y USO PEDAGÓGICO ÚNICAMENTE
   -----------------------------------------------------------------------------------------------------
   Los nombres, rutas, entidades, tablas, columnas y ejemplos utilizados en este script son TOTALMENTE 
   FICTICIOS. Cualquier parecido con personas, empresas, bases de datos o entornos reales es pura 
   coincidencia.
   Este script se proporciona EXCLUSIVAMENTE con fines pedagógicos y demostrativos. 
   NO debe ejecutarse en ambientes de producción bajo ninguna circunstancia.
   =====================================================================================================
   [EN] IMPORTANT NOTICE – FICTIONAL NAMES AND EDUCATIONAL USE ONLY
   -----------------------------------------------------------------------------------------------------
   All names, paths, entities, tables, columns, and examples in this script are COMPLETELY FICTIONAL.
   This script is for EDUCATIONAL PURPOSES ONLY and MUST NOT be executed in production environments.
   ===================================================================================================== */

   -- [EN] Runs in SQL Server
   -- [ES] Funciona en SQL Server

WITH learning_sessions AS (
    -- [ES] 1. Creamos un CTE con datos ficticios que simulan sesiones de estudiantes.
    -- [EN] 1. Create a CTE with sample data simulating student sessions.
    SELECT *
    FROM (VALUES
        (101, CAST('2025-01-03 08:10:00' AS DATETIME), 'mobile'),
        (101, CAST('2025-03-22 14:55:00' AS DATETIME), 'web'),
        (102, CAST('2025-02-10 09:00:00' AS DATETIME), 'web'),
        (102, CAST('2025-02-11 09:05:00' AS DATETIME), 'web'),
        (102, CAST('2025-10-01 18:20:00' AS DATETIME), 'mobile'),
        (103, CAST('2025-07-15 12:00:00' AS DATETIME), 'tablet'),
        (104, CAST('2025-01-01 00:30:00' AS DATETIME), 'mobile'),
        (104, CAST('2025-12-31 23:50:00' AS DATETIME), 'web')
    ) AS t(student_id, session_start, device)
),
sessions_2025 AS (
    -- [ES] 2. Filtramos únicamente las sesiones ocurridas en 2025.
    -- [EN] 2. Filter only the sessions that occurred in 2025.
    SELECT 
        student_id,
        CAST(session_start AS DATE) AS session_date
    FROM learning_sessions
    WHERE session_start >= '2025-01-01'
      AND session_start <  '2026-01-01'
),
agg AS (
    -- [ES] 3. Agrupamos por estudiante.
    -- [EN] 3. Group by student.

    -- [ES] 4. Para cada estudiante obtenemos:
    --       - primera fecha del año (MIN)
    --       - última fecha del año (MAX)
    --       - total de sesiones (COUNT)
    -- [EN] 4. For each student we compute:
    --       - first date of the year (MIN)
    --       - last date of the year (MAX)
    --       - total sessions (COUNT)

    -- [ES] 5. Nos quedamos solo con estudiantes con al menos dos sesiones.
    -- [EN] 5. Keep only students with at least two sessions.
    SELECT
        student_id,
        MIN(session_date) AS first_day,
        MAX(session_date) AS last_day,
        COUNT(*) AS total_sessions
    FROM sessions_2025
    GROUP BY student_id
    HAVING COUNT(*) >= 2
)
-- [ES] 6. Calculamos la diferencia en días entre la primera y última sesión.
-- [EN] 6. Calculate the difference in days between first and last session.
SELECT
    student_id,
    DATEDIFF(DAY, first_day, last_day) AS days_between
FROM agg
ORDER BY student_id;
