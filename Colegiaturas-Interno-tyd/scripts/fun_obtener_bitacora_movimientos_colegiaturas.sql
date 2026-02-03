DROP FUNCTION IF EXISTS fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(
IN dfechainicial date
, IN dfechafinal date
, IN idempleado integer
, IN idtipomovimiento integer
, IN idregion integer
, IN idciudad integer
, IN idcentro integer
, IN irowsperpage integer
, IN icurrentpage integer
, IN sordercolumn character varying
, IN sordertype character varying
, IN scolumns character varying
, OUT records integer
, OUT page integer
, OUT pages integer
, OUT id integer
, OUT fec_registro timestamp without time zone
, OUT idu_tipo_movimiento integer
, OUT nom_tipo_movimiento character varying
, OUT folio_factura character varying
, OUT importe_original numeric
, OUT importe_pagado numeric
, OUT opc_bloqueado_estatus character varying
, OUT idu_empleado integer
, OUT nombre_empleado character varying
, OUT numero_puesto integer
, OUT nombre_puesto character varying
, OUT fec_alta timestamp without time zone
, OUT idu_centro integer
, OUT nombre_centro character varying
, OUT idu_ciudad integer
, OUT nombre_ciudad character varying
, OUT idu_region integer
, OUT nombre_region character varying
, OUT justificacion character varying
, OUT estatus_empleado character varying
, OUT idu_usuario integer
, OUT nom_usuario character varying
, OUT idu_puesto_usuario integer
, OUT nom_puesto_usuario character varying
, OUT idu_centro_usuario integer
, OUT nom_centro_usuario character varying)
  RETURNS SETOF record AS
$BODY$
declare
	/*=====================================================================
		No. Peticion:		16559.1
		Fecha:			16/08/2018
		Colaborador:		98439677 Rafael Ramos
		Sistema:		Colegiaturas
		Modulo:			Bitacora de Movimientos
		Ejemplo:
			SELECT * FROM fun_obtener_bitacora_movimientos_colegiaturas(
				'20080101'
				, '20180820'
				, 0
				, 1
				, 0
				, 0
				, 0
				, 10
				, 1
				, 'folio_factura'
				, 'desc'
				, 'fec_registro, idu_tipo_movimiento, nom_tipo_movimiento, folio_factura, importe_original
					, importe_pagado, opc_bloqueado_estatus, idu_empleado, nombre_empleado, numero_puesto, nombre_puesto
					, fec_alta, idu_centro, nombre_centro, idu_ciudad, nombre_ciudad, idu_region, nombre_region, justificacion
					, estatus_empleado, idu_usuario, nom_usuario, idu_puesto_usuario, nom_puesto_usuario, idu_centro_usuario, nom_centro_usuario')
	=====================================================================*/
	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;
	
	valor record;
	sQuery text;
	sConsulta varchar(3000);
