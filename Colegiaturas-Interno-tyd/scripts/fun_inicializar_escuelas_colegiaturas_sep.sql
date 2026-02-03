DROP FUNCTION IF EXISTS fun_inicializar_escuelas_colegiaturas_sep();

CREATE OR REPLACE FUNCTION fun_inicializar_escuelas_colegiaturas_sep()
RETURNS INTEGER AS
$function$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		
	------------------------------------------------------------------------------------------------------ */
BEGIN
	DELETE FROM stmp_escuelas_colegiaturas_sep;
	
	RETURN 1;
END;
$function$
LANGUAGE plpgsql VOLATILE;
