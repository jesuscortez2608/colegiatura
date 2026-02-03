CREATE OR REPLACE FUNCTION fun_consulta_motivos_revision(
OUT idu_motivo integer, 
OUT des_motivo character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	-- =================================================================================================
	-- Peticion:
	-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
	-- Fecha:
	-- Descripción General: Consulta motivos revision
	-- Ruta Tortoise:
	-- Sistema: Colegiaturas
	-- Servidor Productivo: 10.44.2.183
	-- Servidor Desarrollo: 10.28.114.75
	-- Ejemplo:
	--	SELECT * FROM fun_consulta_motivos_revision ()	
	-- =================================================================================================
	valor record;
BEGIN	
	FOR valor IN( 
		SELECT 	idu_motivo_revision, UPPER(des_motivo_revision) as des_motivo_revision
		FROM 	cat_motivos_revision
		ORDER	BY idu_motivo_revision
		) LOOP
		idu_motivo := valor.idu_motivo_revision;
		des_motivo := valor.des_motivo_revision;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_consulta_motivos_revision() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consulta_motivos_revision() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consulta_motivos_revision() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_consulta_motivos_revision() TO postgres;
COMMENT ON FUNCTION fun_consulta_motivos_revision() IS 'La función consulta los motivos de revisión.';