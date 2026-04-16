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
   [EN] Demo: Deleting duplicated emails in SQL
   [ES] Demo: Borrar correos duplicados en SQL
   ============================================================ */

---------------------------------------------------------------
-- [EN] Create test table
-- [ES] Crear tabla de prueba
---------------------------------------------------------------
create table T (
    id int identity(1,1) primary key,
    email varchar(100) not null
);
go

---------------------------------------------------------------
-- [EN] Insert sample data (duplicates + unique emails)
-- [ES] Insertar datos de ejemplo (correos duplicados y únicos)
---------------------------------------------------------------
insert into T (email) values
('a@sqlenvivo.com'),
('b@sqlenvivo.com'),
('a@sqlenvivo.com'),
('c@sqlenvivo.com'),
('b@sqlenvivo.com'),
('d@sqlenvivo.com');
go

---------------------------------------------------------------
-- [EN] Show records
-- [ES] Mostrar registros
---------------------------------------------------------------
select email, id from T order by 1, 2;

/* ============================================================
   TEST 1 — INCORRECT DELETE (HAVING COUNT > 1)
   ============================================================ */

---------------------------------------------------------------
-- [EN] Start test transaction
-- [ES] Iniciar transacción de prueba
---------------------------------------------------------------
begin tran;

---------------------------------------------------------------
-- [EN] Incorrect DELETE: removes unique emails too
-- [ES] DELETE incorrecto: elimina también correos únicos
---------------------------------------------------------------
delete from T
where id not in (
    select min(id)
    from T
    group by email
    having count(1) > 1
);

---------------------------------------------------------------
-- [EN] Inspect results here if needed
-- [ES] Revisar resultados aquí si es necesario
---------------------------------------------------------------
select email, id from T order by 1, 2;

---------------------------------------------------------------
-- [EN] Undo changes (this DELETE is wrong)
-- [ES] Revertir cambios (este DELETE es incorrecto)
---------------------------------------------------------------
rollback;
go

/* ============================================================
   TEST 2 — CORRECT DELETE USING GROUP BY
   ============================================================ */

begin tran;

---------------------------------------------------------------
-- [EN] Correct DELETE: keeps min(id) for every email
-- [ES] DELETE correcto: conserva el min(id) por cada email
---------------------------------------------------------------
delete from T
where id not in (
    select min(id)
    from T
    group by email
);

select email, id from T order by 1, 2;

---------------------------------------------------------------
-- [EN] Undo changes to keep table intact for next test
-- [ES] Revertir cambios para mantener la tabla intacta
---------------------------------------------------------------
rollback;
go

/* ============================================================
   TEST 3 — MODERN SOLUTION USING ROW_NUMBER()
   ============================================================ */

begin tran;

---------------------------------------------------------------
-- [EN] Modern DELETE using ROW_NUMBER()
-- [ES] DELETE moderno usando ROW_NUMBER()
---------------------------------------------------------------
with d as (
    select
        id,
        row_number() over (partition by email order by id) as rn
    from T
)
delete from d
where rn > 1;

select email, id from T order by 1, 2;

---------------------------------------------------------------
-- [EN] Undo changes (we only want to demonstrate behavior)
-- [ES] Revertir cambios (solo demostración del comportamiento)
---------------------------------------------------------------
rollback;
go

/* ============================================================
   FINAL CLEANUP
   ============================================================ */

---------------------------------------------------------------
-- [EN] Commit final state (table is unchanged)
-- [ES] Confirmar estado final (la tabla queda intacta)
---------------------------------------------------------------
begin tran;
commit;

---------------------------------------------------------------
-- [EN] Drop test table
-- [ES] Eliminar tabla de prueba
---------------------------------------------------------------
drop table T;
go
