DROP FUNCTION IF EXISTS fun_obtener_centros_por_ciudad(VARCHAR);
DROP TYPE IF EXISTS type_obtener_centros_por_ciudad;

CREATE TYPE type_obtener_centros_por_ciudad AS (
	numerocentro CHARACTER(6),
	nombrecentro CHARACTER(30)
);

CREATE OR REPLACE FUNCTION fun_obtener_centros_por_ciudad(VARCHAR)
RETURNS SETOF type_obtener_centros_por_ciudad AS
$function$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 15/11/2016
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.44.2.89
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : Colegiaturas
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT *
		FROM fun_obtener_centros_por_ciudad('4'::VARCHAR)
	------------------------------------------------------------------------------------------------------ */
	cListaCiudades alias for $1;
	returnrec type_obtener_centros_por_ciudad;
	sConsulta varchar(3000);
BEGIN
	sConsulta := 'select numerocentro
					, nombrecentro
			FROM sapcatalogocentros 
			WHERE ciudadn IN (' || cListaCiudades || ')
				OR ciudadadjunta IN (' || cListaCiudades || ')
			ORDER BY numerocentro';
	
	RAISE NOTICE '%', sConsulta;
	
	for returnrec in execute sConsulta loop
		RETURN NEXT returnrec;
	END LOOP;
END;
$function$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_centros_por_ciudad(VARCHAR) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_centros_por_ciudad(VARCHAR) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_centros_por_ciudad(VARCHAR) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_centros_por_ciudad(VARCHAR) TO postgres;