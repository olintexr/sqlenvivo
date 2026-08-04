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

   -- Sample data: simulated sequence of games for the team.
-- Higher game_number means a more recent game.
WITH Games AS (
    SELECT 'Phillies' AS team, 17 AS game_number, 'W' AS result UNION ALL   
    SELECT 'Phillies', 16, 'W' UNION ALL                                   
    SELECT 'Phillies', 15, 'W' UNION ALL                                   
    SELECT 'Phillies', 14, 'W' UNION ALL                                   
    SELECT 'Phillies', 13, 'W' UNION ALL                                   
    SELECT 'Phillies', 12, 'L' UNION ALL
    SELECT 'Phillies', 11, 'L' UNION ALL
    SELECT 'Phillies', 10, 'W' UNION ALL
    SELECT 'Phillies', 9,  'W' UNION ALL
    SELECT 'Phillies', 8,  'W' UNION ALL
    SELECT 'Phillies', 7,  'L' UNION ALL
    SELECT 'Phillies', 6,  'L' UNION ALL
    SELECT 'Phillies', 5,  'W' UNION ALL
    SELECT 'Mets', 16, 'L' UNION ALL                                   
    SELECT 'Mets', 15, 'L' UNION ALL                                   
    SELECT 'Mets', 14, 'W' 
),

-- CTE x:
-- Orders games from most recent to oldest.
-- pos = position in that order (1 = most recent).
-- prev = result of the previous game in the ordered sequence.
x AS (
    SELECT
        team,
        game_number,
        result,
        ROW_NUMBER() OVER (PARTITION BY team ORDER BY game_number DESC) AS pos,
        LAG(result) OVER (PARTITION BY team ORDER BY game_number DESC) AS prev
    FROM Games
),

-- CTE flags:
-- flag = 1 when the result changes compared to the previous game.
-- flag = 0 when the result is the same (streak continues).
-- pos = 1 always has flag = 0 because there is no previous game.
flags AS (
    SELECT
        team,
        pos,
        result,
        CASE 
            WHEN pos = 1 THEN 0          -- first game: no previous result
            WHEN result = prev THEN 0    -- same result: streak continues
            ELSE 1                       -- different result: streak breaks
        END AS flag
    FROM x
)

-- Final calculation:
-- streak_type = result of the most recent game (pos = 1).
-- streak_length:
--   If a flag = 1 exists: first flag position minus 1.
--   If no flag = 1 exists: entire sequence is a streak.
SELECT 
    team,

    -- Type of streak = result of the most recent game
    MAX(CASE WHEN pos = 1 THEN result END) AS streak_type,

    -- Length of the streak
    COALESCE(
        MIN(CASE WHEN flag = 1 THEN pos END) - 1,   -- first break in the streak
        MAX(pos)                                    -- if no break, full sequence is the streak
    ) AS streak_length
FROM flags
GROUP BY team;
