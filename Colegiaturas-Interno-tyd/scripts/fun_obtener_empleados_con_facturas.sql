DROP FUNCTION IF EXISTS fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying);
DROP TYPE IF EXISTS type_obtener_empleados_con_facturas;

CREATE TYPE type_obtener_empleados_con_facturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    idempleado integer,
    nombreempleado character varying(50),
    idpuesto integer,
    puesto character varying(30),
    idcentro integer,
    centro character varying(30),
    idregion integer,
    region character varying(20),
    idciudad integer,
    ciudad character varying(20),
    idempleadodejefeinmediato integer,
    jefeinmediato character varying(50),
    idstatus integer,
    numerodefacturasenproceso integer,
    idtipodocumento integer,
    nomtipodocumento character varying(30),
    fecprimerfecha date,
    totalgralfacturas integer,
    opc_blog_aclaracion integer,
    opc_blog_revision integer);

CREATE OR REPLACE FUNCTION fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_obtener_empleados_con_facturas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 15/11/2016
	Número empleado                : 97695068
	Nombre del empleado            : Héctor Medina
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.2.89
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Blog de aclaraciones
	Ejemplo                        :
-------------------------------------------------------------------------------------
	No. peticion APS		: 16559.1
	Fecha				: 14/05/2018
	Número empleado			: 98439677
	Nombre empleado			: Rafael Ramos Gutiérrez
	Descripcion del cambio		: Se muestra el tipo de documento de la factura EJ: (1 - Ingreso
											     2 - Nota de credito
											     3 - Complemento de pago
											     4 - Especial)
					 *Se agrego una validación para que no se muestren las facturas de externos registradas
					 *Se agrego linea de validacion para busqueda por fechas, y se cambio el campo a comparar(de fec_factura a fec_registro)
	28/06/2018
			Se cambio el valor del estatus 5 a 6, ya que ahora el 6 es PAGADA(ANTERIORMENTE era 5)
	Ejemplo:
		SELECT
			records, page, pages, id,
			idempleado, nombreempleado, idpuesto,
			puesto, idcentro, centro, idregion, region, idciudad,
			ciudad, idempleadodejefeinmediato,
			jefeinmediato, idstatus, numerodefacturasenproceso,
			idtipodocumento, nomtipodocumento, fecprimerfecha,totalgralfacturas, opc_blog_aclaracion, opc_blog_revision
		FROM fun_obtener_empleados_con_facturas(
			0,
			0,
			0,
			4,
			'20190601',
			'20190729',
			0,
			-1,
			1,
			'idempleado',
			'asc',
			'IdEmpleado, NombreEmpleado, IdPuesto, Puesto, IdCentro, Centro, IdRegion, Region, IdCiudad, Ciudad
		, IdEmpleadoDeJefeInmediato, JefeInmediato, IdStatus, NumeroDeFacturasEnProceso, IdTipoDocumento
		, TipoDocumento, FecPrimerFactura, TotalGralFacturas, opc_blog_aclaracion, opc_blog_revision, tipo ')
	*/

	/* PARAMETROS DE FILTRADO */
	iEmpleado ALIAS FOR $1;
	iRegion ALIAS FOR $2;
	iCiudad ALIAS FOR $3;
	iEstatus ALIAS FOR $4;
	dFechaInicial ALIAS FOR $5;
	dFechaFinal ALIAS FOR $6;
	iTipoNomina ALIAS FOR $7;
	
	/* PARAMETROS DE PAGINADO */
	iRowsPerPage ALIAS FOR $8;
	iCurrentPage ALIAS FOR $9;
	sOrderColumn ALIAS FOR $10;
	sOrderType ALIAS FOR $11;
	sColumns ALIAS FOR $12;
	
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sConsulta VARCHAR(3000);

	TotalMovimientos integer;
	TotalGeneralFacturas integer;
		
	returnrec type_obtener_empleados_con_facturas;
BEGIN	
	/* TABLAS PARTICIPANTES */
	-- select * from mov_facturas_colegiaturas /* idu_empleado */
	-- select * from sapcatalogoempleados limit(10) /* numempn - centron - pueston */ select * from sapcatalogoPuestos /* Para sacar el puesto del patron y el empleado. */
	-- select * from sapcatalogocentros limit(10) /* centron - ciudadn */
	-- select * from sapcatalogociudades /* ciudadn - regionzona */
	-- select * from sapregiones /* numero */

	IF iRowsPerPage = -1 THEN
	iRowsPerPage := NULL;
	END IF;
	if iCurrentPage = -1 THEN
	iCurrentPage := NULL;
	END IF;
	
	CREATE TEMPORARY TABLE tmp_empleados_primera_fecha (
		IdEmpleado INTEGER,
		FecPrimerFactura DATE,
		iFactura INTEGER)ON COMMIT DROP;
	
	CREATE TEMPORARY TABLE tmp_facturas (
		tipo integer,
		idFactura integer,
		IdEmpleado integer,
		NombreEmpleado character varying(50),
		IdPuesto integer,
		Puesto character varying(30),
		IdCentro integer,
		Centro character varying(30),
		IdRegion integer,
		Region character varying(20),
		IdCiudad integer,
		Ciudad character varying(20),
		IdEmpleadoDeJefeInmediato INTEGER,
		JefeInmediato character varying(50),
		IdStatus integer,
		IdTipoDocumento integer,
		TipoDocumento character varying(30),
		TipoNomina integer,
		FecMarcoEstatus DATE,
		FecPrimerFactura DATE,
		TotalGralFacturas integer,
		opc_blog_aclaracion integer,
		opc_blog_revision integer
	)ON COMMIT DROP;

	CREATE TEMPORARY TABLE tmp_empleados_con_factura (

-- 	CREATE TABLE tmp_empleados_con_factura (
		tipo integer,
		IdEmpleado integer,
		NombreEmpleado character varying(50),
		IdPuesto integer,
		Puesto character varying(30),
		IdCentro integer,
		Centro character varying(30),
		IdRegion integer,
		Region character varying(20),
		IdCiudad integer,
		Ciudad character varying(20),
		IdEmpleadoDeJefeInmediato INTEGER,
		JefeInmediato character varying(50),
		IdStatus integer,
		NumeroDeFacturasEnProceso integer,
		IdTipoDocumento integer,
		TipoDocumento character varying(30),
		TotalFacturas integer,
		FecPrimerFactura DATE,
		TotalGralFacturas integer,
		Opc_blog_aclaracion integer,
		Opc_blog_revision integer
	)ON COMMIT DROP;
-- 	);
	


	create local temp table tmp_EmpleadosCancelados
	(
		numemp integer
	)on commit drop; 

	insert	into tmp_EmpleadosCancelados (numemp)
	select 	A.numempn 
	from 	SAPCATALOGOEMPLEADOS A
	inner	join MOV_FACTURAS_COLEGIATURAS B on A.numempn=B.idu_empleado
	where 	A.cancelado='1' and B.idu_estatus!=3;

	--RECHAZADO POR SISTEMA
	update	MOV_FACTURAS_COLEGIATURAS 
	set	idu_estatus=3
		, des_observaciones = 'RECHAZADO POR SISTEMA POR BAJA DE COLABORADOR'
		, emp_marco_estatus = 0
		, fec_marco_estatus = now()
	from	tmp_EmpleadosCancelados B
	where	MOV_FACTURAS_COLEGIATURAS.idu_empleado=B.numemp;
	
	
	
	sConsulta := 'INSERT INTO tmp_facturas(tipo, idFactura, IdEmpleado, NombreEmpleado, IdPuesto, IdCentro, IdStatus, IdTipoDocumento, FecMarcoEstatus)
			SELECT	1 as tipo,
				F.idfactura, 
				F.idu_empleado,
				TRIM(E.nombre)||'' ''||TRIM(E.apellidopaterno)||'' ''||TRIM(E.apellidomaterno),
				E.pueston,
				E.centron,
				case when F.idu_estatus=6 then 2 else F.idu_estatus end,
				F.idu_tipo_documento,
				case when F.idu_estatus < 1  then F.fec_registro::DATE ELSE F.fec_marco_estatus::DATE END
			FROM mov_facturas_colegiaturas F INNER JOIN sapcatalogoempleados E ON F.idu_empleado = E.numempn
			WHERE
				F.idu_beneficiario_externo = 0 ';
	if iEstatus < 1 then
		sConsulta := sConsulta || '
				and (E.numempn = ' || iEmpleado::VARCHAR || '::INT AND ' || iEmpleado::VARCHAR || '::INT != 0) 
					and F.fec_registro::date between ''' || dFechaInicial::VARCHAR ||'''::date and ''' || dFechaFinal::VARCHAR ||'''::date
				OR (E.numempn = E.numempn AND ' || iEmpleado::VARCHAR || '::INT = 0) 
					AND F.fec_registro::DATE between ''' || dFechaInicial::VARCHAR ||'''::date and ''' || dFechaFinal::VARCHAR ||'''::date ';
	else
		sConsulta := sConsulta || '
				and (E.numempn = ' || iEmpleado::VARCHAR || '::INT AND ' || iEmpleado::VARCHAR || '::INT != 0) 
					and F.fec_marco_estatus::date between ''' || dFechaInicial::VARCHAR ||'''::date and ''' || dFechaFinal::VARCHAR ||'''::date
				OR (E.numempn = E.numempn AND ' || iEmpleado::VARCHAR || '::INT = 0) 
					AND F.fec_marco_estatus::DATE between ''' || dFechaInicial::VARCHAR ||'''::date and ''' || dFechaFinal::VARCHAR ||'''::date ';
	end if;

	--RAISE NOTICE 'notice %', sConsulta;
	--exit;
	
	execute (sConsulta);
	
	insert into tmp_empleados_primera_fecha (IdEmpleado, FecPrimerFactura,iFactura)
		SELECT tmp.IdEmpleado
			, min(tmp.FecMarcoEstatus)
			, tmp.idFactura
		from tmp_facturas as tmp
		group by tmp.idEmpleado,tmp.idFactura;
	
	update tmp_facturas set FecPrimerFactura = tmp.FecPrimerFactura
	from tmp_empleados_primera_fecha as tmp
	where tmp.IdEmpleado = tmp_facturas.IdEmpleado;
	
	--if (iEstatus in (5 , 3)) then
		INSERT INTO tmp_facturas(tipo, idFactura, IdEmpleado, NombreEmpleado, IdPuesto, IdCentro, IdStatus, IdTipoDocumento, FecMarcoEstatus)
		SELECT	1 as tipo,
			F.idfactura,
			F.idu_empleado,
			TRIM(E.nombre)||' '||TRIM(E.apellidopaterno)||' '||TRIM(E.apellidomaterno),
			E.pueston,
			E.centron, F.idu_estatus,
			F.idu_tipo_documento,
			F.fec_marco_estatus as FecMarcoEstatus
-- 			case when F.idu_estatus < 1  then F.fec_registro::DATE ELSE F.fec_marco_estatus::DATE END
		FROM his_facturas_colegiaturas F INNER JOIN sapcatalogoempleados E ON F.idu_empleado = E.numempn
		WHERE
			idu_beneficiario_externo = 0 and
			(E.numempn = iEmpleado AND iEmpleado != 0) and F.fec_marco_estatus::date between dFechaInicial::date and dFechaFinal::date
			OR (E.numempn = E.numempn AND iEmpleado = 0) AND F.fec_marco_estatus::DATE between dFechaInicial::Date AND dFechaFinal::date;
	
	--end if;
	-- Actualizar el tipo de nomina del colaborador
	update	tmp_facturas
	set	TipoNomina = A.tiponomina::INTEGER
	from	sapcatalogoempleados as A
	where	tmp_facturas.IdEmpleado = A.numempn;

	-- Agregar los PUESTOS a la tabla temporal.	
	UPDATE tmp_facturas SET puesto = TRIM(p.nombre)
	from sapcatalogoPuestos p
	WHERE (CASE WHEN p.numero = '' THEN '0' ELSE p.numero END)::INTEGER = tmp_facturas.idpuesto;

	-- Agregar los campos CENTRO, CIUDAD Y REGION a la tabla temporal.
	UPDATE tmp_facturas
	SET 
		Centro = cn.nombrecentro,
		IdCiudad = cd.ciudadn,
		Ciudad = TRIM(cd.nombreciudad),
		IdRegion = (CASE WHEN cd.regionzona = '' THEN '0' ELSE cd.regionzona END)::INTEGER
	FROM sapcatalogocentros cn INNER JOIN sapcatalogociudades cd
	ON cn.ciudadn = cd.ciudadn
	WHERE cn.centron = tmp_facturas.IdCentro;

	-- Agregar los campos de jefe inmmediato
	UPDATE tmp_facturas
	SET IdEmpleadoDeJefeInmediato = (CASE WHEN c.numerogerente = '' THEN '0' ELSE c.numerogerente END)::INTEGER,
		jefeinmediato = TRIM(e.nombre)||' '||TRIM(e.apellidopaterno)||' '||TRIM(e.apellidomaterno)
	FROM sapcatalogocentros c INNER JOIN sapcatalogoempleados e ON (CASE WHEN c.numerogerente = '' THEN '0' ELSE c.numerogerente END)::INTEGER = e.numempn
	WHERE c.centron = tmp_facturas.IdCentro;

	-- Agregar Región
	UPDATE tmp_facturas SET region = TRIM(r.nombre)
	FROM sapregiones r
	WHERE r.numero = tmp_facturas.IdRegion;

	-- Agregar Descripcion del Tipo de documento que es la factura
	update	tmp_facturas
	set	TipoDocumento = TRIM(D.nom_tipo_documento)
	from	cat_tipo_documento D
	where	D.idu_tipo_documento = tmp_facturas.IdTipoDocumento;

	-- Aplicar los filtros a la tabla temporal de Facturas.
	DELETE FROM tmp_facturas WHERE IdStatus NOT IN (iEstatus);
	IF iRegion <> 0 THEN
		DELETE FROM tmp_facturas WHERE IdRegion NOT IN (iRegion);
	END IF;
	IF iCiudad <> 0 THEN
		DELETE FROM tmp_facturas WHERE IdCiudad NOT IN (iCiudad);
	END IF;
	if iTipoNomina <> 0 then
		delete from tmp_facturas where TipoNomina not in (iTipoNomina);
	end if;

	--if exists ( SELECT BR.id_factura FROM mov_blog_revision AS BR where  BR.id_factura in (SELECT tmp.idFactura from tmp_facturas AS tmp) and BR.opc_leido = 0  ) THEN
	IF (iEstatus = 4) THEN
		update	tmp_facturas AS tmp
		set	opc_blog_aclaracion = 1
		from	mov_blog_aclaraciones AS ba
		--where	ba.id_factura in (SELECT tmp.idFactura FROM tmp_facturas AS tmp)
		where	tmp.idFactura IN (SELECT  ba.id_factura FROM mov_blog_aclaraciones AS ba)
			/*AND tmp.IdEmpleado = ba.idu_empleado_destino
			AND ba.opc_leido = 1*/;
		--end if;
	END IF;

	IF ( iEstatus = 5 ) THEN
		update	tmp_facturas AS tmp
		set	opc_blog_revision = 1
		FROM	mov_blog_revision as br
		where	tmp.idFactura IN (SELECT br.id_factura FROM mov_blog_revision AS br)
			/*AND tmp.IdEmpleado = br.idu_empleado_destino
			AND br.opc_leido = 1*/;
	END IF;

	TotalMovimientos := (SELECT COUNT(*) FROM tmp_facturas);
	if (TotalMovimientos > 0) then
		INSERT INTO tmp_empleados_con_factura (
				tipo
				, IdEmpleado
				, NombreEmpleado
				, IdPuesto
				, Puesto
				, IdCentro
				, Centro
				, IdRegion
				, Region
				, IdCiudad
				, Ciudad
				, IdEmpleadoDeJefeInmediato
				, JefeInmediato
				, IdStatus
				, NumeroDeFacturasEnProceso
				, IdTipoDocumento
				, TipoDocumento
				, FecPrimerFactura
				, opc_blog_aclaracion
				, opc_blog_revision)
		SELECT  tipo
			, IdEmpleado
			, NombreEmpleado
			, IdPuesto
			, Puesto
			, IdCentro
			, Centro
			, IdRegion
			, Region
			, IdCiudad
			, Ciudad
			, IdEmpleadoDeJefeInmediato
			, JefeInmediato
			, IdStatus
			, Count(idEmpleado)
			, IdTipoDocumento
			, TipoDocumento
			, FecPrimerFactura
			, opc_blog_aclaracion
			, opc_blog_revision
		FROM tmp_facturas
		GROUP BY tipo,IdEmpleado, NombreEmpleado, IdPuesto, Puesto, IdCentro, Centro, IdRegion, Region
			, IdCiudad, Ciudad, IdEmpleadoDeJefeInmediato, JefeInmediato, IdStatus
			, IdTipoDocumento, TipoDocumento, FecPrimerFactura, opc_blog_aclaracion, opc_blog_revision;

		TotalGeneralFacturas := (select sum(NumeroDeFacturasEnProceso) from tmp_empleados_con_factura);
		
		insert into tmp_empleados_con_factura (tipo) values (2)	;

		update	tmp_empleados_con_factura
		set	TotalGralFacturas = TotalGeneralFacturas
		where	tipo = 2;
		
	end if;

		sOrderColumn:= 'tipo, FecPrimerFactura';
		sOrderType := 'ASC';
		
	iRecords := (SELECT COUNT(*) FROM tmp_empleados_con_factura);
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) THEN
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM tmp_empleados_con_factura);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
		sConsulta := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_empleados_con_factura
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ' as records,0 as page,0 as pages,0 as id,' || sColumns || ' FROM tmp_empleados_con_factura ';
	END if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	RAISE NOTICE 'notice %', sConsulta;

	FOR returnrec in execute sConsulta loop
		RETURN NEXT returnrec;
	end loop;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying) TO sysetl;
COMMENT ON FUNCTION fun_obtener_empleados_con_facturas(integer, integer, integer, integer, date, date, integer, integer, integer, character varying, character varying, character varying) IS 'La funcion obtiene la informacion del concentrado de facturas de los colaboradores.';