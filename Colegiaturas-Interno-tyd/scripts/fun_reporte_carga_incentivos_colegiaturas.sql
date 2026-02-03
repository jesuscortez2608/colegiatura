DROP FUNCTION IF EXISTS fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_carga_incentivos_colegiaturas(IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT itipo smallint, OUT iempresa integer, OUT snombreempresa character varying, OUT icolaborador integer, OUT scolaborador character varying, OUT icentro integer, OUT scentro character varying, OUT ifactura integer, OUT sfactura character varying, OUT iimportefactura numeric, OUT iimporteincentivo numeric, OUT iimporteisr numeric, OUT iimporteincentivoisr numeric, OUT iajuste integer)
  RETURNS SETOF record AS
$BODY$
declare
    /*
        No. petición APS               : 16995.1 Colegiaturas
        Fecha                          : 29/08/2018
        Número empleado                : 95194185
        Nombre del empleado            : Paimi Arizmendi Lopez
        Sistema                        : Colegiaturas
        Módulo                         : Reporte de incentivos
        Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
        Ejemplo                        : 
            SELECT records, page, pages, iTipo
                , iEmpresa
                , sNombreEmpresa
                , iColaborador
                , sColaborador
                , iCentro
                , sCentro
                , iFactura
                , sFactura
                , iImporteFactura
                , iImporteIncentivo
                , iImporteISR
                , iImporteIncentivoISR
                , iAjuste
            FROM fun_reporte_carga_incentivos_colegiaturas(-1, -1, 'idu_empresa, idu_empleado, tipo', 'ASC');
            select idu_empresa, * from mov_facturas_colegiaturas where idfactura in (1132)
            select empresa, * from sapcatalogoempleados where numempn in (97225101, 95194185)
    ------------------------------------------------------------------------------------------------------ */
	rec record;
	iidu_generacion integer;
	sQuery TEXT;
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sColumns TEXT;
	dFechaQuincena DATE = '1900-01-01';
