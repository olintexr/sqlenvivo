-- Calendario base: secuencia limpia de fechas válidas para el análisis.
-- Define el rango oficial (2024‑01‑01 → 2024‑01‑07), independiente de la asistencia.
WITH cte_fechas AS (
    SELECT CAST('2024-01-01' AS date) AS fecha
    UNION ALL
    SELECT DATEADD(day, 1, fecha)
    FROM cte_fechas
    WHERE fecha < '2024-01-07'
),

-- Asistencia cruda: datos reales con duplicados, ruido y fechas fuera de rango.
-- No se corrige nada aquí; el pipeline debe ser robusto ante basura.
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

-- Limpieza mínima: una fila por (fecha, comensal). No altera el calendario.
cte_distinct AS (
    SELECT DISTINCT fecha, comensal
    FROM cte_asistencia
),

-- Línea de tiempo oficial: ordinal 1..7 basado solo en el calendario limpio.
cte_orden AS (
    SELECT fecha,
           ROW_NUMBER() OVER (ORDER BY fecha) AS dia_ordinal
    FROM cte_fechas
),

-- Racha acumulada por comensal: cuántas veces ha asistido hasta cada fecha.
-- Se compara luego contra el ordinal para detectar asistencia perfecta.
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

-- Sobrevivientes: comensales cuyo acumulado coincide con el ordinal.
cte_descarte AS (
    SELECT fecha, comensal
    FROM cte_win
    WHERE acumulado = dia_ordinal
)

-- Resultado final: por día, cuántos siguen con asistencia perfecta
-- y lista separada por comas de esos comensales.
SELECT
    f.fecha,
    COALESCE(COUNT(d.comensal), 0) AS comensales_en_todos_los_dias,
    COALESCE(STRING_AGG(d.comensal, ', '), '') AS lista_comensales
FROM cte_fechas f
LEFT JOIN cte_descarte d ON d.fecha = f.fecha
GROUP BY f.fecha
ORDER BY f.fecha;
