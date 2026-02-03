CREATE TYPE type_fun_obtener_reporte_acumulado_colegiaturas_alt AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    tipo smallint,
    fecha date,
    fecha_mes character varying(15),
    cheques numeric(12,2),
    banamex numeric(12,2),
    invernomina numeric(12,2),
    bancomer numeric(12,2),
    bancoppel numeric(12,2),
    totalimporte numeric(12,2),
    totalprestacion numeric(12,2),
    total50 bigint,
    total60 bigint,
    total70 bigint,
    total80 bigint,
    total90 bigint,
    total100 bigint,
    totalfacturas bigint,
    totalempleados bigint
);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_acumulado_colegiaturas_alt(date, date, integer, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_fun_obtener_reporte_acumulado_colegiaturas_alt AS
$BODY$
DECLARE
	-- PARAMETROS DE FILTRADO.
	dFechaIni ALIAS FOR $1;
	dFechaFin ALIAS FOR $2;
	iDeduccion ALIAS FOR $3;

	/* PARAMETROS DE PAGINADO */
	iRowsPerPage ALIAS FOR $4;
	iCurrentPage ALIAS FOR $5;
	sOrderColumn ALIAS FOR $6;
	sOrderType ALIAS FOR $7;
	sColumns ALIAS FOR $8;
	
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sConsulta VARCHAR(3000);

	returnrec type_fun_obtener_reporte_acumulado_colegiaturas_alt;
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
			SELECT * FROM fun_obtener_reporte_acumulado_colegiaturas_alt('20160101','20161231',0, 
											10,1,'fecha','asc','tipo, dfecha, fecha, 
											cheques,banamex, invernomina, bancomer, bancoppel, 
											totalimporte, totalprestacion, 
											total50, total60, total70, total80, total90, total100, 
											totalfacturas, totalempleados');
	*/
	-- SELECT * FROM his_facturas_colegiaturas;
	-- SELECT * FROM his_detalle_facturas_colegiaturas;
	-- SELECT * FROM sapcatalogoempleados limit(10);
	-- SELECT idu_rutapago,nom_rutapago FROM cat_rutaspagos;

	-- TABLA DE RESULTADO QUE DEVOLVERA LA FUNCION con los datos completos y ordenados.
	CREATE LOCAL TEMP TABLE temp_resultado(
		tipo smallint not null default 0,
		dfecha date not null default '19000101',
		fecha varchar(15) not null default '',
		cheques numeric(12,2) not null default 0.0, -------(1)
		banamex numeric(12,2) not null default 0.0, -------(2)
		invernomina  numeric(12,2) not null default 0.0, --(4)
		bancomer  numeric(12,2) not null default 0.0, -----(5)
		bancoppel numeric(12,2) not null default 0.0, -----(6)
		totalimporte  numeric(12,2) not null default 0.0,
		totalprestacion numeric(12,2) not null default 0.0,
		total50 bigint not null default 0, --------------- DESCUENTO 50%
		total60 bigint not null default 0, --------------- DESCUENTO 60%
		total70 bigint not null default 0, --------------- DESCUENTO 70%
		total80 bigint not null default 0, --------------- DESCUENTO 80%
		total90 bigint not null default 0, --------------- DESCUENTO 90%
		total100 bigint not null default 0,--------------- DESCUENTO 100%
		totalfacturas bigint not null default 0,
		totalempleados bigint not null default 0
	)ON COMMIT DROP;

	-- Tabla que acumulara los datos de las Facturas.
	CREATE LOCAL TEMP TABLE temp_facturas(
		tipo smallint not null default 0,
		dfecha date not null default '19000101',
		fecha varchar(15) not null default '',
		cheques numeric(12,2) not null default 0.0, -------(1)
		banamex numeric(12,2) not null default 0.0, -------(2)
		invernomina  numeric(12,2) not null default 0.0, --(4)
		bancomer  numeric(12,2) not null default 0.0, -----(5)
		bancoppel numeric(12,2) not null default 0.0, -----(6)
		totalimporte  numeric(12,2) not null default 0.0,
		totalprestacion numeric(12,2) not null default 0.0,
		total50 bigint not null default 0, --------------- DESCUENTO 50%
		total60 bigint not null default 0, --------------- DESCUENTO 60%
		total70 bigint not null default 0, --------------- DESCUENTO 70%
		total80 bigint not null default 0, --------------- DESCUENTO 80%
		total90 bigint not null default 0, --------------- DESCUENTO 90%
		total100 bigint not null default 0,--------------- DESCUENTO 100%
		totalfacturas bigint not null default 0,
		totalempleados bigint not null default 0
	)ON COMMIT DROP;

	-- Tabla que Acumula los totales por mes y se utilizara para sacar el Total General .
	CREATE LOCAL TEMP TABLE temp_totales_mes(
		tipo smallint not null default 0,
		fecha_mes varchar(15) not null default '',
		cheques numeric(12,2) not null default 0.0, -------(1)
		banamex numeric(12,2) not null default 0.0, -------(2)
		invernomina  numeric(12,2) not null default 0.0, --(4)
		bancomer  numeric(12,2) not null default 0.0, -----(5)
		bancoppel numeric(12,2) not null default 0.0, -----(6)
		totalimporte  numeric(12,2) not null default 0.0,
		totalprestacion numeric(12,2) not null default 0.0,
		total50 bigint not null default 0, --------------- DESCUENTO 50%
		total60 bigint not null default 0, --------------- DESCUENTO 60%
		total70 bigint not null default 0, --------------- DESCUENTO 70%
		total80 bigint not null default 0, --------------- DESCUENTO 80%
		total90 bigint not null default 0, --------------- DESCUENTO 90%
		total100 bigint not null default 0,--------------- DESCUENTO 100%
		totalfacturas bigint not null default 0,
		totalempleados bigint not null default 0
	)ON COMMIT DROP;
	
	-- Calcular LOS DATOS DE LAS FACTURAS (POR FECHA).
	INSERT INTO temp_facturas(tipo, dfecha, fecha,
		cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados)
	SELECT 0,
		CAST(FC.fec_cierre AS DATE),
		to_char(fc.fec_cierre,'yyyy-MM'),
		SUM(CASE WHEN E.controlpago = '01' THEN FD.importe_pagado ELSE 0 END),-- "CHEQUES"
		SUM(CASE WHEN E.controlpago = '02' THEN FD.importe_pagado ELSE 0 END),-- "BANAMEX PAGOMATICO"
		SUM(CASE WHEN E.controlpago = '04' THEN FD.importe_pagado ELSE 0 END),-- "INVERNOMINA"
		SUM(CASE WHEN E.controlpago = '05' THEN FD.importe_pagado ELSE 0 END),-- "BANCOMER"
		SUM(CASE WHEN E.controlpago = '06' THEN FD.importe_pagado ELSE 0 END),-- "BANCOPPEL"
		SUM(FD.importe_concepto), -- ================> totalimporte
		SUM(FD.importe_pagado),   -- ================> totalprestacion
		(CASE WHEN FD.prc_descuento = 50 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), -- total50
		(CASE WHEN FD.prc_descuento = 60 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), -- total60
		(CASE WHEN FD.prc_descuento = 70 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), -- total70
		(CASE WHEN FD.prc_descuento = 80 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), -- total80
		(CASE WHEN FD.prc_descuento = 90 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END), -- total90
		(CASE WHEN FD.prc_descuento = 100 THEN COUNT(DISTINCT FC.idfactura) ELSE 0 END),-- total100
		COUNT(DISTINCT FC.idfactura),-- =============> totalfacturas
		COUNT(DISTINCT FC.idu_empleado)-- ===========> totalempleados
	FROM his_facturas_colegiaturas FC
		INNER JOIN his_detalle_facturas_colegiaturas FD ON FC.idfactura = FD.idfactura
		INNER JOIN sapcatalogoempleados E ON E.numempn = FC.idu_empleado
	WHERE (CAST(FC.fec_cierre AS DATE) BETWEEN dFechaIni AND dFechaFin)
		AND ((FC.idu_tipo_deduccion = iDeduccion AND iDeduccion != 0) OR (FC.idu_tipo_deduccion = FC.idu_tipo_deduccion AND iDeduccion = 0))
		AND FC.idu_estatus = 5
	GROUP BY CAST(FC.fec_cierre AS DATE),
		to_char(fc.fec_cierre,'yyyy-MM'),
		FD.prc_descuento;

	-- Calcular LOS TOTALES POR MES.
	INSERT INTO temp_totales_mes(tipo, fecha_mes,
		cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados)
	SELECT 1,
		F.fecha,
		SUM(F.cheques),------ "CHEQUES"
		SUM(F.banamex),------ "BANAMEX PAGOMATICO"
		SUM(F.invernomina),-- "INVERNOMINA"
		SUM(F.bancomer),----- "BANCOMER"
		SUM(F.bancoppel),---- "BANCOPPEL"
		SUM(F.totalimporte),------- ================> totalimporte
		SUM(F.totalprestacion),---- ================> totalprestacion
		SUM(F.total50),-- total50
		SUM(F.total60),-- total60
		SUM(F.total70),-- total70
		SUM(F.total80),-- total80
		SUM(F.total90),-- total90
		SUM(F.total100),-- total100
		SUM(F.totalfacturas),---- ===========> totalfacturas
		SUM(F.totalempleados)---- ===========> totalempleados
	FROM temp_facturas F
	GROUP BY F.fecha;

	-- Insertar los totales por mes en la tabla de facturas.
	INSERT INTO temp_facturas(tipo, fecha,
		cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados)
	SELECT M.tipo,
		M.fecha_mes,
		M.cheques, -------(1)
		M.banamex, -------(2)
		M.invernomina, ---(4)
		M.bancomer, ------(5)
		M.bancoppel, -----(6)
		M.totalimporte,
		M.totalprestacion,
		M.total50, --------------- DESCUENTO 50%
		M.total60, --------------- DESCUENTO 60%
		M.total70, --------------- DESCUENTO 70%
		M.total80, --------------- DESCUENTO 80%
		M.total90, --------------- DESCUENTO 90%
		M.total100,--------------- DESCUENTO 100%
		M.totalfacturas,
		M.totalempleados
	FROM temp_totales_mes M;

	-- Calcular EL TOTAL GENERAL
	INSERT INTO temp_facturas(tipo, fecha,
		cheques, banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados)
	SELECT 2,
		'TOTAL GENERAL',
		SUM(M.cheques),------ "CHEQUES"
		SUM(M.banamex),------ "BANAMEX PAGOMATICO"
		SUM(M.invernomina),-- "INVERNOMINA"
		SUM(M.bancomer),----- "BANCOMER"
		SUM(M.bancoppel),---- "BANCOPPEL"
		SUM(M.totalimporte),----- ================> totalimporte
		SUM(M.totalprestacion),-- ================> totalprestacion
		SUM(M.total50),-- total50
		SUM(M.total60),-- total60
		SUM(M.total70),-- total70
		SUM(M.total80),-- total80
		SUM(M.total90),-- total90
		SUM(M.total100),-- total100
		SUM(M.totalfacturas),-- =============> totalfacturas
		SUM(M.totalempleados)-- ===========> totalempleados
	FROM temp_totales_mes M;

	-- Llenar la tabla Resultado con los datos en orden correcto.
	INSERT INTO temp_resultado(tipo, dfecha, fecha, cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados)
	SELECT tipo, dfecha, fecha, cheques,banamex, invernomina, bancomer, bancoppel, totalimporte, totalprestacion, total50, total60, total70, total80, total90, total100, totalfacturas, totalempleados
	FROM temp_facturas
	ORDER BY fecha, TIPO, dfecha;

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
$BODY$
  LANGUAGE plpgsql VOLATILE;