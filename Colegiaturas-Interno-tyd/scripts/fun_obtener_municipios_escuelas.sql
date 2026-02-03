CREATE TYPE type_obtener_municipios_escuelas AS
   (idu_municipio integer,
    nom_municipio character varying);

CREATE OR REPLACE FUNCTION fun_obtener_municipios_escuelas(integer)
  RETURNS SETOF type_obtener_municipios_escuelas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 16559.1 Colegiaturas
	Fecha                          : 17/11/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Descripción del funcionamiento : Obtiene un listado de los diferentes municipios de las escuelas a partir de un estado
	Ejemplo                        : 
		select idu_municipio, nom_municipio from fun_obtener_municipios_escuelas(20)
	------------------------------------------------------------------------------------------------------ */
	iEstado alias for $1;
	returnrec type_obtener_municipios_escuelas;
BEGIN
	FOR returnrec IN (
		select idu_municipio, nom_municipio from CAT_MUNICIPIOS_COLEGIATURAS
		where idu_estado = iEstado order by idu_municipio
	) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_municipios_escuelas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_municipios_escuelas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_municipios_escuelas(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_municipios_escuelas(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_municipios_escuelas(integer) IS 'OBTIENE LOS MUNICIPIOS DE LAS ESCUELAS.';
