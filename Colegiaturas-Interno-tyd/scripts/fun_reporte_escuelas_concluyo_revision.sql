DROP FUNCTION IF EXISTS fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_escuelas_concluyo_revision(IN idestado integer, IN idmunicipio integer, IN sdfechainicial date, IN sdfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT icantidad integer)
  RETURNS SETOF record AS
$BODY$
declare
/**
---------------------------------------------
	No. Petición:		16559.1
	Fecha:			23/07/2018
	Numero Empleado:	98439677
	Nombre Empleado:	Rafael Ramos Gutierrez
	BD:			Personal
	Sistema:		Colegiaturas
	Modulo:			Reporte Escuelas Actualizadas por Motivo
	Ejemplo:
		SELECT *
		FROM fun_reporte_escuelas_concluyo_revision
			(-1
			, -1
			, '20180701'
			, '20180816'
			, 10
			, 1
			, 'iestado,imunicipio'
			, 'asc'
			, 'iestado, sestado, imunicipio, smunicipio, icantidad')
----------------------------------------------------------------------------*/

	/**VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor record;
	sQuery text;
	sConsulta varchar(3000);
begin
	/**Control de variables de paginado*/
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	create temporary table tmp_escuelas(
		records		integer
		, page		integer
		, pages		integer
		, id		integer
		, iTipoReg	smallint
		, iEstado	integer not null default 0
		, sEstado	character varying(50) not null default ''
		, iMunicipio	integer not null default 0
		, sMunicipio	character varying(50) not null default ''
		, iCantidad	integer not null default 0
	)on commit drop;

	create temporary table tmp_escuelas_concluyo(
		idu_estado integer
		, idu_municipio integer
		, cantidad integer
	)on commit drop;

	sQuery := 'INSERT INTO tmp_escuelas(iEstado
					, iMunicipio
					, iTipoReg)
		SELECT	idu_estado
			, idu_municipio
			, 0 AS iTipoReg
		FROM	mov_bitacora_costos
		WHERE	fec_pendiente::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || '''
			AND fec_revision::DATE > ''1900-01-01''
			AND fec_conclusion::DATE > ''1900-01-01'' ';
	if(idEstado != -1)then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1)then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;

	sQuery := sQuery || ' GROUP BY idu_estado, idu_municipio';
	sQuery := sQuery || ' ORDER BY idu_estado, idu_municipio';

	Execute sQuery;

	sQuery := 'INSERT INTO tmp_escuelas_concluyo(idu_estado
							, idu_municipio
							, cantidad)
		SELECT 	idu_estado
			, idu_municipio
			, COUNT(DISTINCT(rfc)) as cantidad
		FROM 	mov_bitacora_costos
		WHERE	fec_conclusion::DATE > ''1900-01-01''
			AND fec_pendiente::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || ''' ';
	if(idEstado != -1) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	sQuery := sQuery || ' GROUP BY idu_estado, idu_municipio';
	sQuery := sQuery || ' ORDER BY idu_estado, idu_municipio';

	Execute sQuery;

	/**Actualizar Nombre del Estado*/
	update	tmp_escuelas
	set	sEstado = trim(UPPER(a.nom_estado))
	from	cat_estados_colegiaturas a
	where	tmp_escuelas.iEstado = a.idu_estado;

	/**Actualizar Nombre del Municipio*/
	update	tmp_escuelas
	set	sMunicipio = trim(UPPER(nom_municipio))
	from	cat_municipios_colegiaturas a
	where	tmp_escuelas.iEstado = a.idu_estado
		and tmp_escuelas.iMunicipio = a.idu_municipio;

	/** Actualizar el Total de Escuelas Actualizadas */
	update	tmp_escuelas
	set	iCantidad = tmp.cantidad
	from	tmp_escuelas_concluyo as tmp
	where	tmp_escuelas.iEstado = tmp.idu_estado
		and tmp_escuelas.iMunicipio = tmp.idu_municipio;

	if ((select COUNT(*) from tmp_escuelas) > 0) then
		sQuery := 'INSERT INTO tmp_escuelas(iTipoReg, sMunicipio, iCantidad)
			SELECT 1 as iTipoReg , ''TOTAL: '', SUM(iCantidad)
			FROM	tmp_escuelas';

		execute sQuery;
	end if;

	iRecords := (select COUNT(*) from tmp_escuelas);
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
					SELECT ROW_NUMBER() OVER(ORDER BY iTipoReg, ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM tmp_escuelas
					) AS t
				WHERE	t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 AS page, 0 AS pages, 0 AS id,' || sColumns || ' FROM tmp_escuelas ';
	end if;

	for valor in execute(sConsulta)
	loop
		records :=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		iEstado	:=	valor.iEstado;
		sEstado :=	valor.sEstado;
		iMunicipio :=	valor.iMunicipio;
		sMunicipio :=	valor.sMunicipio;
		iCantidad  :=	valor.iCantidad;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_escuelas_concluyo_revision(integer, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene la cantidad de escuelas revisadas y donde se marcó la escuela como "Concluyó revisión".';