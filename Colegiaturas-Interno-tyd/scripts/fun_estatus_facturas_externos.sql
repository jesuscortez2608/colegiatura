CREATE OR REPLACE FUNCTION fun_estatus_facturas_externos(OUT iestatus integer, OUT snombreestatus character varying)
  RETURNS SETOF record AS
$BODY$
declare
  -- ===================================================
-- Peticion			: 16559.1
-- Autor			: Rafael Ramos Gutiérrez 98439677
-- Fecha			: 09/05/2018
-- Descripción General		:  La función obtiene un listado con los diferentes estatus por los que pasa una factura de externos
-- Sistema			: Colegiaturas
-- Base de Datos		: personal
-- Ejemplo			: select * from fun_estatus_facturas_externos()
-- Tablas Utilizadas		: cat_estatus_facturas
-- ===================================================
	sQuery varchar(2000);
	rec record;
begin
	sQuery := 'SELECT idu_estatus, nom_estatus FROM cat_estatus_facturas WHERE idu_tipo_estatus = 0 AND idu_estatus IN (0,3,6) ORDER BY idu_estatus';

	for rec in execute sQuery LOOP
		iEstatus := rec.idu_estatus;
		sNombreEstatus := rec.nom_estatus;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_estatus_facturas_externos() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_estatus_facturas_externos() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_estatus_facturas_externos() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_estatus_facturas_externos() TO postgres;
COMMENT ON FUNCTION fun_estatus_facturas_externos() IS 'La función obtiene un listado con los diferentes estatus por los que pasa una factura de externos:

    0, Facturas pendientes o recientemente subidas
    3, Facturas rechazadas
    6, Facturas pagadas';