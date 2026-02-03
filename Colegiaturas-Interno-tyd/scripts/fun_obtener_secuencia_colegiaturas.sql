CREATE OR REPLACE FUNCTION fun_obtener_secuencia_colegiaturas()
RETURNS INTEGER AS
$function$
DECLARE
	/*
	No. petición APS               : 8613
	Fecha                          : 10/01/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Descripción del funcionamiento : Obtiene la secuencia
	Sistema                        : Colegiaturas
	Módulo                         : Subir documentos a alfresco
	Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas
	Ejemplo                        : 
		SELECT fun_obtener_secuencia_colegiaturas() AS secuencia
	------------------------------------------------------------------------------------------------------ */
BEGIN
	RETURN nextval('sec_documentos_colegiaturas');
END;
$function$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_secuencia_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_secuencia_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_secuencia_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_secuencia_colegiaturas() TO postgres;
