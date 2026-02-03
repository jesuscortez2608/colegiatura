CREATE OR REPLACE FUNCTION fun_obtener_beneficiario_empleado_rfc(
IN iopcion integer, 
IN crfc character, 
IN iempleado integer, 
OUT id integer, 
OUT nombre character, 
OUT parentesco integer, 
OUT escolaridad integer, 
OUT ciclo integer, 
OUT grado integer, 
OUT carrera integer)
  RETURNS SETOF record AS
$BODY$
DECLARE	
	valor record;	
BEGIN
	--TABLA TEMPORAL
	CREATE TEMP TABLE tmp(
		clave integer not null default 0,
		cnombre varchar(100) not null default '',
		itipo_beneficiario integer not null default 0,
		iparentesco integer not null default 0,
		iescolaridad integer not null default 0,
		iciclo integer not null default 0,
		igrado integer not null default 0,
		icarrera integer not null default 0
	) ON COMMIT DROP;

	--
	IF (iOpcion=1) THEN  --Indica si tiene configurada la esccuela para subir facturas
		INSERT INTO tmp(clave, cnombre, iparentesco)
		SELECT 	A.idu_escuela, A.nom_escuela, 0
		FROM 	CAT_ESCUELAS_COLEGIATURAS A
		INNER 	JOIN CAT_ESTUDIOS_BENEFICIARIOS B ON A.idu_escuela=B.idu_escuela
		WHERE 	A.rfc_clave_sep=crfc
				AND B.idu_empleado=iempleado;
	ELSE		
			
		INSERT 	INTO tmp(clave, itipo_beneficiario,iescolaridad, iciclo, igrado, icarrera)
		SELECT 	B.idu_beneficiario,B.opc_tipo_beneficiario, B.idu_escolaridad, B.idu_ciclo_escolar, B.idu_grado_escolar, B.idu_carrera
		FROM 	CAT_ESCUELAS_COLEGIATURAS A
		INNER 	JOIN CAT_ESTUDIOS_BENEFICIARIOS B ON A.idu_escuela=B.idu_escuela		
		WHERE 	A.rfc_clave_sep=crfc
			AND B.idu_empleado=iempleado;

		UPDATE 	tmp SET cnombre=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno, iparentesco=B.parentesco
		FROM	SAPFAMILIARHOJAS B
		WHERE	tmp.clave=B.keyx 
			AND B.numemp=iempleado
			AND tmp.itipo_beneficiario=0;

		UPDATE 	tmp SET cnombre=B.nom_beneficiario || ' ' || B.ape_paterno || ' ' || B.ape_materno, iparentesco=B.idu_parentesco
		FROM	CAT_BENEFICIARIOS_COLEGIATURAS B
		WHERE	tmp.clave=B.idu_beneficiario 
			AND B.idu_empleado=iempleado
			AND tmp.itipo_beneficiario=1;			
	END IF;
		
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN (SELECT clave, cnombre, iparentesco, iescolaridad, iciclo, igrado, icarrera FROM tmp ORDER BY cnombre)
	LOOP
		id:=valor.clave;
		nombre:=valor.cnombre;
		parentesco:=valor.iparentesco;
		escolaridad:=valor.iescolaridad;
		ciclo:=valor.iciclo;
		grado:=valor.igrado;
		carrera:=valor.icarrera;
				
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiario_empleado_rfc(IN iopcion integer, IN crfc character, IN iempleado integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiario_empleado_rfc(IN iopcion integer, IN crfc character, IN iempleado integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiario_empleado_rfc(IN iopcion integer, IN crfc character, IN iempleado integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiario_empleado_rfc(IN iopcion integer, IN crfc character, IN iempleado integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_beneficiario_empleado_rfc(IN iopcion integer, IN crfc character, IN iempleado integer)  IS 'La función consulta las facturas por empleado';
  