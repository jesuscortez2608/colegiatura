-- Function: public.fun_obtener_reporte_acumulado_colegiaturas_rpt(date, date, integer, integer)

-- DROP FUNCTION public.fun_obtener_reporte_acumulado_colegiaturas_rpt(date, date, integer, integer);

CREATE OR REPLACE FUNCTION public.fun_obtener_reporte_acumulado_colegiaturas_rpt(
    date,
    date,
    integer,
    integer)
  RETURNS SETOF type_fun_obtener_reporte_acumulado_colegiaturas_rpt AS
$BODY$
DECLARE
	-- PARAMETROS DE FILTRADO.
	dFechaIni ALIAS FOR $1;
	dFechaFin ALIAS FOR $2;
	iDeduccion ALIAS FOR $3;
	iEmpresa ALIAS FOR $4;
    
    sColumns TEXT;
	sConsulta TEXT;
    iCnt SMALLINT;
	returnrec type_fun_obtener_reporte_acumulado_colegiaturas_rpt;
BEGIN
	/*
		No. petición APS               : 8613.1
		Fecha                          : 22/12/2016
		Número empleado                : 97695068
		Nombre del empleado            : Hector Medina Escareño
		Base de datos                  : administracion
		Servidor de produccion         : 
		Descripción del funcionamiento : Regresa un acumulado de las facturas pagadas
		Descripción del cambio         : NA
		Sistema                        : Colegiaturas
		Módulo                         : Reportes / Acumulado de facturas
		Ejemplo                        : 
			SELECT idu_empresa
                , nom_empresa
                , tipo
                , fecha
                , fecha_mes
                , cheques
                , banamex
                , invernomina
                , bancomer
                , bancoppel
                , totalimporte
                , totalprestacion
                , total50
                , total60
                , total70
                , total80
                , total90
                , totalfacturas
                , totalempleados
			FROM fun_obtener_reporte_acumulado_colegiaturas_rpt('20180101', '20180925', 0, 1);
	*/
	
	sColumns := 'idu_empresa, nom_empresa, tipo, dfecha, fecha,cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
    sColumns := sColumns || ', total50';
    sColumns := sColumns || ', total60';
    sColumns := sColumns || ', total70';
    sColumns := sColumns || ', total80';
    sColumns := sColumns || ', total90';
    sColumns := sColumns || ', totalfacturas, totalempleados';
	
	-- TABLA DE RESULTADO QUE DEVOLVERA LA FUNCION con los datos completos y ordenados.
	CREATE LOCAL TEMP TABLE temp_resultado(
        idu_empresa integer,
        nom_empresa varchar(70),
		tipo smallint default 0,
		dfecha date default '19000101',
		fecha varchar(15) default '',
		cheques numeric(12,2) default 0.0, -------(1)
		banamex numeric(12,2) default 0.0, -------(2)
		invernomina  numeric(12,2) default 0.0, --(4)
		bancomer  numeric(12,2) default 0.0, -----(5)
		bancoppel numeric(12,2) default 0.0, -----(6)
		totalimporte  numeric(12,2) default 0.0,
		totalprestacion numeric(12,2) default 0.0,
		total50 BIGINT DEFAULT 0,
        total60 BIGINT DEFAULT 0,
        total70 BIGINT DEFAULT 0,
        total80 BIGINT DEFAULT 0,
        total90 BIGINT DEFAULT 0,
		totalfacturas bigint default 0,
		totalempleados bigint default 0
	) ON COMMIT DROP;
    
	-- Tabla que acumulara los datos de las Facturas.
	CREATE LOCAL TEMP TABLE temp_facturas(
        idu_empresa integer,
        nom_empresa varchar(70),
		tipo smallint default 0,
		dfecha date default '19000101',
		fecha varchar(15) default '',
		cheques numeric(12,2) default 0.0, -------(1)
		banamex numeric(12,2) default 0.0, -------(2)
		invernomina  numeric(12,2) default 0.0, --(4)
		bancomer  numeric(12,2) default 0.0, -----(5)
		bancoppel numeric(12,2) default 0.0, -----(6)
		totalimporte  numeric(12,2) default 0.0,
		totalprestacion numeric(12,2) default 0.0,
		total50 BIGINT DEFAULT 0,
        total60 BIGINT DEFAULT 0,
        total70 BIGINT DEFAULT 0,
        total80 BIGINT DEFAULT 0,
        total90 BIGINT DEFAULT 0,
		totalfacturas bigint default 0,
		totalempleados bigint default 0
	) ON COMMIT DROP;
    
	-- Tabla que Acumula los totales por mes y se utilizara para sacar el Total General .
	CREATE LOCAL TEMP TABLE temp_totales_mes(
        idu_empresa integer,
        nom_empresa varchar(70),
		tipo smallint default 0,
		fecha_mes varchar(15) default '',
		cheques numeric(12,2) default 0.0, -------(1)
		banamex numeric(12,2) default 0.0, -------(2)
		invernomina  numeric(12,2) default 0.0, --(4)
		bancomer  numeric(12,2) default 0.0, -----(5)
		bancoppel numeric(12,2) default 0.0, -----(6)
		totalimporte  numeric(12,2) default 0.0,
		totalprestacion numeric(12,2) default 0.0,
		total50 BIGINT DEFAULT 0,
        total60 BIGINT DEFAULT 0,
        total70 BIGINT DEFAULT 0,
        total80 BIGINT DEFAULT 0,
        total90 BIGINT DEFAULT 0,
		totalfacturas bigint default 0,
		totalempleados bigint default 0
	) ON COMMIT DROP;
	
	-- Tabla que Acumula los totales por empresa
	CREATE LOCAL TEMP TABLE temp_totales_empresa (
        idu_empresa INTEGER,
		nom_empresa varchar(70),
		tipo smallint default 0,
		fecha_mes varchar(15) default '',
		cheques numeric(12,2) default 0.0, -------(1)
		banamex numeric(12,2) default 0.0, -------(2)
		invernomina  numeric(12,2) default 0.0, --(4)
		bancomer  numeric(12,2) default 0.0, -----(5)
		bancoppel numeric(12,2) default 0.0, -----(6)
		totalimporte  numeric(12,2) default 0.0,
		totalprestacion numeric(12,2) default 0.0,
		total50 BIGINT DEFAULT 0, total51 BIGINT DEFAULT 0, total52 BIGINT DEFAULT 0, total53 BIGINT DEFAULT 0, total54 BIGINT DEFAULT 0, total55 BIGINT DEFAULT 0, total56 BIGINT DEFAULT 0, total57 BIGINT DEFAULT 0, total58 BIGINT DEFAULT 0, total59 BIGINT DEFAULT 0, 
        total60 BIGINT DEFAULT 0, total61 BIGINT DEFAULT 0, total62 BIGINT DEFAULT 0, total63 BIGINT DEFAULT 0, total64 BIGINT DEFAULT 0, total65 BIGINT DEFAULT 0, total66 BIGINT DEFAULT 0, total67 BIGINT DEFAULT 0, total68 BIGINT DEFAULT 0, total69 BIGINT DEFAULT 0, 
        total70 BIGINT DEFAULT 0, total71 BIGINT DEFAULT 0, total72 BIGINT DEFAULT 0, total73 BIGINT DEFAULT 0, total74 BIGINT DEFAULT 0, total75 BIGINT DEFAULT 0, total76 BIGINT DEFAULT 0, total77 BIGINT DEFAULT 0, total78 BIGINT DEFAULT 0, total79 BIGINT DEFAULT 0, 
        total80 BIGINT DEFAULT 0, total81 BIGINT DEFAULT 0, total82 BIGINT DEFAULT 0, total83 BIGINT DEFAULT 0, total84 BIGINT DEFAULT 0, total85 BIGINT DEFAULT 0, total86 BIGINT DEFAULT 0, total87 BIGINT DEFAULT 0, total88 BIGINT DEFAULT 0, total89 BIGINT DEFAULT 0, 
        total90 BIGINT DEFAULT 0, total91 BIGINT DEFAULT 0, total92 BIGINT DEFAULT 0, total93 BIGINT DEFAULT 0, total94 BIGINT DEFAULT 0, total95 BIGINT DEFAULT 0, total96 BIGINT DEFAULT 0, total97 BIGINT DEFAULT 0, total98 BIGINT DEFAULT 0, total99 BIGINT DEFAULT 0, 
        total100 BIGINT DEFAULT 0,
		totalfacturas bigint default 0,
		totalempleados bigint default 0
	) ON COMMIT DROP;
    
	-- Detalle de facturas
	CREATE LOCAL TEMP TABLE temp_detalle_facturas(
		idu_empresa INTEGER,
		nom_empresa varchar(70),
		idu_empleado INTEGER,
		idfactura INTEGER,
		idu_estatus INTEGER,
		fec_cierre DATE,
		fecha VARCHAR(15),
		clv_rutapago INTEGER,
		importe_pagado NUMERIC(12,2),
		importe_concepto NUMERIC(12,2),
		prc_descuento INTEGER,
		idu_tipo_deduccion INTEGER
	) ON COMMIT DROP;
	
	CREATE LOCAL TEMP TABLE tmp_importe_concepto(		
		idfactura INTEGER,		
		importe_concepto NUMERIC(12,2)		
	)ON COMMIT DROP;
    /*
    sConsulta := 'INSERT INTO temp_detalle_facturas (idu_empresa, idu_empleado, idfactura, fec_cierre, fecha, idu_estatus, clv_rutapago, importe_pagado, importe_concepto, prc_descuento, idu_tipo_deduccion)';
    sConsulta := sConsulta || 'SELECT FC.idu_empresa ';
    sConsulta := sConsulta || ', FC.idu_empleado ';
    sConsulta := sConsulta || ', FC.idfactura ';
    sConsulta := sConsulta || ', FC.fec_cierre ';
    sConsulta := sConsulta || ', to_char(FC.fec_cierre,''yyyy-MM'') as fecha ';
    sConsulta := sConsulta || ', FC.idu_estatus ';
    sConsulta := sConsulta || ', FC.clv_rutapago ';
    sConsulta := sConsulta || ', FC.importe_pagado, FC.importe_concepto, FC.prc_descuento, FC.idu_tipo_deduccion ';
    sConsulta := sConsulta || 'FROM view_his_rutas_pagos FC ';
    sConsulta := sConsulta || 'WHERE FC.fec_cierre::DATE BETWEEN ''' || dFechaIni::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
	sConsulta := sConsulta || ' AND FC.idu_estatus = 6 ';
	sConsulta := sConsulta || ' AND FC.idu_empresa > 0 ';
	
	if iDeduccion > 0 then
        sConsulta := sConsulta || ' AND FC.idu_tipo_deduccion = ' || iDeduccion::varchar || ' ';
    end if;
    
    if iEmpresa > 0 then
        sConsulta := sConsulta || ' AND FC.idu_empresa = ' || iEmpresa::varchar || ' ';
    end if;
    
    raise notice 'DETALLE DE FACTURAS: %', sConsulta;
    execute sConsulta;
    */


