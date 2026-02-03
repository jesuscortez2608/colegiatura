DROP FUNCTION IF EXISTS fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_indicadores_reincidencia_por_estado(IN idestado integer, IN dfechainicial date, IN dfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iestado integer, OUT snomestado character varying, OUT cantidad_incidencias integer)
  RETURNS SETOF record AS
$BODY$
declare
	/**----------------------------------------------------------
	No. Peticion:		16559.1
	Fecha:			13/08/2018
	Colaborador:		98439677 Rafael Ramos
	BD:			Personal
	Sistema:		Colegiaturas
	Modulo:			Reporte Indicadores
	Ejemplo:

		SELECT records
			, page
			, pages
			, id
			, iestado
			, snomestado
			, cantidad_incidencias
		 FROM fun_indicadores_reincidencia_por_estado(
			25
			, '20180701'
			, '20180814'
			, -1
			, -1
			, ''
			, ''
			, 'iestado, snomestado, icantidad')
	-----------------------------------------------------------*/
	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor record;
	sQuery text;
	sConsulta varchar(3000);
	--iCantidad integer;
begin
	/*Control de las variables de paginado*/
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	--iCantidad := (SELECT COUNT(fec_conclusion) from mov_bitacora_costos where opc_frecuente != 0 and fec_revision::DATE between dFechaInicial and dFechaFinal group by idu_estado);
	create temporary table tmp_consulta(
		records		integer
		, page		integer
		, pages		integer
		, id		integer
		, iEstado	integer
		, sNomEstado	character varying
		, iCantidad	integer
	)on commit drop;

	sQuery := 'INSERT INTO tmp_consulta(iEstado
					, iCantidad)
			SELECT	mov.idu_estado
				, COUNT(DISTINCT mov.rfc) AS iCantidad
			FROM	mov_bitacora_costos AS mov
			WHERE	mov.opc_frecuente > 0
				AND mov.fec_conclusion::DATE > ''1900-01-01''
				AND mov.fec_pendiente::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	if(idEstado != 0) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado;
	end if;
	sQuery := sQuery || ' GROUP BY mov.idu_estado';
	execute sQuery;

	/**NOMBRE DE ESTADO*/
	update	tmp_consulta
	set	sNomEstado = trim(UPPER(A.nom_estado))
	from	cat_estados_colegiaturas A
	where	tmp_consulta.iEstado = A.idu_estado;

	/**SECCION DE GRID*/
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
					SELECT ROW_NUMBER() OVER(ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM tmp_consulta
					) AS t
				WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 AS page, 0 AS pages, 0 AS id,' || sColumns || ' FROM tmp_consulta ';
	end if;

	for valor in execute(sConsulta)
	loop
		records :=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		iEstado :=	valor.iEstado;
		sNomEstado :=	valor.sNomEstado;
		cantidad_incidencias := valor.iCantidad;
		return next;
	end loop;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_indicadores_reincidencia_por_estado(integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado de las revisiones que se han levantado por Estado.';