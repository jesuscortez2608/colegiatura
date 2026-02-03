CREATE OR REPLACE FUNCTION fun_consultar_escuelas_por_rfc(
IN srfc character, 
OUT idescuela integer, 
OUT escuela character, 
OUT estado character, 
OUT municipio character, 
OUT localidad character)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	valor record;	
	
	/*--------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 04/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez
	BD: Personal
	Servidor: 10.28.114.75
	Modulo: Colegiaturas
	Repositorio: 
	Descripción: Consulta las escuelas que coincidan con el RFC que se manda como parametro,
	la escuela no debe ser en linea ó extranjero es decir, idu_estado>0 
	Ejemplo: SELECT * FROM fun_consultar_escuelas_por_rfc ('AEQWE13213FSD');
	--------------------------------------------------------------------------------*/	
	BEGIN	
		--
		CREATE LOCAL TEMP TABLE tmpDatos (			
			rfc_clave_sep character(20),
			idu_escuela integer,			
			nom_escuela character(100),
			idu_estado integer,
			nom_estado character(60),
			idu_municipio integer,
			nom_municipio character(150),
			idu_localidad integer,
			nom_localidad character(60)		
			)
		ON COMMIT DROP;
		
		--
		INSERT 	INTO tmpDatos (rfc_clave_sep,idu_escuela,nom_escuela,idu_estado,idu_municipio,idu_localidad)			
		SELECT 	A.rfc_clave_sep, A.idu_escuela, A.nom_escuela, A.idu_estado, A.idu_municipio, A.idu_localidad 
		FROM 	CAT_ESCUELAS_COLEGIATURAS A
		WHERE 	A.rfc_clave_sep=srfc AND idu_estado>0;
			
		
		--ESTADOS
		UPDATE	tmpDatos SET nom_estado=B.nom_estado
		FROM	CAT_ESTADOS_COLEGIATURAS B
		WHERE	tmpDatos.idu_estado=B.idu_estado;

		--MUNICIPIO
		UPDATE	tmpDatos SET nom_municipio=B.nom_municipio
		FROM	CAT_MUNICIPIOS_COLEGIATURAS B
		WHERE	tmpDatos.idu_estado=B.idu_estado and tmpDatos.idu_municipio=B.idu_municipio;

		--LOCALIDAD
		UPDATE	tmpDatos SET nom_localidad=B.nom_localidad
		FROM	CAT_LOCALIDADES_COLEGIATURAS B
		WHERE	tmpDatos.idu_estado=B.idu_estado and tmpDatos.idu_municipio=B.idu_municipio and tmpDatos.idu_localidad=B.idu_localidad;
		
		
		FOR valor IN (SELECT 
			--rfc_clave_sep,
			idu_escuela,
			nom_escuela,
			--idu_estado,
			nom_estado,
			--idu_municipio,
			nom_municipio,
			--idu_localidad,
			nom_localidad
		FROM tmpDatos)
		LOOP		
			idescuela:=valor.idu_escuela; 
			escuela:=valor.nom_escuela; 
			estado:=valor.nom_estado; 
			municipio:=valor.nom_municipio; 
			localidad:=valor.nom_localidad;
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_por_rfc(character) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_por_rfc(character) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_por_rfc(character) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_por_rfc(character) TO postgres;
COMMENT ON FUNCTION fun_consultar_escuelas_por_rfc(character) IS 'La función consulta escuelas por medio de su rfc.';