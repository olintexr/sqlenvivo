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
   [ES] Ejemplo 1: Transformar filas en columnas usando PIVOT
   [EN] Example 1: Transform rows into columns using PIVOT
   ============================================================ */

-- [ES] CTE con datos de prueba
-- [EN] CTE with sample data
with Emails as (
    select 101 as CustomerID, 'Personal' as EmailType, 'a.personal@sqlenvivo.com' as Email union all
    select 101, 'Work',      'a.work@sqlenvivo.com'                        union all
    select 101, 'Extra',     'a.extra@sqlenvivo.com'                       union all
    select 202, 'Personal',  'b.personal@sqlenvivo.com'                    union all
    select 202, 'Work',      'b.work@sqlenvivo.com'                        union all
    select 303, 'Personal',  'c.personal@sqlenvivo.com'
)

-- [ES] Transformación usando PIVOT (solo SQL Server)
-- [EN] Transformation using PIVOT (SQL Server only)
select 
    CustomerID,
    [Personal],
    [Work],
    [Extra]
from Emails
pivot (
    max(Email)
        -- [ES] MAX() no calcula nada: solo devuelve el único valor por tipo
        -- [EN] MAX() does not compute anything: it simply returns the single value per type
    for EmailType in ([Personal], [Work], [Extra])
) as p;


/* ============================================================
   [ES] Ejemplo 2: Transformar filas en columnas usando CASE + MAX()
   [EN] Example 2: Transform rows into columns using CASE + MAX()
   ============================================================ */

-- [ES] CTE con los mismos datos de prueba
-- [EN] CTE with the same sample data
with Emails as (
    select 101 as CustomerID, 'Personal' as EmailType, 'a.personal@sqlenvivo.com' as Email union all
    select 101, 'Work',      'a.work@sqlenvivo.com'                        union all
    select 101, 'Extra',     'a.extra@sqlenvivo.com'                       union all
    select 202, 'Personal',  'b.personal@sqlenvivo.com'                    union all
    select 202, 'Work',      'b.work@sqlenvivo.com'                        union all
    select 303, 'Personal',  'c.personal@sqlenvivo.com'
)

-- [ES] Transformación universal usando CASE + MAX()
-- [EN] Universal transformation using CASE + MAX()
select 
    CustomerID,
    max(case when EmailType = 'Personal' then Email end) as Personal,
    max(case when EmailType = 'Work'     then Email end) as Work,
    max(case when EmailType = 'Extra'    then Email end) as Extra
from Emails
group by CustomerID;
-- [ES] MAX() devuelve el único valor por tipo (MIN() también funcionaría)
-- [EN] MAX() returns the single value per type (MIN() would work as well)
