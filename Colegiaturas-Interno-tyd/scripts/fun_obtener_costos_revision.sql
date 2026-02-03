--DROP FUNCTION IF EXISTS fun_obtener_costos_revision(integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_costos_revision(IN ipage integer, IN ilimit integer, IN iconexion integer, IN iescuela integer, IN iopcion integer, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT scicloescolar character varying, OUT snomescolaridad character varying, OUT snomcarrera character varying, OUT stipopago character varying, OUT iimporteconcepto numeric, OUT dfecharevision character, OUT itiporegistro smallint, OUT iidu_revision integer, OUT iidu_escuela integer, OUT iidu_ciclo_escolar integer, OUT iidu_escolaridad integer, OUT iidu_carrera integer, OUT iidu_tipo_pago integer, OUT iidu_usuario_registro integer, OUT ikeyx integer)
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
	sRfc varchar(20);

BEGIN
	--CODIGO
	
	--TABLA TEMPORAL
	CREATE TEMP TABLE tmpDatos(
		CicloEscolar VARCHAR(30), 
		NomEscolaridad VARCHAR(30), 
		NomCarrera VARCHAR(100), 
		TipoPago VARCHAR(20),
		ImporteConcepto NUMERIC, 
		FechaRevision DATE, 
		TipoRegistro SMALLINT, 		
		idu_revision INTEGER NOT NULL ,
		idu_escuela INTEGER NOT NULL ,
		idu_ciclo_escolar INTEGER NOT NULL ,
		idu_escolaridad INTEGER NOT NULL ,
		idu_carrera INTEGER NOT NULL DEFAULT 0,
		idu_tipo_pago INTEGER NOT NULL ,
		idu_usuario_registro INTEGER NOT NULL DEFAULT 0,
		keyx INTEGER NOT NULL ,
		Conexion INTEGER NOT NULL
	) ON COMMIT DROP;

	
	--ESCUELAS	
	CREATE TEMP TABLE tmpEscuela(
		idEscuela integer not null,
		idEstado  integer not null default 0,
		idMunicipio integer not null default 0,
		idLocalidad integer not null default 0
	) ON COMMIT DROP;

	--RFC
	sRfc:=(select rfc_clave_sep from CAT_ESCUELAS_COLEGIATURAS where idu_escuela=iescuela);
	
	--ESCUELAS	
	insert 	into tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
	select 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	idu_escuela=iescuela;
		--rfc_clave_Sep=sRfc;
		
	--ESCUELA DE LA MISMA LOCALIDAD CON DIFERENTE ESCOLARIDAD
	insert 	into tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
	select 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	rfc_clave_Sep=sRfc
		and idu_estado= (select idEstado from tmpEscuela)
		and idu_municipio= (select idMunicipio from tmpEscuela)
		and idu_localidad= (select idLocalidad from tmpEscuela)
		and idu_escuela!=iescuela;

	IF (iOpcion=0) then
		--BORRAR TEMPORAL
		delete from stmp_revision_colegiaturas where idu_usuario=iconexion;
		delete from STMP_DETALLE_REVISION_COLEGIATURAS where idu_usuario=iconexion AND prc_descuento=0;
		

		delete 	from stmp_detalle_revision_colegiaturas 
		where 	idu_escuela in (select idescuela from tmpEscuela)
			--idu_escuela=iescuela
			and idu_usuario=iconexion AND prc_descuento=0; --eliminar los costos
	
		--MOV  REVISION
		INSERT 	INTO stmp_revision_colegiaturas (idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision, idu_usuario)
		SELECT 	idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision, iconexion
		FROM 	MOV_REVISION_COLEGIATURAS
		where 	idu_escuela in (select idescuela from tmpEscuela);
			--idu_escuela=iescuela;

		--MOV REVISION DETALLE
		INSERT  INTO stmp_detalle_revision_colegiaturas (importe_concepto, fec_registro, idu_tipo_registro, idu_motivo, idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, idu_usuario_registro, keyx, idu_usuario)
		SELECT  importe_concepto, fec_registro, 1, idu_motivo, idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, idu_usuario_registro, keyx,iconexion
		FROM	MOV_DETALLE_REVISION_COLEGIATURAS
		where 	idu_escuela in (select idescuela from tmpEscuela)
			--idu_escuela=iescuela
			and prc_descuento=0;

		--HIS REVISION
		INSERT  INTO stmp_revision_colegiaturas (idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision, idu_usuario)
		SELECT  idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision, iconexion
		FROM	HIS_REVISION_COLEGIATURAS
		where 	idu_escuela in (select idescuela from tmpEscuela); 
			--idu_escuela=iescuela;
			--and prc_descuento=0;

		--HIS REVISION DETALLE
		INSERT  INTO stmp_detalle_revision_colegiaturas (Prc_descuento, fec_registro, idu_tipo_registro, idu_motivo, idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, importe_concepto,idu_usuario_registro, keyx, idu_usuario)
		SELECT  prc_descuento, fec_registro, 2, idu_motivo, idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, importe_concepto, idu_usuario_registro, keyx,iconexion
		FROM	HIS_DETALLE_REVISION_COLEGIATURAS
		where 	idu_escuela in (select idescuela from tmpEscuela)
			--idu_escuela=iescuela
			and prc_descuento=0;
	end if;
	
	--TEMPORAL
	INSERT 	INTO tmpDatos (ImporteConcepto, FechaRevision,TipoRegistro, idu_revision,idu_escuela,idu_ciclo_escolar,idu_escolaridad,idu_carrera,idu_tipo_pago, idu_usuario_registro,keyx,Conexion)
	SELECT 	importe_concepto, fec_registro, idu_tipo_registro,  idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, idu_usuario_registro, keyx, idu_usuario
	from	stmp_detalle_revision_colegiaturas
	WHERE	idu_usuario=iconexion 
		AND idu_escuela in (select idescuela from tmpEscuela)
		--and idu_escuela=iescuela
		and prc_descuento=0;

	--CILCO ESCOLAR
	update	tmpDatos set CicloEscolar=B.des_ciclo_escolar
	from	CAT_CICLOS_ESCOLARES B
	where	tmpDatos.idu_ciclo_escolar=B.idu_ciclo_escolar;

	--ESCOLARIDADES
	update	tmpDatos set NomEscolaridad=B.nom_escolaridad
	FROM	CAT_ESCOLARIDADES B
	where 	tmpDatos.idu_escolaridad=B.idu_escolaridad;

	--TIPO PAGO
	update	tmpDatos set TipoPago=B.des_tipo_pago
	FROM	CAT_TIPOS_PAGOS B
	where 	tmpDatos.idu_tipo_pago=B.idu_tipo_pago;

	--CARRERA
	update	tmpDatos set NomCarrera=B.nom_carrera
	FROM	CAT_CARRERAS B
	where 	tmpDatos.idu_carrera=B.idu_carrera;

	-- VARIABLES DE PAGINADO

	if iPage = -1 then
		iPage := null;
	end if;
	if iLimit = -1 then
		iLimit := null;
	end if;

	iRecords := (SELECT COUNT(*) FROM tmpDatos);

	sColumns := 'CicloEscolar, NomEscolaridad, NomCarrera, TipoPago, ImporteConcepto, FechaRevision, TipoRegistro, idu_revision, idu_escuela, 
	idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago,idu_usuario_registro, keyx, Conexion';

	if (iPage is not null and iLimit is not null) then
		iStart := (iLimit * iPage) - iLimit + 1;
		iTotalPages := ceiling(iRecords / (iLimit * 1.0));
		
		--
		sQuery := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		, ' || CAST(iPage AS VARCHAR) || ' AS page
		, ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		, id
		, ' || sColumns || '
		from (
		SELECT ROW_NUMBER() OVER (ORDER BY idu_ciclo_escolar DESC) AS id, ' || sColumns || '
		FROM tmpDatos
		) AS t
		WHERE  t.Conexion= ' || iConexion || ' and t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
	else 
		sQuery := 'SELECT ' || iRecords::VARCHAR || ' AS records, 0 as page, 0 as pages, 0 as id, ' || sColumns || ' FROM tmpDatos ';
	end if;
		
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN EXECUTE (sQuery)
		LOOP
			records:=valor.records;
			page:=valor.page;
			pages:=valor.pages;
			id:=valor.id;			
			sCicloEscolar:=valor.CicloEscolar;
			sNomEscolaridad:=valor.NomEscolaridad;
			sNomCarrera:=valor.NomCarrera;
			sTipoPago:=valor.TipoPago;
			iImporteConcepto:=valor.ImporteConcepto;
			dFechaRevision:=valor.FechaRevision;
			iTipoRegistro:=valor.TipoRegistro;
			iidu_revision:=valor.idu_revision; 
			iidu_escuela:=valor.idu_escuela; 
			iidu_ciclo_escolar:=valor.idu_ciclo_escolar;
			iidu_escolaridad:=valor.idu_escolaridad;
			iidu_carrera:=valor.idu_carrera;
			iidu_tipo_pago:=valor.idu_tipo_pago;
			iidu_usuario_registro:=valor.idu_usuario_registro;
			ikeyx:=valor.keyx;			
		RETURN NEXT;
		END LOOP;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_costos_revision(integer, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_costos_revision(integer, integer, integer, integer, integer) TO syspersonal;
COMMENT ON FUNCTION fun_obtener_costos_revision(integer, integer, integer, integer, integer) IS 'La función obtiene los costos de revision de las escuelas.';