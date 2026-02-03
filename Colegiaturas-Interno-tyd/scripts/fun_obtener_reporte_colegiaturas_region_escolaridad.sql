DROP FUNCTION IF EXISTS fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date);
DROP TYPE IF EXISTS type_obtener_reporte_colegiaturas_region_escolaridad;

CREATE TYPE type_obtener_reporte_colegiaturas_region_escolaridad AS
   (numero_region smallint,
    nombre_region character varying(20),
    total_maternal numeric(12,2),
    total_kinder numeric(12,2),
    total_primaria numeric(12,2),
    total_secundaria numeric(12,2),
    total_preparatoria numeric(12,2),
    total_maestria numeric(12,2),
    total_ingles numeric(12,2),
    total_otro_idioma numeric(12,2),
    total_otros_estudios numeric(12,2),
    total_doctorado numeric(12,2),
    total_general numeric(12,2));

CREATE OR REPLACE FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date)
  RETURNS SETOF type_obtener_reporte_colegiaturas_region_escolaridad AS
$BODY$
declare 
	returnrec type_obtener_reporte_colegiaturas_region_escolaridad;
	/*
		No. peticiÃ³n APS               : 8613.1
		Fecha                          : 21/12/2016
		NÃºmero empleado                : 97695068
		Nombre del empleado            : HÃ©ctor Medina EscareÃ±o
		Base de datos                  : Personal
		Servidor de pruebas            : 10.44.2.89
		Servidor de produccion         : 10.44.2.183
		DescripciÃ³n del funcionamiento : Genera el reporte de becas por Region y escolaridad.
		DescripciÃ³n del cambio         : NA
		Sistema                        : Colegiaturas
		MÃ³dulo                         : Reportes
		Ejemplo                        : 
			SELECT * FROM fun_obtener_reporte_colegiaturas_region_escolaridad(-1, 2, 1, '20160101','20170131');
	*/

	-- PARAMETROS DE FILTRADO
	iRutaPago ALIAS FOR $1;
	iEstatus ALIAS FOR $2;
	iTipoDeduccion ALIAS FOR $3;
	dFechaInicio ALIAS FOR $4;
	dFechaFin ALIAS FOR $5;

	/*
		SELECT * FROM cat_escolaridades;
		SELECT * FROM sapcatalogoempleados;
		SELECT * FROM cat_empleados_colegiaturas WHERE numempn = 41101;
		SELECT * FROM sapcatalogoempleados WHERE numempn IN (95194185,93902761,91047781,92486819,97060151)
	*/
	-- SELECT * FROM his_facturas_colegiaturas /* idfactura */
	-- SELECT * FROM his_detalle_facturas_colegiaturas /* idfactura - idu_ciclo_escolar */
	-- SELECT * FROM mov_facturas_colegiaturas /* idu_empleado */
	-- SELECT * FROM sapcatalogoempleados limit(10) /* numempn - centron - pueston */ select * from sapcatalogoPuestos /* Para sacar el puesto del patron y el empleado. */
	-- SELECT * FROM sapcatalogocentros limit(10) /* centron - ciudadn */
	-- SELECT * FROM sapcatalogociudades /* ciudadn - regionzona */
	-- SELECT * FROM sapregiones /* numero */