sConsulta := 'INSERT INTO temp_detalle_facturas (idfactura)';
	sConsulta := sConsulta || 'SELECT DISTINCT FC.idfactura ';    
	sConsulta := sConsulta || 'FROM view_his_rutas_pagos FC ';
	sConsulta := sConsulta || 'WHERE FC.fec_cierre::DATE BETWEEN ''' || dFechaIni::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
	sConsulta := sConsulta || ' AND FC.idu_estatus = 6 ';
	sConsulta := sConsulta || ' AND FC.idu_empresa > 0 ';
		
	if iDeduccion > 0 then
        sConsulta := sConsulta || ' AND FC.idu_tipo_deduccion = ' || iDeduccion::varchar || ' ';
    end if;
    
    if iEmpresa > 0 then
        sConsulta := sConsulta || ' AND FC.idu_empresa = ' || iEmpresa::varchar || ' ';
    end if;
    
    raise notice 'DETALLE DE FACTURAS: %', sConsulta;
    execute sConsulta;
	
	--
	update	temp_detalle_facturas set idu_empresa=FC.idu_empresa, 
			idu_empleado=FC.idu_empleado, 
			--idfactura, 
			fec_cierre=FC.fec_cierre, 
			fecha=to_char(FC.fec_cierre,'yyyy-MM'), 
			idu_estatus=FC.idu_estatus, 
			clv_rutapago=FC.clv_rutapago, 
			importe_pagado=FC.importe_pagado, 
			--importe_concepto=FC.importe_concepto, 
			prc_descuento=FC.prc_descuento, 
			idu_tipo_deduccion=FC.idu_tipo_deduccion
	FROM 	view_his_rutas_pagos FC
	where 	FC.idfactura=temp_detalle_facturas.idfactura;
	
	--INSERTAR IMPORTE CONCEPTO
	insert 	into tmp_importe_concepto (idfactura,importe_concepto)
	select 	idfactura, sum (importe_concepto) 
	from 	view_his_rutas_pagos
	where 	idfactura in (select idfactura from temp_detalle_facturas)
	GROUP 	BY idfactura;

	--ACTUALIZAR IMPORTE CONCEPTO
	update 	temp_detalle_facturas set importe_concepto=B.importe_concepto
	from	tmp_importe_concepto B
	where	temp_detalle_facturas.idfactura=B.idfactura;	
    
    update temp_detalle_facturas set nom_empresa = empr.nombre
    from sapempresas as empr
    where empr.clave = temp_detalle_facturas.idu_empresa;
    
	-- Calcular LOS DATOS DE LAS FACTURAS (POR FECHA).
	sConsulta := 'INSERT INTO temp_facturas(idu_empresa, nom_empresa, tipo, dfecha, fecha, cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
    sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT FC.idu_empresa, FC.nom_empresa, 0 as tipo, ';
	sConsulta := sConsulta || '	FC.fec_cierre::DATE, ';
	sConsulta := sConsulta || '	FC.fecha, ';
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 1 THEN FC.importe_pagado ELSE 0 END), '; -- "CHEQUES"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 2 THEN FC.importe_pagado ELSE 0 END), '; -- "BANAMEX PAGOMATICO"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 4 THEN FC.importe_pagado ELSE 0 END), '; -- "INVERNOMINA"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 5 THEN FC.importe_pagado ELSE 0 END), '; -- "BANCOMER"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 6 THEN FC.importe_pagado ELSE 0 END), '; -- "BANCOPPEL"
	sConsulta := sConsulta || '	SUM(FC.importe_concepto), '; -- ================> totalimporte
	sConsulta := sConsulta || '	SUM(FC.importe_pagado), ';   -- ================> totalprestacion
	
	sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento between 50 and 60 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
	sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento between 61 and 70 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
	sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento between 71 and 80 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
	sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento between 81 and 90 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
	sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento between 91 and 100 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
    
	sConsulta := sConsulta || '	COUNT(DISTINCT FC.idfactura), '; -- =============> totalfacturas
	sConsulta := sConsulta || '	COUNT(DISTINCT FC.idu_empleado) '; -- ===========> totalempleados
	sConsulta := sConsulta || 'FROM temp_detalle_facturas FC ';
	
	sConsulta := sConsulta || 'GROUP BY FC.fec_cierre::DATE, FC.fecha, FC.idu_empresa, FC.nom_empresa, FC.prc_descuento ';
    
    raise notice 'DATOS DE LAS FACTURAS (POR FECHA): %', sConsulta;
    execute sConsulta;
    
    -- Calcular LOS TOTALES POR MES.
	sConsulta := 'INSERT INTO temp_totales_mes(idu_empresa, nom_empresa, tipo, fecha_mes';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion ';
    sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT F.idu_empresa, F.nom_empresa, 1, F.fecha, ';
    sConsulta := sConsulta || '    SUM( COALESCE(F.cheques, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.banamex, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.invernomina, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancomer, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancoppel, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalimporte, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalprestacion, 0.0) ),';
    
    sConsulta := sConsulta || '    SUM( COALESCE(F.total50, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.total60, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.total70, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.total80, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.total90, 0) ),';
    
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalfacturas, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalempleados, 0) )';
    sConsulta := sConsulta || 'FROM temp_facturas F ';
    sConsulta := sConsulta || 'GROUP BY F.idu_empresa, F.nom_empresa, F.fecha';
    
    raise notice '%', sConsulta;
    execute sConsulta;
    
    -- Totales por mes
	update temp_totales_mes set totalfacturas = sub.totalfacturas
        , totalempleados = sub.totalempleados
    from (
        select FC.idu_empresa
            , FC.fecha mes
            , count(distinct FC.idfactura) as totalfacturas
            , count(distinct FC.idu_empleado) as totalempleados
        from temp_detalle_facturas as FC
        GROUP BY FC.idu_empresa, FC.fecha
        ) as sub
    where temp_totales_mes.idu_empresa = sub.idu_empresa
        and temp_totales_mes.fecha_mes = sub.mes
        and temp_totales_mes.tipo = 1;
    
	-- Insertar los totales por mes en la tabla de facturas.
	sConsulta := 'INSERT INTO temp_facturas(idu_empresa, nom_empresa, tipo, fecha';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT M.idu_empresa, M.nom_empresa, M.tipo ';
	sConsulta := sConsulta || ', M.fecha_mes ';
	sConsulta := sConsulta || ', COALESCE(M.cheques, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.banamex, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.invernomina, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancomer, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancoppel, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalimporte, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalprestacion, 0.0)';
    
	sConsulta := sConsulta || ', COALESCE(M.total50, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total60, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total70, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total80, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total90, 0)';
	
	sConsulta := sConsulta || ', COALESCE(M.totalfacturas, 0)';
	sConsulta := sConsulta || ', COALESCE(M.totalempleados, 0)';
	sConsulta := sConsulta || 'FROM temp_totales_mes M';
    
	raise notice 'TOTALES POR MES: %', sConsulta;
    execute sConsulta;
    
    -- Calcular los totales por empresa
    sConsulta := 'INSERT INTO temp_totales_empresa(tipo, fecha_mes, idu_empresa, nom_empresa';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion ';
    sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 2 ';
	sConsulta := sConsulta || ', ''TOTAL EMPRESA'' ';
	sConsulta := sConsulta || ', F.idu_empresa ';
	sConsulta := sConsulta || ', F.nom_empresa ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.cheques, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.banamex, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.invernomina, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.bancomer, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.bancoppel, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.totalimporte, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.totalprestacion, 0.0) ) ';
    
    sConsulta := sConsulta || ', SUM(COALESCE(F.total50, 0)) ';
	sConsulta := sConsulta || ', SUM(COALESCE(F.total60, 0)) ';
	sConsulta := sConsulta || ', SUM(COALESCE(F.total70, 0)) ';
	sConsulta := sConsulta || ', SUM(COALESCE(F.total80, 0)) ';
	sConsulta := sConsulta || ', SUM(COALESCE(F.total90, 0)) ';
    
    sConsulta := sConsulta || ', SUM( COALESCE(F.totalfacturas, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(F.totalempleados, 0) ) ';
    sConsulta := sConsulta || 'FROM temp_facturas F ';
    sConsulta := sConsulta || 'WHERE F.tipo = 1 ';
    sConsulta := sConsulta || 'GROUP BY F.idu_empresa, F.nom_empresa';
    
    raise notice '%', sConsulta;
    execute sConsulta;
    
    -- Total de empleados por empresa
    update temp_totales_empresa set totalfacturas = sub.totalfacturas
        , totalempleados = sub.totalempleados
    from (
        select idu_empresa
            , count(distinct idfactura) as totalfacturas
            , count(distinct idu_empleado) as totalempleados
        from temp_detalle_facturas
        group by idu_empresa
        ) as sub
    where sub.idu_empresa = temp_totales_empresa.idu_empresa;
    
    -- Insertar los totales por empresa en la tabla de facturas.
	sConsulta := 'INSERT INTO temp_facturas(tipo, fecha, idu_empresa, nom_empresa ';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT M.tipo ';
	sConsulta := sConsulta || ', M.fecha_mes ';
	sConsulta := sConsulta || ', M.idu_empresa ';
	sConsulta := sConsulta || ', '''' AS nom_empresa ';
	sConsulta := sConsulta || ', COALESCE(M.cheques, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.banamex, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.invernomina, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancomer, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancoppel, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalimporte, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalprestacion, 0.0)';
    
	sConsulta := sConsulta || ', COALESCE(M.total50, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total60, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total70, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total80, 0)';
	sConsulta := sConsulta || ', COALESCE(M.total90, 0)';
    
	sConsulta := sConsulta || ', COALESCE(M.totalfacturas, 0)';
	sConsulta := sConsulta || ', COALESCE(M.totalempleados, 0)';
	sConsulta := sConsulta || 'FROM temp_totales_empresa M';
    
    raise notice 'TOTALES POR EMPRESA: %', sConsulta;
    execute sConsulta;
    
	-- Calcular EL TOTAL GENERAL
	sConsulta := 'INSERT INTO temp_facturas(tipo, fecha';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 3';
    sConsulta := sConsulta || ', ''TOTAL GENERAL''';
    sConsulta := sConsulta || ', SUM( COALESCE(M.cheques, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.banamex, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.invernomina, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.bancomer, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.bancoppel, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalimporte, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalprestacion, 0.0) ) ';
    
    sConsulta := sConsulta || ', SUM( COALESCE(M.total50, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.total60, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.total70, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.total80, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.total90, 0) ) ';
    
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalfacturas, 0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalempleados, 0) ) ';
	sConsulta := sConsulta || 'FROM temp_totales_mes M ';
	
    raise notice 'Calcular EL TOTAL GENERAL: %', sConsulta;
    execute sConsulta;

    update temp_facturas set totalfacturas = sub.totalfacturas
        , totalempleados = sub.totalempleados
    from (
        select count(distinct idfactura) as totalfacturas
            , count(distinct idu_empleado) as totalempleados
        from temp_detalle_facturas
        ) as sub
    where temp_facturas.tipo = 3;
    
	-- Llenar la tabla Resultado con los datos en orden correcto.
	sConsulta := 'INSERT INTO temp_resultado(idu_empresa, nom_empresa, tipo, dfecha, fecha, cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50';
    sConsulta := sConsulta || ', total60';
    sConsulta := sConsulta || ', total70';
    sConsulta := sConsulta || ', total80';
    sConsulta := sConsulta || ', total90, totalfacturas, totalempleados)';
    sConsulta := sConsulta || 'SELECT idu_empresa, nom_empresa, tipo, dfecha, fecha ';
    sConsulta := sConsulta || ', COALESCE(cheques, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(banamex, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(invernomina, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(bancomer, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(bancoppel, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(totalimporte, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(totalprestacion, 0.0) ';
    
    sConsulta := sConsulta || ', COALESCE(total50, 0) ';
    sConsulta := sConsulta || ', COALESCE(total60, 0) ';
    sConsulta := sConsulta || ', COALESCE(total70, 0) ';
    sConsulta := sConsulta || ', COALESCE(total80, 0) ';
    sConsulta := sConsulta || ', COALESCE(total90, 0) ';
    
    sConsulta := sConsulta || ', COALESCE(totalfacturas, 0) ';
    sConsulta := sConsulta || ', COALESCE(totalempleados, 0) ';
	sConsulta := sConsulta || 'FROM temp_facturas ';
	sConsulta := sConsulta || 'ORDER BY idu_empresa, fecha, tipo, dfecha ';
	
	raise notice 'Llenar la tabla Resultado con los datos en orden correcto: %', sConsulta;
    execute sConsulta;
    
	sConsulta := ' SELECT ' || sColumns || ' FROM temp_resultado ';
	sConsulta := sConsulta || 'ORDER BY idu_empresa, fecha, tipo';
	
	RAISE NOTICE 'notice %', sConsulta;
	
	FOR returnrec in execute sConsulta loop
		RETURN NEXT returnrec;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100
  ROWS 1000;
ALTER FUNCTION public.fun_obtener_reporte_acumulado_colegiaturas_rpt(date, date, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.fun_obtener_reporte_acumulado_colegiaturas_rpt(date, date, integer, integer) TO syspersonal;