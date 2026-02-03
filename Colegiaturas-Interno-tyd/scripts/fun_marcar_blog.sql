CREATE OR REPLACE FUNCTION fun_marcar_blog(integer, integer)
  RETURNS void AS
$BODY$

DECLARE
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.2.89
	     Servidor de produccion         : 10.44.2.183
	     Descripción del funcionamiento : 
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Blog de aclaraciones
	     Ejemplo                        : 
		 SELECT fun_marcar_blog(93902727, 7);
	*/
	iFactura ALIAS FOR $1;
	iEmpleado ALIAS FOR $2;
BEGIN
	-- Todas las notificaciones donde el iEmpleado aparezca como empleado destino
	-- y la factura corresponda con el campo id_factura, se marcarán como leídas (opc_leido = 1)
	UPDATE mov_blog_aclaraciones SET opc_leido = 1
	WHERE idu_empleado_destino = iEmpleado
		AND id_factura = iFactura
		AND opc_leido = 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_marcar_blog(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_marcar_blog(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_marcar_blog(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_marcar_blog(integer, integer) TO postgres;