CREATE OR REPLACE FUNCTION fun_catalogociudades(character)
	RETURNS SETOF type_ciudad AS
$BODY$
DECLARE
	cRegion	ALIAS FOR $1;
	registro type_ciudad;
BEGIN
	FOR registro IN SELECT numero, nombreciudad, regionzona
			FROM sapcatalogociudades
			WHERE regionzona = cRegion
        		ORDER BY numero
	LOOP
	RETURN NEXT registro;
	END LOOP;
	RETURN;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_catalogociudades(character) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_catalogociudades(character) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_catalogociudades(character) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_catalogociudades(character) TO postgres;
COMMENT ON FUNCTION fun_catalogociudades(character) IS 'La función obtiene el catálogo de ciudades';
