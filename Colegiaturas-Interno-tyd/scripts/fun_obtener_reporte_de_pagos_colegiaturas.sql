DROP FUNCTION if exists fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying);
drop type if exists type_obtener_reporte_de_pagos_colegiaturas;

CREATE TYPE type_obtener_reporte_de_pagos_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    tipo_movimiento integer,
    idu_empresa integer,
    nom_empresa character varying,
    rango_fecha_mes character varying(7),
    id_ruta_pago integer,
    id_factura integer,
    num_empleado integer,
    nom_empleado character varying(50),
    fecha date,
    idu_centro integer,
    nombre_centro character varying(30),
    num_tarjeta character varying(16),
    importe_concepto numeric(12,2),
    importe_pagado numeric(12,2),
    idu_tipo_deduccion integer,
    tipo_deduccion character varying(30),
    descuento integer,
    folio_factura character varying(100));

CREATE OR REPLACE FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_obtener_reporte_de_pagos_colegiaturas AS
$BODY$
declare 
	/*
		No. peticion APS               : 8613.1
		Fecha                           : 12/12/2016
		Numero empleado                : 97695068
		Nombre del empleado             : Héctor Medina Escareño
		Base de datos                   : Personal
		Descripcion del funcionamiento : Generar el reporte de pagos de colegiaturas
		Descripcion del cambio         : NA
		Sistema                         : Colegiaturas
		MÃ³dulo                         : Reportes
		Ejemplo                         : 
			select * 
			from fun_obtener_reporte_de_pagos_colegiaturas(1, 0, 0, '20181001', '20181023', 20, 1, 'idu_empresa,rango_fecha_mes,tipo_movimiento,idu_centro,num_empleado', 'asc','tipo_movimiento,idu_empresa,nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura,num_empleado,nom_empleado,
                            fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,
                            idu_tipo_deduccion, tipo_deduccion, descuento, folio_factura')
				
            
            select * 
            from fun_obtener_reporte_de_pagos_colegiaturas(1, 0, 6, '20180701', '20180901', 20, 1, 'idu_empresa,rango_fecha_mes,tipo_movimiento', 'asc','tipo_movimiento,idu_empresa,nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura,num_empleado,nom_empleado,
				fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,
				idu_tipo_deduccion, tipo_deduccion, descuento, folio_factura')
	*/
	
	/* PARAMETROS DE FILTRADO */
	iEmpresa ALIAS FOR $1;
	iRutaPago ALIAS FOR $2;
	iEstatus ALIAS FOR $3;
	dFechaInicio ALIAS FOR $4;
	dFechaFin ALIAS FOR $5;
    
	/* PARAMETROS DE PAGINADO */
	iRowsPerPage ALIAS FOR $6;
	iCurrentPage ALIAS FOR $7;
	sOrderColumn ALIAS FOR $8;
	sOrderType ALIAS FOR $9;
	sColumns ALIAS FOR $10;
	
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sQuery TEXT;
    
	returnrec type_obtener_reporte_de_pagos_colegiaturas;
