DROP FUNCTION IF EXISTS fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_costos_sin_modificar(IN idusuario integer, IN idestado integer, IN idmunicipio integer, IN sidrfc character varying, IN sidclavesep character varying, IN idescolaridad integer, IN dfechainicial date, IN dfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iusuario integer, OUT susuario character varying, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT sclavesep character varying, OUT srfc character varying, OUT iescolaridad integer, OUT sescolaridad character varying, OUT dfechapendiente date, OUT dfecharevision date)
  RETURNS SETOF record AS
$BODY$
declare
/**
---------------------------------------------
	No. Petición:		16559.1
	Fecha:			19/07/2018
	Numero Empleado:	98439677
	Nombre Empleado:	Rafael Ramos Gutierrez
	BD:			Personal
	Sistema:		Colegiaturas
	Modulo:			Reporte Concluyo Revision(Costos Sin Modificar)
	Ejemplo:
	
		SELECT records, page, pages, id, iusuario, susuario, iestado, sestado, imunicipio, smunicipio, sclavesep, srfc, iescolaridad, sescolaridad, dfechapendiente, dfecharevision
		FROM fun_reporte_costos_sin_modificar(
			0
			, 25
			, 0
			, ''
			, ''
			, 0
			, '20180701'
			, '20180816'
			, 10
			, 1
			, 'dfecharevision'
			, 'asc'
			, 'iusuario,susuario,iestado,sestado,imunicipio,smunicipio,sclavesep,srfc,iescolaridad,sescolaridad,dfechapendiente,dfecharevision')
---------------------------------------------
*/

	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor record;
	sQuery text;
	sConsulta varchar(3000);
begin
	/*CONTROL DE LAS VARIABLES DE PAGINADO*/
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	create temporary table tmp_costosSM(
		records		integer
		, page		integer
		, pages		integer
		, id		integer
		, iUsuario	integer not null default 0
		, sUsuario	character varying(200) not null default ''
		, iEstado	integer not null default 0
		, sEstado	character varying(150) not null default ''
		, iMunicipio	integer not null default 0
		, sMunicipio	character varying(150) not null default ''
		, sClaveSEP	character varying(20) not null default ''
		, sRfc		character varying(20) not null default ''
		, iEscuela	integer not null default 0
		, iEscolaridad	integer not null default 0
		, sEscolaridad	character varying(30) not null default ''
		, dFechaPendiente	date not null default '1900-01-01'
		, dFechaRevision	date not null default '1900-01-01'
	)on commit drop;

	sQuery := 'INSERT INTO tmp_costosSM(iUsuario
					, iEstado
					, iMunicipio
					, sRfc
					, sClaveSEP
					, iEscuela
					, iEscolaridad
					, dFechaPendiente
					, dFechaRevision)
			SELECT	DISTINCT idu_usuario
				, idu_estado
				, idu_municipio
				, rfc
				, clave_sep
				, idu_escuela
				, idu_escolaridad
				, fec_pendiente
				, fec_conclusion
			FROM	mov_bitacora_costos
			WHERE	idu_tipo_revision = 6
				AND fec_conclusion::DATE > ''1900-01-01''
				AND fec_conclusion::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
				--AND fec_revision::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	if(idEstado != 0) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idUsuario != 0) then
		sQuery := sQuery || ' AND idu_usuario = ' || idUsuario || '';
	end if;
	if(idMunicipio != 0) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	if(sidRFC != '') then
		sQuery := sQuery || ' AND rfc = ''' || sidRFC || '''';
	end if;
	if(sidClaveSEP != '') then
		sQuery := sQuery || ' AND clave_sep = ''' || sidClaveSEP || '''';
	end if;
	if(idEscolaridad != 0) then
		sQuery := sQuery || ' AND idu_escolaridad = ' || idEscolaridad || '';
	end if;

	Execute sQuery;

	/**NOMBRE de USUARIO*/
	update	tmp_costosSM
	set	sUsuario = trim(UPPER(a.nombre)) || ' ' || TRIM(UPPER(a.apellidopaterno)) || ' ' || trim(UPPER(a.apellidomaterno))
	from	sapcatalogoempleados a
	where	tmp_costosSM.iUsuario = a.numempn ;

	/**NOMBRE de ESTADO*/
	update	tmp_costosSM
	set	sEstado = trim(UPPER(nom_estado))
	from	cat_estados_colegiaturas a
	where	tmp_costosSM.iEstado = a.idu_estado;

	/**NOMBRE de MUNICIPIO*/
	update	tmp_costosSM
	set	sMunicipio = trim(UPPER(nom_municipio))
	from	cat_municipios_colegiaturas a
	where	tmp_costosSM.iEstado = a.idu_estado
		and tmp_costosSM.iMunicipio = a.idu_municipio;

	/**CLAVE SEP de la ESCUELA*/
	update	tmp_costosSM
	set	sClaveSEP = trim(clave_sep)
	from	cat_escuelas_colegiaturas a
	where	tmp_costosSM.iEscuela =a.idu_escuela;

	/**DESCRIPCION de la ESCOLARIDAD*/
	update	tmp_costosSM
	set	sEscolaridad = trim(UPPER(nom_escolaridad))
	from	cat_escolaridades a
	where	tmp_costosSM.iEscolaridad = a.idu_escolaridad;

	/*update	tmp_costosSM
	set	dFechaPendiente = rev.fec_captura::DATE
	from	mov_revision_colegiaturas as rev
	where	tmp_costosSM.iEscuela = rev.idu_escuela;*/

	iRecords := (select COUNT(*) from tmp_costosSM);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage +1;
		iTotalPages := CEILING(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
				SELECT ' || cast(iRecords as varchar) || ' AS records
				     , ' || cast(iCurrentPage as varchar) || ' AS page
				     , ' || cast(iTotalPages as varchar) || ' AS pages
				     , id
				     , ' || sColumns || '
				FROM (
					SELECT ROW_NUMBER() OVER(ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM tmp_costosSM
					) AS t
				WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' '; 
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_costosSM ';
	end if;
	--raise notice '%', sConsulta;
	for valor in execute(sConsulta)
	loop
		records	:=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		iUsuario:=	valor.iUsuario;
		sUsuario:=	valor.sUsuario;
		iEstado	:=	valor.iEstado;
		sEstado	:=	valor.sEstado;
		iMunicipio :=	valor.iMunicipio;
		sMunicipio :=	valor.sMunicipio;
		sClaveSEP  :=	valor.sClaveSEP;
		sRfc	:=	valor.sRfc;
		iEscolaridad :=	valor.iEscolaridad;
		sEscolaridad := valor.sEscolaridad;
		dFechaPendiente:= valor.dFechaPendiente;
		dFechaRevision := valor.dFechaRevision;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_costos_sin_modificar(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado de las revisiones que se concluyeron sin realizar modificaciones en el catálogo de costos.';