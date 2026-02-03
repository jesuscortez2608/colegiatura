CREATE OR REPLACE FUNCTION public.fun_obtener_catalogo_estados(
IN idu_estado integer, 
IN nom_estado character varying, 
OUT id_estado integer, 
OUT nombre_estado character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES		
	sQuery TEXT;	
	valor record;	
	
BEGIN		
	sQuery := 'SELECT idu_estado, nom_estado FROM cat_estados_colegiaturas';
	
	IF (idu_estado>0) THEN
		sQuery := sQuery || ' WHERE idu_estado=' || idu_estado || '';
		sQuery := sQuery || ' ORDER BY idu_estado';		
	ELSE
		IF (nom_estado='') THEN			
			sQuery := sQuery || ' ORDER BY idu_estado';
		ELSE
			sQuery := sQuery || ' WHERE nom_estado LIKE ''%' || nom_estado || '%'''; 
			sQuery := sQuery || ' ORDER BY nom_estado';
		END IF;
	END IF;
	
	FOR valor IN EXECUTE (sQuery)
	LOOP
		id_estado:=valor.idu_estado;
		nombre_estado:=valor.nom_estado;
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fun_obtener_catalogo_estados(integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION public.fun_obtener_catalogo_estados(integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION public.fun_obtener_catalogo_estados(integer, character varying) TO sysetl;
