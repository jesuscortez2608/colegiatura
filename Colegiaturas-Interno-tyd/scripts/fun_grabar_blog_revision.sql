CREATE OR REPLACE FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text)
  RETURNS SETOF void AS
$BODY$
DECLARE
	-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 22/06/2018
-- Descripción General: Graba el blog de revisión 
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.44.114.75
-- Ejemplo: SELECT * FROM fun_marcar_blog_revision (262, 94827443)
-- ==================================================================================================
	--DECLARACION DE VARIABLES
	nNotificar integer not null default 0;
	valor record;

BEGIN	
	INSERT INTO MOV_BLOG_REVISION(id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, fec_registro)
	VALUES(iFactura, iEmpleado, iEmpleadoDes, cComentario, 0, NOW());
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
 
 GRANT EXECUTE ON FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text) TO postgres;
COMMENT ON FUNCTION fun_grabar_blog_revision(IN ifactura integer, IN iempleado integer, IN iempleadodes integer, IN ccomentario text) IS 'La función graba comentario en el blog.';