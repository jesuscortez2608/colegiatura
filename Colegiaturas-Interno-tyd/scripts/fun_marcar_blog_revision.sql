CREATE OR REPLACE FUNCTION fun_marcar_blog_revision(integer, integer)
  RETURNS void AS
$BODY$

DECLARE
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 22/06/2018
-- Descripción General: Actualiza el blog de revisión a estatus leido
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.44.114.75
-- Ejemplo: SELECT * FROM fun_marcar_blog_revision (262, 94827443)
-- ====================================================================================================
	iFactura ALIAS FOR $1;
	iEmpleado ALIAS FOR $2;
BEGIN
	-- Todas las notificaciones donde el iEmpleado aparezca como empleado destino
	-- y la factura corresponda con el campo id_factura, se marcarán como leídas (opc_leido = 1)
	UPDATE 	MOV_BLOG_REVISION SET opc_leido = 1, idu_empleado_destino=iEmpleado
	WHERE 	idu_empleado_destino = 0 --iEmpleado
			AND idu_empleado_origen!=iEmpleado
			AND id_factura = iFactura
			AND opc_leido = 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_marcar_blog_revision(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_marcar_blog_revision(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_marcar_blog_revision(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_marcar_blog_revision(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_marcar_blog_revision(integer, integer) IS 'La función marca como leído el blog recibido.';