DROP FUNCTION IF EXISTS fun_consultar_bitacora_revision(integer, integer, character varying, character varying, character varying, integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_consultar_bitacora_revision(IN idestado integer, IN idmunicipio integer, IN snomescuela character varying, IN sidrfc character varying, IN sidclavesep character varying, IN idcicloescolar integer, IN idmotivo integer, IN idusuario integer, IN dfechainicial date, IN dfechafinal date, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT dfecharevision timestamp without time zone, OUT itipomovimiento integer, OUT stipomovimiento character varying, OUT imotivorevision integer, OUT smotivorevision character varying, OUT srfc character varying, OUT sclavesep character varying, OUT srazonsocial character varying, OUT iestado integer, OUT snombreestado character varying, OUT imunicipio integer, OUT snombremunicipio character varying, OUT stelefonoescuela character varying, OUT snombreescuela character varying, OUT scorreo character varying, OUT scontacto character varying, OUT sareacontacto character varying, OUT sextensioncontacto character varying, OUT scicloescolar character varying, OUT sescolaridad character varying, OUT scarrera character varying, OUT stpp character varying, OUT idescuento integer, OUT imotivodescuento integer, OUT smotivodescuento character varying, OUT ncosto numeric, OUT iporcentaje integer, OUT iusuario integer, OUT snombreusuario character varying, OUT dfechapendiente timestamp without time zone, OUT dfechaconclusion timestamp without time zone)
  RETURNS SETOF record AS
$BODY$
declare
	/**-------------------------------------------- 
		Peticion:	16559.1
		Fecha:		11/08/2018
		Colaborador:	98439677 Rafael Ramos
		BD:		Personal PostgreSQL
		Sistema:	Colegiaturas
		Modulo:		Bitacora de Costos
		Ejemplo:
			SELECT records, page, pages, id, dfecharevision, itipomovimiento, stipomovimiento, imotivorevision, smotivorevision, srfc, sclavesep, srazonsocial, iestado, snombreestado, imunicipio, snombremunicipio, stelefonoescuela, snombreescuela
					, scorreo, scontacto, sareacontacto, sextensioncontacto, scicloescolar, sescolaridad, scarrera, stpp, idescuento, imotivodescuento, smotivodescuento, ncosto, iporcentaje
					, iusuario, snombreusuario, dfechapendiente, dfechaconclusion
				FROM fun_consultar_bitacora_revision(
					25
					, 6
					, ''
					, ''
					, ''
					, 2018
					, 0
					, 0
					, '20180701'
					, '20180827'
					, 10
					, 1
					, 'dfechapendiente'
					, 'desc'
					, 'dFechaRevision, iTipoMovimiento , sTipoMovimiento, iMotivoRevision, sMotivoRevision, sRFC, sClaveSep , sRazonSocial , iEstado , sNombreEstado , iMunicipio , sNombreMunicipio , sTelefonoEscuela , iEscuela , sNombreEscuela , sCorreo , sContacto 
				, sAreaContacto , sExtencionContacto , iCicloEscolar , sCicloEscolar , iEscolaridad , sEscolaridad , iCarrera , sCarrera , iTPP , sTPP , iDescuento , iMotivoDescuento , sMotivoDescuento , nCosto 
				, iPorcentaje , iUsuario , sNombreUsuario , dFechaPendiente , dFechaConclusion')
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

	create temporary table tmp_consulta(
		records integer
		, page integer
		, pages integer
		, id integer
		, dFechaRevision timestamp without time zone
		, iTipoMovimiento integer
		, sTipoMovimiento character varying
		, iMotivoRevision integer
		, sMotivoRevision character varying
		, sRFC character varying
		, sClaveSep character varying
		, sRazonSocial character varying
		, iEstado integer
		, sNombreEstado character varying
		, iMunicipio integer
		, sNombreMunicipio character varying
		, sTelefonoEscuela character varying
		, iEscuela integer
		, sNombreEscuela character varying
		, sCorreo character varying
		, sContacto character varying
		, sAreaContacto character varying
		, sExtencionContacto character varying
		, iCicloEscolar integer
		, sCicloEscolar character varying
		, iEscolaridad integer
		, sEscolaridad character varying
		, iCarrera integer
		, sCarrera character varying
		, iTPP integer
		, sTPP character varying
		, iDescuento integer
		, iMotivoDescuento integer
		, sMotivoDescuento character varying
		, nCosto numeric(12,2)
		, iPorcentaje integer
		, iUsuario integer
		, sNombreUsuario character varying
		, dFechaPendiente timestamp without time zone
		, dFechaConclusion timestamp without time zone
	) on commit drop;

	sQuery := 'INSERT INTO tmp_consulta(dFechaRevision
				, iTipoMovimiento
				, iMotivoRevision
				, sRFC
				, sClaveSep
				, sRazonSocial
				, iEstado
				, iMunicipio
				, sTelefonoEscuela
				, iEscuela
				, sNombreEscuela
				, sCorreo
				, sContacto
				, sAreaContacto
				, sExtencionContacto
				, iCicloEscolar
				, iEscolaridad
				, iCarrera
				, iTPP
				, iDescuento
				, iMotivoDescuento
				, nCosto
				, iPorcentaje
				, iUsuario
				, dFechaPendiente
				, dFechaConclusion)
			SELECT	fec_revision
				, idu_tipo_revision
				, idu_motivo_revision
				, rfc
				, clave_sep
				, razon_social
				, idu_estado
				, idu_municipio
				, tel_contacto
				, idu_escuela
				, nom_escuela
				, email_contacto
				, nom_contacto
				, area_contacto
				, ext_contacto
				, idu_ciclo_escolar
				, idu_escolaridad
				, idu_carrera
				, idu_tipo_periodo
				, prc_descuento
				, idu_motivo
				, importe_concepto
				, porcentaje_tolerancia
				, idu_usuario
				, fec_pendiente
				, fec_conclusion
			FROM	mov_bitacora_costos
			WHERE	idu_escuela = idu_escuela
				AND fec_revision::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	/**SECCION DE FILTROS*/
	if(idEstado != -1)then
		sQuery := sQuery || ' AND idu_estado = ' || idEstado || '';
	end if;
	if(idMunicipio != -1) then
		sQuery := sQuery || ' AND idu_municipio = ' || idMunicipio || '';
	end if;
	--POR NOMBRE DE ESCUELA
	if(sNomEscuela != '') then
		sQuery := sQuery || ' AND nom_escuela LIKE ''%' || sNomEscuela || '%''';
	end if;
	--POR RFC
	if(sidRFC != '') then
		sQuery := sQuery || ' AND rfc LIKE ''%' || sidRFC || '%''';
	end if;
	--POR CLAVE SEP
	if(sidClaveSep != '') then
		sQuery := sQuery || ' AND clave_sep LIKE ''%' || sidClaveSep || '%''';
	end if;
	--POR CICLO ESCOLAR
	if(idCicloEscolar > 0) then
		sQuery := sQuery || ' AND idu_ciclo_escolar = ' || idCicloEscolar;
	end if;
	--POR MOTIVO
	if(idMotivo > 0) then
		--sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo;
		sQuery := sQuery || ' AND idu_tipo_revision = ' || idMotivo;
	end if;
	--POR USUARIO
	if(idUsuario > 0) then
		sQuery := sQuery || ' AND idu_usuario = ' || idUsuario;
	end if;
	raise notice '%',sQuery;
	execute sQuery;


	/**ACTUALIZAR DATOS FALTANTES*/
	--ACTUALIZAR EL TIPO DE MOVIMIENTO
	update	tmp_consulta set sTipoMovimiento = trim(UPPER(A.des_tipo_revision))
	from	cat_tipo_revision A
	where	tmp_consulta.iTipoMovimiento = A.idu_tipo_revision;

	--ACTUALIZAR EL MOTIVO DE REVISION
	update	tmp_consulta set sMotivoRevision = trim(UPPER(A.des_motivo))
	from	cat_motivos_colegiaturas A
	WHERE	tmp_consulta.iMotivoRevision = A.idu_motivo
		and A.idu_tipo_motivo = 4;
	

	--ACTUALIZAR EL NOMBRE DE ESTADO
	update	tmp_consulta set sNombreEstado = trim(UPPER(A.nom_estado))
	from	cat_estados_colegiaturas A
	where	tmp_consulta.iEstado = A.idu_estado;
	
	--ACTUALIZAR EL NOMBRE DE MUNICIPIO
	update	tmp_consulta set sNombreMunicipio = trim(UPPER(A.nom_municipio))
	from	cat_municipios_colegiaturas A
	where	tmp_consulta.iEstado = A.idu_estado
		and tmp_consulta.iMunicipio =  A.idu_municipio;
		
	--ACTUALIZAR EL CICLO ESCOLAR
	update	tmp_consulta set sCicloEscolar = trim(des_ciclo_escolar)
	from	cat_ciclos_escolares A
	where	tmp_consulta.iCicloEscolar = A.idu_ciclo_escolar;
	
	--ACTUALIZAR LA ESCOLARIDAD
	update	tmp_consulta set sEscolaridad = trim(UPPER(A.nom_escolaridad))
	from	cat_escolaridades A
	where	tmp_consulta.iEscolaridad = A.idu_escolaridad;
	
	--ACTUALIZAR LA CARRERA
	update	tmp_consulta set sCarrera = trim(UPPER(A.nom_carrera))
	from	cat_carreras A
	where	tmp_consulta.iCarrera = A.idu_carrera;
	
	--ACTUALIZAR EL TPP
	update	tmp_consulta set sTPP = trim(UPPER(A.des_tipo_pago))
	from	cat_tipos_pagos A
	where	tmp_consulta.iTPP = A.idu_tipo_pago;
	
	--ACTUALIZAR EL MOTIVO DE DESCUENTO
	update	tmp_consulta set sMotivoDescuento = trim(UPPER(A.des_motivo))
	from	cat_motivos_colegiaturas A
	where	tmp_consulta.iMotivoDescuento = A.idu_motivo
		and A.idu_tipo_motivo = 5;
		
	--ACTUALIZAR EL USUARIO
	update	tmp_consulta set sNombreUsuario = trim(UPPER(A.nombre)) || ' ' || trim(UPPER(A.apellidopaterno)) || ' ' || trim(UPPER(A.apellidomaterno))
	from	sapcatalogoempleados A
	where	tmp_consulta.iUsuario = A.numempn;
	
	--ACTUALIZA DATOS DE CONTACTO
	/*
	update	tmp_consulta 
	set 	sTelefonoEscuela = esc.tel_contacto
		, sCorreo = trim(esc.email_contacto)
		, sContacto = trim(esc.nom_contacto)
		, sAreaContacto = trim(esc.area_contacto)
		, sExtencionContacto = trim(esc.ext_contacto)
	from	cat_escuelas_colegiaturas as esc
	where	tmp_consulta.iEscuela = esc.idu_escuela;
	*/

	/**-----------SECCION DE GRID----------*/
	iRecords := (select COUNT(*) from tmp_consulta);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iTotalPages := CEILING(iRecords/(iRowsPerPage * 1.0));

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
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 AS page, 0 AS pages, 0 AS id,' || sColumns || ' FROM tmp_consulta ORDER BY ' || sOrderColumn || ' ' || sOrderType;
	end if;

	for valor in execute(sConsulta)
	loop
		records		   :=	valor.records;
		page               :=	valor.page;
		pages              :=	valor.pages;
		id                 :=	valor.id;
		dFechaRevision     :=	valor.dFechaRevision;
		iTipoMovimiento    :=	valor.iTipoMovimiento;
		sTipoMovimiento    :=	valor.sTipoMovimiento;
		iMotivoRevision	   :=	valor.iMotivoRevision;
		sMotivoRevision	   := 	valor.sMotivoRevision;
		sRFC               :=	valor.sRFC;
		sClaveSep	   :=	valor.sClaveSep;
		sRazonSocial       :=	valor.sRazonSocial;
		iEstado            :=	valor.iEstado;
		sNombreEstado      :=	valor.sNombreEstado;
		iMunicipio         :=	valor.iMunicipio;
		sNombreMunicipio   :=	valor.sNombreMunicipio;
		sTelefonoEscuela   :=	valor.sTelefonoEscuela;
		sNombreEscuela     :=	valor.sNombreEscuela;
		sCorreo            :=	valor.sCorreo;
		sContacto          :=	valor.sContacto;
		sAreaContacto      :=	valor.sAreaContacto;
		sExtensionContacto :=	valor.sExtencionContacto;
		sCicloEscolar      :=	valor.sCicloEscolar;
		sEscolaridad       :=	valor.sEscolaridad;
		sCarrera           :=	valor.sCarrera;
		sTPP               :=	valor.sTPP;
		iDescuento         :=	valor.iDescuento;
		iMotivoDescuento   :=	valor.iMotivoDescuento;
		sMotivoDescuento   :=	valor.sMotivoDescuento;
		nCosto 		   :=	valor.nCosto;
		iPorcentaje        :=	valor.iPorcentaje;
		iUsuario           :=	valor.iUsuario;
		sNombreUsuario     :=	valor.sNombreUsuario;
		dFechaPendiente    :=	valor.dFechaPendiente;
		dFechaConclusion   :=	valor.dFechaConclusion;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consultar_bitacora_revision(integer, integer, character varying, character varying, character varying, integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_bitacora_revision(integer, integer, character varying, character varying, character varying, integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
COMMENT ON FUNCTION fun_consultar_bitacora_revision(integer, integer, character varying, character varying, character varying, integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función consulta los diferentes registros de la bitácora de costos, teniendo en cuenta los tipos de revisión que se han realizado durante la operación.';  