DROP FUNCTION IF EXISTS fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_empleados_especiales(IN iempleado integer, IN iopcfechas smallint, IN dfechainicial date, IN dfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT idtipomovimiento smallint, OUT snombremovimiento character varying, OUT idempleado integer, OUT snombre character varying, OUT scentro character varying, OUT snombrecentro character varying, OUT spuesto integer, OUT snombrepuesto character varying, OUT dfechaingreso date, OUT iusuario integer, OUT snombreusuario character varying, OUT dfecharegistro timestamp without time zone, OUT sobservaciones character varying)
  RETURNS SETOF record AS
$BODY$
declare
/*---------------------------------------------------------
	No.Petición:			16559.1
	Fecha:				23/04/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Reporte Empleados Especiales
	Ejemplo:

select * from fun_reporte_empleados_especiales(0::INTEGER
						,0::SMALLINT
						,'19000101'::DATE
						,'19000101'::DATE
						,10
						,1
						,'dfecharegistro'::character varying
						,'asc'::character varying
						,'idtipomovimiento, snombremovimiento, idempleado, snombre
						, scentro, snombrecentro, spuesto, snombrepuesto
						, dfechaingreso, iusuario, snombreusuario
						, dfecharegistro, sobservaciones'::character varying);


	
-----------------------------------------------------------*/

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
		iRowsPerPage := NULL;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	create temporary table tmp_consulta(
		records		integer
		, page		integer
		, pages		integer
		, id		integer
		, idTipoMovimiento integer not null default 0
		, sNombreMovimiento character varying (50) not null default ''
		, idEmpleado	integer not null default 0
		, sNombre	character varying(150) not null default ''
		, sCentro	character varying(6) not null default ''
		, sNombreCentro	character varying(100) not null default ''
		, sPuesto	smallint not null default 0
		, sNombrePuesto	character varying(100) not null default ''
		, dFechaIngreso	date not null default '19000101'
		, iUsuario	integer not null default 0
		, sNombreUsuario character varying (150) not null default ''
		, dFechaRegistro timestamp without time zone not null default '19000101'
		, sObservaciones character varying (300) not null default ''
	) on commit drop;

	sQuery := 'INSERT INTO tmp_consulta (idTipoMovimiento
					, idEmpleado
					, iUsuario
					, dFechaRegistro
					, sObservaciones)
			SELECT	idu_tipo_movimiento
				, idu_empleado_especial
				, idu_empleado_registro
				, fec_registro
				, des_justificacion_especial
			FROM	mov_bitacora_movimientos_colegiaturas 
			WHERE 	idu_tipo_movimiento in (4,5)';
	if (iEmpleado != 0) then
		sQuery := sQuery || ' AND idu_empleado_especial = ' || iEmpleado || '';
	end if;
	if (iOpcFechas = 1) then
		sQuery := sQuery || 'AND fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || '''';
	end if;
	sQuery := sQuery || ' ORDER BY idu_empleado_especial, fec_registro;';
	execute sQuery;

	update 	tmp_consulta
	set	sNombre = trim(UPPER(a.nombre)) || ' ' || trim(UPPER(a.apellidopaterno)) || ' ' ||TRIM(UPPER(a.apellidomaterno))
		, sCentro = a.centro
		, sPuesto = a.pueston
		, dFechaIngreso = a.fechaalta::DATE
	from	sapcatalogoempleados a
	where	tmp_consulta.idEmpleado = a.numempn;

	update	tmp_consulta
	set	sNombreCentro = a.nombrecentro
	from	sapcatalogocentros a
	where	tmp_consulta.sCentro = a.numerocentro;

	update	tmp_consulta
	set	sNombrePuesto = a.nombre
	from	sapcatalogopuestos a
	where	tmp_consulta.sPuesto = a.numero::int;

	update	tmp_consulta
	set	sNombreUsuario = trim(UPPER(a.nombre)) || ' ' || trim(UPPER(a.apellidopaterno)) || ' ' ||TRIM(UPPER(a.apellidomaterno))
	from	sapcatalogoempleados a
	where	tmp_consulta.iUsuario = a.numempn;

	update	tmp_consulta
	set	sNombreMovimiento = nom_tipo_movimiento
	from	cat_tipos_movimientos_bitacora a
	where	tmp_consulta.idTipoMovimiento = a.idu_tipo_movimiento;

	iRecords := (select COUNT(*) from tmp_consulta);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iTotalPages := CEILING(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
				SELECT ' || cast(iRecords as varchar) || ' AS records
				     , ' || cast(iCurrentPage as varchar) || ' AS page
				     , ' || cast(iTotalPages as varchar) || ' AS pages
				     , id
				     , ' || sColumns || '
				FROM (
					SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM tmp_consulta
					) AS t
				WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_consulta ';
	end if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	for valor in execute (sConsulta)
	loop
		records :=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		idTipoMovimiento := valor.idTipoMovimiento;
		sNombreMovimiento := valor.sNombreMovimiento;
		idEmpleado :=	valor.idEmpleado;
		sNombre :=	valor.sNombre;
		sCentro :=	valor.sCentro;
		sNombreCentro := valor.sNombreCentro;
		sPuesto :=	valor.sPuesto;
		sNombrePuesto := valor.sNombrePuesto;
		dFechaIngreso := valor.dFechaIngreso;
		iUsuario :=	valor.iUsuario;
		sNombreUsuario := valor.sNombreUsuario;
		dFechaRegistro := valor.dFechaRegistro;
		sObservaciones := valor.sObservaciones;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_empleados_especiales(integer, smallint, date, date, integer, integer, character varying, character varying, character varying) IS 'La funcion obtiene el reporte de colaboradores que se marcaron como especial en la captura de empleados con prestacion de colegiaturas';  