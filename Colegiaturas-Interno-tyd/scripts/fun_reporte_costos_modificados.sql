DROP FUNCTION IF EXISTS fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_costos_modificados(IN idusuario integer, IN idestado integer, IN idmunicipio integer, IN sidrfc character varying, IN sidclavesep character varying, IN idescolaridad integer, IN dfechainicial date, IN dfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iusuario integer, OUT susuario character varying, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT sclavesep character varying, OUT srfc character varying, OUT iescolaridad integer, OUT sescolaridad character varying, OUT dfechapendiente date, OUT dfecharevision date)
  RETURNS SETOF record AS
$BODY$
declare
/**
---------------------------------------------
	No. Petición:		16559.1
	Fecha:			18/07/2018
	Numero Empleado:	98439677
	Nombre Empleado:	Rafael Ramos Gutierrez
	BD:			Personal
	Sistema:		Colegiaturas
	Modulo:			Reporte Concluyo Revision(Costos Modificados)
	Ejemplo:
		SELECT records, page, pages, id, iusuario, susuario, iestado, sestado, imunicipio, smunicipio, sclavesep, srfc, iescolaridad, sescolaridad, dfechapendiente, dfecharevision
		FROM fun_reporte_costos_modificados(
			0
			, 25
			, 0
			, ''
			, ''
			, 0
			, '20180801'
			, '20180927'
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
BEGIN
	/*Control de las variables de paginado */
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	create temporary table tmp_costos(
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

	sQuery := 'INSERT INTO tmp_costos(iUsuario
					, iEstado
					, iMunicipio
					, sRfc
					, sClaveSEP
					, iEscuela
					, iEscolaridad
					, dFechaPendiente
					, dFechaRevision)
			SELECT DISTINCT idu_usuario
				, idu_estado
				, idu_municipio
				, rfc
				, clave_sep
				, idu_escuela
				, idu_escolaridad
				, fec_pendiente::DATE
				, fec_conclusion::DATE
			FROM	mov_bitacora_costos
			WHERE	idu_tipo_revision IN (3,8)
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

	raise notice '%', sQuery;
	execute sQuery;
 
	/**NOMBRE de USUARIO*/
	update	tmp_costos
	set	sUsuario = trim(UPPER(a.nombre)) || ' ' || TRIM(UPPER(a.apellidopaterno)) || ' ' || trim(UPPER(a.apellidomaterno))
	from	sapcatalogoempleados a
	where	tmp_costos.iUsuario = a.numempn ;

	/**NOMBRE de ESTADO*/
	update	tmp_costos
	set	sEstado = trim(UPPER(nom_estado))
	from	cat_estados_colegiaturas a
	where	tmp_costos.iEstado = a.idu_estado;

	/**NOMBRE de MUNICIPIO*/
	update	tmp_costos
	set	sMunicipio = trim(UPPER(nom_municipio))
	from	cat_municipios_colegiaturas a
	where	tmp_costos.iEstado = a.idu_estado
		and tmp_costos.iMunicipio = a.idu_municipio;


	/**DESCRIPCION de la ESCOLARIDAD*/
	update	tmp_costos
	set	sEscolaridad = trim(UPPER(nom_escolaridad))
	from	cat_escolaridades a
	where	tmp_costos.iEscolaridad = a.idu_escolaridad;

	iRecords := (select COUNT(*) from tmp_costos);
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
					FROM tmp_costos
					) AS t
				WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' '; 
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_costos ';
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
GRANT EXECUTE ON FUNCTION fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_costos_modificados(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado de los costos que han sido modificados en el catálogo de costos.';