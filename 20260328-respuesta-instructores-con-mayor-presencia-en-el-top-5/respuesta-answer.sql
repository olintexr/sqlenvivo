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
WITH 
-- ============================================
-- Fake table: instructors
-- EN: Simulated instructor table
-- ES: Tabla simulada de instructores
-- ============================================

instructors AS (
    SELECT 1 AS instructor_id, 'Alice Johnson' AS instructor_name UNION ALL
    SELECT 2, 'Carlos Prego' UNION ALL
    SELECT 3, 'Mei Tan' UNION ALL
    SELECT 4, 'John Smith' UNION ALL
    SELECT 5, 'Laura Guerra'
),

-- ============================================
-- Fake table: courses
-- EN: Simulated courses table (course_title matches real schema)
-- ES: Tabla simulada de cursos (course_title coincide con el esquema real)
-- ============================================
courses AS (
    SELECT 101 AS course_id, 1 AS instructor_id, 'SQL Basics' AS course_title UNION ALL
    SELECT 102, 1, 'Advanced SQL' UNION ALL
    SELECT 103, 1, 'Query Tuning' UNION ALL
    SELECT 201, 2, 'Python for Data' UNION ALL
    SELECT 202, 2, 'ETL Pipelines' UNION ALL
    SELECT 301, 3, 'Data Visualization' UNION ALL
    SELECT 302, 3, 'Dashboards' UNION ALL
    SELECT 401, 4, 'Machine Learning Intro' UNION ALL
    SELECT 402, 4, 'ML Pipelines' UNION ALL
    SELECT 501, 5, 'Statistics 101'
),

-- ============================================
-- Fake table: course_rankings
-- EN: Simulated rankings table with intentional ties
-- ES: Tabla simulada de rankings con empates intencionales
-- ============================================
course_rankings AS (
    -- Alice (ID 1): 5 Top-5 appearances
    -- Alice (ID 1): 5 apariciones en el Top 5
    SELECT 101 AS course_id, 1 AS therank UNION ALL
    SELECT 101, 3 UNION ALL
    SELECT 102, 2 UNION ALL
    SELECT 103, 4 UNION ALL
    SELECT 103, 5 UNION ALL
    -- Carlos (ID 2): 5 Top-5 appearances (tie with Alice)
    -- Carlos (ID 2): 5 apariciones en el Top 5 (empate con Alice)
    SELECT 201, 1 UNION ALL
    SELECT 201, 2 UNION ALL
    SELECT 202, 3 UNION ALL
    SELECT 202, 4 UNION ALL
    SELECT 202, 5 UNION ALL
    -- Mei (ID 3): 3 Top-5 appearances
    -- Mei (ID 3): 3 apariciones en el Top 5
    SELECT 301, 2 UNION ALL
    SELECT 301, 5 UNION ALL
    SELECT 302, 4 UNION ALL
    -- John (ID 4): 2 Top-5 appearances
    -- John (ID 4): 2 apariciones en el Top 5
    SELECT 401, 3 UNION ALL
    SELECT 402, 5 UNION ALL
    -- Laura (ID 5): 5 Top-5 appearances (triple tie)
    -- Laura (ID 5): 5 apariciones en el Top 5 (triple empate)
    SELECT 501, 1 UNION ALL
    SELECT 501, 2 UNION ALL
    SELECT 501, 3 UNION ALL
    SELECT 501, 4 UNION ALL
    SELECT 501, 5
),

-- ============================================
-- CTE #1: Count Top-5 appearances per instructor
-- CTE #1: Conteo de apariciones Top 5 por instructor
-- ============================================
cte_instructor_top_counts AS (
    SELECT 
        MAX(i.instructor_name) AS instructor_name,
        COUNT(1) AS cnt
    FROM instructors i
    INNER JOIN courses c ON i.instructor_id = c.instructor_id
    INNER JOIN course_rankings cr ON c.course_id = cr.course_id
    WHERE cr.therank <= 5
    GROUP BY i.instructor_id
),

-- ============================================
-- CTE #2: Rank instructors using DENSE_RANK
-- CTE #2: Ranking de instructores usando DENSE_RANK
-- ============================================
cte_ranked_instructors AS (
    SELECT 
        instructor_name,
        DENSE_RANK() OVER (ORDER BY cnt DESC) AS instructor_rank,
        cnt
    FROM cte_instructor_top_counts
)

-- ============================================
-- Final Query: Top 3 instructors
-- Consulta Final: Top 3 instructores
-- ============================================
-- EN: Avoid SELECT * because it returns unnecessary columns, 
--     breaks when the schema changes, and reduces clarity and performance.
-- ES: Evita SELECT * porque devuelve columnas innecesarias,
--     se rompe si cambia el esquema y reduce claridad y rendimiento.
-- ============================================
SELECT instructor_name, instructor_rank, cnt
FROM cte_ranked_instructors
WHERE instructor_rank <= 3
ORDER BY instructor_rank, instructor_name;