CREATE OR REPLACE FUNCTION fun_eliminar_beneficiarios_estudios(
IN iempleado integer, 
IN iconfiguracion integer)
  RETURNS integer AS
$BODY$
DECLARE 
-- ===========================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 24/04/2018
-- Descripción General: Eliminar el beneficiario seleccionado de la configuración de beneficiarios
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo:  10.44.114.75
-- Ejemplo: SELECT * FROM fun_listado_beneficiarios_estudios (94827443)
-- ===========================================================================================================
BEGIN
		
	DELETE 	FROM CAT_ESTUDIOS_BENEFICIARIOS
	WHERE 	idu_empleado=iEmpleado 
			AND idu_configuracion=iConfiguracion;

	RETURN 0;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_eliminar_beneficiarios_estudios(iempleado integer, iconfiguracion integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_beneficiarios_estudios(iempleado integer, iconfiguracion integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_beneficiarios_estudios(iempleado integer, iconfiguracion integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_beneficiarios_estudios(iempleado integer, iconfiguracion integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_beneficiarios_estudios(iempleado integer, iconfiguracion integer) IS 'La función elimina los estudios de los beneficiarios.';