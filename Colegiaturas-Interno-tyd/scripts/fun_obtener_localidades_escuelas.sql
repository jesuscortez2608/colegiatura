CREATE TYPE type_obtener_localidades_escuelas AS
   (idu_localidad integer,
    nom_localidad character varying);

CREATE OR REPLACE FUNCTION fun_obtener_localidades_escuelas(integer, integer)
  RETURNS SETOF type_obtener_localidades_escuelas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 16559.1 Colegiaturas
	Fecha                          : 05/04/2018
	Número empleado                : 98439677
	Nombre del empleado            : Rafael Ramos Gutiérrez
	Base de datos                  : Personal
	Descripción del funcionamiento : Obtiene un listado de las diferentes localidades de las escuelas a partir de un municipio
	Ejemplo                        : 
		select idu_localidad, nom_localidad from fun_obtener_localidades_escuelas (25, 1)
	------------------------------------------------------------------------------------------------------ */
	iEstado 	alias for $1;
	iMunicipio	alias for $2;	
	returnrec type_obtener_localidades_escuelas;
BEGIN
	FOR returnrec IN (
		select idu_localidad, nom_localidad from cat_localidades_colegiaturas
		where idu_estado = iEstado and idu_municipio = iMunicipio order by idu_localidad
	) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_localidades_escuelas(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_escuelas(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_escuelas(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_escuelas(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_localidades_escuelas(integer, integer) IS 'OBTIENE LAS LOCALIDADES DONDE SE ENCUENTRAN UBICADAS LAS ESCUELAS DEL SISTEMA DE COLEGIATURAS';