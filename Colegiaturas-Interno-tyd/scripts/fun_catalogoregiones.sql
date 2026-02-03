CREATE OR REPLACE FUNCTION fun_catalogoregiones()
  RETURNS SETOF type_region AS
$BODY$
   DECLARE
        registro type_region;
BEGIN
	FOR registro IN SELECT numero,nombre
			FROM sapregiones
        		ORDER BY numero
	LOOP
	RETURN NEXT registro;
	END LOOP;
	RETURN ;
      	
END;
$BODY$
 LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_catalogoregiones() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_catalogoregiones() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_catalogoregiones() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_catalogoregiones() TO postgres;
COMMENT ON FUNCTION fun_catalogoregiones() IS 'La función obtiene el catálogo de regiones';
