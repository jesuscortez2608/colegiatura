DROP FUNCTION IF EXISTS fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_por_rango_incidencias(IN idusuario integer, IN idestado integer, IN idmunicipio integer, IN sidrfc character varying, IN sidclavesep character varying, IN idescolaridad integer, IN sdfechainicial date, IN sdfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iusuario integer, OUT susuario character varying, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT srfc character varying, OUT sclavesep character varying, OUT iescolaridad integer, OUT sescolaridad character varying, OUT dfecharevision date)
  RETURNS SETOF record AS
$BODY$
declare
/**
---------------------------------------------
	No. Petición:		16559.1
	Fecha:			26/07/2018
	Numero Empleado:	98439677
	Nombre Empleado:	Rafael Ramos Gutierrez
	BD:			Personal
	Sistema:		Colegiaturas
	Modulo:			Reporte Rango de Incidencias
	Ejemplo:

	SELECT *
	FROM fun_reporte_por_rango_incidencias(
		95194185
		, 25
		, 0
		, ''
		, ''
		, 0
		, '20180401'
		, '20180816'
		, 10
		, 1
		, 'iestado,dfecharevision'
		, 'asc'
		, 'iusuario, susuario, iestado, sestado, imunicipio, smunicipio, srfc
			, sclavesep, iescolaridad, sescolaridad, dfecharevision')


SELECT *
	FROM fun_reporte_por_rango_incidencias(
		0
		, 25
		, 10
		, ''
		, '25UBH0021Z'
		, 0
		, '20180401'
		, '20180730'
		, 10
		, 1
		, 'iestado,dfecharevision'
		, 'asc'
		, 'iusuario, susuario, iestado, sestado, imunicipio, smunicipio, srfc, sclavesep, iescolaridad, sescolaridad, dfecharevision')
------------------------------------------------------------------------*/


	/*VARIABlES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor recorD;
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

	create temporary table tmp_rango(
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
		, sRFC		character varying(20) not null default ''
		, sClaveSEP	character varying(20) not null default ''
		, iEscolaridad	integer not null default 0
		, sEscolaridad 	character varying(30) not null default ''
		, dFechaRevision	date not null default '1900-01-01'
	)on commit drop;

	sQuery := 'INSERT INTO tmp_rango(iUsuario
					, iEstado
					, iMunicipio
					, sRFC
					, sClaveSEP
					, iEscolaridad
					, dFechaRevision)
			SELECT	idu_usuario
				, idu_estado
				, idu_municipio
				, rfc
				, clave_sep
				, idu_escolaridad
				, fec_revision
			FROM	mov_bitacora_costos
			WHERE	opc_frecuente != 0
				AND fec_revision::DATE BETWEEN ''' || sdFechaInicial || ''' AND ''' || sdFechaFinal || ''' ';
	if(idUsuario != 0) then
		sQuery := sQuery || ' AND idu_usuario = ' || idUsuario || '';
	end if;
	if(idEstado != 0) then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
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

	sQuery := sQuery || ' GROUP BY idu_usuario, idu_estado, idu_municipio, rfc, clave_sep, idu_escolaridad, fec_revision ';

	execute sQuery;

	/**Nombre de Usuario*/
	update	tmp_rango
	set	sUsuario = UPPER(trim(a.nombre)) || ' ' || UPPER(trim(a.apellidopaterno)) || ' ' || UPPER(trim(a.apellidomaterno))
	from	sapcatalogoempleados a
	where	tmp_rango.iUsuario = a.numempn;

	/**Nombre de Estado*/
	update	tmp_rango
	set	sEstado = UPPER(trim(a.nom_estado))
	from	cat_estados_colegiaturas a
	where	tmp_rango.iEstado = a.idu_estado;

	/**Nombre de Municipio*/
	update	tmp_rango
	set	sMunicipio = UPPER(trim(a.nom_municipio))
	from	cat_municipios_colegiaturas a
	where	tmp_rango.iEstado = a.idu_estado
		AND tmp_rango.iMunicipio = a.idu_municipio;

	/**Nombre de Escolaridad*/
	update	tmp_rango
	set	sEscolaridad = UPPER(trim(a.nom_escolaridad))
	from	cat_escolaridades a
	where	tmp_rango.iEscolaridad = a.idu_escolaridad;

	iRecords := (select COUNT(*) from tmp_rango);
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
					FROM tmp_rango
					) AS t
				WHERE	t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 AS page, 0 AS pages, 0 AS id,' || sColumns || ' FROM tmp_rango ';
	end if;

	for valor in execute(sConsulta)
	loop
		records :=	valor.records;
		page	:=	valor.page;
		pages	:=	valor.pages;
		id	:=	valor.id;
		iUsuario:=	valor.iUsuario;
		sUsuario:=	valor.sUsuario;
		iEstado :=	valor.iEstado;
		sEstado :=	valor.sEstado;
		iMunicipio :=	valor.iMunicipio;
		sMunicipio :=	valor.sMunicipio;
		sRFC	:=	valor.sRFC;
		sClaveSEP  :=	valor.sClaveSEP;
		iEscolaridad:=	valor.iEscolaridad;
		sEscolaridad:=	valor.sEscolaridad;
		dFechaRevision	:= valor.dFechaRevision;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_por_rango_incidencias(integer, integer, integer, character varying, character varying, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función debe aplicar el siguiente criterio: Si una Escuela tuvo más de 3 actualizaciones en un período menor a 15 días, debe aparecer en el listado.';