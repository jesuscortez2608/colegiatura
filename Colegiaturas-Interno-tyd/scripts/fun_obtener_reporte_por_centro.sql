DROP FUNCTION IF EXISTS fun_obtener_reporte_por_centro(integer, integer, integer, integer, integer, text, integer, smallint, date, date, integer, integer, smallint, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_por_centro(IN idclaverutapago integer, IN idestatus integer, IN idregion integer, IN idciudad integer, IN idarea integer, IN idseccion text, IN idtipodeduccion integer, IN iopcrangofecha smallint, IN dfechainicial date, IN dfechafinal date, IN idescolaridad integer, IN idcentro integer, IN iopcciclo smallint, IN idciclo integer, IN idempresa integer, OUT tipo integer, OUT idu_empresa integer, OUT nom_empresa character varying, OUT idu_area integer, OUT nom_area character varying, OUT idu_seccion integer, OUT nom_seccion character varying, OUT idu_centro integer, OUT nom_centro character varying, OUT total_colaboradores integer, OUT total_facturas integer, OUT total_importefactura numeric, OUT total_importepagado numeric, OUT total_beneficiarios integer)
  RETURNS SETOF record AS
$BODY$
declare
	/**
        -----------------------------------------------------------------------------------------
            No.Peticion:        16559.1
            Colaborador:        Rafael Ramos 98439677
            Sistema:            Colegiaturas
            Ejemplo:
                
                    SELECT tipo
                        , idu_empresa
                        , nom_empresa
                        , idu_area
                        , nom_area
                        , idu_seccion
                        , nom_seccion
                        , idu_centro
                        , nom_centro
                        , total_colaboradores
                        , total_facturas
                        , total_importefactura
                        , total_importepagado
                        , total_beneficiarios
                    FROM fun_obtener_reporte_por_centro(-1::INTEGER
                        , 2::INTEGER
                        , 0::INTEGER
                        , 0::INTEGER
                        , 0 ::INTEGER
                        , '0,23,24,32,33,35,36,37,38,41,42,43,44,45,58,59,60,61,62,64,65,66,68,10,1,2,3,4,5,6,11,12,13,14,15,8,9,29,46,71,72,73,74,75,88,89,90,91,92,93,94,95,96,97,98,99,100,101,79,80,81,82,83,84,85,56,70,39,7,40,28,52,63,102,103,104,105,106,107,108,31,69,16,25,50,53,54,55,18,21,22,67,76,77,78,17,20,26,30,34,47,48,49,51,57,87,19,86,27'::VARCHAR
                        , 0::INTEGER
                        , 1::SMALLINT
                        , '20181001'::DATE
                        , '20181025'::DATE
                        , 0::INTEGER
                        , 0::INTEGER
                        , 0::SMALLINT
                        , 2018::INTEGER
                        , 0::INTEGER)
	*/

	
	valor record;
	sQuery varchar(3000);
	sConsulta text;

	iTotalRegistros integer;
	
begin
	create temporary table tmp_centros_becas(
		tipo integer--
		, idu_centro integer--
		, nom_centro character varying(100) not null default ''--
		, idu_empresa integer--
		, nom_empresa character varying(50) not null default ''--
		, idfactura integer--
		, idu_beneficiario integer--
		, importe_factura numeric(12,2)--
		, importe_pagado numeric(12,2)--
		, clv_ruta_pago integer--
		, idu_empleado integer--
		, idu_estatus integer--
		, idu_escolaridad integer--
		, fecha_registro date--
		, idu_region integer--
		, idu_ciudad integer--
		, idu_area integer
		, nom_area character varying(50) not null default ''
		, idu_seccion integer--
		, nom_seccion character varying(50) not null default ''
		, idu_ciclo_escolar integer--
		, idu_tipo_deduccion integer--
		, total_colaboradores integer
		, total_facturas integer
		, total_importefactura numeric(12,2)
		, total_importepagado numeric(12,2)
		, total_beneficiarios integer
	)on commit drop;

	create temporary table tmp_totales_centros(
		tipo integer
		, idu_empresa integer
		, nom_empresa character varying(30) not null default ''
		, idu_centro integer 
		, nom_centro character varying(100) not null default ''
		, idu_area integer
		, nom_area character varying(100) not null default ''
		, idu_seccion integer
		, nom_seccion character varying(100) not null default ''
		, total_colaboradores integer
		, total_facturas integer
		, total_importefactura numeric(12,2)
		, total_importepagado numeric(12,2)
		, total_beneficiarios integer
	)on commit drop;

	create temporary table tmp_beneficiarios(
		beneficiario integer
	)on commit drop;

	create temporary table tmp_total_facturas_centro(
		idfactura integer
		, centro integer
		, total_importefactura numeric(12,2)
	)on commit drop;

	create temporary table tmp_total_centro(
		centro integer
		, total_importefactura numeric(12,2)
	)on commit drop;

	if(idEstatus = 2) then
		sQuery := 'INSERT INTO tmp_centros_becas(
				tipo
				, idu_centro
				, idu_empresa
				, idfactura
				, idu_beneficiario
				, idu_empleado
				, idu_estatus
				, idu_escolaridad
				, fecha_registro
				, idu_tipo_deduccion
				, importe_factura
				, importe_pagado
				)
		SELECT	0
			, mov.idu_centro
			, mov.idu_empresa
			, mov.idfactura
			, det.idu_beneficiario
			, mov.idu_empleado
			, mov.idu_estatus
			, det.idu_escolaridad
			, mov.fec_registro::DATE
			, mov.idu_tipo_deduccion
			, det.importe_concepto
			, det.importe_pagado
		FROM	mov_facturas_colegiaturas AS mov
		INNER JOIN mov_detalle_facturas_colegiaturas AS det ON(mov.idfactura = det.idfactura)
		WHERE mov.idu_estatus IN (1,2,4,5)
		AND	mov.idu_tipo_documento IN (1,3,4)
		AND mov.idu_beneficiario_externo = 0';
		if (iOpcRangoFecha = 1) then
			sQuery := sQuery || ' AND mov.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if (iOpcCiclo = 1) then
			sQuery := sQuery || ' AND det.idu_ciclo_escolar = ' || idCiclo || '';
		end if;
		
		raise notice '%', sQuery;
		execute (sQuery);
		
	end if;
	if(idEstatus = 6) then
		sQuery := '
			INSERT INTO tmp_centros_becas(
					tipo
					, idu_centro
					, idu_empresa
					, idfactura
					, idu_empleado
					, idu_estatus
					, idu_beneficiario
					, idu_escolaridad
					, fecha_registro
					, idu_tipo_deduccion
					, importe_factura
					, importe_pagado
					)
			SELECT
				0
				, his.idu_centro
				, his.idu_empresa
				, his.idfactura
				, his.idu_empleado
				, his.idu_estatus
				, det.idu_beneficiario
				, det.idu_escolaridad
				, his.fec_registro
				, his.idu_tipo_deduccion
				, det.importe_concepto
				, det.importe_pagado
			FROM	his_facturas_colegiaturas AS his
			INNER JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
			WHERE his.idu_estatus = 6
                AND	his.idu_tipo_documento IN (1,3,4)
                AND his.idu_beneficiario_externo = 0';
		if (iOpcRangoFecha = 1) then
			sQuery := sQuery || ' AND his.fec_cierre::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if (iOpcCiclo = 1) then
			sQuery := sQuery || ' AND det.idu_ciclo_escolar = ' || idCiclo || '';
		end if;
        
		execute (sQuery);
	end if;

	
		update	tmp_centros_becas
		set	    nom_empresa = trim(UPPER(A.nom_empresa))
		from	view_empresas_colegiaturas as A
		where	tmp_centros_becas.idu_empresa = A.idu_empresa;

		update  tmp_centros_becas
		set     nom_centro = trim(UPPER(C.nombrecentro))
                , idu_ciudad = C.ciudadn
                , idu_seccion = C.seccion::INTEGER
		from    sapcatalogocentros AS C
		where   tmp_centros_becas.idu_centro = C.numerocentro::INTEGER;

		update  tmp_centros_becas
		set     clv_ruta_pago = (CASE when E.controlpago = '' then 0 ELSE E.controlpago::INTEGER END)
		from    sapcatalogoempleados as E
		where   tmp_centros_becas.idu_empleado = E.numempn;

		update  tmp_centros_becas
		set     idu_region = CD.regionzona::INTEGER
		FROM    sapcatalogociudades as CD
		where   tmp_centros_becas.idu_ciudad = CD.ciudadn;
		
		update  tmp_centros_becas
		set     idu_area = SA.idu_area
                , nom_area = trim(UPPER(SA.nom_area))
                , nom_seccion = trim(UPPER(SA.nom_seccion))
		FROM    cat_area_seccion as SA
		where   tmp_centros_becas.idu_seccion = SA.idu_seccion;

    /*=============APLICAR FILTROS DE BUSQUEDA================*/
    IF (idclaverutapago != -1)THEN
        DELETE from tmp_centros_becas a where a.clv_ruta_pago not in (idclaverutapago);
    END IF;
    if(idregion != 0)then
        delete from tmp_centros_becas a where a.idu_region not in (idregion);
    end if;
    if(idciudad != 0)then
        delete from tmp_centros_becas a where a.idu_ciudad not in (idciudad);
    end if;
    if(idseccion != '')then
        sQuery := 'DELETE FROM tmp_centros_becas a WHERE a.idu_seccion NOT IN (' || idseccion || ')';
        execute(sQuery);
    end if;
    if(idtipodeduccion != 0) then
        delete from tmp_centros_becas a where a.idu_tipo_deduccion not in (idtipodeduccion);
    end if;
    if(idescolaridad != 0)then
        delete from tmp_centros_becas a where a.idu_escolaridad not in (idescolaridad);
    end if;
    if(idcentro != 0) then
        delete from tmp_centros_becas a where a.idu_centro not in (idcentro);
    end if;
    if(idempresa != 0)then
        delete from tmp_centros_becas a where a.idu_empresa not in (idempresa);
    end if;
    --==================================================================================
	--CALCULAR TOTALES POR CENTRO EN TABLA TMP_TOTALES_CENTROS
	insert into tmp_totales_centros(
		tipo
		, idu_centro
		, nom_centro
		, idu_empresa
		, nom_empresa
		, idu_area
		, nom_area
		, idu_seccion
		, nom_seccion
		, total_colaboradores
		, total_facturas
		, total_importefactura
		, total_importepagado
		, total_beneficiarios)
	SELECT 1
		, a.idu_centro
		, a.nom_centro
		, a.idu_empresa
		, a.nom_empresa
		, a.idu_area
		, a.nom_area
		, a.idu_seccion
		, a.nom_seccion
		, COUNT(DISTINCT a.idu_empleado)
		, COUNT(DISTINCT a.idfactura)
		, SUM(a.importe_factura)
		, SUM(a.importe_pagado)
		, COUNT(DISTINCT a.idu_empleado::VARCHAR || a.idu_beneficiario::VARCHAR)
	FROM	tmp_centros_becas AS a
	group	by a.idu_empresa, a.nom_empresa, a.idu_centro, a.nom_centro, a.idu_seccion, a.nom_seccion
		, a.idu_area, a.nom_area;


	insert into tmp_total_facturas_centro(
		idfactura
		, centro
		, total_importefactura)
	SELECT distinct a.idfactura
		, a.idu_centro
		, a.importe_factura
	FROM	tmp_centros_becas AS a
	group	by a.idfactura, a.idu_centro, a.importe_factura;

	insert into tmp_total_centro(
			centro
			, total_importefactura)
	SELECT	a.centro
		, SUM(a.total_importefactura)
	FROM	tmp_total_facturas_centro as a
	group	by a.centro;

	update	tmp_totales_centros
	set	total_importefactura = a.total_importefactura
	from	tmp_total_centro as a 
	where	tmp_totales_centros.idu_centro = a.centro;

	iTotalRegistros := (SELECT COUNT(*) from tmp_totales_centros);

	--CALCULAR EL TOTAL GENERAL
	if (iTotalRegistros != 0) then
		insert into tmp_totales_centros(
			tipo
			, total_colaboradores
			, total_facturas
			, total_importefactura
			, total_importepagado
			, total_beneficiarios)
		select	2
			, SUM(a.total_colaboradores)
			, SUM(a.total_facturas)
			, SUM(a.total_importefactura)
			, SUM(a.total_importepagado)
			, SUM(a.total_beneficiarios)
		from	tmp_totales_centros AS a;

		insert into tmp_beneficiarios(beneficiario)
		select COUNT(DISTINCT (idu_beneficiario, idu_empleado)) from tmp_centros_becas 
		group by idu_beneficiario, idu_empleado;

		update	tmp_totales_centros
		set	total_beneficiarios = (SELECT SUM(beneficiario) from tmp_beneficiarios)
		where	tmp_totales_centros.tipo = 2;
	end if;


	for valor in (SELECT tmp.tipo
                    , tmp.idu_empresa
                    , tmp.nom_empresa
                    , tmp.idu_centro
                    , tmp.nom_centro
                    , tmp.idu_area
                    , tmp.nom_area
                    , tmp.idu_seccion
                    , tmp.nom_seccion
                    , tmp.total_colaboradores
                    , tmp.total_facturas
                    , tmp.total_importefactura
                    , tmp.total_importepagado
                    , tmp.total_beneficiarios
                    FROM tmp_totales_centros as tmp
                    order by tmp.idu_empresa, tmp.tipo)
                    loop
                        tipo			    :=	valor.tipo;
                        idu_empresa 		:=	valor.idu_empresa;
                        nom_empresa 		:=	valor.nom_empresa;
                        idu_area 		    :=	valor.idu_area;
                        nom_area 		    :=	valor.nom_area;
                        idu_seccion 		:=	valor.idu_seccion;
                        nom_seccion 		:=	valor.nom_seccion;
                        idu_centro 		    :=	valor.idu_centro;
                        nom_centro 		    :=	valor.nom_centro;
                        total_colaboradores :=	valor.total_colaboradores;
                        total_facturas 		:=	valor.total_facturas;
                        total_importefactura:=	valor.total_importefactura;
                        total_importepagado :=	valor.total_importepagado;
                        total_beneficiarios	:=	valor.total_beneficiarios;
                        return next;
                    end loop;
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_por_centro(integer, integer, integer, integer, integer, text, integer, smallint, date, date, integer, integer, smallint, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_por_centro(integer, integer, integer, integer, integer, text, integer, smallint, date, date, integer, integer, smallint, integer, integer) TO syspersonal;
COMMENT ON FUNCTION fun_obtener_reporte_por_centro(integer, integer, integer, integer, integer, text, integer, smallint, date, date, integer, integer, smallint, integer, integer) IS 'La funcion obtiene el reporte de pagos por centro';