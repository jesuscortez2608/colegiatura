DROP FUNCTION IF EXISTS fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date);
DROP TYPE IF EXISTS type_obtener_reporte_colegiaturas_region_escolaridad_dinamica;


CREATE TYPE type_obtener_reporte_colegiaturas_region_escolaridad_dinamica AS
   (idu_empresa integer,
    nom_empresa character varying,
    idu_region smallint,
    nom_region character varying(20),
    idu_escolaridad_1 integer,
    nom_escolaridad_1 character varying,
    idu_escolaridad_2 integer,
    nom_escolaridad_2 character varying,
    idu_escolaridad_3 integer,
    nom_escolaridad_3 character varying,
    idu_escolaridad_4 integer,
    nom_escolaridad_4 character varying,
    idu_escolaridad_5 integer,
    nom_escolaridad_5 character varying,
    idu_escolaridad_6 integer,
    nom_escolaridad_6 character varying,
    idu_escolaridad_7 integer,
    nom_escolaridad_7 character varying,
    idu_escolaridad_8 integer,
    nom_escolaridad_8 character varying,
    idu_escolaridad_9 integer,
    nom_escolaridad_9 character varying,
    idu_escolaridad_10 integer,
    nom_escolaridad_10 character varying,
    totales_colegiaturas text,
    total_general integer);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date)
  RETURNS SETOF type_obtener_reporte_colegiaturas_region_escolaridad_dinamica AS
$BODY$
declare 
	returnrec type_obtener_reporte_colegiaturas_region_escolaridad_dinamica;
	/*
		No. petición APS               : 8613.1
		Fecha                          : 21/12/2016
		Número empleado                : 97695068
		Nombre del empleado            : Héctor Medina Escareño
		Base de datos                  : Personal
		Servidor de pruebas            : 10.44.2.89
		Servidor de produccion         : 10.44.2.183
		Descripción del funcionamiento : Genera el reporte de becas por Region y escolaridad.
		Descripción del cambio         : NA
		Sistema                        : Colegiaturas
		Módulo                         : Reportes
		Ejemplo                        : 
            select * from fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(0, 6, 0, 1, '20180701','20180831')
	*/
	-- PARAMETROS DE FILTRADO
	iRutaPago ALIAS FOR $1;
	iEstatus ALIAS FOR $2;
	iTipoDeduccion ALIAS FOR $3;
	iEmpresa ALIAS FOR $4;
	dFechaInicio ALIAS FOR $5;
	dFechaFin ALIAS FOR $6;
    
	sQuery TEXT;
	rec RECORD;
	cnt INTEGER;
	select_columnas TEXT;
