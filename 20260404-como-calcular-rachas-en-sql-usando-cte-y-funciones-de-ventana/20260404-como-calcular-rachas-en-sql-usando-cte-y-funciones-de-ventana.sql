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

-- [ES] Calendario base: secuencia limpia de fechas válidas para el análisis.
-- [ES] Define el rango oficial (2024‑01‑01 → 2024‑01‑07), independiente de la asistencia.

-- [EN] Base calendar: clean sequence of valid dates for the analysis.
-- [EN] Defines the official range (2024‑01‑01 → 2024‑01‑07), independent from attendance data.

WITH cte_fechas AS (
    SELECT CAST('2024-01-01' AS date) AS fecha
    UNION ALL
    SELECT DATEADD(day, 1, fecha)
    FROM cte_fechas
    WHERE fecha < '2024-01-07'
),

-- [ES] Asistencia cruda: datos reales con duplicados, ruido y fechas fuera de rango.
-- [ES] No se corrige nada aquí; el pipeline debe ser robusto ante basura.

-- [EN] Raw attendance: real-world data with duplicates, noise, and out-of-range dates.
-- [EN] Nothing is fixed here; the pipeline must remain robust in the presence of garbage input.

cte_asistencia AS (
    SELECT *
    FROM (VALUES
        ('2023-12-31','Ana'), ('2023-12-31','Luis'), ('2023-12-31','Maria'),
        ('2024-01-01','Ana'), ('2024-01-01','Luis'), ('2024-01-01','Maria'),
        ('2024-01-01','Ruperto'), ('2024-01-01','Ruperto'), ('2024-01-01','Ruperto'),
        ('2024-01-01','Ruperto'),
        ('2024-01-02','Ana'), ('2024-01-02','Luis'), ('2024-01-02','Ruperto'),
        ('2024-01-02','Olinto'),
        ('2024-01-03','Ana'), ('2024-01-03','Maria'), ('2024-01-03','Luis'),
        ('2024-01-03','Ruperto'), ('2024-01-03','Maria'),
        ('2024-01-04','Ana'), ('2024-01-04','Maria'), ('2024-01-04','Ruperto'),
        ('2024-01-05','Ana'), ('2024-01-05','Luis'),
        ('2024-01-06','Ana'), ('2024-01-06','Ruperto'),
        ('2024-01-07','Ana'), ('2024-01-07','Maria'), ('2024-01-07','Ruperto'),
        ('2024-01-08','Ana'), ('2024-01-08','Maria'), ('2024-01-08','Ruperto')
    ) AS A(fecha, comensal)
),

-- [ES] Limpieza mínima: una fila por (fecha, comensal). No altera el calendario.
-- [EN] Minimal cleanup: one row per (date, attendee). Does not modify the calendar.

cte_distinct AS (
    SELECT DISTINCT fecha, comensal
    FROM cte_asistencia
),

-- [ES] Línea de tiempo oficial: ordinal 1..7 basado solo en el calendario limpio.
-- [EN] Official timeline: ordinal 1..7 based solely on the clean calendar.

cte_orden AS (
    SELECT fecha,
           ROW_NUMBER() OVER (ORDER BY fecha) AS dia_ordinal
    FROM cte_fechas
),

-- [ES] Racha acumulada por comensal: cuántas veces ha asistido hasta cada fecha.
-- [ES] Se compara luego contra el ordinal para detectar asistencia perfecta.

-- [EN] Cumulative streak per attendee: how many times they have attended up to each date.
-- [EN] Later compared against the ordinal to detect perfect attendance.

cte_win AS (
    SELECT
        a.fecha,
        o.dia_ordinal,
        a.comensal,
        COUNT(1) OVER (
            PARTITION BY a.comensal
            ORDER BY a.fecha
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS acumulado
    FROM cte_distinct a
    JOIN cte_orden o ON o.fecha = a.fecha
),

-- [ES] Sobrevivientes: comensales cuyo acumulado coincide con el ordinal.
-- [EN] Survivors: attendees whose cumulative count matches the ordinal.

cte_descarte AS (
    SELECT fecha, comensal
    FROM cte_win
    WHERE acumulado = dia_ordinal
)

-- [ES] Resultado final: por día, cuántos siguen con asistencia perfecta
-- [ES] y lista separada por comas de esos comensales.

-- [EN] Final result: for each day, how many still maintain perfect attendance
-- [EN] and a comma‑separated list of those attendees.

SELECT
    f.fecha,
    COALESCE(COUNT(d.comensal), 0) AS comensales_en_todos_los_dias,
    COALESCE(STRING_AGG(d.comensal, ', '), '') AS lista_comensales
FROM cte_fechas f
LEFT JOIN cte_descarte d ON d.fecha = f.fecha
GROUP BY f.fecha
ORDER BY f.fecha;
