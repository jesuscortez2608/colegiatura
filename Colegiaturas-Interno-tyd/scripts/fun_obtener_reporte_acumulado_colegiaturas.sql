drop function if exists fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, INTEGER, integer, integer, character varying, character varying, character varying);
drop type if exists type_fun_obtener_reporte_acumulado_colegiaturas;

CREATE TYPE type_fun_obtener_reporte_acumulado_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    tipo smallint,
    fecha date,
    fecha_mes character varying(15),
    idu_empresa INTEGER,
    nom_empresa VARCHAR(70),
    cheques numeric(12,2),
    banamex numeric(12,2),
    invernomina numeric(12,2),
    bancomer numeric(12,2),
    bancoppel numeric(12,2),
    totalimporte numeric(12,2),
    totalprestacion numeric(12,2),
    total50 bigint,total51 bigint,total52 bigint,total53 bigint,total54 bigint,total55 bigint,total56 bigint,total57 bigint,total58 bigint,total59 bigint,
    total60 bigint,total61 bigint,total62 bigint,total63 bigint,total64 bigint,total65 bigint,total66 bigint,total67 bigint,total68 bigint,total69 bigint,
    total70 bigint,total71 bigint,total72 bigint,total73 bigint,total74 bigint,total75 bigint,total76 bigint,total77 bigint,total78 bigint,total79 bigint,
    total80 bigint,total81 bigint,total82 bigint,total83 bigint,total84 bigint,total85 bigint,total86 bigint,total87 bigint,total88 bigint,total89 bigint,
    total90 bigint,total91 bigint,total92 bigint,total93 bigint,total94 bigint,total95 bigint,total96 bigint,total97 bigint,total98 bigint,total99 bigint,total100 bigint,
    totalfacturas bigint,
    totalempleados bigint);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, INTEGER, integer, integer, character varying, character varying, character varying)
 RETURNS SETOF type_fun_obtener_reporte_acumulado_colegiaturas
AS $function$
DECLARE
	-- PARAMETROS DE FILTRADO.
	dFechaIni ALIAS FOR $1;
	dFechaFin ALIAS FOR $2;
	iDeduccion ALIAS FOR $3;
	iEmpresa ALIAS FOR $4;

	/* PARAMETROS DE PAGINADO */
	iRowsPerPage ALIAS FOR $5;
	iCurrentPage ALIAS FOR $6;
	sOrderColumn ALIAS FOR $7;
	sOrderType ALIAS FOR $8;
	sColumns ALIAS FOR $9;
	
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sConsulta TEXT;
    iCnt SMALLINT;
	returnrec type_fun_obtener_reporte_acumulado_colegiaturas;
