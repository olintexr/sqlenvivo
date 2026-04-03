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

-- [ES] EJEMPLO DE MALA PRÁCTICA: USO DE NOT IN CON POSIBLE NULL
-- --------------------------------------------------------------------------------------------------
-- Este ejemplo muestra cómo NOT IN puede producir resultados incorrectos cuando la subconsulta 
-- contiene al menos un valor NULL. Aunque la lógica parece válida, la presencia de un solo NULL 
-- hace que toda la condición se evalúe como UNKNOWN, impidiendo que cualquier fila cumpla el 
-- predicado. Este patrón es una de las causas más comunes de consultas que "no devuelven nada" 
-- sin razón aparente.
--
-- [EN] BAD PRACTICE EXAMPLE: USING NOT IN WITH POTENTIAL NULL VALUES
-- --------------------------------------------------------------------------------------------------
-- This example demonstrates how NOT IN can produce incorrect or empty results when the subquery 
-- contains even a single NULL value. Although the logic appears correct, the presence of a NULL 
-- forces the entire condition into an UNKNOWN state, preventing any row from satisfying the 
-- predicate. This pattern is one of the most frequent causes of queries that "return nothing" 
-- without an obvious explanation.

WITH producto AS (
    SELECT * FROM (VALUES
		(1, 'Laptop'),
		(2, 'Mouse'),
		(3, 'Teclado'),
		(4, 'Monitor'),
		(5, 'Impresora'),
		(6, 'Parlantes'),
		(7, 'Webcam'),
		(8, 'Disco Externo')
    ) AS t(producto_id, nombre)
),
venta AS (
    SELECT * FROM (VALUES
        (101, 1, '2024-01-10'),
        (102, NULL, '2024-01-12'),
        (103, 2, '2024-02-01')
    ) AS t(venta_id, producto_id, fecha)
)
SELECT producto_id, nombre
FROM producto
WHERE producto_id NOT IN (SELECT producto_id FROM venta);

-- [ES] BUENA PRÁCTICA: USO DE NOT EXISTS PARA EVITAR PROBLEMAS CON NULL
-- --------------------------------------------------------------------------------------------------
-- NOT EXISTS es la forma recomendada para identificar filas sin correspondencia en otra tabla. 
-- A diferencia de NOT IN, este patrón no se ve afectado por valores NULL y permite que el motor 
-- utilice índices de manera eficiente. Además, la evaluación se detiene en cuanto se encuentra 
-- la primera coincidencia, lo que mejora el rendimiento en tablas grandes.
--
-- [EN] BEST PRACTICE: USING NOT EXISTS TO AVOID NULL-RELATED ISSUES
-- --------------------------------------------------------------------------------------------------
-- NOT EXISTS is the recommended approach for identifying rows with no matching entries in another 
-- table. Unlike NOT IN, this pattern is not affected by NULL values and allows the database engine 
-- to leverage indexes efficiently. It also benefits from short‑circuit evaluation, stopping as soon 
-- as a match is found, which improves performance on large datasets.

WITH producto AS (
    SELECT * FROM (VALUES
		(1, 'Laptop'),
		(2, 'Mouse'),
		(3, 'Teclado'),
		(4, 'Monitor'),
		(5, 'Impresora'),
		(6, 'Parlantes'),
		(7, 'Webcam'),
		(8, 'Disco Externo')
    ) AS t(producto_id, nombre)
),
venta AS (
    SELECT * FROM (VALUES
        (101, 1, '2024-01-10'),
        (102, NULL, '2024-01-12'),
        (103, 2, '2024-02-01')
    ) AS t(venta_id, producto_id, fecha)
)
SELECT p.producto_id, p.nombre
FROM producto p
WHERE NOT EXISTS (
    SELECT 1
    FROM venta v
    WHERE v.producto_id = p.producto_id
);

-- [ES] BUENA PRÁCTICA: LEFT JOIN + IS NULL COMO ALTERNATIVA SEGURA
-- --------------------------------------------------------------------------------------------------
-- Este patrón utiliza un LEFT JOIN para identificar filas del lado izquierdo que no tienen 
-- coincidencias en la tabla relacionada. La condición IS NULL evita comparaciones ambiguas y 
-- permite que el motor optimice la búsqueda mediante índices. Aunque suele ser ligeramente menos 
-- eficiente que NOT EXISTS, sigue siendo una opción segura y ampliamente utilizada.
--
-- [EN] BEST PRACTICE: LEFT JOIN + IS NULL AS A SAFE ALTERNATIVE
-- --------------------------------------------------------------------------------------------------
-- This pattern uses a LEFT JOIN to identify rows on the left side that have no matching entries 
-- in the related table. The IS NULL condition avoids ambiguous comparisons and allows the engine 
-- to optimize lookups using indexes. Although it is often slightly less efficient than NOT EXISTS, 
-- it remains a safe and widely used alternative.

WITH producto AS (
    SELECT * FROM (VALUES
		(1, 'Laptop'),
		(2, 'Mouse'),
		(3, 'Teclado'),
		(4, 'Monitor'),
		(5, 'Impresora'),
		(6, 'Parlantes'),
		(7, 'Webcam'),
		(8, 'Disco Externo')
    ) AS t(producto_id, nombre)
),
venta AS (
    SELECT * FROM (VALUES
        (101, 1, '2024-01-10'),
        (102, NULL, '2024-01-12'),
        (103, 2, '2024-02-01')
    ) AS t(venta_id, producto_id, fecha)
)
SELECT p.producto_id, p.nombre
FROM producto p
LEFT JOIN venta v
    ON v.producto_id = p.producto_id
WHERE v.producto_id IS NULL;