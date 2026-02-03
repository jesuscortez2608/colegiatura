CREATE OR REPLACE FUNCTION fun_obtener_estados_escuelas()
  RETURNS SETOF type_obtener_estados_escuelas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 16559.1 Colegiaturas
	Fecha                          : 17/11/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Descripción del funcionamiento : Obtiene un listado de los diferentes estados de las escuelas
	Ejemplo                        : 
		select idu_estado, nom_estado
		from fun_obtener_estados_escuelas()
		
		1 - Escuelas publicas
		2 - Escuelas privadas
	------------------------------------------------------------------------------------------------------ */
	returnrec type_obtener_estados_escuelas;
BEGIN
	FOR returnrec IN (
		select idu_estado, nom_estado from cat_estados_colegiaturas  order by idu_estado
	)

	 LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_estados_escuelas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_estados_escuelas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_estados_escuelas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_estados_escuelas() TO postgres;
COMMENT ON FUNCTION fun_obtener_estados_escuelas() IS 'La función obtiene estados de colegiaturas.';