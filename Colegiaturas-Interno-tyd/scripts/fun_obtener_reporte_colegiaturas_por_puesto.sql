DROP FUNCTION IF EXISTS fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(IN idrutapago integer, IN idestatus integer, IN idempresa integer, IN idregion integer, IN idciudad integer, IN idtipodeduccion integer, IN idescolaridad integer, IN iopcfecha smallint, IN dfechainicial date, IN dfechafinal date, IN iopcciclo smallint, IN idciclo integer, IN idarea integer, IN idseccion text, IN idcentro integer, OUT tipo integer, OUT idu_empresa integer, OUT nom_empresa character varying, OUT idu_puesto integer, OUT nom_puesto character varying, OUT idu_centro integer, OUT nom_centro character varying, OUT idu_area integer, OUT nom_area character varying, OUT idu_seccion integer, OUT nom_seccion character varying, OUT total_colaboradores integer, OUT total_facturas integer, OUT total_importefactura numeric, OUT total_importepagado numeric, OUT total_beneficiarios integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
	/*==================================================================
		No. Peticion:		16559.1
		Fecha:			30/08/2018
		Colaborador:		Rafael Ramos 98439677
		Sistema:		Colegiaturas
		Modulo:			Reporte Pagos Por Puesto
		Ejemplo:
			SELECT * FROM fun_obtener_reporte_colegiaturas_por_puesto(
					-1
					, 0
					, 0
					, 0
					, 0
					, 0
					, 0
					, 1::SMALLINT
					, '20180701'::DATE
					, '20181025'::DATE
					, 0::SMALLINT
					, 2018
					, 0
					, '0,23,24,32,33,35,36,37,38,41,42,43,44,45,58,59,60,61,62,64,65,66,68,10,1,2,3,4,5,6,11,12,13,14,15,8,9,29,46,71,72,73,74,75,88,89,90,91,92,93,94,95,96,97,98,99,100,101,79,80,81,82,83,84,85,56,70,39,7,40,28,52,63,102,103,104,105,106,107,108,31,69,16,25,50,53,54,55,18,21,22,67,76,77,78,17,20,26,30,34,47,48,49,51,57,87,19,86,27'::VARCHAR
					, 0)
					his_facturas_colegiaturas where idu_empleado = 97225101
					his_detalle_facturas_colegiaturas where idu_empleado = 97225101

					select * from tmp_puestos_becas where idu_centro = 57780
	==================================================================*/
	sQuery text;
	valor record;
	TotalRegistros integer;
	
BEGIN
	create temporary table tmp_puestos_becas(
		tipo integer
		, idu_empresa integer--
		, nom_empresa character varying(30)--
		, idu_puesto integer--
		, nom_puesto character varying(30)--
		, idu_centro integer--
		, nom_centro character varying(100)--
		, idu_area integer
		, nom_area character varying(50)
		, idu_seccion integer--
		, nom_seccion character varying(50)
		, idfactura integer--
		, idu_beneficiario integer--
		, importe_factura numeric(12,2)--
		, importe_pagado numeric(12,2)--
		, clv_ruta_pago integer--
		, idu_empleado integer--
		, idu_estatus integer--
		, idu_escolaridad integer--
		, fec_registro date--
		, idu_region integer--
		, idu_ciudad integer--
		, idu_ciclo_escolar integer--
		, idu_tipo_deduccion integer--
		, total_colaboradores integer
		, total_facturas integer
		, total_importefactura numeric(21,2)
		, total_importepagado numeric(21,2)
		, total_beneficiarios integer
	)on commit drop;

	create temporary table tmp_totales_puestos(
		tipo integer
		, idu_empresa integer
		, nom_empresa character varying(30)
		, idu_puesto integer
		, nom_puesto character varying(30)
		, idu_centro integer
		, nom_centro character varying(100)
		, idu_area integer
		, nom_area character varying(50)
		, idu_seccion integer
		, nom_seccion character varying(50)
		, total_colaboradores integer
		, total_facturas integer
		, total_importefactura numeric(21,2)
		, total_importepagado numeric(21,2)
		, total_beneficiarios integer
	)on commit drop;

	create temporary table tmp_beneficiarios(
		beneficiario integer
	)on commit drop;

	create temporary table tmp_total_facturas_puesto(
		idfactura integer
		, puesto integer
		, total_importefactura numeric(12,2)
	)on commit drop;

	create temporary table tmp_total_puesto(
		puesto integer
		, total_importefactura numeric(12,2)
	)on commit drop;

	if(idEstatus = 0 or idEstatus = 1 or idEstatus = 2 or idEstatus = 4 or idEstatus = 5)then
		sQuery:= 'INSERT INTO tmp_puestos_becas(tipo
				, idu_empresa
				, idu_centro
				, idfactura
				, idu_beneficiario
				, importe_factura
				, importe_pagado
				, idu_empleado
				, idu_estatus
				, idu_escolaridad
				, fec_registro
				, idu_ciclo_escolar
				, idu_tipo_deduccion
			)
		SELECT	0
			, mov.idu_empresa
			, mov.idu_centro
			, mov.idfactura
			, det.idu_beneficiario
			, det.importe_concepto
			, det.importe_pagado
			, mov.idu_empleado
			, mov.idu_estatus
			, det.idu_escolaridad
			, mov.fec_registro::DATE
			, det.idu_ciclo_escolar
			, mov.idu_tipo_deduccion
		FROM	mov_facturas_colegiaturas AS mov
		INNER   JOIN mov_detalle_facturas_colegiaturas AS det ON (mov.idfactura = det.idfactura)
		WHERE	mov.idu_estatus = ' || idEstatus || '
			AND mov.idu_tipo_documento IN (1,3,4)
			AND mov.idu_beneficiario_externo = 0';
		if(iOpcFecha = 1)then
			sQuery := sQuery || ' AND mov.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if(iOpcCiclo = 1)then
			sQuery := sQuery || ' AND det.idu_ciclo_escolar = ' || idCiclo || ' ';
		end if;

		raise NOTICE '%', sQuery;
		Execute (sQuery);
		
	end if;
	if(idEstatus = 3)then
		sQuery:= 'INSERT INTO tmp_puestos_becas(tipo
				, idu_empresa
				, idu_centro
				, idfactura
				, idu_beneficiario
				, importe_factura
				, importe_pagado
				, idu_empleado
				, idu_estatus
				, idu_escolaridad
				, fec_registro
				, idu_ciclo_escolar
				, idu_tipo_deduccion
			)
		SELECT	0
			, mov.idu_empresa
			, mov.idu_centro
			, mov.idfactura
			, det.idu_beneficiario
			, mov.importe_factura
			, mov.importe_pagado
			, mov.idu_empleado
			, mov.idu_estatus
			, det.idu_escolaridad
			, mov.fec_registro::DATE
			, det.idu_ciclo_escolar
			, mov.idu_tipo_deduccion
		FROM	mov_facturas_colegiaturas AS mov
		INNER	JOIN mov_detalle_facturas_colegiaturas AS det ON (mov.idfactura = det.idfactura)
		WHERE	mov.idu_estatus = ' || idEstatus || '
			AND mov.idu_tipo_documento IN (1,3,4)
			AND mov.idu_beneficiario_externo = 0';
		if(iOpcFecha = 1)then
			sQuery := sQuery || ' AND mov.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if(iOpcCiclo = 1)then
			sQuery := sQuery || ' AND det.idu_ciclo_escolaro = ' || idCiclo || ' ';
		end if;

		raise NOTICE '%', sQuery;
		Execute (sQuery);
		----DATOS DEL HISTORICO
		sQuery:= 'INSERT INTO tmp_puestos_becas(tipo
				, idu_empresa
				, idu_centro
				, idfactura
				, idu_beneficiario
				, importe_factura
				, importe_pagado
				, idu_empleado
				, idu_estatus
				, idu_escolaridad
				, fec_registro
				, idu_ciclo_escolar
				, idu_tipo_deduccion
			)
		SELECT	0
			, his.idu_empresa
			, his.idu_centro
			, his.idfactura
			, det.idu_beneficiario
			, his.importe_factura
			, his.importe_pagado
			, his.idu_empleado
			, his.idu_estatus
			, det.idu_escolaridad
			, his.fec_registro::DATE
			, det.idu_ciclo_escolar
			, his.idu_tipo_deduccion
		FROM	his_facturas_colegiaturas AS his
		INNER	JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
		WHERE	his.idu_estatus = ' || idEstatus || '
			AND his.idu_tipo_documento IN (1,3,4)
			AND his.idu_beneficiario_externo = 0';
		if(iOpcFecha = 1)then
			sQuery := sQuery || ' AND his.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if(iOpcCiclo = 1)then
			sQuery := sQuery || ' AND det.idu_ciclo_escolaro = ' || idCiclo || ' ';
		end if;

		raise NOTICE '%', sQuery;
		Execute (sQuery);

	end if;
	if(idEstatus = 6)then
		sQuery:= 'INSERT INTO tmp_puestos_becas(tipo
				, idu_empresa
				, idu_centro
				, idfactura
				, idu_beneficiario
				, importe_factura
				, importe_pagado
				, idu_empleado
				, idu_estatus
				, idu_escolaridad
				, fec_registro
				, idu_ciclo_escolar
				, idu_tipo_deduccion
			)
		SELECT	0
			, his.idu_empresa
			, his.idu_centro
			, his.idfactura
			, det.idu_beneficiario
			, his.importe_factura
			, his.importe_pagado
			, his.idu_empleado
			, his.idu_estatus
			, det.idu_escolaridad
			, his.fec_registro::DATE
			, det.idu_ciclo_escolar
			, his.idu_tipo_deduccion
		FROM	his_facturas_colegiaturas AS his
		INNER	JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
		WHERE	his.idu_estatus = ' || idEstatus || '
			AND his.idu_tipo_documento IN (1,3,4)
			AND his.idu_beneficiario_externo = 0';
		if(iOpcFecha = 1)then
			sQuery := sQuery || ' AND his.fec_cierre::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
		end if;
		if(iOpcCiclo = 1)then
			sQuery := sQuery || ' AND det.idu_ciclo_escolar = ' || idCiclo || ' ';
		end if;

		raise NOTICE '%', sQuery;
		Execute (sQuery);
	end if;
		--ACTUALIZAR NOMBRE DE EMPRESA
		update	tmp_puestos_becas
		set	nom_empresa = trim(UPPER(emp.nom_empresa))
		from	view_empresas_colegiaturas emp
		where	tmp_puestos_becas.idu_empresa = emp.idu_empresa;
		--ACTUALIZAR NOMBRES DE PUESTO Y CENTRO
		update	tmp_puestos_becas
		set	idu_puesto = A.pueston
			, idu_centro = A.centron
			, clv_ruta_pago = (case when A.controlpago = '' then 0 else A.controlpago::INTEGER end)
		from	sapcatalogoempleados A
		where	tmp_puestos_becas.idu_empleado = A.numempn;

		update	tmp_puestos_becas
		set	nom_puesto = trim(UPPER(P.nombre))
		from	sapcatalogopuestos P
		where	tmp_puestos_becas.idu_puesto = P.numero::INTEGER;

		update	tmp_puestos_becas
		set	nom_centro = trim(UPPER(C.nombrecentro))
			, idu_ciudad = C.ciudadn
			, idu_seccion = C.seccion::INTEGER
		from	sapcatalogocentros C
		where	tmp_puestos_becas.idu_centro = C.numerocentro::INTEGER;

		update	tmp_puestos_becas
		set	idu_region = C.regionzona::INTEGER
		from	sapcatalogociudades C
		where	tmp_puestos_becas.idu_ciudad = C.ciudadn;

		update 	tmp_puestos_becas
		set	idu_area = sa.idu_area
			, nom_area = trim(UPPER(sa.nom_area))
			, nom_seccion = trim(UPPER(sa.nom_seccion))
		from	cat_area_seccion sa
		where	tmp_puestos_becas.idu_seccion = sa.idu_seccion;
		
		/*========APLICAR FILTROS DE BUSQUEDA (PARAMETROS)===========*/

	IF (idRutaPago != -1) THEN
		DELETE FROM tmp_puestos_becas a where a.clv_ruta_pago not in (idRutaPago);
	END IF;
	if (idEmpresa != 0) then
		delete from tmp_puestos_becas a where a.idu_empresa not in (idEmpresa);
	end if;
	if (idRegion != 0) then
		delete from tmp_puestos_becas a where a.idu_region not in (idRegion);
	end if;
	if (idCiudad != 0) then
		delete from tmp_puestos_becas a where a.idu_ciudad not in (idCiudad);
	end if;
	if (idTipoDeduccion != 0) then
		delete from tmp_puestos_becas a where a.idu_tipo_deduccion not in (idTipoDeduccion);
	end if;
	if (idEscolaridad != 0) then
		delete from tmp_puestos_becas a where a.idu_escolaridad not in (idEscolaridad);
	end if;
	if (idcentro != 0) then
		delete from tmp_puestos_becas as tmp where tmp.idu_centro not in (idcentro);
	end if;
	if (idSeccion != '') then
		sQuery := 'delete from tmp_puestos_becas A where A.idu_seccion not in (' || idSeccion || ')';
		execute (sQuery);
	end if;

	--CALCULAR TOTALES POR PUESTO
	insert into tmp_totales_puestos(
		tipo
		, idu_empresa
		, nom_empresa
		, idu_puesto
		, nom_puesto
		, idu_centro
		, nom_centro
		, idu_area
		, nom_area
		, idu_seccion
		, nom_seccion
		, total_colaboradores
		, total_facturas
		, total_importefactura
		, total_importepagado
		, total_beneficiarios)
	SELECT	1
		, tmp.idu_empresa
		, tmp.nom_empresa
		, tmp.idu_puesto
		, tmp.nom_puesto
		, tmp.idu_centro
		, tmp.nom_centro
		, tmp.idu_area
		, tmp.nom_area
		, tmp.idu_seccion
		, tmp.nom_seccion
		, COUNT(DISTINCT tmp.idu_empleado)
		, COUNT(DISTINCT tmp.idfactura)
		, SUM(tmp.importe_factura)
		, SUM(tmp.importe_pagado)
		, COUNT(DISTINCT tmp.idu_beneficiario)
	FROM	tmp_puestos_becas as tmp
	group	by tmp.idu_empresa, tmp.nom_empresa, tmp.idu_puesto, tmp.nom_puesto, tmp.idu_centro
		, tmp.nom_centro, tmp.idu_seccion, tmp.nom_seccion, tmp.idu_area, tmp.nom_area;
    
	TotalRegistros := (select COUNT(*) from tmp_totales_puestos);

	--CALCULAR EL TOTAL GENERAL
	if (TotalRegistros != 0) then
		insert into tmp_totales_puestos(
			tipo
			, total_colaboradores
			, total_facturas
			, total_importefactura
			, total_importepagado
			, total_beneficiarios)
		select	2
			, SUM(tmp.total_colaboradores)
			, SUM(tmp.total_facturas)
			, SUM(tmp.total_importefactura)
			, SUM(tmp.total_importepagado)
			, SUM(tmp.total_beneficiarios)
		From	tmp_totales_puestos as tmp;

		insert into tmp_beneficiarios(beneficiario)
		select COUNT(distinct (idu_beneficiario, idu_empleado)) from tmp_puestos_becas
		group by idu_beneficiario, idu_empleado;

		update	tmp_totales_puestos
		set	total_beneficiarios = (select SUM(beneficiario) from tmp_beneficiarios)
		WHERE	tmp_totales_puestos.tipo = 2;
	end if;
	for valor in (select
			tmp.tipo
			, tmp.idu_empresa
			, tmp.nom_empresa
			, tmp.idu_puesto
			, tmp.nom_puesto
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
			FROM tmp_totales_puestos as tmp
			order by tmp.idu_empresa, tmp.idu_puesto)
			loop
				tipo		:=	valor.tipo;
				idu_empresa	:=	valor.idu_empresa;
				nom_empresa	:=	valor.nom_empresa;
				idu_puesto	:=	valor.idu_puesto;
				nom_puesto	:=	valor.nom_puesto;
				idu_centro	:=	valor.idu_centro;
				nom_centro	:=	valor.nom_centro;
				idu_area	:=	valor.idu_area;
				nom_area	:=	valor.nom_area;
				idu_seccion	:=	valor.idu_seccion;
				nom_seccion	:=	valor.nom_seccion;
				total_colaboradores	:=	valor.total_colaboradores;
				total_facturas		:=	valor.total_facturas;
				total_importefactura	:=	valor.total_importefactura;
				total_importepagado	:=	valor.total_importepagado;
				total_beneficiarios	:=	valor.total_beneficiarios;
				return next;

			end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_colegiaturas_por_puesto(integer, integer, integer, integer, integer, integer, integer, smallint, date, date, smallint, integer, integer, text, integer) IS 'La función genera el reporte de pagos por puesto';