BEGIN
    sQuery := 'CREATE TEMP TABLE tmp_region_escolaridad (idu_empresa INTEGER';
    --sQuery := 'CREATE TABLE tmp_region_escolaridad (idu_empresa INTEGER';
    sQuery := sQuery || ', nom_empresa VARCHAR';
    sQuery := sQuery || ', idu_region INTEGER';
    sQuery := sQuery || ', nom_region VARCHAR';
    
    FOR rec IN (SELECT idu_escolaridad, nom_escolaridad FROM cat_escolaridades ORDER BY idu_escolaridad)
    LOOP
        sQuery := sQuery || ', idu_escolaridad_' || rec.idu_escolaridad::VARCHAR || ' INTEGER NOT NULL DEFAULT(0)';
        sQuery := sQuery || ', nom_escolaridad_' || rec.idu_escolaridad::VARCHAR || ' VARCHAR NOT NULL DEFAULT('''')';
    END LOOP;
    
    sQuery := sQuery || ', total_general INTEGER NOT NULL DEFAULT(0)';
    --sQuery := sQuery || ');';
    sQuery := sQuery || ') ON COMMIT DROP;';
    
    RAISE NOTICE '%', sQuery;
    EXECUTE(sQuery);
    
    -- Tabla para el reporte
    CREATE TEMP TABLE  tmp_reporte (idu_empresa INTEGER,
        nom_empresa VARCHAR,
        numero_region smallint,
        nombre_region character varying(20),
        totales_colegiaturas text,
        total_general INTEGER
    ) on commit drop;
    
    -- Empleados involucrados
    --select count(*) from tmp_empleados_involucrados
    --drop table tmp_empleados_involucrados
    CREATE TEMP TABLE tmp_empleados_involucrados (idu_empresa INTEGER
    --CREATE TABLE tmp_empleados_involucrados (idu_empresa INTEGER
        , idu_region INTEGER
        , idu_empleado INTEGER
        --, idu_escolaridad INTEGER);
        , idu_escolaridad INTEGER) ON COMMIT DROP;
    
    IF iEstatus = 3 or iEstatus = 6 THEN
        -- Si quiere consultar estatus pagadas o rechazadas, consulta las dos tablas (mov_facturas_colegiaturas e his_facturas_colegiaturas)
        sQuery := 'INSERT INTO tmp_empleados_involucrados (idu_empresa, idu_region, idu_empleado, idu_escolaridad) ';
        sQuery := sQuery || 'SELECT DISTINCT fac.idu_empresa ';
        sQuery := sQuery || ', CASE WHEN TRIM(ciu.regionzona) = '''' THEN ''0'' ELSE ciu.regionzona end::INTEGER idu_region ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', det.idu_escolaridad ';
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
        
        if iTipoDeduccion > 0 then
            sQuery := sQuery || '  AND fac.idu_tipo_deduccion = ' || iTipoDeduccion::VARCHAR || ' ';
        end if;
        
        raise notice '%q', sQuery;
        execute (sQuery);
        
        -- Si quiere consultar estatus pagadas o rechazadas, consulta las dos tablas (mov_facturas_colegiaturas e his_facturas_colegiaturas)
        sQuery := 'INSERT INTO tmp_empleados_involucrados (idu_empresa, idu_region, idu_empleado, idu_escolaridad) ';
        sQuery := sQuery || 'SELECT DISTINCT fac.idu_empresa ';
        sQuery := sQuery || ', CASE WHEN TRIM(ciu.regionzona) = '''' THEN ''0'' ELSE ciu.regionzona end::INTEGER idu_region ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', det.idu_escolaridad ';
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
        
        if iTipoDeduccion > 0 then
            sQuery := sQuery || '  AND fac.idu_tipo_deduccion = ' || iTipoDeduccion::VARCHAR || ' ';
        end if;
        
        raise notice '%', sQuery;
        execute (sQuery);
    end if;
    
    if iEstatus != 3 AND iEstatus != 6 then
        sQuery := 'INSERT INTO tmp_empleados_involucrados (idu_empresa, idu_region, idu_empleado, idu_escolaridad) ';
        sQuery := sQuery || 'SELECT DISTINCT fac.idu_empresa ';
        sQuery := sQuery || ', CASE WHEN TRIM(ciu.regionzona) = '''' THEN ''0'' ELSE ciu.regionzona end::INTEGER idu_region ';
        sQuery := sQuery || ', fac.idu_empleado ';
        sQuery := sQuery || ', det.idu_escolaridad ';
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
        
        if iTipoDeduccion > 0 then
            sQuery := sQuery || '  AND fac.idu_tipo_deduccion = ' || iTipoDeduccion::VARCHAR || ' ';
        end if;
        
        raise notice '%', sQuery;
        execute (sQuery);
    END IF;
    
    INSERT INTO tmp_region_escolaridad(idu_empresa, idu_region)
    SELECT DISTINCT idu_empresa
        , idu_region
    FROM tmp_empleados_involucrados
    ORDER BY idu_empresa, idu_region;
    
    /*UPDATE tmp_region_escolaridad SET idu_escolaridad_1 = res.cant_empleados
    FROM (SELECT idu_empresa, idu_region, idu_escolaridad, COUNT(DISTINCT idu_empleado) as cant_empleados
            FROM tmp_empleados_involucrados as emp
            where emp.idu_empresa = 0
                and emp.idu_region = 1
                and emp.idu_escolaridad = 1
            group by idu_empresa, idu_region, idu_escolaridad) as res
    WHERE tmp_region_escolaridad.idu_empresa = res.idu_empresa
        and tmp_region_escolaridad.idu_region = res.idu_region;*/
    
    sQuery := '';
    FOR rec IN (
        SELECT tmp.idu_empresa
            , tmp.idu_region
            , tmp.idu_escolaridad
        FROM tmp_empleados_involucrados tmp
        group by tmp.idu_empresa, tmp.idu_region, tmp.idu_escolaridad
        ORDER BY tmp.idu_empresa, tmp.idu_region, tmp.idu_escolaridad
        )
    LOOP
        sQuery := sQuery ||'UPDATE tmp_region_escolaridad SET idu_escolaridad_' || rec.idu_escolaridad::varchar || ' = res.cant_empleados
                    FROM (SELECT emp.idu_empresa, emp.idu_region, emp.idu_escolaridad, COUNT(DISTINCT emp.idu_empleado) as cant_empleados
                            FROM tmp_empleados_involucrados as emp
                            where emp.idu_empresa = ' || rec.idu_empresa || '
                                and emp.idu_region = ' || rec.idu_region || '
                                and emp.idu_escolaridad = ' || rec.idu_escolaridad || '
                            group by emp.idu_empresa, emp.idu_region, emp.idu_escolaridad) as res
                    WHERE tmp_region_escolaridad.idu_empresa = res.idu_empresa
                        and tmp_region_escolaridad.idu_region = res.idu_region;';
    END LOOP;
    raise notice '%', sQuery;
    execute sQuery;
    
    update tmp_region_escolaridad set nom_empresa = emp.nombre
    from sapempresas as emp
    where emp.clave = tmp_region_escolaridad.idu_empresa;
    
    update tmp_region_escolaridad set nom_region = reg.nombre
    from sapregiones as reg
    where reg.numero = tmp_region_escolaridad.idu_region;
    
    -- Actualizar total general
    --UPDATE tmp_region_escolaridad SET total_general = idu_escolaridad_1+idu_escolaridad_2+idu_escolaridad_3+idu_escolaridad_4+idu_escolaridad_5+idu_escolaridad_6+idu_escolaridad_7+idu_escolaridad_8+idu_escolaridad_9+idu_escolaridad_10;
    sQuery := 'UPDATE tmp_region_escolaridad SET total_general = ' ;
    cnt := 0;
    FOR rec IN (SELECT idu_escolaridad, nom_escolaridad FROM cat_escolaridades ORDER BY idu_escolaridad)
    LOOP
        if cnt = 0 then
            sQuery := sQuery || 'idu_escolaridad_' || rec.idu_escolaridad::VARCHAR || '';
        else
            sQuery := sQuery || ' + idu_escolaridad_' || rec.idu_escolaridad::VARCHAR || '';
        end if;
        cnt := cnt + 1;
    END LOOP;
    raise notice '%', sQuery;
    execute sQuery;
    
    raise notice '%', 'PAIMI';
    -- Actualizar nombres de regiones
    sQuery := '';
    FOR rec IN (SELECT idu_escolaridad, nom_escolaridad FROM cat_escolaridades ORDER BY idu_escolaridad)
    LOOP
        sQuery := sQuery || 'UPDATE tmp_region_escolaridad SET nom_escolaridad_' || rec.idu_escolaridad::varchar || ' = esc.nom_escolaridad FROM cat_escolaridades AS esc WHERE idu_escolaridad = ' || rec.idu_escolaridad::varchar || ';';
    END LOOP;
    raise notice '%', sQuery;
    execute sQuery;

    sQuery := 'SELECT idu_empresa
                , nom_empresa
                , idu_region
                , nom_region
                , idu_escolaridad_1, nom_escolaridad_1
                , idu_escolaridad_2, nom_escolaridad_2
                , idu_escolaridad_3, nom_escolaridad_3
                , idu_escolaridad_4, nom_escolaridad_4
                , idu_escolaridad_5, nom_escolaridad_5
                , idu_escolaridad_6, nom_escolaridad_6
                , idu_escolaridad_7, nom_escolaridad_7
                , idu_escolaridad_8, nom_escolaridad_8
                , idu_escolaridad_9, nom_escolaridad_9
                , idu_escolaridad_10, nom_escolaridad_10
                , ';
    cnt := 0;
    FOR rec IN (SELECT idu_escolaridad, nom_escolaridad FROM cat_escolaridades ORDER BY idu_escolaridad)
    LOOP
        if cnt = 0 then
            sQuery := sQuery || 'rpad(nom_escolaridad_' || rec.idu_escolaridad::varchar || ', length(nom_escolaridad_' || rec.idu_escolaridad::varchar || '), '' '') || '':'' || lpad(idu_escolaridad_' || rec.idu_escolaridad::varchar || '::varchar, 5, '' '') || '' | '' ';
        else
            sQuery := sQuery || ' || rpad(nom_escolaridad_' || rec.idu_escolaridad::varchar || ', length(nom_escolaridad_' || rec.idu_escolaridad::varchar || '), '' '') || '':'' || lpad(idu_escolaridad_' || rec.idu_escolaridad::varchar || '::varchar, 5, '' '') || '' | '' ';
        end if;
        cnt := cnt + 1;
    END LOOP;
    sQuery := sQuery || ', total_general
    FROM tmp_region_escolaridad 
    ORDER BY idu_empresa, idu_region';
    
    raise notice '%', sQuery;
    execute sQuery;
    
    for returnrec in execute (sQuery) loop
		RETURN NEXT returnrec;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica(integer, integer, integer, integer, date, date) IS 'La función obtiene el reporte de pagos por region-escolaridad de colegiaturas.'; 