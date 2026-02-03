CREATE OR REPLACE FUNCTION fun_obtener_motivos_revision(OUT idu_motivo integer, OUT des_motivo character varying)
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
	--	SELECT * FROM fun_consulta_motivos_revision()
	----------------------------------------------------------------------------------------------------
	-- Peticion:	16559.1
	-- Colaborador:	Rafael Ramos 98439677
	-- Fecha:	10/08/2018
	-- Descripcion del cambio: Se cambia la tabla de donde se toman los motivos
	-- =================================================================================================
	valor record;
BEGIN	
	FOR valor IN( 
		SELECT 	mot.idu_motivo, UPPER(mot.des_motivo) as des_motivo		
		FROM	cat_motivos_colegiaturas as mot
		where	mot.idu_tipo_motivo = 4
		ORDER	BY mot.idu_motivo
		) LOOP
		idu_motivo := valor.idu_motivo;
		des_motivo := valor.des_motivo;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_revision() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_revision() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_revision() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_revision() TO postgres;
COMMENT ON FUNCTION fun_obtener_motivos_revision() IS 'La función consulta los motivos de revisión.';