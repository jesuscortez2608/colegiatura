DROP FUNCTION IF EXISTS fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_reporte_incentivos_colegiaturas(IN dfechaquincena date, IN idu_colaborador integer, IN p_empresa integer, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT itipo smallint, OUT iempresa integer, OUT snombreempresa character varying, OUT icolaborador integer, OUT scolaborador character varying, OUT icentro integer, OUT scentro character varying, OUT ifactura integer, OUT sfactura character varying, OUT iimportefactura numeric, OUT iimporteincentivo numeric, OUT iimporteisr numeric, OUT iimporteincentivoisr numeric, OUT iajuste integer)
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
            FROM fun_reporte_incentivos_colegiaturas('2018-10-31', 0, 0, -1, -1, 'idu_empresa, idu_empleado, tipo', 'ASC');
    ------------------------------------------------------------------------------------------------------ */
	rec record;
	sQuery TEXT;
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sColumns TEXT;
begin
    IF iRowsPerPage < 0 OR page < 0 THEN
        iRowsPerPage := NULL;
        iCurrentPage := NULL;
    END IF;
    
    sColumns := 'tipo,idu_empresa,nom_empresa,idu_empleado,nom_empleado,idu_centro,nom_centro,idfactura,fol_fiscal,importe_factura,importe_incentivo,importe_isr,importe_incentivo_isr,idu_ajuste';
    
    CREATE TEMP TABLE tmp_generaciones_quincena (idu_generacion integer
        , fec_quincena date) on commit drop;
    
    insert into tmp_generaciones_quincena (idu_generacion, fec_quincena)
        select DISTINCT idu_generacion
            , fec_quincena
        from mov_generacion_pagos_colegiaturas
        where fec_quincena = dFechaQuincena;
    
    insert into tmp_generaciones_quincena (idu_generacion, fec_quincena)
        select DISTINCT idu_generacion
            , fec_quincena
        from his_generacion_pagos_colegiaturas
        where fec_quincena = dFechaQuincena;
    
    --CREATE TEMP TABLE tmp_reporte_incentivos (tipo SMALLINT
    drop table if exists tmp_reporte_incentivos;
    CREATE TABLE tmp_reporte_incentivos (tipo SMALLINT
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
        , fec_quincena DATE
    );
    --) on commit drop;
    
    -- Detalle de facturas y ajustes pagados
    sQuery := 'INSERT INTO tmp_reporte_incentivos(tipo, idu_empresa, nom_empresa ';
    sQuery := sQuery || ', idu_empleado, nom_empleado, idu_centro, nom_centro ';
    sQuery := sQuery || ', idfactura, fol_fiscal ';
    sQuery := sQuery || ', importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste, idu_generacion, fec_quincena) ';
    sQuery := sQuery || 'SELECT 0 as tipo, 0 idu_empresa, '''' as nom_empresa';
    sQuery := sQuery || ', pag.idu_empleado, '''' as nom_empleado, 0 idu_centro, '''' as nom_centro ';
    sQuery := sQuery || ', pag.idfactura, '''' fol_fiscal ';
    sQuery := sQuery || ', pag.importe_factura, pag.importe_pagado, 0.0::numeric(12,2), 0.0::numeric(12,2), pag.idu_ajuste, pag.idu_generacion, quincenas.fec_quincena ';
    sQuery := sQuery || 'FROM his_detalle_generacion_pagos_colegiaturas pag ';
    sQuery := sQuery || '  INNER JOIN tmp_generaciones_quincena quincenas ON (quincenas.idu_generacion = pag.idu_generacion) ';
    sQuery := sQuery || 'WHERE 1 = 1 ';
    
    if idu_colaborador > 0 then
        sQuery := sQuery || ' AND pag.idu_empleado = ' || idu_colaborador::VARCHAR || ' ';
    end if;
    
    raise notice '%', sQuery;
    execute (sQuery);
    
    -- Detalle de facturas y ajustes por pagar
    sQuery := 'INSERT INTO tmp_reporte_incentivos(tipo, idu_empresa, nom_empresa ';
    sQuery := sQuery || ', idu_empleado, nom_empleado, idu_centro, nom_centro ';
    sQuery := sQuery || ', idfactura, fol_fiscal ';
    sQuery := sQuery || ', importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste, idu_generacion, fec_quincena) ';
    sQuery := sQuery || 'SELECT 0 as tipo, 0 idu_empresa, '''' as nom_empresa';
    sQuery := sQuery || ', pag.idu_empleado, '''' as nom_empleado, 0 idu_centro, '''' as nom_centro ';
    sQuery := sQuery || ', pag.idfactura, '''' fol_fiscal ';
    sQuery := sQuery || ', pag.importe_factura, pag.importe_pagado, 0.0::numeric(12,2), 0.0::numeric(12,2), pag.idu_ajuste, pag.idu_generacion, quincenas.fec_quincena ';
    sQuery := sQuery || 'FROM mov_detalle_generacion_pagos_colegiaturas pag ';
    sQuery := sQuery || '  INNER JOIN tmp_generaciones_quincena quincenas ON (quincenas.idu_generacion = pag.idu_generacion) ';
    sQuery := sQuery || 'WHERE 1 = 1 ';
    
    if idu_colaborador > 0 then
        sQuery := sQuery || ' AND pag.idu_empleado = ' || idu_colaborador::VARCHAR || ' ';
    end if;
    
    raise notice '%', sQuery;
    execute (sQuery);
    
    -- Actualizar centro, empresa, folio fiscal
    update tmp_reporte_incentivos set idu_empresa = emp.empresa
        , idu_centro = emp.centron
    from sapcatalogoempleados as emp
    where emp.numempn = tmp_reporte_incentivos.idu_empleado;
    
    update tmp_reporte_incentivos set fol_fiscal = mov.fol_fiscal
    from mov_facturas_colegiaturas as mov
    where mov.idfactura = tmp_reporte_incentivos.idfactura;
    
    update tmp_reporte_incentivos set idu_empresa = his.idu_empresa
        , idu_centro = his.idu_centro
        , fol_fiscal = his.fol_fiscal
    from his_facturas_colegiaturas as his
    where his.idfactura = tmp_reporte_incentivos.idfactura;
    
    if p_empresa > 0 then
        delete from tmp_reporte_incentivos as tmp where tmp.idu_empresa != p_empresa;
    end if;
    
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
    INSERT INTO tmp_reporte_incentivos(tipo, idu_generacion, fec_quincena, idu_empresa, nom_empresa
                    , idu_empleado, nom_empleado, idu_centro, nom_centro
                    , idfactura, fol_fiscal
                    , importe_factura, importe_incentivo, importe_isr, importe_incentivo_isr, idu_ajuste)
        SELECT 2, 0 as idu_generacion, tmp.fec_quincena, tmp.idu_empresa, '' as nom_empresa
                    , 999999999 as idu_empleado, '' as nom_empleado, 0 as idu_centro, '' as nom_centro
                    , 0 as idfactura, '' as fol_fiscal
                    , sum(tmp.importe_factura), sum(tmp.importe_incentivo), sum(tmp.importe_isr), sum(tmp.importe_incentivo_isr), 0 as idu_ajuste
        FROM tmp_reporte_incentivos as tmp
        WHERE tmp.tipo = 1
        group by tmp.idu_empresa, tmp.fec_quincena, tmp.tipo;
    
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
			where t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
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
GRANT EXECUTE ON FUNCTION fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_reporte_incentivos_colegiaturas(date, integer, integer, integer, integer, character varying, character varying) IS 'La función obtiene los datos para el reporte de la carga de incentivos';