BEGIN
	/* CONTROL DE VARIABLES DE PAGINADO NULAS */
	IF iRowsPerPage = -1 THEN
        iRowsPerPage := NULL;
	END IF;
	if iCurrentPage = -1 THEN
        iCurrentPage := NULL;
	END IF;
    
	CREATE LOCAL TEMP TABLE temp_totales_por_mes(
		tipo_movimiento integer,
		idu_empresa INTEGER,
        nom_empresa VARCHAR,
		rango_fecha_mes character varying(7),
		nom_empleado character varying(50),
		importe_concepto numeric(12,2),
		importe_pagado numeric(12,2)
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE temp_obtener_reporte_de_pagos_colegiaturas (
		tipo_movimiento integer,
		idu_empresa INTEGER,
        nom_empresa VARCHAR,
		rango_fecha_mes character varying(7),
		id_ruta_pago integer,
		id_factura integer,
		num_empleado integer,
		nom_empleado character varying(50),
		fecha date,
		idu_centro integer,
		nombre_centro character varying(30),
		num_tarjeta character varying(16),
		importe_concepto numeric(12,2),
		importe_pagado numeric(12,2),
		idu_tipo_deduccion integer,
		tipo_deduccion character varying(30),
		descuento integer,
		folio_factura character varying(100)
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE resultado_reporte_de_pagos_colegiaturas (
		tipo_movimiento integer,
		idu_empresa INTEGER,
        nom_empresa VARCHAR,
		rango_fecha_mes character varying(7),
		id_ruta_pago integer,
		id_factura integer,
		num_empleado integer,
		nom_empleado character varying(50),
		fecha date,
		idu_centro integer,
		nombre_centro character varying(30),
		num_tarjeta character varying(16),
		importe_concepto numeric(12,2),
		importe_pagado numeric(12,2),
		idu_tipo_deduccion integer,
		tipo_deduccion character varying(30),
		descuento integer,
		folio_factura character varying(100)
	)ON COMMIT DROP;
	
	IF iEstatus = 3 or iEstatus = 6 THEN
        -- Si quiere consultar estatus pagadas o rechazadas, consulta las dos tablas (mov_facturas_colegiaturas e his_facturas_colegiaturas)
        sQuery := 'INSERT INTO temp_obtener_reporte_de_pagos_colegiaturas(tipo_movimiento, idu_empresa, rango_fecha_mes, id_factura, id_ruta_pago, num_empleado, fecha, idu_centro, importe_concepto, importe_pagado, idu_tipo_deduccion, descuento, folio_factura) ';
        sQuery := sQuery || 'SELECT 0 ';
        sQuery := sQuery || ', fac.idu_empresa ';
        sQuery := sQuery || ', to_char(fac.fec_registro,''yyyy-MM'') ';
        sQuery := sQuery || ', fac.idfactura ';
        sQuery := sQuery || ', case when trim(emp.controlpago) = '''' then ''0'' else emp.controlpago end::INTEGER ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', fac.fec_registro ';
        sQuery := sQuery || ', emp.centron ';
        sQuery := sQuery || ', SUM(det.importe_concepto) ';
        sQuery := sQuery || ', SUM(det.importe_pagado) ';
        sQuery := sQuery || ', fac.idu_tipo_deduccion ';
        sQuery := sQuery || ', det.prc_descuento ';
        sQuery := sQuery || ', fac.fol_fiscal ';
        sQuery := sQuery || 'from mov_facturas_colegiaturas as fac ';
        sQuery := sQuery || '  inner join mov_detalle_facturas_colegiaturas as det on (fac.idfactura = det.idfactura) ';
        sQuery := sQuery || '  inner join sapcatalogoempleados AS emp ON (emp.numempn = fac.idu_empleado) ';
        sQuery := sQuery || '  inner join sapcatalogocentros AS cen on (emp.centro = cen.numerocentro) ';
        sQuery := sQuery || '  inner join sapcatalogociudades AS ciu on (ciu.numero = cen.numerociudad) ';
        sQuery := sQuery || 'where fac.fec_registro::DATE between ''' || dFechaInicio::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
        sQuery := sQuery || '  AND fac.idu_beneficiario_externo = 0 ';
        sQuery := sQuery || '  AND fac.idu_tipo_documento in (1,3,4) ';
        sQuery := sQuery || '  AND fac.idu_estatus = ' || iEstatus::VARCHAR || ' ';
        
        if iEmpresa > 0 then
            sQuery := sQuery || '  AND fac.idu_empresa = ' || iEmpresa::VARCHAR || ' ';
        end if;
        
        if iRutaPago > 0 then
            sQuery := sQuery || '  AND emp.controlpago = ''' || lpad(iRutaPago::VARCHAR, 2, '0') || ''' ';
        end if;
        
        sQuery := sQuery || 'GROUP BY fac.idu_empresa
                                    , to_char(fac.fec_registro,''yyyy-MM'')
                                    , fac.idfactura
                                    , emp.controlpago
                                    , fac.idu_empleado
                                    , fac.fec_registro
                                    , emp.centron
                                    , fac.idu_tipo_deduccion
                                    , det.prc_descuento
                                    , fac.fol_fiscal ';
        
        raise notice '%q', sQuery;
        execute (sQuery);
        
        -- Si quiere consultar estatus pagadas o rechazadas, consulta las dos tablas (mov_facturas_colegiaturas e his_facturas_colegiaturas)
        sQuery := 'INSERT INTO temp_obtener_reporte_de_pagos_colegiaturas(tipo_movimiento, idu_empresa, rango_fecha_mes, id_factura, id_ruta_pago, num_empleado, fecha, idu_centro, importe_concepto, importe_pagado, idu_tipo_deduccion, descuento, folio_factura) ';
        sQuery := sQuery || 'SELECT DISTINCT 0';
        sQuery := sQuery || ', fac.idu_empresa  ';
        if iEstatus = 3 then
            sQuery := sQuery || ', to_char(fac.fec_registro,''yyyy-MM'') ';
        else
            sQuery := sQuery || ', to_char(fac.fec_cierre,''yyyy-MM'') ';
        end if;
        sQuery := sQuery || ', fac.idfactura ';
        sQuery := sQuery || ', fac.clv_rutapago ';
        sQuery := sQuery || ', fac.idu_empleado ';
        if iEstatus = 3 then
            sQuery := sQuery || ', fac.fec_registro::DATE ';
        else
            sQuery := sQuery || ', fac.fec_cierre::DATE ';
        end if;
        sQuery := sQuery || ', fac.idu_centro ';
        sQuery := sQuery || ', SUM(det.importe_concepto) ';
        sQuery := sQuery || ', SUM(det.importe_pagado) ';
        sQuery := sQuery || ', fac.idu_tipo_deduccion ';
        sQuery := sQuery || ', det.prc_descuento ';
        sQuery := sQuery || ', fac.fol_fiscal ';
        sQuery := sQuery || 'from his_facturas_colegiaturas as fac ';
        sQuery := sQuery || '  inner join his_detalle_facturas_colegiaturas as det on (fac.idfactura = det.idfactura) ';
        sQuery := sQuery || '  inner join sapcatalogocentros AS cen on (fac.idu_centro = cen.centron) ';
        sQuery := sQuery || '  inner join sapcatalogociudades AS ciu on (ciu.numero = cen.numerociudad) ';
        if iEstatus = 3 then
            sQuery := sQuery || 'where fac.fec_registro::DATE between ''' || dFechaInicio::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
        else
            sQuery := sQuery || 'where fac.fec_cierre::DATE between ''' || dFechaInicio::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
        end if;
        sQuery := sQuery || '  AND fac.idu_beneficiario_externo = 0 ';
        sQuery := sQuery || '  AND fac.idu_tipo_documento in (1,3,4) ';
        sQuery := sQuery || '  AND fac.idu_estatus = ' || iEstatus::VARCHAR || ' ';
        
        if iEmpresa > 0 then
            sQuery := sQuery || '  AND fac.idu_empresa = ' || iEmpresa::VARCHAR || ' ';
        end if;
        
        if iRutaPago > 0 then
            sQuery := sQuery || '  AND fac.clv_rutapago = ' || iRutaPago::VARCHAR || ' ';
        end if;
        
        sQuery := sQuery || 'GROUP BY fac.idu_empresa ';
        if iEstatus = 3 then
            sQuery := sQuery || ', to_char(fac.fec_registro,''yyyy-MM'') ';
        ELSE
            sQuery := sQuery || ', to_char(fac.fec_cierre,''yyyy-MM'') ';
        END IF;
        sQuery := sQuery || ', fac.idfactura ';
        sQuery := sQuery || ', fac.clv_rutapago ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', fac.idu_empleado ';
        if iEstatus = 3 then
            sQuery := sQuery || ', fac.fec_registro::DATE ';
        else
            sQuery := sQuery || ', fac.fec_cierre::DATE ';
        end if;
        sQuery := sQuery || ', fac.idu_centro ';
        sQuery := sQuery || ', fac.idu_tipo_deduccion ';
        sQuery := sQuery || ', det.prc_descuento ';
        sQuery := sQuery || ', fac.fol_fiscal ';
        
        raise notice '%', sQuery;
        execute (sQuery);
    end if;
    
    if iEstatus != 3 AND iEstatus != 6 then
        sQuery := 'INSERT INTO temp_obtener_reporte_de_pagos_colegiaturas(tipo_movimiento, idu_empresa, rango_fecha_mes, id_factura, id_ruta_pago, num_empleado, fecha, idu_centro, importe_concepto, importe_pagado, idu_tipo_deduccion, descuento, folio_factura) ';
        sQuery := sQuery || 'SELECT 0 ';
        sQuery := sQuery || ', fac.idu_empresa ';
        sQuery := sQuery || ', to_char(fac.fec_registro,''yyyy-MM'') ';
        sQuery := sQuery || ', fac.idfactura ';
        sQuery := sQuery || ', case when trim(emp.controlpago) = '''' then ''0'' else emp.controlpago end::INTEGER ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', fac.fec_registro ';
        sQuery := sQuery || ', emp.centron ';
        sQuery := sQuery || ', SUM(det.importe_concepto) ';
        sQuery := sQuery || ', SUM(det.importe_pagado) ';
        sQuery := sQuery || ', fac.idu_tipo_deduccion ';
        sQuery := sQuery || ', det.prc_descuento ';
        sQuery := sQuery || ', fac.fol_fiscal ';
        sQuery := sQuery || 'from mov_facturas_colegiaturas as fac ';
        sQuery := sQuery || '  inner join mov_detalle_facturas_colegiaturas as det on (fac.idfactura = det.idfactura) ';
        sQuery := sQuery || '  inner join sapcatalogoempleados AS emp ON (emp.numempn = fac.idu_empleado) ';
        sQuery := sQuery || '  inner join sapcatalogocentros AS cen on (emp.centro = cen.numerocentro) ';
        sQuery := sQuery || '  inner join sapcatalogociudades AS ciu on (ciu.numero = cen.numerociudad) ';
        sQuery := sQuery || 'where fac.fec_registro::DATE between ''' || dFechaInicio::varchar || '''::DATE AND ''' || dFechaFin::varchar || '''::DATE ';
        sQuery := sQuery || '  AND fac.idu_beneficiario_externo = 0 ';
        sQuery := sQuery || '  AND fac.idu_tipo_documento in (1,3,4) ';
        sQuery := sQuery || '  AND fac.idu_estatus = ' || iEstatus::VARCHAR || ' ';
        
        if iEmpresa > 0 then
            sQuery := sQuery || '  AND fac.idu_empresa = ' || iEmpresa::VARCHAR || ' ';
        end if;
        
        if iRutaPago > 0 then
            sQuery := sQuery || '  AND emp.controlpago = ''' || lpad(iRutaPago::VARCHAR, 2, '0') || ''' ';
        end if;
        
        sQuery := sQuery || 'GROUP BY fac.idu_empresa
                                    , to_char(fac.fec_registro,''yyyy-MM'')
                                    , fac.idfactura
                                    , emp.controlpago
                                    , fac.idu_empleado
                                    , fac.fec_registro
                                    , emp.centron
                                    , fac.idu_tipo_deduccion
                                    , det.prc_descuento
                                    , fac.fol_fiscal ';
        
        raise notice '%q', sQuery;
        execute (sQuery);
    END IF;
	
	-- Agregar los datos de la empresa
	update temp_obtener_reporte_de_pagos_colegiaturas SET nom_empresa = emp.nombre
	from sapempresas as emp
	where emp.clave = temp_obtener_reporte_de_pagos_colegiaturas.idu_empresa;
	
	-- Agregar los datos del empleado.
	update temp_obtener_reporte_de_pagos_colegiaturas SET nom_empleado = ( TRIM(e.nombre) || ' ' || TRIM(e.apellidopaterno) || ' ' || TRIM(e.apellidomaterno) ),
		num_tarjeta = case when id_ruta_pago = 1 then '' else e.numerotarjeta end
	FROM sapcatalogoempleados e
	WHERE temp_obtener_reporte_de_pagos_colegiaturas.num_empleado = e.numempn;
    
	-- Agregar el Nombre Centro donde se emitio la factura.
	UPDATE temp_obtener_reporte_de_pagos_colegiaturas
	SET nombre_centro = c.nombrecentro
	FROM sapcatalogocentros c
	WHERE temp_obtener_reporte_de_pagos_colegiaturas.idu_centro = c.centron;

	-- Agregar el tipo de deduccion
	UPDATE temp_obtener_reporte_de_pagos_colegiaturas
	SET tipo_deduccion = d.nom_deduccion
	FROM cat_tipos_deduccion d
	WHERE temp_obtener_reporte_de_pagos_colegiaturas.idu_tipo_deduccion = d.idu_tipo;
	
	-- Calcular los totales por mes y almacenarlos en la tabla temporal de totales.
	INSERT INTO temp_totales_por_mes(tipo_movimiento, idu_empresa, nom_empresa, rango_fecha_mes, nom_empleado, importe_concepto, importe_pagado)
	SELECT 1
        , p.idu_empresa
        , p.nom_empresa
        , p.rango_fecha_mes
        , 'Total Mes '||(CASE
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '01' THEN 'ENE'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '02' THEN 'FEB'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '03' THEN 'MAR'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '04' THEN 'ABR'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '05' THEN 'MAY'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '06' THEN 'JUN'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '07' THEN 'JUL'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '08' THEN 'AGO'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '09' THEN 'SEP'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '10' THEN 'OCT'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '11' THEN 'NOV'
			WHEN SUBSTRING(p.rango_fecha_mes FROM 6 FOR 7) = '12' THEN 'DIC'
			ELSE ''
		END)||'/'||SUBSTRING(p.rango_fecha_mes FROM 1 FOR 4),
		SUM(p.importe_concepto),
		SUM(p.importe_pagado)
	FROM temp_obtener_reporte_de_pagos_colegiaturas p
	GROUP BY p.rango_fecha_mes, p.rango_fecha_mes, p.idu_empresa, p.nom_empresa;

	INSERT INTO temp_obtener_reporte_de_pagos_colegiaturas(tipo_movimiento, idu_empresa, nom_empresa, rango_fecha_mes, nom_empleado, importe_concepto, importe_pagado)
	SELECT t.tipo_movimiento,
        t.idu_empresa,
        t.nom_empresa,
		t.rango_fecha_mes,
		nom_empleado,
		t.importe_concepto,
		t.importe_pagado
	FROM temp_totales_por_mes t;
	
	-- Calcular Totales Generales.
	INSERT INTO temp_obtener_reporte_de_pagos_colegiaturas(tipo_movimiento, nom_empleado, importe_concepto, importe_pagado)
	SELECT 2,
		'Total General',
		SUM(importe_concepto),
		SUM(importe_pagado)
	FROM temp_totales_por_mes
	GROUP BY tipo_movimiento;
    
	-- Llenar la tabla Resultado con los datos en orden correcto.
	INSERT INTO resultado_reporte_de_pagos_colegiaturas(tipo_movimiento, idu_empresa, nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura
        ,num_empleado,nom_empleado,fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,idu_tipo_deduccion,tipo_deduccion,descuento,folio_factura)
	SELECT tipo_movimiento,idu_empresa, nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura
        ,num_empleado,nom_empleado,fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,idu_tipo_deduccion,tipo_deduccion,descuento,folio_factura
	FROM temp_obtener_reporte_de_pagos_colegiaturas
	ORDER BY idu_empresa, rango_fecha_mes, tipo_movimiento;
    
	iRecords := (SELECT COUNT(*) FROM resultado_reporte_de_pagos_colegiaturas);
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) THEN
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM resultado_reporte_de_pagos_colegiaturas);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
		sQuery := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM resultado_reporte_de_pagos_colegiaturas
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sQuery := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM resultado_reporte_de_pagos_colegiaturas ';
	END if;
	
	sQuery := sQuery || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
	
	RAISE NOTICE 'notice %', sQuery;
    
	FOR returnrec IN EXECUTE sQuery LOOP
		RETURN NEXT returnrec;
	END LOOP;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_de_pagos_colegiaturas(integer, integer, integer, date, date, integer, integer, character varying, character varying, character varying) IS 'La función obtiene el reporte de pagos de colegiaturas.';  