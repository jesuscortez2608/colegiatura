DROP FUNCTION IF EXISTS fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(IN idestado integer, IN idmunicipio integer, IN idmotivo integer, IN sdfechainicial date, IN sdfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT imotivo integer, OUT smotivo character varying, OUT icantidadmotivo integer, OUT icantidadconcluyo integer)
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
		FROM fun_reporte_escuelas_actualizadas_por_motivo
			(-1
			, -1
			, 0
			, '20180701'
			, '20180816'
			, 10
			, 1
			, 'iestado,imunicipio'
			, 'asc'
			, 'iestado, sestado, imunicipio, smunicipio, imotivo, smotivo, icantidadmotivo, icantidadconcluyo')
---------------------------------------------*/

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
	
	create temporary table tmp_escuelas(
	--DROP TABLE IF EXISTS tmp_escuelas;
	--create table tmp_escuelas (
		records		integer
		, page		integer
		, pages		integer
		, id		integer
		, iTipoReg  	SMALLINT
		, iEstado	integer not null default 0
		, sEstado	character varying(50) not null default ''
		, iMunicipio	integer not null default 0
		, sMunicipio	character varying(50) not null default ''
		, iMotivo	integer not null default 0
		, sMotivo	character varying (30) not null default ''
		, iCantidadMotivo	integer not null default 0
		, iCantidadConcluyo	integer not null default 0
	--);
	)on commit drop;
	
	create temporary table tmp_escuelas_revisadas (
	--DROP TABLE IF EXISTS tmp_escuelas_revisadas;
	--create table tmp_escuelas_revisadas (
		idu_estado INTEGER,
		idu_municipio INTEGER,
		idu_motivo INTEGER,
		cantidad INTEGER
	--);
	)on commit drop;
	
	create temporary table tmp_escuelas_concluyo_revision (
	--DROP TABLE IF EXISTS tmp_escuelas_concluyo_revision;
	--create table tmp_escuelas_concluyo_revision (
		idu_estado INTEGER,
		idu_municipio INTEGER,
		idu_motivo INTEGER,
		cantidad INTEGER
	--);
	)on commit drop;
	
	sQuery := 'INSERT INTO tmp_escuelas(iEstado
					, iMunicipio
					, iMotivo
					, iTipoReg
					)
		SELECT  idu_estado
			, idu_municipio
			, idu_motivo_revision
			, 0 AS iTipoReg
		FROM	mov_bitacora_costos
		WHERE	fec_pendiente::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || ''' ';
	if(idMotivo != 0) then
		sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo || '';
	end if;
	if(idEstado != -1) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	sQuery := sQuery || ' GROUP BY idu_estado,idu_municipio,idu_motivo_revision ';
	--sQuery := sQuery || ' ORDER BY idu_estado,idu_municipio,idu_motivo_revision ';

	execute sQuery;
	
	sQuery := 'INSERT INTO tmp_escuelas_revisadas (idu_estado
							, idu_municipio
							, idu_motivo
							, cantidad)
		SELECT 	idu_estado
			, idu_municipio
			, idu_motivo_revision
			, COUNT(DISTINCT rfc) as cantidad
		FROM 	mov_bitacora_costos
		WHERE 	fec_pendiente::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || ''' ';
	if(idMotivo != 0) then
		sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo || '';
	end if;
	if(idEstado != -1) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	sQuery := sQuery || ' GROUP BY idu_estado, idu_municipio, idu_motivo_revision ';
	sQuery := sQuery || ' ORDER BY idu_estado, idu_municipio, idu_motivo_revision ';
	
	--RAISE NOTICE '%', sQuery;
	execute sQuery;
	
	sQuery := 'INSERT INTO tmp_escuelas_concluyo_revision (idu_estado
								, idu_municipio
								, idu_motivo
								, cantidad)
		SELECT 	idu_estado
			, idu_municipio
			, idu_motivo_revision
			, COUNT(DISTINCT rfc) as cantidad
		FROM 	mov_bitacora_costos
		WHERE 	fec_conclusion::DATE > ''1900-01-01''::DATE
			AND fec_pendiente::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || ''' ';
	if(idMotivo != 0) then
		sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo || '';
	end if;
	if(idEstado != -1) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	sQuery := sQuery || ' GROUP BY idu_estado, idu_municipio, idu_motivo_revision ';
	sQuery := sQuery || ' ORDER BY idu_estado, idu_municipio, idu_motivo_revision ';
	
	--RAISE NOTICE '%', sQuery;
	execute sQuery;
	
	
--update mov_bitacora_costos set idu_motivo = 2 where idu_escuela = 206849
/*	insert into	tmp_escuelas(iCantidadMotivo)
	select		count(idu_estado)
	from		mov_bitacora_costos
	where		idu_motivo = idMotivo;
	
	insert into	tmp_escuelas(iCantidadConcluyo)
	select		count(idu_estado)
	from		mov_bitacora_costos
	where		idu_motivo = idMotivo
		AND	fec_revision != '1900-01-01';
*/
	/**Actualizar Descripcion del motivo*/
	update	tmp_escuelas
	set	sMotivo = trim(UPPER(a.des_motivo))
	from	cat_motivos_colegiaturas a
	where	tmp_escuelas.iMotivo = a.idu_motivo
		and A.idu_tipo_motivo = 4;

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
	
	UPDATE tmp_escuelas SET iCantidadMotivo = tmp.cantidad
	FROM tmp_escuelas_revisadas as tmp
	WHERE tmp_escuelas.iEstado = tmp.idu_estado
		AND tmp_escuelas.iMunicipio = tmp.idu_municipio
		AND tmp_escuelas.iMotivo = tmp.idu_motivo;
	
	
	UPDATE tmp_escuelas SET iCantidadConcluyo = tmp.cantidad
	FROM tmp_escuelas_concluyo_revision as tmp
	WHERE tmp_escuelas.iEstado = tmp.idu_estado
		AND tmp_escuelas.iMunicipio = tmp.idu_municipio
		AND tmp_escuelas.iMotivo = tmp.idu_motivo;

	if ((select COUNT(*) from tmp_escuelas) > 0) then
		sQuery := 'INSERT INTO	tmp_escuelas(iTipoReg, sMotivo, iCantidadMotivo, iCantidadConcluyo)
			SELECT 1 AS iTipoReg, ''TOTALES: '', SUM(iCantidadMotivo), SUM(iCantidadConcluyo)
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
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_escuelas ';
	end if;
	
	--RAISE NOTICE '%', sConsulta;
	
	for valor in execute(sConsulta)
	loop
		records :=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		iEstado :=	valor.iEstado;
		sEstado :=	valor.sEstado;
		iMunicipio :=	valor.iMunicipio;
		sMunicipio :=	valor.sMunicipio;
		iMotivo :=	valor.iMotivo;
		sMotivo :=	valor.sMotivo;
		iCantidadMotivo := valor.iCantidadMotivo ;
		iCantidadConcluyo := valor.iCantidadConcluyo ;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_escuelas_actualizadas_por_motivo(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene la cantidad de escuelas revisadas por motivo de revisión.';