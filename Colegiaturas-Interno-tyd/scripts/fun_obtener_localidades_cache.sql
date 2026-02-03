CREATE OR REPLACE FUNCTION public.fun_obtener_localidades_cache(IN iEstado integer
    , IN iMunicipio integer
    , OUT idu_estado INTEGER
    , OUT nom_estado VARCHAR
    , OUT idu_municipio INTEGER
    , OUT nom_municipio VARCHAR
    , OUT idu_localidad INTEGER
    , OUT nom_localidad VARCHAR)
RETURNS SETOF RECORD
AS $function$
DECLARE
	/*
	Fecha                          : 06/04/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Descripción del funcionamiento : Obtiene listado de localidades en base a estado y municipio para formulario de ejemplo de caché
	Ejemplo                        : 
		select * from fun_obtener_localidades_cache(25, 6)
		SELECT idu_estado
            , nom_estado
            , idu_municipio
            , nom_municipio
            , idu_localidad
            , nom_localidad 
		FROM fun_obtener_localidades_cache (25, 6)
	------------------------------------------------------------------------------------------------------ */
	rec RECORD;
BEGIN
    create temp table tmp_localidades_cache (idu_estado integer
        , nom_estado varchar
        , idu_municipio integer
        , nom_municipio varchar
        , idu_localidad integer
        , nom_localidad varchar
    ) on commit drop;

    insert into tmp_localidades_cache (idu_estado, nom_estado, idu_municipio, nom_municipio, idu_localidad, nom_localidad)
        select loc.idu_estado
            , '' as nom_estado
            , loc.idu_municipio
            , '' as nom_municipio
            , loc.idu_localidad
            , loc.nom_localidad 
        from cat_localidades_colegiaturas as loc
		where loc.idu_estado = iEstado 
            and loc.idu_municipio = iMunicipio;
    
    update tmp_localidades_cache set nom_estado = est.nom_estado
    from cat_estados_colegiaturas as est
    where est.idu_estado = iEstado;

    update tmp_localidades_cache set nom_municipio = mpio.nom_municipio
    from cat_municipios_colegiaturas as mpio
    where mpio.idu_estado = iEstado
        and mpio.idu_municipio = iMunicipio;
    
	FOR rec IN (
		select tmp.idu_estado
            , tmp.nom_estado
            , tmp.idu_municipio
            , tmp.nom_municipio
            , tmp.idu_localidad
            , tmp.nom_localidad 
        from tmp_localidades_cache as tmp
        order by tmp.idu_localidad
	) LOOP
        idu_estado := rec.idu_estado;
        nom_estado := rec.nom_estado;
        idu_municipio := rec.idu_municipio;
        nom_municipio := rec.nom_municipio;
        idu_localidad := rec.idu_localidad;
        nom_localidad := rec.nom_localidad;
		RETURN NEXT;
	END LOOP;
END;
$function$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_localidades_cache(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_cache(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_cache(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_localidades_cache(integer, integer) TO postgres;
