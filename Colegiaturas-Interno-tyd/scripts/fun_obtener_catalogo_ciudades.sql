CREATE OR REPLACE FUNCTION fun_obtener_catalogo_ciudades(
IN idu_estado integer, 
IN idu_ciudad integer, 
IN nom_ciudad character varying, 
OUT id_estado integer, 
OUT nombre_estado character varying, 
OUT id_ciudad integer, 
OUT nombre_ciudad character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES		
	sQuery TEXT;	
	valor record;	

	/*
	CONDICIONES
	idu_estado = 0, idu_ciudad = 0, nom_ciudad = "", regresa todos los registros ordenados por clave de estado, ciudad
	idu_estado = 0, idu_ciudad = 0, nom_ciudad != "", busca Ciudad por nombre, el resultado lo ordena por nombre de ciudad (alfabético)
	idu_estado != 0, idu_ciudad = 0, nom_ciudad != "", busca Ciudad por nombre en un estado especificado, ordenado por clave de estado y nombre de ciudad (alfabético)
	idu_ciudad != 0, busca Ciudad por clave, busca ciudad por clave, el resultado lo ordena por idu_estado e idu_ciudad
	*/
	
BEGIN		
	sQuery := 'SELECT A.idu_estado, B.nom_estado, A.idu_ciudad, A.nom_ciudad FROM cat_ciudades_colegiaturas A INNER JOIN cat_estados_colegiaturas B ON A.idu_estado=B.idu_estado';
	
	IF (idu_estado=0) THEN
		IF (idu_ciudad=0) THEN	
			IF (nom_ciudad='') THEN
				sQuery := sQuery || ' ORDER BY A.idu_estado, A.idu_ciudad';	
			ELSE
				sQuery := sQuery || ' WHERE A.nom_ciudad LIKE ''%' || nom_ciudad || '%'''; 
				sQuery := sQuery || ' ORDER BY A.nom_ciudad';
			END IF;			
		END IF;
	ELSE
		IF (idu_ciudad=0) THEN		
			IF (nom_ciudad!='') THEN 
				sQuery := sQuery || ' WHERE A.idu_estado = ' || idu_estado || ' AND A.nom_ciudad LIKE ''%' || nom_ciudad || '%'''; 
				sQuery := sQuery || ' ORDER BY A.idu_estado, A.nom_ciudad';
			ELSE
				sQuery := sQuery || ' WHERE A.idu_estado = ' || idu_estado;
				sQuery := sQuery || ' ORDER BY A.nom_ciudad';
			END IF;
		ELSE
			sQuery := sQuery || ' WHERE A.idu_estado = ' || idu_estado || ' AND A.idu_ciudad = ' || idu_ciudad;
			sQuery := sQuery || ' ORDER BY A.idu_estado, A.idu_ciudad';
		END IF;
	END IF;

	--
	FOR valor IN EXECUTE (sQuery)
	LOOP
		id_estado:=valor.idu_estado;
		nombre_estado:=valor.nom_estado;
		id_ciudad:=valor.idu_ciudad;
		nombre_ciudad:=valor.nom_ciudad;
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_ciudades(integer, integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_ciudades(integer, integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_ciudades(integer, integer, character varying) TO sysetl;
