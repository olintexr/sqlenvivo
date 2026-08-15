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

/* ============================================================
   [EN] Numeric Islands Detection in SQL
   Two methods:
   1. ROW_NUMBER() difference method (didactic)
   2. LAG() break-detection method (efficient)
   ============================================================
   [ES] Detección de Islas Numéricas en SQL
   Dos métodos:
   1. Método de diferencia ROW_NUMBER() (didáctico)
   2. Método de detección de pausas LAG() (eficiente)
   ============================================================ */

/* ============================================================
   [EN] Method 1: ROW_NUMBER() difference method
   [ES] Método 1: Método de diferencia ROW_NUMBER()
   ============================================================ */

with cte_numbers as (
    -- [EN] Raw input numbers (unordered)
    -- [ES] Números de entrada sin procesar (desordenados)
    select *
    from (values
        (20),(18),(17),(15),
        (14),(13),(11),(9),
        (7),(6),(5),(4),
        (2),(1)
    ) v(num)
),
cte_islands as (
    -- [EN] Assign island key using the gaps-and-islands trick:
    -- [EN] consecutive numbers share the same (num - row_number)
    -- [ES] Asignar clave de isla usando el truco de brechas e islas:
    -- [ES] los números consecutivos comparten el mismo (num - row_number)
    select
        num,
        num - row_number() over(order by num) as island_key
    from cte_numbers
),
cte_final as (
    -- [EN] Group by island_key and compute island boundaries
    -- [ES] Agrupar por island_key y calcular los límites de la isla
    select
        island_key,
        min(num) as start_num,
        max(num) as end_num,
        count(*) as island_size,
        rank() over(order by island_key) as island_id
    from cte_islands
    group by island_key
    having count(*) > 1   -- [EN] keep only islands with more than one element
                          -- [ES] mantener solo islas con más de un elemento
)
select island_id, island_size, start_num, end_num
from cte_final
order by island_id;



/* ============================================================
   [EN] Method 2: LAG() break-detection method
   [ES] Método 2: Método de detección de pausas LAG()
   ============================================================ */

with cte_numbers as (
    -- [EN] Raw input numbers (unordered)
    -- [ES] Números de entrada sin procesar (desordenados)
    select *
    from (values
        (20),(18),(17),(15),
        (14),(13),(11),(9),
        (7),(6),(5),(4),
        (2),(1)
    ) v(num)
),
cte_lag as (
    -- [EN] Compare each number with the previous one
    -- [EN] If the difference is not 1, a new island starts
    -- [ES] Comparar cada número con el anterior
    -- [ES] Si la diferencia no es 1, comienza una nueva isla
    select
        num,
        lag(num) over(order by num) as prev_num,
        case when num - lag(num) over(order by num) = 1
             then 0 else 1 end as island_break
    from cte_numbers
),
cte_islands as (
    -- [EN] Accumulate island breaks to generate island keys
    -- [ES] Acumular pausas de islas para generar claves de islas
    select
        num,
        sum(island_break) over(order by num) as island_key
    from cte_lag
),
cte_final as (
    -- [EN] Compute island boundaries
    -- [ES] Calcular los límites de la isla
    select
        island_key,
        min(num) as start_num,
        max(num) as end_num,
        count(*) as island_size,
        rank() over(order by island_key) as island_id
    from cte_islands
    group by island_key
    having count(*) > 1
)
select island_id, island_size, start_num, end_num
from cte_final
order by island_id;
