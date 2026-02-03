--DROP FUNCTION IF EXISTS fun_obtener_listado_escolaridades_por_rfc_escuela(IN srfc character varying, IN iestado integer, IN imunicipio integer, IN ilocalidad integer);

CREATE OR REPLACE FUNCTION fun_obtener_listado_escolaridades_por_rfc_escuela(
IN srfc character varying, 
IN iestado integer, 
IN imunicipio integer, 
IN ilocalidad integer, 
IN snombre character varying, 
OUT iescolaridad integer, 
OUT sescolaridad character varying, 
OUT iopc_carrera integer, 
OUT iescuela integer,
OUT iestatus integer)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	sQuery TEXT;
	valor record;
	iEscuelaNueva integer;	
	-- =================================================================================================
	-- Peticion:
	-- Autor: Omar AlejANDro Lizarraga HernANDez 94827443
	-- Fecha:
	-- Descripción General: Consulta el nombre de la carrera de acuerdo al id 
	-- Ruta Tortoise:
	-- Sistema: Colegiaturas
	-- Servidor Productivo: 10.44.2.183
	-- Servidor Desarrollo: 10.28.114.75
	-- Ejemplo:
	--	SELECT * FROM fun_obtener_listado_escolaridades (0)
	--	SELECT * FROM fun_obtener_listado_escolaridades (1): 
	-- =================================================================================================
	BEGIN			
		CREATE TEMP TABLE tmp_Datos (
			idu_escuela integer,
			escolaridad INTEGER DEFAULT 0,
			nom_escolaridad CHARACTER VARYING(30) DEFAULT '',
			opc_carrera INTEGER DEFAULT 0,
			estatus integer DEFAULT 0 			--si tiene escolaridades regresa 0, si no regresa 1
		)ON COMMIT DROP;	

		IF (EXISTS (
			SELECT 	idu_escuela 
			FROM 	CAT_ESCUELAS_COLEGIATURAS 
			WHERE 	rfc_clave_sep= srfc 
					AND idu_estado=iEstado
					AND idu_municipio=iMunicipio
					AND idu_localidad=iLocalidad
					AND idu_escolaridad>0
					--AND  snombre
					--AND TRIM(nom_escuela)=trim(srfc)
				)) THEN
				
			--ESCUELAS
			/*INSERT INTO tmp_Datos (idu_escuela,escolaridad, estatus)
			SELECT  A.idu_escuela, A.idu_escolaridad, 0
			FROM	CAT_ESCUELAS_COLEGIATURAS A
			WHERE 	A.rfc_clave_sep= srfc 
				AND idu_estado=iEstado
				AND idu_municipio=iMunicipio
				AND idu_localidad=iLocalidad
				AND idu_escolaridad>0;*/

			--
			IF trim(snombre)='' THEN
				INSERT INTO tmp_Datos (escolaridad)
				SELECT 	DISTINCT idu_Escolaridad
				FROM 	CAT_ESCUELAS_COLEGIATURAS 
				WHERE 	rfc_clave_sep= srfc
						AND idu_estado=iEstado
						AND idu_municipio=iMunicipio
						AND idu_localidad=iLocalidad
						AND idu_escolaridad>0;
					--AND TRIM(nom_escuela)=trim(snombre);

				UPDATE	tmp_Datos set idu_escuela=B.idu_Escuela, estatus=0
				FROM	CAT_ESCUELAS_COLEGIATURAS B
				WHERE	tmp_Datos.escolaridad=B.idu_escolaridad
						AND B.rfc_clave_sep= srfc 
						AND B.idu_estado=iEstado
						AND B.idu_municipio=iMunicipio
						AND B.idu_localidad=iLocalidad
						AND B.idu_escolaridad>0;
					--AND TRIM(B.nom_escuela)=trim(snombre);
			ELSE
				INSERT INTO tmp_Datos (escolaridad)
				SELECT 	DISTINCT idu_Escolaridad
				FROM 	CAT_ESCUELAS_COLEGIATURAS 
				WHERE 	rfc_clave_sep= srfc
						AND idu_estado=iEstado
						AND idu_municipio=iMunicipio
						AND idu_localidad=iLocalidad
						AND idu_escolaridad>0
						AND TRIM(nom_escuela)=trim(snombre);

				UPDATE	tmp_Datos set idu_escuela=B.idu_Escuela, estatus=0
				FROM	CAT_ESCUELAS_COLEGIATURAS B
				WHERE	tmp_Datos.escolaridad=B.idu_escolaridad
						AND B.rfc_clave_sep= srfc 
						AND B.idu_estado=iEstado
						AND B.idu_municipio=iMunicipio
						AND B.idu_localidad=iLocalidad
						AND B.idu_escolaridad>0
						AND TRIM(B.nom_escuela)=trim(snombre);
			END IF;

			--ESCOLARIDADES
			UPDATE  tmp_Datos set nom_escolaridad=B.nom_escolaridad, opc_carrera=B.opc_carrera
			FROM 	CAT_ESCOLARIDADES B
			WHERE 	tmp_Datos.escolaridad=B.idu_escolaridad;
		ELSE 

			iEscuelaNueva:=(SELECT idu_escuela FROM CAT_ESCUELAS_COLEGIATURAS WHERE rfc_clave_sep= srfc AND idu_estado=iEstado AND idu_municipio=iMunicipio AND idu_localidad=iLocalidad order by idu_escuela desc limit 1);
			
			--TODAS LAS ESCOLARIDADES
			INSERT 	INTO tmp_Datos (idu_escuela,escolaridad,nom_escolaridad,opc_carrera, estatus)
			SELECT 	iEscuelaNueva,idu_escolaridad,nom_escolaridad, opc_carrera, 1 
			FROM 	CAT_ESCOLARIDADES;
		END IF;		

		sQuery := 'SELECT  A.escolaridad, A.nom_escolaridad, A.opc_carrera, A.idu_escuela, A.estatus FROM tmp_Datos A ORDER BY A.escolaridad ';
		
		FOR valor IN EXECUTE (sQuery)
		LOOP
			iEscolaridad:=valor.escolaridad;
			sEscolaridad:=valor.nom_escolaridad;
			iopc_carrera:=valor.opc_carrera;
			iEscuela:=valor.idu_escuela;
			iestatus:=valor.estatus;
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_por_rfc_escuela(IN srfc character varying, IN iestado integer, IN imunicipio integer, IN ilocalidad integer,IN snombre character varying)   TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_por_rfc_escuela(IN srfc character varying, IN iestado integer, IN imunicipio integer, IN ilocalidad integer,IN snombre character varying)   TO syspersonal;
COMMENT ON FUNCTION fun_obtener_listado_escolaridades_por_rfc_escuela(IN srfc character varying, IN iestado integer, IN imunicipio integer, IN ilocalidad integer,IN snombre character varying)  IS 'La función obtiene un listado de escolaridades por rfc de la escuela';