begin

	/*Control de las variables de paginado*/
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	create temporary table tmp_consulta(
		fec_registro timestamp without time zone
		, idu_tipo_movimiento integer
		, nom_tipo_movimiento character varying
		, folio_factura character varying
		, importe_original numeric(12,2)
		, importe_pagado numeric(12,2)
		, opc_bloqueado_estatus character varying
		, idu_empleado integer
		, nombre_empleado character varying
		, numero_puesto integer
		, nombre_puesto character varying
		, fec_alta timestamp without time zone
		, idu_centro integer
		, nombre_centro character varying
		, idu_ciudad integer
		, nombre_ciudad character varying
		, idu_region integer
		, nombre_region character varying
		, justificacion character varying
		, estatus_empleado character varying
		, idu_usuario integer
		, nom_usuario character varying
		, idu_puesto_usuario integer
		, nom_puesto_usuario character varying
		, idu_centro_usuario integer
		, nom_centro_usuario character varying
	)on commit drop;
	create temporary table tmp_resultado(
		fec_registro timestamp without time zone
		, idu_tipo_movimiento integer
		, nom_tipo_movimiento character varying
		, folio_factura character varying
		, importe_original numeric(12,2)
		, importe_pagado numeric(12,2)
		, opc_bloqueado_estatus character varying
		, idu_empleado integer
		, nombre_empleado character varying
		, numero_puesto integer
		, nombre_puesto character varying
		, fec_alta timestamp without time zone
		, idu_centro integer
		, nombre_centro character varying
		, idu_ciudad integer
		, nombre_ciudad character varying
		, idu_region integer
		, nombre_region character varying	
		, justificacion character varying
		, estatus_empleado character varying
		, idu_usuario integer
		, nom_usuario character varying
		, idu_puesto_usuario integer
		, nom_puesto_usuario character varying
		, idu_centro_usuario integer
		, nom_centro_usuario character varying
	)on commit drop;
	if (idTipoMovimiento = 1)then --//=============// MOVIMIENTO: "EDITAR IMPORTE A PAGAR" //========//
		sQuery := 'INSERT INTO tmp_consulta(fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, folio_factura
						, importe_original
						, importe_pagado
						, idu_empleado
						, idu_centro
						, justificacion
						, idu_usuario)
				SELECT	b.fec_registro
					, b.idu_tipo_movimiento
					, (SELECT t.nom_tipo_movimiento FROM cat_tipos_movimientos_bitacora t WHERE t.idu_tipo_movimiento = ' || idTipoMovimiento || ')
					, (CASE WHEN EXISTS (SELECT idu_factura FROM mov_facturas_colegiaturas WHERE idfactura = m.idfactura) THEN m.fol_fiscal ELSE h.fol_fiscal END)
					, b.importe_original
					, b.importe_pagado
					, (CASE WHEN EXISTS (SELECT idfactura FROM mov_facturas_colegiaturas WHERE idfactura = m.idfactura) THEN m.idu_empleado ELSE h.idu_empleado END)
					, (CASE WHEN EXISTS (SELECT idfactura FROM mov_facturas_colegiaturas WHERE idfactura = m.idfactura) THEN m.idu_centro ELSE h.idu_centro END)
					, UPPER(b.des_justificacion)
					, b.idu_empleado_registro
				FROM	mov_bitacora_movimientos_colegiaturas b
					LEFT JOIN mov_facturas_colegiaturas m ON m.idfactura = b.idu_factura
					LEFT JOIN his_facturas_colegiaturas h ON h.idfactura = b.idu_factura
				WHERE	b.idu_tipo_movimiento = ' || idTipoMovimiento || '
					AND b.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		raise notice '%', sQuery;
		execute sQuery;
	elsif (idTipoMovimiento = 2)then --//=============// MOVIMIENTO: "COLABORADOR BLOQUEADO" //========//
		sQuery := 'INSERT INTO tmp_consulta (fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, idu_empleado
						, opc_bloqueado_estatus
						, justificacion
						, idu_usuario)
				SELECT	b.fec_registro
					, b.idu_tipo_movimiento
					, (SELECT t.nom_tipo_movimiento FROM cat_tipos_movimientos_bitacora t WHERE t.idu_tipo_movimiento = ' || idTipoMovimiento || ')
					, b.idu_empleado_bloqueado
					, (CASE WHEN b.opc_bloqueado = 1 THEN ''BLOQUEADO'' ELSE ''DESBLOQUEADO'' END)
					, UPPER(b.des_justificacion)
					, b.idu_empleado_registro
				FROM	mov_bitacora_movimientos_colegiaturas b
				WHERE	b.idu_tipo_movimiento = ' || idTipoMovimiento || '
					AND b.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		raise NOTICE '%', sQuery;
		execute sQuery;
	elsif (idTipoMovimiento = 4)then
		sQuery := 'INSERT INTO tmp_consulta(fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, idu_empleado
						, justificacion
						, idu_usuario)
				SELECT	b.fec_registro
					, b.idu_tipo_movimiento
					, (SELECT t.nom_tipo_movimiento FROM cat_tipos_movimientos_bitacora t WHERE t.idu_tipo_movimiento = ' || idTipoMovimiento || ')
					, b.idu_empleado_especial
					, UPPER(b.des_justificacion_especial)
					, b.idu_empleado_registro
				FROM	mov_bitacora_movimientos_colegiaturas b
				WHERE	b.idu_tipo_movimiento = ' || idTipoMovimiento || '
					AND b.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		raise NOTICE '%', sQuery;
		execute sQuery;
	elsif (idTipoMovimiento = 5)then
		sQuery := 'INSERT INTO tmp_consulta(fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, idu_empleado
						, justificacion
						, idu_usuario)
				SELECT	b.fec_registro
					, b.idu_tipo_movimiento
					, (SELECT t.nom_tipo_movimiento FROM cat_tipos_movimientos_bitacora t WHERE t.idu_tipo_movimiento = ' || idTipoMovimiento || ')
					, b.idu_empleado_especial
					, UPPER(b.des_justificacion_especial)
					, b.idu_empleado_registro
				FROM	mov_bitacora_movimientos_colegiaturas b
				WHERE	b.idu_tipo_movimiento = ' || idTipoMovimiento || '
					AND b.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		raise NOTICE '%', sQuery;
		execute sQuery;
	elsif (idTipoMovimiento = 7)then
		sQuery := 'INSERT INTO tmp_consulta(fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, idu_empleado
						, idu_usuario)
				SELECT	b.fec_registro
					, b.idu_tipo_movimiento
					, (SELECT t.nom_tipo_movimiento FROM cat_tipos_movimientos_bitacora t WHERE t.idu_tipo_movimiento = ' || idTipoMovimiento || ')
					, b.idu_empleado_especial
					, b.idu_empleado_registro
				FROM	mov_bitacora_movimientos_colegiaturas b
				WHERE	b.idu_tipo_movimiento = ' || idTipoMovimiento || '
					AND b.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		raise NOTICE '%', sQuery;
		execute sQuery;
	end if;

	if(idEmpleado != 0)then
		delete from tmp_consulta as tmp where tmp.idu_empleado not in (idEmpleado);
	end if;

	--AGREGAR DATOS DEL COLABORADOR
	update	tmp_consulta
	set	nombre_empleado = TRIM(A.nombre) || ' ' || trim(A.apellidopaterno) || ' ' || trim(A.apellidomaterno)
		, estatus_empleado  = (case when A.cancelado = '1' then 'BAJA' else 'ACTIVO' end)
		, numero_puesto = A.pueston
		, idu_centro = A.centron
		, fec_alta = A.fechaalta
	from	sapcatalogoempleados A
	where	tmp_consulta.idu_empleado = A.numempn;

	--AGREGAR DATOS DEL USUARIO
	update	tmp_consulta
	set	nom_usuario = trim(A.nombre) || ' ' || trim(A.apellidopaterno) || ' ' || trim(A.apellidomaterno)
		, idu_puesto_usuario = A.pueston
		, idu_centro_usuario = A.centron
	FROm	sapcatalogoempleados A
	where	tmp_consulta.idu_usuario = A.numempn;

	--NOMBRE DE PUESTO EMPLEADO
	update	tmp_consulta
	set	nombre_puesto = trim(UPPER(p.nombre))
	from	sapcatalogopuestos p
	where	tmp_consulta.numero_puesto = (p.numero)::integer;

	--NOMBRE DE PUESTO USUARIO
	update	tmp_consulta
	set	nom_puesto_usuario = trim(UPPER(p.nombre))
	from	sapcatalogopuestos p
	where	tmp_consulta.idu_puesto_usuario = (p.numero)::integer;

	--NOMBRE CENTRO DE EMPLEADO
	update	tmp_consulta
	set	nombre_centro = trim(UPPER(A.nombrecentro))
		, idu_ciudad = A.ciudadn
	from	sapcatalogocentros A
	where	tmp_consulta.idu_centro = A.centron;

	--NOMBRE CENTRO DE USUARIO
	update	tmp_consulta
	set	nom_centro_usuario = trim(UPPER(A.nombrecentro))
	from	sapcatalogocentros A
	where	tmp_consulta.idu_centro_usuario = A.centron;

	--NOMBRE DE CIUDAD Y el ID de La REGION DEL EMPLEADO
	update	tmp_consulta
	set	nombre_ciudad = trim(UPPER(A.nombreciudad))
		, idu_region = (case when A.regionzona = '' then '0' else A.regionzona end)::integer
	from	sapcatalogociudades A
	where	tmp_consulta.idu_ciudad = A.ciudadn;

	--NOMBRE DE LA REGION DEL EMPLEADO
	update	tmp_consulta
	set	nombre_region = trim(UPPER(A.nombre))
	from	sapregiones A
	where	tmp_consulta.idu_region = (A.numero)::integer;

	--APLICACION DE FILTROS DE REGION, CIUDAD Y CENTRO (DEL EMPLEADO)
	if(idRegion != 0) then
		delete from tmp_consulta as tmp where tmp.idu_region not in (idRegion);
	end if;
	if(idCiudad != 0) then
		delete from tmp_consulta as tmp where tmp.idu_ciudad not in (idCiudad);
	end if;
	if(idCentro != 0) then
		delete from tmp_consulta as tmp where tmp.idu_centro not in (idCentro);
	end if;


	--PASAR LOS DATOS DE LA TABLA DE CONSULTA A LA TABLA DE RESULTADO
	insert into tmp_resultado(fec_registro
		, idu_tipo_movimiento
		, nom_tipo_movimiento
		, folio_factura
		, importe_original
		, importe_pagado
		, opc_bloqueado_estatus
		, idu_empleado
		, nombre_empleado
		, numero_puesto
		, nombre_puesto
		, fec_alta
		, idu_centro
		, nombre_centro
		, idu_ciudad
		, nombre_ciudad
		, idu_region
		, nombre_region
		, justificacion
		, estatus_empleado
		, idu_usuario
		, nom_usuario
		, idu_puesto_usuario
		, nom_puesto_usuario
		, idu_centro_usuario
		, nom_centro_usuario)
	select	tmp.fec_registro
		, tmp.idu_tipo_movimiento
		, tmp.nom_tipo_movimiento
		, tmp.folio_factura
		, tmp.importe_original
		, tmp.importe_pagado
		, tmp.opc_bloqueado_estatus
		, tmp.idu_empleado
		, tmp.nombre_empleado
		, tmp.numero_puesto
		, tmp.nombre_puesto
		, tmp.fec_alta
		, tmp.idu_centro
		, tmp.nombre_centro
		, tmp.idu_ciudad
		, tmp.nombre_ciudad
		, tmp.idu_region
		, tmp.nombre_region
		, tmp.justificacion
		, tmp.estatus_empleado
		, tmp.idu_usuario
		, tmp.nom_usuario
		, tmp.idu_puesto_usuario
		, tmp.nom_puesto_usuario
		, tmp.idu_centro_usuario
		, tmp.nom_centro_usuario
	from	tmp_consulta as tmp
	order	by tmp.fec_registro desc;
