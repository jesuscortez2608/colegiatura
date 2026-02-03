CREATE OR REPLACE FUNCTION fun_blog_aclaraciones(integer)
  RETURNS SETOF type_blog_aclaraciones AS
$BODY$
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
		SELECT id_factura, comentario
		FROM fun_blog_aclaraciones(11)
	------------------------------------------------------------------------------------------------------ */
	iFactura alias for $1;
	returnrec type_blog_aclaraciones;
BEGIN
	FOR returnrec IN (
		SELECT id_factura
			, comentario
		FROM mov_blog_aclaraciones
		WHERE id_factura = iFactura) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_blog_aclaraciones(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_blog_aclaraciones(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_blog_aclaraciones(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_blog_aclaraciones(integer) TO postgres;
COMMENT ON FUNCTION fun_blog_aclaraciones(integer) IS 'Blog de aclaraciones';