BEGIN
	/* CONTROL DE VARIABLES DE PAGINADO NULAS */
	IF iRowsPerPage = -1 THEN
	iRowsPerPage := NULL;
	END IF;
	if iCurrentPage = -1 THEN
	iCurrentPage := NULL;
	END IF;
	
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
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas('20180601', '20180925', 0, 1, 3, 1, 'fecha', 'asc', '*');
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas('20180101', '20180925', 0, 1,-1, 1, 'idu_empresa, fecha, tipo', 'asc', '*') where tipo > 0;
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas('20180101', '20180925', 0, 16,-1, 1, 'idu_empresa, fecha, tipo', 'asc', '*') where tipo > 0;
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas('20180101', '20180925', 0, 0,-1, 1, 'idu_empresa, fecha, tipo', 'asc', '*');
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas('20180701', '20180731', 0, 1, 3, 1, 'fecha', 'asc', '*');
            
			select distinct idu_empresa from view_his_rutas_pagos where fec_cierre::DATE between '20180101' and '20180925'
	*/
	
	sColumns := 'tipo, dfecha, fecha, idu_empresa, nom_empresa,cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
    sColumns := sColumns || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sColumns := sColumns || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sColumns := sColumns || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sColumns := sColumns || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sColumns := sColumns || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100';
    sColumns := sColumns || ', totalfacturas, totalempleados';
	
	-- TABLA DE RESULTADO QUE DEVOLVERA LA FUNCION con los datos completos y ordenados.
	CREATE LOCAL TEMP TABLE temp_resultado(
		tipo smallint default 0,
		dfecha date default '19000101',
		fecha varchar(15) default '',
		idu_empresa INTEGER,
		nom_empresa varchar(70),
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
	)ON COMMIT DROP;
    
	-- Tabla que acumulara los datos de las Facturas.
	CREATE LOCAL TEMP TABLE temp_facturas(
		tipo smallint default 0,
		dfecha date default '19000101',
		fecha varchar(15) default '',
		idu_empresa INTEGER,
		nom_empresa varchar(70),
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
	)ON COMMIT DROP;
    
	-- Tabla que Acumula los totales por mes y se utilizara para sacar el Total General .
	CREATE LOCAL TEMP TABLE temp_totales_mes(
		tipo smallint default 0,
		fecha_mes varchar(15) default '',
		idu_empresa INTEGER,
		nom_empresa varchar(70),
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
	)ON COMMIT DROP;

	-- Tabla que Acumula los totales por empresa
	CREATE LOCAL TEMP TABLE temp_totales_empresa(
		tipo smallint default 0,
		fecha_mes varchar(15) default '',
		idu_empresa INTEGER,
		nom_empresa varchar(70),
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
	)ON COMMIT DROP;
	
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
	)ON COMMIT DROP;
	
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
    sConsulta := sConsulta || ', to_char(FC.fec_cierre,''yyyy-MM'') ';
    sConsulta := sConsulta || ', FC.idu_estatus ';
    sConsulta := sConsulta || ', FC.clv_rutapago ';
    sConsulta := sConsulta || ', FC.importe_pagado, FC.importe_concepto, FC.prc_descuento, FC.idu_tipo_deduccion ';
    sConsulta := sConsulta || 'FROM view_his_rutas_pagos FC ';
    sConsulta := sConsulta || 'WHERE FC.fec_cierre::DATE BETWEEN ''' || dFechaIni::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
	sConsulta := sConsulta || ' AND FC.idu_estatus = 6 ';
	sConsulta := sConsulta || ' AND FC.idu_empresa > 0 ';
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

    --NOMBRE EMPRESA
    update 	temp_detalle_facturas set nom_empresa = empr.nombre
    from 	sapempresas as empr
    where 	empr.clave = temp_detalle_facturas.idu_empresa;
    
	-- Calcular LOS DATOS DE LAS FACTURAS (POR FECHA).
	sConsulta := 'INSERT INTO temp_facturas(tipo, dfecha, fecha, idu_empresa, nom_empresa, cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
    sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 0, ';
	sConsulta := sConsulta || '	FC.fec_cierre::DATE, ';
	sConsulta := sConsulta || '	FC.fecha, ';
	sConsulta := sConsulta || '	FC.idu_empresa, ';
	sConsulta := sConsulta || '	FC.nom_empresa, ';
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 1 THEN FC.importe_pagado ELSE 0 END), '; -- "CHEQUES"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 2 THEN FC.importe_pagado ELSE 0 END), '; -- "BANAMEX PAGOMATICO"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 4 THEN FC.importe_pagado ELSE 0 END), '; -- "INVERNOMINA"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 5 THEN FC.importe_pagado ELSE 0 END), '; -- "BANCOMER"
	sConsulta := sConsulta || '	SUM(CASE WHEN FC.clv_rutapago = 6 THEN FC.importe_pagado ELSE 0 END), '; -- "BANCOPPEL"
	sConsulta := sConsulta || '	SUM(FC.importe_concepto), '; -- ================> totalimporte
	sConsulta := sConsulta || '	SUM(FC.importe_pagado), ';   -- ================> totalprestacion
	
	iCnt := 50;
	LOOP
        sConsulta := sConsulta || '	(CASE WHEN FC.prc_descuento = ' || iCnt::varchar || ' THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), ';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
	sConsulta := sConsulta || '	COUNT(DISTINCT FC.idfactura), '; -- =============> totalfacturas
	sConsulta := sConsulta || '	COUNT(DISTINCT FC.idu_empleado) '; -- ===========> totalempleados
	sConsulta := sConsulta || 'FROM temp_detalle_facturas FC ';
	sConsulta := sConsulta || 'WHERE FC.fec_cierre::DATE BETWEEN ''' || dFechaIni::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
	sConsulta := sConsulta || ' AND FC.idu_estatus = 6 ';
	sConsulta := sConsulta || ' AND FC.idu_empresa > 0 ';
	
	if iDeduccion > 0 then
        sConsulta := sConsulta || ' AND FC.idu_tipo_deduccion = ' || iDeduccion::varchar || ' ';
    end if;
    
    if iEmpresa > 0 then
        sConsulta := sConsulta || ' AND FC.idu_empresa = ' || iEmpresa::varchar || ' ';
    end if;
    
	sConsulta := sConsulta || 'GROUP BY FC.fec_cierre::DATE, FC.fecha, FC.idu_empresa, FC.nom_empresa, FC.prc_descuento ';
    
    raise notice 'DATOS DE LAS FACTURAS (POR FECHA): %', sConsulta;
    execute sConsulta;
    
    -- Calcular LOS TOTALES POR MES.
	sConsulta := 'INSERT INTO temp_totales_mes(tipo, fecha_mes, idu_empresa, nom_empresa';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion ';
    sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 1, ';
	sConsulta := sConsulta || '    F.fecha,';
	sConsulta := sConsulta || '    F.idu_empresa,';
	sConsulta := sConsulta || '    F.nom_empresa,';
    sConsulta := sConsulta || '    SUM( COALESCE(F.cheques, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.banamex, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.invernomina, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancomer, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancoppel, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalimporte, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalprestacion, 0.0) ),';
    
    iCnt := 50;
	LOOP
        sConsulta := sConsulta || '    SUM( COALESCE(F.total' || iCnt::varchar || ', 0) ),';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
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
	sConsulta := 'INSERT INTO temp_facturas(tipo, fecha, idu_empresa, nom_empresa ';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT M.tipo ';
	sConsulta := sConsulta || ', M.fecha_mes ';
	sConsulta := sConsulta || ', M.idu_empresa ';
	sConsulta := sConsulta || ', M.nom_empresa ';
	sConsulta := sConsulta || ', COALESCE(M.cheques, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.banamex, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.invernomina, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancomer, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.bancoppel, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalimporte, 0.0)';
	sConsulta := sConsulta || ', COALESCE(M.totalprestacion, 0.0)';
	
	iCnt := 50;
	LOOP
        sConsulta := sConsulta || ', COALESCE(M.total' || iCnt::varchar || ', 0)';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
	sConsulta := sConsulta || ', COALESCE(M.totalfacturas, 0)';
	sConsulta := sConsulta || ', COALESCE(M.totalempleados, 0)';
	sConsulta := sConsulta || 'FROM temp_totales_mes M';
    
	raise notice 'TOTALES POR MES: %', sConsulta;
    execute sConsulta;
    
    -- Calcular los totales por empresa
    sConsulta := 'INSERT INTO temp_totales_empresa(tipo, fecha_mes, idu_empresa, nom_empresa';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion ';
    sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 2, ';
	sConsulta := sConsulta || '    ''TOTAL EMPRESA'',';
	sConsulta := sConsulta || '    F.idu_empresa,';
	sConsulta := sConsulta || '    F.nom_empresa,';
    sConsulta := sConsulta || '    SUM( COALESCE(F.cheques, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.banamex, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.invernomina, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancomer, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.bancoppel, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalimporte, 0.0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalprestacion, 0.0) ),';
    
    iCnt := 50;
	LOOP
        sConsulta := sConsulta || '    SUM( COALESCE(F.total' || iCnt::varchar || ', 0) ),';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalfacturas, 0) ),';
    sConsulta := sConsulta || '    SUM( COALESCE(F.totalempleados, 0) )';
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
	sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
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
	
	iCnt := 50;
	LOOP
        sConsulta := sConsulta || ', COALESCE(M.total' || iCnt::varchar || ', 0)';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
	sConsulta := sConsulta || ', COALESCE(M.totalfacturas, 0)';
	sConsulta := sConsulta || ', COALESCE(M.totalempleados, 0)';
	sConsulta := sConsulta || 'FROM temp_totales_empresa M';
    
    raise notice 'TOTALES POR EMPRESA: %', sConsulta;
    execute sConsulta;
    
	-- Calcular EL TOTAL GENERAL
	sConsulta := 'INSERT INTO temp_facturas(tipo, fecha, idu_empresa, nom_empresa ';
	sConsulta := sConsulta || ', cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
	sConsulta := sConsulta || 'SELECT 3';
    sConsulta := sConsulta || ', ''TOTAL GENERAL''';
    sConsulta := sConsulta || ', 9999 as idu_empresa ';
    sConsulta := sConsulta || ', '''' as nom_empresa ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.cheques, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.banamex, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.invernomina, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.bancomer, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.bancoppel, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalimporte, 0.0) ) ';
    sConsulta := sConsulta || ', SUM( COALESCE(M.totalprestacion, 0.0) ) ';
    
    iCnt := 50;
	LOOP
        sConsulta := sConsulta || ', SUM( COALESCE(M.total' || iCnt::VARCHAR || ', 0) ) ';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
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
	sConsulta := 'INSERT INTO temp_resultado(tipo, dfecha, fecha, idu_empresa, nom_empresa, cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion';
	sConsulta := sConsulta || ', total50, total51, total52, total53, total54, total55, total56, total57, total58, total59';
    sConsulta := sConsulta || ', total60, total61, total62, total63, total64, total65, total66, total67, total68, total69';
    sConsulta := sConsulta || ', total70, total71, total72, total73, total74, total75, total76, total77, total78, total79';
    sConsulta := sConsulta || ', total80, total81, total82, total83, total84, total85, total86, total87, total88, total89';
    sConsulta := sConsulta || ', total90, total91, total92, total93, total94, total95, total96, total97, total98, total99, total100, totalfacturas, totalempleados)';
    sConsulta := sConsulta || 'SELECT tipo, dfecha, fecha, idu_empresa, nom_empresa ';
    sConsulta := sConsulta || ', COALESCE(cheques, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(banamex, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(invernomina, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(bancomer, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(bancoppel, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(totalimporte, 0.0) ';
    sConsulta := sConsulta || ', COALESCE(totalprestacion, 0.0) ';
    
    iCnt := 50;
	LOOP
        sConsulta := sConsulta || ', COALESCE(total' || iCnt::VARCHAR || ', 0) ';
        iCnt := iCnt + 1;
        EXIT WHEN iCnt > 100;
    END LOOP;
    
    sConsulta := sConsulta || ', COALESCE(totalfacturas, 0) ';
    sConsulta := sConsulta || ', COALESCE(totalempleados, 0) ';
	sConsulta := sConsulta || 'FROM temp_facturas ';
	sConsulta := sConsulta || 'ORDER BY idu_empresa, fecha, tipo, dfecha ';
	
	raise notice 'Llenar la tabla Resultado con los datos en orden correcto: %', sConsulta;
    execute sConsulta;
    
	iRecords := (SELECT COUNT(*) FROM temp_resultado);
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) THEN
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM temp_resultado);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
		sConsulta := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM temp_resultado
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM temp_resultado ';
	END if;
	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
	
	RAISE NOTICE 'notice %', sConsulta;
	
	FOR returnrec in execute sConsulta loop
		RETURN NEXT returnrec;
	end loop;
END;
$function$
LANGUAGE plpgsql volatile security definer;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, integer, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, integer, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, integer, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, integer, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_acumulado_colegiaturas(date, date, integer, integer, integer, integer, character varying, character varying, character varying) IS 'La función obtiene el reporte del acumulado de pagos de colegiaturas.';