CREATE OR REPLACE FUNCTION fun_grabar_revision_colegiaturas(
IN irevision integer, 
IN iescuela integer, 
IN sescuela character varying, 
IN iusuario integer, 
IN imotivorevision integer, 
IN srfc character varying, 
IN srazonsocial character varying, 
IN iestado integer, 
IN imunicipio integer, 
IN ilocalidad integer, 
IN sclavesep character varying, 
IN iopcion integer, 
OUT iiestado integer, 
OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES	
	sQuery TEXT;	
	valor record;	
	--sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER; 
	dfec_captura timestamp without time zone;
	sRfc varchar(20);
	FechaInicioConclusion date;
	cNombreAnt varchar(100);
	cFlag varchar(100);
BEGIN
    --drop table IF exists tmpDatos;
	--CREATE TABLE tmpDatos(
	CREATE TEMP TABLE tmpDatos(
		icontacto integer not null default 0,
		iescuela  integer not null default 0,
		nom_contacto VARCHAR(60) not null default '',
		telefono VARCHAR(50) not null default '',
		email VARCHAR(50) not null default '',
		area VARCHAR(50) not null default '',
		ext VARCHAR(50) not null default '',
		observaciones text not null default '',
		usuario_registro integer not null default 0
	) ON COMMIT DROP;
	--);
    
	--TABLA TEMPORAL
	--drop table IF exists tmpEstado;
	--CREATE table tmpEstado (
	CREATE TEMP TABLE tmpEstado(
		estado integer not null default 0,
		mensaje varchar(250) not null default ''
	) ON COMMIT DROP;
	--);
	
	--TMP ESCUELA
	--drop table IF exists tmpEscuela;
	--CREATE TABLE tmpEscuela(
	CREATE TEMP TABLE tmpEscuela(
		idEscuela integer not null default 0,
		idEstado  integer not null default 0,
		idMunicipio integer not null default 0,
		idLocalidad integer not null default 0
	) ON COMMIT DROP;
	--);
    
	--RFC
	sRfc:=(SELECT rfc_clave_sep FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_escuela=iescuela);
	
	INSERT 	INTO tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
	SELECT 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
	FROM 	CAT_ESCUELAS_COLEGIATURAS
	WHERE	idu_escuela=iescuela;
    
    raise notice '1 %', 'INSERT INTO tmpEscuela';
    
	--MODIFCIAR DATOS ESCUELA
	--NOMBRE ESCUELA
	IF (sescuela!='') then
		cNombreAnt:=(SELECT nom_escuela FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_escuela=iescuela); 
		
		UPDATE CAT_ESCUELAS_COLEGIATURAS set nom_escuela=sescuela, clave_sep=sclavesep, razon_social=srazonsocial
		WHERE --idu_escuela=iescuela;
				idu_estado= iestado
				AND idu_municipio=imunicipio
				AND idu_localidad=ilocalidad
				AND rfc_clave_Sep=srfc
				AND nom_escuela=cNombreAnt;
		
		raise notice '2 %', 'UPDATE CAT_ESCUELAS_COLEGIATURAS';
	END IF;
	
	--IF (irevision>0) then		
		INSERT 	INTO tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
		SELECT 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
		FROM 	CAT_ESCUELAS_COLEGIATURAS
		WHERE	rfc_clave_Sep=sRfc
				AND idu_estado= (SELECT idEstado FROM tmpEscuela)
				AND idu_municipio= (SELECT idMunicipio FROM tmpEscuela)
				AND idu_localidad= (SELECT idLocalidad FROM tmpEscuela)
				AND idu_escuela!=iescuela;
			
        raise notice '3 %', 'INSERT INTO tmpEscuela';
	--END IF;
	
	UPDATE 	MOV_REVISION_COLEGIATURAS set fec_revision=now(), usuario_revision=iUsuario, idu_estatus_revision=2
	WHERE 	idu_escuela IN (SELECT idu_escuela FROM tmpEscuela)
			AND idu_escuela in (SELECT idu_escuela FROM STMP_DETALLE_REVISION_COLEGIATURAS);
    
    raise notice '4 %', 'UPDATE MOV_REVISION_COLEGIATURAS';
    
    dfec_captura:=(SELECT fec_captura FROM MOV_REVISION_COLEGIATURAS WHERE idu_escuela=iEscuela ORDER BY fec_captura LIMIT 1 );
	dfec_captura := coalesce(dfec_captura, now());
    /**
    ----------------------------------------------
    MODIFICACION DE DATOS GENERALES
    ----------------------------------------------
    */
    IF 	not exists (
        SELECT idu_escuela 
        FROM CAT_ESCUELAS_COLEGIATURAS 
        WHERE idu_escuela=iEscuela 
            AND rfc_clave_sep=sRfc 
            AND clave_sep=sClaveSep 
            AND razon_social=sRazonSocial 
            AND idu_estado=iEstado 
            AND idu_municipio=iMunicipio 
            AND nom_escuela=sEscuela 
            AND idu_localidad=iLocalidad ) then
        
		INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision,idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_escolaridad, fec_revision, idu_usuario)
		SELECT 	A.idu_revision, iMotivoRevision, 1, iEstado, iMunicipio, iEscuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_escolaridad, now(), iUsuario	
		FROM 	STMP_REVISION_COLEGIATURAS A
		INNER	JOIN CAT_ESCUELAS_COLEGIATURAS B ON A.idu_escuela=B.idu_escuela
		WHERE	A.idu_usuario=iUsuario
				AND A.idu_escuela in (SELECT idescuela FROM tmpEscuela)
				AND A.idu_revision=iRevision;
        
        raise notice '5 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    END IF;
    
    /**----------------------------------------------
    MOV DETALLE REVISION COLEGIATURAS
    ----------------------------------------------*/	
    --INSERTAR EN LA BITACORA DESCUENTOS NUEVOS, DEL CILCO ESCOLAR ACTUAL		
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision,idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT	idu_revision, iMotivoRevision,7 ,iEstado, iMunicipio,idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=1 
			AND idu_usuario=iUsuario
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento>0
			AND keyx not in ( SELECT keyx FROM MOV_DETALLE_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idescuela FROM tmpEscuela) AND prc_descuento>0 );
    
    raise notice '6 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --INSERTAR EN LA BITACORA COSTOS NUEVOS, DEL CICLO ESCOLAR ACTUAL
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT	idu_revision,iMotivoRevision,8 ,iEstado, iMunicipio,idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=1 
			AND idu_usuario=iUsuario
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento=0
			AND keyx not in (
				SELECT 	keyx 
				FROM 	MOV_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela)
				AND prc_descuento=0
			);
	    
    raise notice '7 %', 'INSERT INTO MOV_BITACORA_COSTOS';
	
	--INSERTAR EN LA MOV REVISIONES NUEVAS 
	INSERT 	INTO MOV_DETALLE_REVISION_COLEGIATURAS (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, idu_usuario_registro, fec_registro,keyx)	
	SELECT	idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, iUsuario, fec_registro,keyx
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=1 
			AND idu_usuario=iUsuario 
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND keyx not in (
				SELECT 	keyx 
				FROM 	MOV_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela)
			);
    
    raise notice '8 %', 'INSERT INTO MOV_DETALLE_REVISION_COLEGIATURAS';
    
	--INSERTAR EN LA BITOCORA SI HUBO MODIFICACIONES DE DESCUENTO 
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT 	A.idu_revision,iMotivoRevision,2,iEstado,iMunicipio,A.idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, A.idu_ciclo_escolar, A.idu_escolaridad, A.idu_carrera, A.idu_tipo_pago, A.prc_descuento, A.idu_motivo, A.importe_concepto,0,dfec_captura,now(), A.idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS A
	inner	join MOV_DETALLE_REVISION_COLEGIATURAS B on A.keyx=B.keyx
	WHERE	A.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND B.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND A.idu_usuario=iUsuario
			AND A.idu_tipo_registro=1
			AND A.prc_descuento>0
			AND (	A.prc_descuento!=B.prc_descuento 
				OR A.idu_escolaridad!=B.idu_escolaridad 
				or A.idu_carrera!=B.idu_carrera 
				or A.idu_tipo_pago!=B.idu_tipo_pago 
				or A.idu_motivo!=B.idu_motivo
			);
    
    raise notice '9 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
	--INSERTAR EN LA BITACORA SI HUBO MODIFICACIONES DE COSTOS
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT 	A.idu_revision,iMotivoRevision,3,iEstado,iMunicipio,A.idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, A.idu_ciclo_escolar, A.idu_escolaridad, A.idu_carrera, A.idu_tipo_pago, A.prc_descuento, A.idu_motivo, A.importe_concepto,0,dfec_captura,now(), A.idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS A
	inner	join MOV_DETALLE_REVISION_COLEGIATURAS B on A.keyx=B.keyx
	WHERE	A.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND B.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND A.idu_usuario=iUsuario
			AND A.idu_tipo_registro=1
			AND A.prc_descuento=0
			AND (	A.importe_concepto!=B.importe_concepto 
				OR A.idu_escolaridad!=B.idu_escolaridad 
				or A.idu_carrera!=B.idu_carrera 
				or A.idu_tipo_pago!=B.idu_tipo_pago 
				or A.idu_motivo!=B.idu_motivo
			);
    
    raise notice '10 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
	--MODIFICAR REVISIONES EXISTENTES
	UPDATE 	MOV_DETALLE_REVISION_COLEGIATURAS 
			SET idu_revision=B.idu_revision,
			idu_ciclo_escolar=B.idu_ciclo_escolar, 
			idu_escolaridad=B.idu_escolaridad,
			idu_carrera=B.idu_carrera, 
			idu_tipo_pago=B.idu_tipo_pago, 
			prc_descuento=B.prc_descuento, 
			idu_motivo=B.idu_motivo, 
			importe_concepto=B.importe_concepto, 
			idu_usuario_registro=iUsuario			
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS B
	WHERE	MOV_DETALLE_REVISION_COLEGIATURAS.keyx=B.keyx
			AND MOV_DETALLE_REVISION_COLEGIATURAS.idu_escuela=B.idu_escuela
			AND MOV_DETALLE_REVISION_COLEGIATURAS.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND idu_tipo_registro=1
			AND B.idu_usuario=iUsuario;
    
    raise notice '11 %', 'UPDATE MOV_DETALLE_REVISION_COLEGIATURAS';
    
	--INSERTAMOS EN LA BITACORA DESCUENTOS QUE FUERON ELIMINADOS 
	INSERT INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT  idu_revision,iMotivoRevision,9 ,iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), iUsuario,0
	FROM 	MOV_DETALLE_REVISION_COLEGIATURAS			
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento>0
			AND keyx NOT IN (
				SELECT 	keyx 
				FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_tipo_registro=1 
				AND idu_usuario=iUsuario 
				AND idu_escuela in (SELECT idescuela FROM tmpEscuela) 
				AND prc_descuento>0
			);
    
    raise notice '12 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --INSERTAMOS EN LA BITACORA COSTOS QUE FUERON ELIMINADOS 
	INSERT	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision, idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT  idu_revision,iMotivoRevision, 10 ,iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), iUsuario,0
	FROM 	MOV_DETALLE_REVISION_COLEGIATURAS			
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento=0
			AND keyx NOT IN (
				SELECT 	keyx 
				FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_tipo_registro=1 
				AND idu_usuario=iUsuario 
				AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
				AND prc_descuento=0
			);
    
    raise notice '13 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --ELIMINAR LAS REVISIONES QUE ESTABAN EN LA MOV Y NO SE ENCUENTRAN EN LA STMP
	DELETE 	FROM MOV_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela) 
			AND keyx not in (
				SELECT  keyx
				FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_tipo_registro=1 
					AND idu_usuario=iUsuario
					AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			);
    
    raise notice '14 %', 'DELETE FROM MOV_DETALLE_REVISION_COLEGIATURAS';
    
    /**----------------------------------------------
    HIS DETALLE REVISION COLEGIATURAS 
    ----------------------------------------------*/
			
    --INSERTAR EN LA BITACORA DESCUENTOS NUEVOS 
	INSERT INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision, idu_tipo_revision, idu_estado, idu_municipio, idu_escuela,  nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT	idu_revision, iMotivoRevision, 7, iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=2 
			AND idu_usuario=iUsuario
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento>0
			AND keyx not in (
			SELECT keyx FROM HIS_DETALLE_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idescuela FROM tmpEscuela) AND prc_descuento>0
			);
    
    raise notice '15 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --INSERTAMOS EN LA BITACORA COSTOS NUEVOS 
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision, idu_motivo_revision, idu_tipo_revision, idu_estado, idu_municipio, idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT	idu_revision, iMotivoRevision, 8, iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=2 
			AND idu_usuario=iUsuario
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND prc_descuento=0
			AND keyx not in (
			SELECT keyx FROM HIS_DETALLE_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idescuela FROM tmpEscuela) AND prc_descuento=0
			);
    
    raise notice '16 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
	--INSERTAR EN LA HIS REVISIONES NUEVAS 
	INSERT 	INTO HIS_DETALLE_REVISION_COLEGIATURAS (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, idu_usuario_registro, fec_registro, keyx)
	SELECT	idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, iUsuario, fec_registro, keyx
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_tipo_registro=2 
			AND idu_usuario=iUsuario 
			AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND keyx not in (
			SELECT keyx FROM HIS_DETALLE_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idescuela FROM tmpEscuela)
			);
    
    raise notice '17 %', 'INSERT INTO HIS_DETALLE_REVISION';
    
    --INSERTAR EN LA BITOCORA SI HUBO MODIFICACIONES DE DESCUENTO 
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT 	A.idu_revision,iMotivoRevision,2,iEstado,iMunicipio,A.idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, A.idu_ciclo_escolar, A.idu_escolaridad, A.idu_carrera, A.idu_tipo_pago, A.prc_descuento, A.idu_motivo, A.importe_concepto,0,dfec_captura,now(), A.idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS A
	inner	join HIS_DETALLE_REVISION_COLEGIATURAS B on A.keyx=B.keyx
	WHERE	A.idu_escuela=iEscuela
			AND B.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND A.idu_usuario=iUsuario
			AND A.idu_tipo_registro=2
			AND A.prc_descuento>0
			AND (	A.prc_descuento!=B.prc_descuento 
				OR A.idu_escolaridad!=B.idu_escolaridad 
				or A.idu_carrera!=B.idu_carrera 
				or A.idu_tipo_pago!=B.idu_tipo_pago 
				or A.idu_motivo!=B.idu_motivo
			);
    
	raise notice '18 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --INSERTAR EN LA BITOCORA SI HUBO MODIFICACIONES DE COSTOS
	INSERT 	INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT 	A.idu_revision,iMotivoRevision,3,iEstado,iMunicipio,A.idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, A.idu_ciclo_escolar, A.idu_escolaridad, A.idu_carrera, A.idu_tipo_pago, A.prc_descuento, A.idu_motivo, A.importe_concepto,0,dfec_captura,now(), A.idu_usuario,0
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS A
	inner	join HIS_DETALLE_REVISION_COLEGIATURAS B on A.keyx=B.keyx
	WHERE	A.idu_escuela=iEscuela
			AND B.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND A.idu_usuario=iUsuario
			AND A.idu_tipo_registro=2
			AND A.prc_descuento=0
			AND (	A.importe_concepto!=B.importe_concepto 
				OR A.idu_escolaridad!=B.idu_escolaridad 
				or A.idu_carrera!=B.idu_carrera 
				or A.idu_tipo_pago!=B.idu_tipo_pago 
				or A.idu_motivo!=B.idu_motivo
			);
    
    raise notice '19 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --MODIFICAR REVISIONES EXISTENTES
	UPDATE 	HIS_DETALLE_REVISION_COLEGIATURAS 
			SET idu_revision=B.idu_revision,
			idu_ciclo_escolar=B.idu_ciclo_escolar, 
			idu_escolaridad=B.idu_escolaridad,
			idu_carrera=B.idu_carrera, 
			idu_tipo_pago=B.idu_tipo_pago, 
			prc_descuento=B.prc_descuento, 
			idu_motivo=B.idu_motivo, 
			importe_concepto=B.importe_concepto, 
			idu_usuario_registro=iUsuario
	FROM 	STMP_DETALLE_REVISION_COLEGIATURAS B
	WHERE	HIS_DETALLE_REVISION_COLEGIATURAS.keyx=B.keyx
			AND HIS_DETALLE_REVISION_COLEGIATURAS.idu_escuela=B.idu_escuela
			AND HIS_DETALLE_REVISION_COLEGIATURAS.idu_escuela in (SELECT idescuela FROM tmpEscuela)
			AND idu_tipo_registro=2
			AND B.idu_usuario=iUsuario;
    
    raise notice '20 %', 'UPDATE HIS_DETALLE_REVISION_COLEGIATURAS ';
    
    --INSERTAMOS EN LA BITACORA LOS DESCUENTOS QUE FUERON ELIMINADOS 
	INSERT INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT  idu_revision,iMotivoRevision,9,iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), iUsuario,0
	FROM 	HIS_DETALLE_REVISION_COLEGIATURAS			
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela) 
			AND keyx NOT IN (
				SELECT 	keyx 
				FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
				WHERE 	idu_tipo_registro=2 
					AND idu_usuario=iUsuario 
					AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			);
    
    raise notice '21 %', 'INSERT INTO MOV_BITACORA_COSTOS ';
    
    --INSERTAMOS EN LA BITACORA LOS COSTOS QUE FUERON ELIMINADOS 
	INSERT INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision, idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social,idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_periodo, prc_descuento, 
			idu_motivo, importe_concepto, porcentaje_tolerancia, fec_pENDiente, fec_revision, idu_usuario, opc_frecuente)
	SELECT  idu_revision,iMotivoRevision,10,iEstado, iMunicipio, idu_escuela, sEscuela, sRfc, sClaveSep, sRazonSocial, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto,0,dfec_captura,now(), iUsuario,0
	FROM 	HIS_DETALLE_REVISION_COLEGIATURAS			
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela) 
			AND keyx NOT IN (
			SELECT 	keyx 
			FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
			WHERE 	idu_tipo_registro=2 
				AND idu_usuario=iUsuario 
				AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
		 );
    
    raise notice '22 %', 'INSERT INTO MOV_BITACORA_COSTOS';
    
    --ELIMINAR LAS REVISIONES QUE ESTABAN EN LA HIS Y NO SE ENCUENTRAN EN LA STMP
	DELETE 	FROM HIS_DETALLE_REVISION_COLEGIATURAS 
	WHERE 	idu_escuela in (SELECT idescuela FROM tmpEscuela) 
			AND keyx not in (
			SELECT  keyx
			FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 
			WHERE 	idu_tipo_registro=2 
					AND idu_usuario=iUsuario
					AND idu_escuela in (SELECT idescuela FROM tmpEscuela)
			);	
	
	raise notice '23 %', 'DELETE FROM HIS_DETALLE_REVISION_COLEGIATURAS';
	
    DELETE FROM STMP_REVISION_COLEGIATURAS WHERE idu_usuario=iUsuario AND idu_escuela in (SELECT idescuela FROM tmpEscuela);
    DELETE FROM STMP_DETALLE_REVISION_COLEGIATURAS WHERE idu_usuario=iUsuario AND idu_escuela in (SELECT idescuela FROM tmpEscuela);

	--CONCLUIR
	IF (iOpcion=2) then 
		
		FechaInicioConclusion:=(SELECT CURRENT_DATE - INTERVAL '15 day');
        
		raise notice '24 %', 'FechaInicioConclusion : ' || FechaInicioConclusion::varchar;
        
		IF (exists (SELECT idu_escuela FROM MOV_BITACORA_COSTOS WHERE idu_escuela in (SELECT idEscuela FROM tmpEscuela))) THEN 
		    raise notice '25 %', 'exists : SELECT idu_escuela FROM MOV_BITACORA_COSTOS WHERE idu_escuela in (SELECT idEscuela FROM tmpEscuela)';
		    
			UPDATE MOV_BITACORA_COSTOS set fec_conclusion=now() WHERE idu_escuela in (SELECT idEscuela FROM tmpEscuela);
			raise notice '26 %', 'UPDATE MOV_BITACORA_COSTOS';
		    
			UPDATE 	MOV_REVISION_COLEGIATURAS set fec_conclusion = now()
					, idu_estatus_revision=2 
			FROM 	tmpEscuela esc
			WHERE 	esc.idescuela = MOV_REVISION_COLEGIATURAS.idu_escuela;
		    
		    raise notice '27 %', 'UPDATE MOV_REVISION_COLEGIATURAS';
		    
		    IF (SELECT count(idu_escuela) FROM MOV_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idEscuela FROM tmpEscuela) AND fec_conclusion>=FechaInicioConclusion) > 3 then

				UPDATE 	MOV_BITACORA_COSTOS set opc_frecuente=1
				WHERE 	idu_escuela in (SELECT idEscuela FROM tmpEscuela);
			
			raise notice '28 %', 'UPDATE MOV_REVISION_COLEGIATURAS';
		    END IF;			
		    
		else	
			INSERT INTO MOV_BITACORA_COSTOS (idu_revision,idu_motivo_revision,idu_tipo_revision,idu_estado, idu_municipio,idu_escuela, nom_escuela, rfc, clave_sep, razon_social, fec_revision, fec_conclusion,idu_usuario)
			VALUES (irevision, imotivorevision, 6, iestado, imunicipio, iescuela, sescuela, srfc, sclavesep,srazonsocial, NOW(),NOW(), iusuario);

			raise notice '29 %', 'INSERT INTO MOV_BITACORA_COSTOS';

			UPDATE 	MOV_BITACORA_COSTOS SET idu_escolaridad=B.idu_escolaridad, fec_pendiente=B.fec_captura
			FROM	CAT_ESCUELAS_COLEGIATURAS B
			WHERE	MOV_BITACORA_COSTOS.idu_escuela=B.idu_escuela
					AND MOV_BITACORA_COSTOS.idu_revision=irevision;

			raise notice '30 %', 'UPDATE MOV_BITACORA_COSTOS';
		    
			/*UPDATE 	MOV_REVISION_COLEGIATURAS set fec_conclusion=now()
				, idu_estatus_revision=3
			FROM 	tmpEscuela esc
			WHERE 	esc.idescuela = MOV_REVISION_COLEGIATURAS.idu_escuela;*/

			raise notice '31 %', 'UPDATE MOV_REVISION_COLEGIATURAS';
		    
		    ---NUEVO
		    IF (SELECT count(idu_escuela) FROM MOV_REVISION_COLEGIATURAS WHERE idu_escuela in (SELECT idEscuela FROM tmpEscuela) AND fec_conclusion>=FechaInicioConclusion) > 3 then
				
				UPDATE 	MOV_BITACORA_COSTOS set opc_frecuente=1
				WHERE 	idu_escuela in (SELECT idEscuela FROM tmpEscuela); 
				
				raise notice '32 %', 'UPDATE MOV_BITACORA_COSTOS';
		    END IF;
		    
		END IF;
		
		UPDATE 	MOV_REVISION_COLEGIATURAS set fec_conclusion=now(), idu_estatus_revision=3
		FROM 	tmpEscuela esc
		WHERE 	esc.idescuela = MOV_REVISION_COLEGIATURAS.idu_escuela;
        
        INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Conclusión grabada con éxito') ;
    --REVISAR    
    else
        INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Revisión grabada con éxito') ;
    END IF;

	--RETORNA VALOR DE UNA CONSULTA
	FOR valor IN (SELECT estado, mensaje FROM tmpEstado)
	LOOP
		iiEstado:=valor.estado;
		sMensaje:=valor.mensaje;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_revision_colegiaturas(integer, integer, character varying, integer, integer, character varying, character varying, integer, integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_revision_colegiaturas(integer, integer, character varying, integer, integer, character varying, character varying, integer, integer, integer, character varying, integer) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_revision_colegiaturas(integer, integer, character varying, integer, integer, character varying, character varying, integer, integer, integer, character varying, integer) IS 'La función obtiene un listado de beneficiarios con estudios configurados por el colaborador.';