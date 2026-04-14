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


/* =====================================================================================================
[EN] Presentation: This script demonstrates the relational division pattern using CTEs to determine
    which candidates meet 100% of the skills required for each role.
[ES] Presentación: Este script demuestra el patrón de división relacional usando CTEs para identificar
    qué candidatos cumplen el 100% de las habilidades requeridas por cada rol.
   ===================================================================================================== */

-- ============================================================================================
-- [EN] CTE 0: Sample data (fictional) – roles and required skills
-- [ES] CTE 0: Datos de ejemplo (ficticios) – roles y habilidades requeridas
-- ============================================================================================
WITH ROLE_REQUIREMENTS AS (
    SELECT * FROM (VALUES
        ('astronaut', 'maths'),
        ('astronaut', 'chemistry'),
        ('engineer',  'maths'),
        ('scientist', 'maths'),
        ('scientist', 'chemistry'),
        ('scientist', 'physics')
    ) AS t(role, skill)
),
-- ============================================================================================
-- [EN] CTE 1: Sample data (fictional) – candidates and their skills
-- [ES] CTE 1: Datos de ejemplo (ficticios) – candidatos y sus habilidades
-- ============================================================================================
CANDIDATE_SKILLS AS (
    SELECT * FROM (VALUES
        ('Ann',   'maths'),
        ('Ann',   'chemistry'),
        ('John',  'maths'),
        ('John',  'physics'),
        ('Lewis', 'maths'),
        ('Lewis', 'chemistry'),
        ('Lewis', 'physics')
    ) AS t(candidate, skill)
),

-- ============================================================================================
-- [EN] CTE 2: Match candidates to the skills required by each role
-- [ES] CTE 2: Relacionar candidatos con las habilidades requeridas por cada rol
-- ============================================================================================
candidate_role_matches AS (
    SELECT
        cs.candidate,
        rr.role,
        cs.skill
    FROM ROLE_REQUIREMENTS rr
    JOIN CANDIDATE_SKILLS cs
        ON cs.skill = rr.skill
)

-- ============================================================================================
-- [EN] Final query: Apply relational division logic
-- [ES] Query final: Aplicar la lógica de división relacional
-- ============================================================================================
SELECT
    candidate,
    role
FROM candidate_role_matches
GROUP BY
    candidate,
    role
HAVING
    COUNT(DISTINCT skill) =
    (
        -- [EN] Count how many skills each role requires
        -- [ES] Contar cuántas habilidades requiere cada rol
        SELECT COUNT(DISTINCT skill)
        FROM ROLE_REQUIREMENTS rr2
        WHERE rr2.role = candidate_role_matches.role
    )

-- [EN] Final ordering for clarity
-- [ES] Orden final para mayor claridad
ORDER BY role, candidate;
