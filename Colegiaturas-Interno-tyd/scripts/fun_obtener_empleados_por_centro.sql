drop function if exists fun_obtener_empleados_por_centro(character varying);
drop type if exists type_obtener_empleados_por_centro;

CREATE TYPE type_obtener_empleados_por_centro AS
   (idu_centro integer,
    idu_empleado integer,
    nom_empleado character varying(150));

CREATE OR REPLACE FUNCTION fun_obtener_empleados_por_centro(character varying)
  RETURNS SETOF type_obtener_empleados_por_centro AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 04/11/2016
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.2.89
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT idu_centro
			, idu_empleado
			, nom_empleado
		FROM fun_obtener_empleados_por_centro('230140,230297,230468'::VARCHAR)
	------------------------------------------------------------------------------------------------------ */
	sListadoCentros alias for $1;
	sQuery VARCHAR(3000);
	returnrec type_obtener_empleados_por_centro;
BEGIN
	CREATE TEMPORARY TABLE tmp_empleados_colegiaturas (
		idu_centro INTEGER,
		idu_empleado INTEGER, 
		nom_empleado VARCHAR(150)
	)on commit drop;
	
	sQuery := 'INSERT INTO tmp_empleados_colegiaturas(idu_centro, idu_empleado, nom_empleado)
		SELECT centron
			, numempn
			, trim(nombre) || '' '' || trim(apellidopaterno) || '' '' || trim(apellidomaterno)
		FROM sapcatalogoempleados
		WHERE centron IN (' || sListadoCentros || ' )
			AND cancelado != ''1'' ';
	raise notice '%',sQuery;
	
	EXECUTE sQuery;
	
	FOR returnrec IN (
		SELECT tmp.idu_centro
			, tmp.idu_empleado
			, tmp.nom_empleado
		FROM tmp_empleados_colegiaturas AS tmp
			INNER JOIN cat_empleados_colegiaturas AS ec ON (ec.idu_empleado = tmp.idu_empleado)
		ORDER BY tmp.nom_empleado
	) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_por_centro(character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_por_centro(character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_por_centro(character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_por_centro(character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_empleados_por_centro(character varying) IS 'La función obtiene un listado de colaboradores en base a un listado de centros.';