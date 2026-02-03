DROP FUNCTION if exists fun_obtener_variable_colegiaturas(character varying);

CREATE OR REPLACE FUNCTION fun_obtener_variable_colegiaturas(IN nomvariable character varying, OUT variable character)
  RETURNS SETOF character AS
$BODY$
DECLARE
		
	sQuery VARCHAR;	
	valor record;
	
	-- =================================================================================================
	-- Peticion:
	-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
	-- Fecha:
	-- Descripción General: Consulta el nombre de la carrera de acuerdo al id 
	-- Ruta Tortoise:
	-- Sistema: Colegiaturas_33
	-- Servidor Productivo: 10.44.2.183
	-- Servidor Desarrollo: 10.28.114.75
	-- Ejemplo:
	--	SELECT * FROM fun_obtener_variable_colegiaturas('pct_tolerancia')	
	-- =================================================================================================
	
	BEGIN		
		sQuery := 'SELECT ' || nomVariable || ' as variable FROM ctl_variables_colegiaturas';							
				
		FOR valor IN EXECUTE (sQuery)
		LOOP
			variable:=valor.variable;
			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_variable_colegiaturas(character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_variable_colegiaturas(character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_variable_colegiaturas(character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_variable_colegiaturas(character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_variable_colegiaturas(character varying) IS 'La función consulta el porcentaje de tolerancia.';