/*===============================PAGINADO DE GRID==================================*/
	iRecords := (SELECT COUNT(*) from tmp_resultado);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (select COUNT(*) from tmp_resultado);
		iTotalPages := CEILING(iRecords / (iRowsPerPage * 1.0));
		sConsulta := '
				SELECT ' || cast(iRecords as varchar) || ' AS records
				     , ' || cast(iCurrentPage as varchar) || ' AS page
				     , ' || cast(iTotalPages as varchar) || ' AS pages
				     , id
				     , ' || sColumns || '
				FROM (
					SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM	tmp_resultado
					) AS t
				WHERE	t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := ' SELECT ' || iRecords::varchar || ' AS records, 0 AS page, 0 AS pages, 0 AS id,' || sColumns || ' FROM tmp_resultado ORDER BY ' || sOrderColumn || ' ' || sOrderType || '';
	end if;

	raise NOTICE '%', sConsulta;
	for valor in execute(sConsulta)
	loop
		records			:=	valor.records;
		page			:=	valor.page;
		pages			:=	valor.pages;
		id			:=	valor.id;
		fec_registro		:=	valor.fec_registro;
		idu_tipo_movimiento	:=	valor.idu_tipo_movimiento;
		nom_tipo_movimiento	:=	valor.nom_tipo_movimiento;
		folio_factura		:=	valor.folio_factura;
		importe_original	:=	valor.importe_original;
		importe_pagado		:=	valor.importe_pagado;
		opc_bloqueado_estatus	:=	valor.opc_bloqueado_estatus;
		idu_empleado		:=	valor.idu_empleado;
		nombre_empleado		:=	valor.nombre_empleado;
		numero_puesto		:=	valor.numero_puesto;
		nombre_puesto		:=	valor.nombre_puesto;
		fec_alta		:=	valor.fec_alta;
		idu_centro		:=	valor.idu_centro;
		nombre_centro		:=	valor.nombre_centro;
		idu_ciudad		:=	valor.idu_ciudad;
		nombre_ciudad		:=	valor.nombre_ciudad;
		idu_region		:=	valor.idu_region;
		nombre_region		:=	valor.nombre_region;
		justificacion		:=	valor.justificacion;
		estatus_empleado	:=	valor.estatus_empleado;
		idu_usuario		:=	valor.idu_usuario;
		nom_usuario		:=	valor.nom_usuario;
		idu_puesto_usuario	:=	valor.idu_puesto_usuario;
		nom_puesto_usuario	:=	valor.nom_puesto_usuario;
		idu_centro_usuario	:=	valor.idu_centro_usuario;
		nom_centro_usuario	:=	valor.nom_centro_usuario;
		return next;
	end loop;
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_bitacora_movimientos_colegiaturas(date, date, integer, integer, integer, integer, integer, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado con los diferentes movimientos en la bitácora de colegiaturas.';  