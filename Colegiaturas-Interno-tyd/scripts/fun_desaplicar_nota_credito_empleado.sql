CREATE OR REPLACE FUNCTION fun_desaplicar_nota_credito_empleado(ifactura integer, inota integer)
  RETURNS void AS
$BODY$
DECLARE     
	--cFactura Varchar(100);
	--iFolioFactura integer DEFAULT 1;
	--valor record;	
	
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 17-08-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: SELECT * FROM fun_desaplicar_nota_credito_empleado (145, 146)
-- ====================================================================================================
BEGIN 
	delete 	from MOV_APLICACION_NOTAS_CREDITO
	WHERE	idnotacredito=iNota
			and idfactura=iFactura;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_desaplicar_nota_credito_empleado(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_desaplicar_nota_credito_empleado(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_desaplicar_nota_credito_empleado(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_desaplicar_nota_credito_empleado(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_desaplicar_nota_credito_empleado(integer, integer)IS 'La función quita la nota de crédito a una factura';

