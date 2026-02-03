DROP FUNCTION IF EXISTS fun_listado_beneficiarios_estudios(INTEGER);

CREATE OR REPLACE FUNCTION fun_listado_beneficiarios_estudios(IN iempleado integer, OUT idconfiguracion integer, OUT ibeneficiario integer, OUT nombrebeneficiario character varying, OUT iparentesco integer, OUT parentesco character varying, OUT iescuela integer, OUT rfc_escuela character varying, OUT nomescuela character varying, OUT iescolaridad integer, OUT escolaridad character varying, OUT icarrera integer, OUT carrera character varying, OUT icicloescolar integer, OUT cicloescolar character varying, OUT igradoescolar character varying, OUT gradoescolar character varying, OUT fecharegistro character varying, OUT tipo_beneficiario integer)
  RETURNS SETOF record AS
$BODY$
DECLARE  
	valor record;
-- ===========================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 24/04/2018
-- Descripción General: 
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo:  10.44.114.75
-- Ejemplo: SELECT * FROM fun_listado_beneficiarios_estudios (94827443)
-- ===========================================================================================================
BEGIN

	CREATE TEMPORARY TABLE tmp_EstudiosBeneficiarios
	(
		idu_configuracion integer not null default 0,
		idu_empleado integer not null default 0,
		idu_beneficiario integer not null default 0,
		nom_beneficiario varchar(150) not null default '',		
		idu_parentesco integer not null default 0,
		nom_parentesco varchar(10) not null default '',	
		fec_registro varchar(10) not null default '',
		idu_escuela integer  not null default 0,		
		nom_rfc_escuela varchar(20) not null default '',
		nom_nombre_escuela varchar(100) not null default '',		
		idu_escolaridad integer  not null default 0,
		des_escolaridad varchar(30) not null default '',
		idu_carrera integer,
		des_carrera varchar(100) not null default '',
		idu_cicloescolar integer  not null default 0,
		des_cicloescolar varchar(30) not null default '',
		idu_gradoescolar integer  not null default 0,
		des_gradoescolar varchar(30) not null default '',		
		opc_tipo_beneficiario integer  not null default 0
	)on commit drop;	

	--ESTUDIOS BENEFICIARIOS
	INSERT 	INTO tmp_EstudiosBeneficiarios (idu_configuracion, idu_empleado,idu_beneficiario, idu_escuela,idu_escolaridad, idu_carrera, idu_cicloescolar, idu_gradoescolar, fec_registro, opc_tipo_beneficiario )
	SELECT 	idu_configuracion, idu_empleado, idu_beneficiario, idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_grado_escolar, to_char(fec_registro,'dd-MM-yyyy'), opc_tipo_beneficiario
	FROM	CAT_ESTUDIOS_BENEFICIARIOS
	WHERE 	idu_empleado=iEmpleado;

	--BENEFICIARIOS CAPTURADOS
	UPDATE	tmp_EstudiosBeneficiarios SET idu_parentesco=B.idu_parentesco, nom_beneficiario=COALESCE(TRIM(UPPER(B.nom_beneficiario)), '') || ' ' || COALESCE(TRIM(UPPER(B.ape_paterno)),'') || ' ' || COALESCE(TRIM(UPPER(B.ape_materno)),'')
	FROM	CAT_BENEFICIARIOS_COLEGIATURAS B
	WHERE	tmp_EstudiosBeneficiarios.idu_empleado=B.idu_empleado 
		AND tmp_EstudiosBeneficiarios.idu_beneficiario=B.idu_beneficiario
		AND tmp_EstudiosBeneficiarios.opc_tipo_beneficiario=1;	

	--BENEFICIARIOS HOJA AZUL
	UPDATE 	tmp_EstudiosBeneficiarios SET idu_parentesco=b.parentesco
			,nom_beneficiario= COALESCE(trim(b.nombre),'')||' '||COALESCE(trim(b.apellidopaterno),'')||' '||COALESCE(trim(b.apellidomaterno),'')
	FROM 	SAPFAMILIARHOJAS b where tmp_EstudiosBeneficiarios.idu_empleado=b.numemp
			AND b.keyx=tmp_EstudiosBeneficiarios.idu_beneficiario
			AND tmp_EstudiosBeneficiarios.opc_tipo_beneficiario=0;
	
	--ESCOLARIDAD
	UPDATE 	tmp_EstudiosBeneficiarios set des_escolaridad=B.nom_escolaridad 
	FROM 	CAT_ESCOLARIDADES B
	WHERE 	tmp_EstudiosBeneficiarios.idu_escolaridad=B.idu_escolaridad;

	--CARRERA
	UPDATE 	tmp_EstudiosBeneficiarios set des_carrera=B.nom_carrera
	FROM 	CAT_CARRERAS B
	WHERE 	tmp_EstudiosBeneficiarios.idu_carrera=B.idu_carrera;

	--NOMBRE ESCUELA
	UPDATE 	tmp_EstudiosBeneficiarios set nom_rfc_escuela=B.rfc_clave_sep, nom_nombre_escuela=B.nom_escuela 
	FROM 	CAT_ESCUELAS_COLEGIATURAS B
	WHERE 	tmp_EstudiosBeneficiarios.idu_escuela= B.idu_escuela;

	--PARENTESCO
	UPDATE 	tmp_EstudiosBeneficiarios SET nom_parentesco= B.des_parentesco
	FROM 	CAT_PARENTESCOS B
	WHERE	tmp_EstudiosBeneficiarios.idu_parentesco=B.idu_parentesco;

	--CICLO ESCOLAR
	UPDATE 	tmp_EstudiosBeneficiarios SET des_cicloescolar=B.des_ciclo_escolar
	FROM 	CAT_CICLOS_ESCOLARES B
	WHERE	tmp_EstudiosBeneficiarios.idu_cicloescolar=B.idu_ciclo_escolar;

	--GRADO ESCOLAR
	UPDATE 	tmp_EstudiosBeneficiarios SET des_gradoescolar=B.nom_grado_escolar
	FROM	CAT_GRADOS_ESCOLARES B
	WHERE	tmp_EstudiosBeneficiarios.idu_escolaridad=B.idu_escolaridad
		AND tmp_EstudiosBeneficiarios.idu_gradoescolar=B.idu_grado_escolar; 
	--
	FOR valor IN (SELECT  idu_configuracion, idu_beneficiario, nom_beneficiario, idu_parentesco, nom_parentesco, idu_escuela, nom_rfc_escuela, nom_nombre_escuela, idu_escolaridad, des_escolaridad, idu_carrera, des_carrera, idu_cicloescolar, des_cicloescolar, idu_gradoescolar, des_gradoescolar, fec_registro, opc_tipo_beneficiario
		FROM tmp_EstudiosBeneficiarios ORDER BY fec_registro) LOOP
		idconfiguracion:= valor.idu_configuracion;
		iBeneficiario:= valor.idu_beneficiario; 
		NombreBeneficiario:= valor.nom_beneficiario;
		iParentesco:= valor.idu_parentesco;
		Parentesco:= valor.nom_parentesco;		
		iEscuela:= valor.idu_escuela;
		rfc_escuela:= valor.nom_rfc_escuela;
		NomEscuela:= valor.nom_nombre_escuela;
		iEscolaridad:= valor.idu_escolaridad;
		Escolaridad:= valor.des_escolaridad;
		icarrera:= valor.idu_carrera;
		carrera:= valor.des_carrera;
		icicloescolar:=valor.idu_cicloescolar;
		cicloescolar:=valor.des_cicloescolar;
		iGradoEscolar:= valor.idu_gradoescolar;
		GradoEscolar:= valor.des_gradoescolar;
		fecharegistro:=valor.fec_registro;
		tipo_beneficiario:=valor.opc_tipo_beneficiario;
		
		RETURN NEXT;
	END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_listado_beneficiarios_estudios(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_listado_beneficiarios_estudios(integer) TO syspersonal;
COMMENT ON FUNCTION fun_listado_beneficiarios_estudios(integer) IS 'La función obtiene un listado de beneficiarios con estudios configurados por el colaborador.';