BEGIN
	CREATE LOCAL TEMP TABLE temp_empleados_permitidos(
		num_empleado integer
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE temp_centros_permitidos(
		idu_centro integer
	)ON COMMIT DROP;

	-- Tabla temporal para guardar los datos de la factura, tanto de "mov", "his".
	CREATE LOCAL TEMP TABLE temp_movimientos_facturas(
		idu_factura integer, ----------- Columnas del cabecero.
		idu_empleado integer,
		idu_centro integer,
		idu_estatus integer,
		idu_tipo_deduccion integer,
		idu_escolaridad integer, ------- Columnas del detalle.
		importe_concepto numeric(12,2),
		importe_pagado numeric(12, 2),
		keyx integer
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE temp_facturas(
		idu_empleado integer,
		idu_centro integer,
		idu_ciudad integer,
		idu_region smallint,
		idu_escolaridad integer,
		importe_concepto numeric(12, 2),
		importe_pagado numeric(12, 2)
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE temp_reporte_colegiaturas_region_escolaridad(
		numero_region smallint,
		nombre_region character varying(20),
		total_maternal numeric(12,2),---------"MATERNAL"
		total_kinder numeric(12,2),-----------"KINDER"
		total_primaria numeric(12,2),---------"PRIMARIA"
		total_secundaria numeric(12,2),	------"SECUNDARIA"
		total_preparatoria numeric(12,2),-----"PREPARATORIA"
		total_maestria numeric(12,2),---------"MAESTRÍA"
		total_ingles numeric(12,2),-----------"INGLÉS"
		total_otro_idioma numeric(12,2),------"OTRO IDIOMA"
		total_otros_estudios numeric(12,2),---"OTROS ESTUDIOS"
		total_doctorado numeric(12,2),	------"DOCTORADO"
		total_general numeric(12,2)----------- |>> TOTAL GENERAL <<|
	)ON COMMIT DROP;

	-- Determinar los empleados permitidos.
	INSERT INTO temp_empleados_permitidos(num_empleado)
	SELECT idu_empleado 
	FROM cat_empleados_colegiaturas e
	WHERE ((e.idu_rutapago = iRutaPago AND iRutaPago != -1) OR (e.idu_rutapago = e.idu_rutapago AND iRutaPago = -1))
	GROUP BY idu_empleado;


	-- Llenar los datos de las tablas de facturas "mov" y "his".
	-- Guardar los datos de las facturas. Empezando por las facturas de "mov".
	INSERT INTO temp_movimientos_facturas(idu_factura, idu_empleado, idu_centro, idu_estatus, idu_tipo_deduccion, idu_escolaridad, importe_concepto, importe_pagado, keyx)
	SELECT FC.idfactura, FC.idu_empleado, FC.idu_centro, FC.idu_estatus, FC.idu_tipo_deduccion, FD.idu_escolaridad, FD.importe_concepto, FD.importe_pagado, FD.keyx
	FROM mov_facturas_colegiaturas FC
		INNER JOIN mov_detalle_facturas_colegiaturas FD	ON FC.idfactura = FD.idfactura
	WHERE (FC.idu_estatus = iEstatus AND FC.idu_estatus NOT IN(5, 6)) -- Filtro por estatus. Discriminar las Facturas con estatus: (5).-Pagada Y (6).-Cancelada
		AND ((FC.idu_tipo_deduccion = iTipoDeduccion AND iTipoDeduccion != 0) OR (FC.idu_tipo_deduccion = FC.idu_tipo_deduccion AND iTipoDeduccion = 0)) -- Filtro por tipo de deducción.
		AND (FC.fec_factura BETWEEN dFechaInicio AND dFechaFin) -- Fecha Factura.
	GROUP BY FC.idfactura, FC.idu_empleado,	FC.idu_centro, FC.idu_estatus, FC.idu_tipo_deduccion, FD.idu_escolaridad, FD.importe_concepto, FD.importe_pagado, FD.keyx;
	
	-- Guardar los datos de las facturas registrados en "his".
	INSERT INTO temp_movimientos_facturas(idu_factura, idu_empleado, idu_centro, idu_estatus, idu_tipo_deduccion, idu_escolaridad, importe_concepto, importe_pagado, keyx)
	SELECT FC.idfactura, FC.idu_empleado, FC.idu_centro, FC.idu_estatus, FC.idu_tipo_deduccion, FD.idu_escolaridad, FD.importe_concepto, FD.importe_pagado,	FD.keyx
	FROM his_facturas_colegiaturas FC
		INNER JOIN his_detalle_facturas_colegiaturas FD	ON FC.idfactura = FD.idfactura
	WHERE (FC.idu_estatus = iEstatus AND FC.idu_estatus NOT IN(0, 1, 2, 4)) -- Filtro por estatus. Discriminar las Facturas con estatus:(0).-Pendiente, (1).-Proceso, (2).-Aceptada, (4).-Aclaración
		AND ((FC.idu_tipo_deduccion = iTipoDeduccion AND iTipoDeduccion != 0) OR (FC.idu_tipo_deduccion = FC.idu_tipo_deduccion AND iTipoDeduccion = 0)) -- Filtro por tipo de deducción.
		AND (FC.fec_cierre BETWEEN dFechaInicio AND dFechaFin) -- Fecha Factura.
	GROUP BY FC.idfactura, FC.idu_empleado,	FC.idu_centro, FC.idu_estatus, FC.idu_tipo_deduccion, FD.idu_escolaridad, FD.importe_concepto, FD.importe_pagado, FD.keyx;

	-- Llenar tabla temporal de facturas.
	INSERT INTO temp_facturas(idu_empleado, idu_centro, idu_escolaridad, importe_concepto, importe_pagado)
	SELECT F.idu_empleado,
		F.idu_centro,
		F.idu_escolaridad,
		F.importe_concepto,
		F.importe_pagado
	FROM temp_movimientos_facturas F
		INNER JOIN temp_empleados_permitidos E
		ON F.idu_empleado = E.num_empleado;

	-- Agregar el campo CIUDAD a la tabla de facturas.
	UPDATE temp_facturas
	SET idu_ciudad = cn.ciudadn
	FROM sapcatalogocentros cn
	WHERE temp_facturas.idu_centro = cn.centron;

	-- Agregar el campo REGION a la tabla de facturas.
	UPDATE temp_facturas
	SET idu_region = (CASE WHEN cd.regionzona = '' THEN '0' ELSE cd.regionzona END)::SMALLINT
	FROM sapcatalogociudades cd
	WHERE temp_facturas.idu_ciudad = cd.ciudadn;
	
	INSERT INTO temp_reporte_colegiaturas_region_escolaridad(numero_region, nombre_region, total_maternal, total_kinder, total_primaria, total_secundaria, total_preparatoria, total_maestria, total_ingles, total_otro_idioma, total_otros_estudios, total_doctorado, total_general)
	SELECT
		R.numero,
		R.nombre,
		SUM(CASE WHEN F.idu_escolaridad = 1 THEN F.importe_pagado ELSE 0 END), -- "MATERNAL"
		SUM(CASE WHEN F.idu_escolaridad = 2 THEN F.importe_pagado ELSE 0 END), -- "KINDER"
		SUM(CASE WHEN F.idu_escolaridad = 3 THEN F.importe_pagado ELSE 0 END), -- "PRIMARIA"
		SUM(CASE WHEN F.idu_escolaridad = 4 THEN F.importe_pagado ELSE 0 END), -- "SECUNDARIA"
		SUM(CASE WHEN F.idu_escolaridad = 5 THEN F.importe_pagado ELSE 0 END), -- "PREPARATORIA"
		SUM(CASE WHEN F.idu_escolaridad = 6 THEN F.importe_pagado ELSE 0 END), -- "MAESTRÍA"
		SUM(CASE WHEN F.idu_escolaridad = 7 THEN F.importe_pagado ELSE 0 END), -- "INGLÉS"
		SUM(CASE WHEN F.idu_escolaridad = 8 THEN F.importe_pagado ELSE 0 END), -- "OTRO IDIOMA"
		SUM(CASE WHEN F.idu_escolaridad = 9 THEN F.importe_pagado ELSE 0 END), -- "OTROS ESTUDIOS"
		SUM(CASE WHEN F.idu_escolaridad = 10 THEN F.importe_pagado ELSE 0 END),-- "DOCTORADO"
		SUM(F.importe_pagado) ---------------------------------------------------------------->> //TOTAL GENERAL//
	FROM sapregiones R 
		INNER JOIN temp_facturas F ON R.numero = F.idu_region
	GROUP BY R.numero,R.nombre;

	FOR returnrec IN (
		SELECT numero_region,
			nombre_region,
			total_maternal,--------- "MATERNAL"
			total_kinder,----------- "KINDER"
			total_primaria,--------- "PRIMARIA"
			total_secundaria,------- "SECUNDARIA"
			total_preparatoria,----- "PREPARATORIA"
			total_maestria,--------- "MAESTRÍA"
			total_ingles,----------- "INGLÉS"
			total_otro_idioma,------ "OTRO IDIOMA"
			total_otros_estudios,--- "OTROS ESTUDIOS"
			total_doctorado,-------- "DOCTORADO"
			total_general----------- //TOTAL GENERAL//
		FROM temp_reporte_colegiaturas_region_escolaridad
	)LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad(integer, integer, integer, date, date) TO postgres;
