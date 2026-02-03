CREATE OR REPLACE FUNCTION public.fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer, OUT idescuela integer, OUT escuela character, OUT iestado integer, OUT estado character, OUT imunicipio integer, OUT municipio character, OUT ilocalidad integer, OUT localidad character)
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
		
		if iEscuela>0 then
		
			--INSERTAR ESCUELA QUE SE ESPECIFICA
			INSERT 	INTO tmpDatos (rfc_clave_sep,idu_escuela,nom_escuela,idu_estado,idu_municipio,idu_localidad)			
			SELECT 	A.rfc_clave_sep, A.idu_escuela,A.nom_escuela, A.idu_estado, A.idu_municipio, A.idu_localidad 
			FROM 	CAT_ESCUELAS_COLEGIATURAS A
			WHERE 	A.idu_escuela=iEscuela
				AND idu_estado>0;			
			
			INSERT 	INTO tmpDatos (rfc_clave_sep,idu_escuela,nom_escuela,idu_estado,idu_municipio,idu_localidad)
			select 	distinct A.rfc_clave_sep, 1,A.nom_escuela, A.idu_estado, A.idu_municipio, A.idu_localidad 
			FROM 	CAT_ESCUELAS_COLEGIATURAS A
			WHERE 	A.rfc_clave_sep=srfc
				and (idu_estado!=(select idu_estado from tmpDatos) or idu_municipio!=(select idu_municipio from tmpDatos) or idu_localidad!=(select idu_localidad from tmpDatos))
			order	by idu_municipio;			
		else
			--
			INSERT 	INTO tmpDatos (rfc_clave_sep,idu_escuela,nom_escuela,idu_estado,idu_municipio,idu_localidad)			
			SELECT 	distinct A.rfc_clave_sep, 1,A.nom_escuela, A.idu_estado, A.idu_municipio, A.idu_localidad 
			FROM 	CAT_ESCUELAS_COLEGIATURAS A
			WHERE 	A.rfc_clave_sep=srfc 
				AND idu_estado>0;	
		end if;
		
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
			idu_estado,
			nom_estado,
			idu_municipio,
			nom_municipio,
			idu_localidad,
			nom_localidad
		FROM tmpDatos)
		LOOP		
			idescuela:=valor.idu_escuela; 
			escuela:=valor.nom_escuela; 
			iestado:=valor.idu_estado;
			estado:=valor.nom_estado; 
			imunicipio:=valor.idu_municipio; 
			municipio:=valor.nom_municipio; 
			ilocalidad:=valor.idu_localidad;
			localidad:=valor.nom_localidad;
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;  
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer) TO postgres;
COMMENT ON FUNCTION fun_consultar_escuelas_distintas_por_rfc(IN srfc character, IN iescuela integer)  IS 'La función obtiene las escuelas que tienen el mismo rfc';