begin
    if date_part('day', now()::DATE) <= 15 then
        -- Día 15 del mes
        dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
    else
        -- Último día del mes
        dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
    end if;
    
    IF iRowsPerPage < 0 OR page < 0 THEN
        iRowsPerPage := NULL;
        iCurrentPage := NULL;
    END IF;
    
    iidu_generacion := (select max(idu_generacion) from mov_generacion_pagos_colegiaturas limit 1);
    
    sColumns := 'tipo,idu_empresa,nom_empresa,idu_empleado,nom_empleado,idu_centro,nom_centro,idfactura,fol_fiscal,importe_factura,importe_incentivo,importe_isr,importe_incentivo_isr,idu_ajuste';
    
    CREATE TEMP TABLE tmp_reporte_incentivos (tipo SMALLINT
    --drop table if exists tmp_reporte_incentivos;
    --CREATE TABLE tmp_reporte_incentivos (tipo SMALLINT
        , idu_empresa INTEGER
        , nom_empresa VARCHAR
        , idu_empleado INTEGER
        , nom_empleado VARCHAR
        , idu_centro INTEGER
        , nom_centro VARCHAR
        , idfactura INTEGER
        , fol_fiscal VARCHAR
        , importe_factura NUMERIC(12,2)
        , importe_incentivo NUMERIC(12,2)
        , importe_isr NUMERIC(12,2)
        , importe_incentivo_isr NUMERIC(12,2)
        , idu_ajuste SMALLINT
        , idu_generacion INTEGER
    --);
    ) on commit drop;
    
    -- Detalle de facturas y ajustes pagados
    INSERT INTO tmp_reporte_incentivos(tipo, idu_empresa, nom_empresa, idu_empleado, nom_empleado, idu_centro, nom_centro, idfactura, fol_fiscal, importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste, idu_generacion)
    SELECT DISTINCT 0 AS tipo,
           0 AS idu_empresa,
           '' AS nom_empresa,
           det.idu_empleado,
           '' AS nom_empleado,
           0 AS idu_centro,
           '' AS nom_centro,
           det.idfactura,
           '' AS fol_fiscal,
           det.importe_factura,
           det.importe_pagado,
           0.0::numeric(12, 2),
           0.0::numeric(12, 2),
           det.idu_ajuste,
           det.idu_generacion
    FROM mov_generacion_pagos_colegiaturas pag
        RIGHT JOIN mov_detalle_generacion_pagos_colegiaturas det on (det.idu_generacion = pag.idu_generacion)
    WHERE pag.fec_quincena = dFechaQuincena
    UNION ALL
    SELECT DISTINCT 0 AS tipo,
           0 AS idu_empresa,
           '' AS nom_empresa,
           det.idu_empleado,
           '' AS nom_empleado,
           0 AS idu_centro,
           '' AS nom_centro,
           det.idfactura,
           '' AS fol_fiscal,
           det.importe_factura,
           det.importe_pagado,
           0.0::numeric(12, 2),
           0.0::numeric(12, 2),
           det.idu_ajuste,
           det.idu_generacion
    FROM his_generacion_pagos_colegiaturas pag
        RIGHT JOIN his_detalle_generacion_pagos_colegiaturas det on (det.idu_generacion = pag.idu_generacion)
    WHERE pag.fec_quincena = dFechaQuincena;
    
    -- Actualizar centro, empresa, folio fiscal
    update tmp_reporte_incentivos set idu_empresa = mov.idu_empresa
        , idu_centro = mov.idu_centro
        , fol_fiscal = mov.fol_fiscal
    from mov_facturas_colegiaturas as mov
    where tmp_reporte_incentivos.idu_ajuste = 0
        and mov.idfactura = tmp_reporte_incentivos.idfactura;
    
    update tmp_reporte_incentivos set idu_empresa = mov.idu_empresa
        , idu_centro = mov.idu_centro
        , fol_fiscal = mov.fol_fiscal
    from his_facturas_colegiaturas as mov
    where tmp_reporte_incentivos.idfactura = mov.idfactura;
    
    -- TOTALES POR EMPLEADO (provisionales -1, después se agruparán)
    INSERT INTO tmp_reporte_incentivos(tipo, idu_generacion, idu_empresa, nom_empresa
                    , idu_empleado, nom_empleado, idu_centro, nom_centro
                    , idfactura, fol_fiscal
                    , importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste)
        SELECT -1, tmp.idu_generacion, tmp.idu_empresa, '' as nom_empresa
                    , tmp.idu_empleado, '' as nom_empleado, 0 as idu_centro, '' as nom_centro
                    , 0 as idfactura, '' as fol_fiscal
                    , sum(tmp.importe_factura), sum(tmp.importe_incentivo), sum(tmp.importe_isr), sum(tmp.importe_incentivo_isr), 0 as idu_ajuste
        FROM tmp_reporte_incentivos as tmp
        WHERE tmp.tipo = 0
        group by tmp.idu_empresa, tmp.idu_generacion, tmp.idu_empleado, tmp.tipo;
    
    UPDATE tmp_reporte_incentivos as tmp SET importe_isr = pag.importe_isr
        , importe_incentivo_isr = pag.importe_pagado + pag.importe_isr
    from mov_generacion_pagos_colegiaturas as pag 
    where pag.idu_generacion = tmp.idu_generacion 
        and pag.idu_empleado = tmp.idu_empleado
        and tmp.tipo = -1;
    
    UPDATE tmp_reporte_incentivos as tmp SET importe_isr = pag.importe_isr
        , importe_incentivo_isr = pag.importe_pagado + pag.importe_isr
    from his_generacion_pagos_colegiaturas as pag 
    where pag.idu_generacion = tmp.idu_generacion
        and pag.idu_empleado = tmp.idu_empleado
        and tmp.tipo = -1;
    
    -- Agrupar los totales por empleado, y borrar los provisionales
    INSERT INTO tmp_reporte_incentivos(tipo, idu_generacion, idu_empresa, nom_empresa
                    , idu_empleado, nom_empleado, idu_centro, nom_centro
                    , idfactura, fol_fiscal
                    , importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste)
        SELECT 1, 0 as idu_generacion, tmp.idu_empresa, '' as nom_empresa
                    , tmp.idu_empleado, '' as nom_empleado, 0 as idu_centro, '' as nom_centro
                    , 0 as idfactura, '' as fol_fiscal
                    , sum(tmp.importe_factura), sum(tmp.importe_incentivo), sum(tmp.importe_isr), sum(tmp.importe_incentivo_isr), 0 as idu_ajuste
        FROM tmp_reporte_incentivos as tmp
        where tmp.tipo = -1
        group by tmp.idu_empresa, tmp.idu_empleado, tmp.tipo;
        
    delete from tmp_reporte_incentivos where tipo = -1;
    
    -- TOTALES POR EMPRESA
    INSERT INTO tmp_reporte_incentivos(tipo, idu_generacion, idu_empresa, nom_empresa
                    , idu_empleado, nom_empleado, idu_centro, nom_centro
                    , idfactura, fol_fiscal
                    , importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste)
        SELECT 2, tmp.idu_generacion, tmp.idu_empresa, '' as nom_empresa
                    , 999999999 as idu_empleado, '' as nom_empleado, 0 as idu_centro, '' as nom_centro
                    , 0 as idfactura, '' as fol_fiscal
                    , sum(tmp.importe_factura), sum(tmp.importe_incentivo), sum(tmp.importe_isr), sum(tmp.importe_incentivo_isr), 0 as idu_ajuste
        FROM tmp_reporte_incentivos as tmp
        WHERE tmp.tipo = 1
        group by tmp.idu_empresa, tmp.idu_generacion, tmp.tipo;
    
    -- TOTAL GENERAL
    INSERT INTO tmp_reporte_incentivos(tipo, idu_empresa, nom_empresa
                    , idu_empleado, nom_empleado, idu_centro, nom_centro
                    , idfactura, fol_fiscal
                    , importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste)
        SELECT 3, SUM(tmp.idu_empresa), '' as nom_empresa
                    , 999999999 as idu_empleado, '' as nom_empleado, 0 as idu_centro, '' as nom_centro
                    , 0 as idfactura, '' as fol_fiscal
                    , sum(tmp.importe_factura), sum(tmp.importe_incentivo), sum(tmp.importe_isr), sum(tmp.importe_incentivo_isr), 0 as idu_ajuste
        FROM tmp_reporte_incentivos as tmp
        WHERE tmp.tipo = 1
        group by tmp.tipo;
    
    -- ACTUALIZAR NOMBRES Y DEFINICIONES
    UPDATE tmp_reporte_incentivos SET nom_empresa = empr.nombre
    FROM sapempresas as empr
    WHERE empr.clave = tmp_reporte_incentivos.idu_empresa;
    
    UPDATE tmp_reporte_incentivos SET nom_empleado = trim(empl.nombre) || ' ' || trim(empl.apellidopaterno) || ' ' || trim(empl.apellidomaterno)
    FROM sapcatalogoempleados as empl
    WHERE empl.numempn = tmp_reporte_incentivos.idu_empleado;
    
    UPDATE tmp_reporte_incentivos SET nom_centro = trim(cen.nombrecentro)
    FROM sapcatalogocentros as cen
    WHERE cen.centron = tmp_reporte_incentivos.idu_centro;
    
    UPDATE tmp_reporte_incentivos SET fol_fiscal = 'TOTAL POR EMPRESA, ' || trim(nom_empresa)
    WHERE tmp_reporte_incentivos.tipo = 2;
    
    UPDATE tmp_reporte_incentivos SET fol_fiscal = 'TOTAL GENERAL'
    WHERE tmp_reporte_incentivos.tipo = 3;
    
    iRecords := (SELECT COUNT(*) FROM tmp_reporte_incentivos);
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
		
		sQuery := '
			select ' || CAST(iRecords AS VARCHAR) || '::INTEGER AS records
				, ' || CAST(iCurrentPage AS VARCHAR) || '::INTEGER AS page
				, ' || CAST(iTotalPages AS VARCHAR) || '::INTEGER AS pages
				, id::INTEGER
				, ' || sColumns || '
			from (
					SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ')::INTEGER AS id, ' || sColumns || '
					FROM tmp_reporte_incentivos
					) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sQuery := ' SELECT ' || iRecords::VARCHAR || '::INTEGER AS records, 1::INTEGER AS page, 1::INTEGER AS pages, 0::INTEGER AS id, ' || sColumns || ' FROM tmp_reporte_incentivos ';
	END if;
	sQuery := sQuery || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
	
	RAISE NOTICE 'notice %', sQuery;
    
    for rec in EXECUTE (sQuery)
	loop
        records := rec.records;
        page := rec.page;
        pages := rec.pages;
        id := rec.id;
        iTipo := rec.tipo;
        iEmpresa := rec.idu_empresa;
        sNombreEmpresa := rec.nom_empresa;
        iColaborador := rec.idu_empleado;
        sColaborador := rec.nom_empleado;
        iCentro := rec.idu_centro;
        sCentro := rec.nom_centro;
        iFactura := rec.idfactura;
        sFactura := rec.fol_fiscal;
        iImporteFactura := rec.importe_factura;
        iImporteIncentivo := rec.importe_incentivo;
        iImporteISR := rec.importe_isr;
        iImporteIncentivoISR := rec.importe_incentivo_isr;
        iAjuste := rec.idu_ajuste;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_carga_incentivos_colegiaturas(integer, integer, character varying, character varying) IS 'La función obtiene los datos para el reporte de la carga de incentivos';