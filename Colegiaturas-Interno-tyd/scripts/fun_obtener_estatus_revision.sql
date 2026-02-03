CREATE OR REPLACE FUNCTION fun_obtener_estatus_revision(
OUT idu_estatus integer, 
OUT des_estatus character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	-- =================================================================================================
	-- Peticion:
	-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
	-- Fecha:
	-- Descripción General: Consulta estatus revision
	-- Ruta Tortoise:
	-- Sistema: Colegiaturas
	-- Servidor Productivo: 10.44.2.183
	-- Servidor Desarrollo: 10.28.114.75
	-- Ejemplo:
	--	SELECT * FROM fun_obtener_estatus_revision ()	
	-- =================================================================================================
	valor record;
BEGIN	
	FOR valor IN( 
		SELECT 	idu_estatus_revision, UPPER(des_estatus_revision) AS des_estatus_revision
		FROM 	cat_estatus_revision
		ORDER	BY idu_estatus_revision
		) LOOP
		idu_estatus := valor.idu_estatus_revision;
		des_estatus := valor.des_estatus_revision;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
 GRANT EXECUTE ON FUNCTION fun_obtener_estatus_revision() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_revision() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_revision() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_revision() TO postgres;
COMMENT ON FUNCTION fun_obtener_estatus_revision() IS 'La función obtiene los estatus de revision de colegituras.';