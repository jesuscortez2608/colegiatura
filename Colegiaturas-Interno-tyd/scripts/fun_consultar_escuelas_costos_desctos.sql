DROP FUNCTION IF EXISTS fun_consultar_escuelas_costos_desctos(integer, character varying, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_consultar_escuelas_costos_desctos(IN iopcion integer, IN snombre character varying, IN iestado integer, IN iciudad integer, IN ilocalidad integer, OUT idescuela integer, OUT snomescuela character varying, OUT srfc character varying, OUT idestado integer, OUT sestado character varying, OUT idciudad integer, OUT sciudad character varying, OUT idlocalidad integer, OUT slocalidad character varying, OUT iescolaridad integer, OUT sescolaridad character varying, OUT srazonsocial character varying, OUT sclavesep character varying, OUT idcarrera integer, OUT snomcarrera character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	--DECLARACION DE VARIABLES
	dFecha timestamp;	
	sQuery TEXT;	
	valor record;	
	sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER; 
	
	/*--------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 04/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez
	BD: Personal
	Servidor: 10.28.114.75
	Modulo: Colegiaturas
	Repositorio: 
	Descripción: 
	Ejemplo: SELECT * FROM fun_consultar_escuelas_por_rfc ('AEQWE13213FSD');
	--------------------------------------------------------------------------------*/	
	BEGIN	
		--
		CREATE LOCAL TEMP TABLE tmpDatos (
			escuela integer,
			nomescuela character varying,
			rfc character varying,
			Estado integer,
			nomEstado character Varying,
			Ciudad integer,
			nomCiudad character Varying,
			Localidad integer,
			nomLocalidad character Varying,
			Escolaridad integer,
			nomEscolaridad character Varying,
			RazonSocial character Varying,
			ClaveSep character Varying,
			Carrera integer,
			nomCarrera character Varying
		)
		ON COMMIT DROP;

		sQuery := 'INSERT INTO tmpDatos (escuela,nomescuela,rfc,Estado,Ciudad,Localidad,Escolaridad,RazonSocial,ClaveSep,Carrera)
		SELECT idu_escuela, nom_escuela, rfc_clave_sep, idu_estado, idu_municipio,  idu_localidad, idu_escolaridad,razon_social, clave_sep, idu_carrera FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_estado>0'; 

		--
		IF (iOpcion=0) THEN 
			sQuery := sQuery || ' AND rfc_clave_sep LIKE ''%' || sNombre || '%'''; 
		else
			sQuery := sQuery || ' AND nom_escuela LIKE ''%' || sNombre || '%'''; 	
		END IF;

		--ESTADO
		IF (iEstado>0) THEN 
			sQuery := sQuery || ' AND idu_estado=' || iEstado; 		
		END IF;

		--CIUDAD
		IF (iCiudad>0) THEN 
			sQuery := sQuery || ' AND idu_municipio=' || iCiudad; 		
		END IF;

		--LOCALIDAD
		IF (iLocalidad>0) THEN 
			sQuery := sQuery || ' AND idu_localidad=' || iLocalidad; 		
		END IF;

		raise notice 'ff :nImporteConcepto %', sQuery;
		execute sQuery;

		--ESTADO		
		UPDATE	tmpDatos set nomEstado=B.nom_estado
		FROM	CAT_ESTADOS_COLEGIATURAS B
		where	tmpDatos.Estado=B.idu_estado;
		
		--CIUDAD		
		UPDATE	tmpDatos set nomCiudad=B.nom_municipio
		FROM	CAT_MUNICIPIOS_COLEGIATURAS B
		where	tmpDatos.Estado=B.idu_estado and tmpDatos.Ciudad=B.idu_municipio;
		
		--LOCALIDAD		
		UPDATE	tmpDatos set nomLocalidad=B.nom_localidad
		FROM	CAT_LOCALIDADES_COLEGIATURAS B
		where	tmpDatos.Estado=B.idu_estado 
			and tmpDatos.Ciudad=B.idu_municipio 
			and tmpDatos.Localidad=B.idu_localidad;
		
		--ESCOLARIDAD	
		UPDATE	tmpDatos set nomEscolaridad=B.nom_escolaridad
		FROM	CAT_ESCOLARIDADES B
		where	tmpDatos.Escolaridad=B.idu_escolaridad;

		--CARRERA
		UPDATE	tmpDatos set nomCarrera=B.nom_carrera
		FROM	CAT_CARRERAS B
		where	tmpDatos.Carrera=B.idu_carrera;
				
		
		FOR valor IN (
			SELECT 	escuela,nomescuela,rfc,Estado,nomEstado,Ciudad,nomCiudad,Localidad,nomLocalidad,Escolaridad,nomEscolaridad,RazonSocial,ClaveSep,Carrera,nomCarrera	
			FROM 	tmpDatos
			order	by idestado, idciudad, idlocalidad)
		LOOP					
			idescuela:=valor.escuela;
			snomescuela:=valor.nomescuela;
			srfc:=valor.rfc;
			idEstado:=valor.Estado;
			sEstado:=valor.nomEstado; 
			idCiudad:=valor.Ciudad;
			sCiudad:=valor.nomCiudad;
			idLocalidad:=valor.Localidad; 
			sLocalidad:=valor.nomLocalidad;
			iEscolaridad:=valor.Escolaridad; 
			sEscolaridad:=valor.nomEscolaridad;
			sRazonSocial:=valor.RazonSocial;
			sClaveSep:=valor.ClaveSep;
			idCarrera:=valor.Carrera;
			snomCarrera:=valor.nomCarrera;			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
  GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_costos_desctos(IN iopcion integer, IN snombre character varying, IN iestado integer, IN iciudad integer, IN ilocalidad integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_escuelas_costos_desctos(IN iopcion integer, IN snombre character varying, IN iestado integer, IN iciudad integer, IN ilocalidad integer) TO syspersonal;
COMMENT ON FUNCTION fun_consultar_escuelas_costos_desctos(IN iopcion integer, IN snombre character varying, IN iestado integer, IN iciudad integer, IN ilocalidad integer) IS 'La función obtiene los costos/descuentos de la escuela seleccionada';