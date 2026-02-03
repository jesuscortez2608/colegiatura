drop function if exists fun_validar_costos_colegiaturas(integer, integer, integer);
drop function if exists fun_validar_costos_colegiaturas(integer);
drop type if exists type_validar_costos_colegiaturas;

CREATE TYPE type_validar_costos_colegiaturas AS
   (idu_factura integer,
    idu_estatus integer,
    nom_estatus character varying);

CREATE OR REPLACE FUNCTION fun_validar_costos_colegiaturas(integer)
  RETURNS SETOF type_validar_costos_colegiaturas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 16995 Colegiaturas
	Fecha                          : 04/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : Recibe como parámetro 
        ID de la escuela, el Ciclo escolar, ID Factura
        iEscolaridad alias for $2;
        iCicloEscolar alias for $3;
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        :         
		select * from fun_validar_costos_colegiaturas(iFactura::INTEGER)
	------------------------------------------------------------------------------------------------------ */
	iFactura alias for $1;
    
	iEscuela INTEGER;
	iCicloEscolar INTEGER;
	sRfcEscuela varchar;
	iEstado integer;
	iMunicipio integer;
	iLocalidad integer;
	
	iEstatus integer;
	sEstatus varchar;
	
	returnrec type_validar_costos_colegiaturas;
BEGIN
    -- Obtener escuela desde la factura, y el RFC de la escuela desde el catálogo de escuelas
    if exists (select 1 from mov_facturas_colegiaturas where idfactura = iFactura) then
        iEscuela := (select idu_escuela from mov_facturas_colegiaturas where idfactura = iFactura limit 1);
        sRfcEscuela := (select rfc_clave_sep from cat_escuelas_colegiaturas where idu_escuela = iEscuela limit 1);
        iCicloEscolar := (select idu_ciclo_escolar from mov_detalle_facturas_colegiaturas where idfactura = iFactura limit 1);
    elsif exists (select 1 from his_facturas_colegiaturas where idfactura = iFactura) then
        iEscuela := (select idu_escuela from his_facturas_colegiaturas where idfactura = iFactura limit 1);
        sRfcEscuela := (select rfc_clave_sep from cat_escuelas_colegiaturas where idu_escuela = iEscuela limit 1);
        iCicloEscolar := (select idu_ciclo_escolar from his_detalle_facturas_colegiaturas where idfactura = iFactura limit 1);
    elsE
        iEscuela := (select idu_escuela from stmp_facturas_colegiaturas where idfactura = iFactura limit 1);
        sRfcEscuela := (select rfc_clave_sep from cat_escuelas_colegiaturas where idu_escuela = iEscuela limit 1);
        iCicloEscolar := (select idu_ciclo_escolar from stmp_detalle_facturas_colegiaturas where idfactura = iFactura limit 1);
    end if;
    
    -- Obtener los datos de la escuela
    --drop table if exists tmp_datos_escuela;
    --create table tmp_datos_escuela (rfc_escuela varchar
    create temp table tmp_datos_escuela (rfc_escuela varchar
        , idu_escuela integer
        , idu_estado integer
        , idu_municipio integer
        , idu_localidad integer
        , idu_escolaridad integer
        , idu_carrera integer
    ) on commit drop;
    --);
    
    insert into tmp_datos_escuela (rfc_escuela, idu_escuela, idu_estado, idu_municipio, idu_localidad, idu_escolaridad, idu_carrera)
        select rfc_clave_sep
            , idu_escuela
            , idu_estado
            , idu_municipio
            , idu_localidad
            , idu_escolaridad
            , idu_carrera
        from cat_escuelas_colegiaturas
        where idu_escuela = iEscuela
        limit 1;
        
    --drop table if exists tmp_escuelas_rfc;
    --create table tmp_escuelas_rfc (rfc_escuela varchar
    create temp table tmp_escuelas_rfc (rfc_escuela varchar
        , idu_escuela integer
        , idu_estado integer
        , idu_municipio integer
        , idu_localidad integer
        , idu_escolaridad integer
        , idu_carrera integer
    ) on commit drop;
    --);
    
    -- Obtener escuelas que coincidan con rfc, estado, municipio, localidad, escolaridad
    insert into tmp_escuelas_rfc (rfc_escuela, idu_escuela, idu_estado, idu_municipio, idu_localidad, idu_escolaridad, idu_carrera)
        select esc.rfc_clave_sep
            , esc.idu_escuela
            , esc.idu_estado
            , esc.idu_municipio
            , esc.idu_localidad
            , esc.idu_escolaridad
            , esc.idu_carrera
        from cat_escuelas_colegiaturas esc
            inner join tmp_datos_escuela tmp on (esc.rfc_clave_sep = tmp.rfc_escuela
                                            and esc.idu_estado = tmp.idu_estado
                                            and esc.idu_municipio = tmp.idu_municipio
                                            and esc.idu_localidad = tmp.idu_localidad
                                            and esc.idu_escolaridad = tmp.idu_escolaridad);
    
    -- Crear tablas para almacenar costos y descuentos
   --drop table if exists tmp_costos_conceptos;
   --create table tmp_costos_conceptos (idu_escuela integer
   create temp table tmp_costos_conceptos (idu_escuela integer
        , idu_escolaridad integer
        , idu_carrera integer
        , idu_ciclo_escolar integer
        , idu_tipo_pago integer
        , importe_concepto numeric(12,2) not null default(0.0)
   ) on commit drop;
   --);
    
    --drop table if exists tmp_descuentos;
    --create temp table tmp_descuentos (idu_escuela integer
    create temp table tmp_descuentos (idu_escuela integer
        , idu_escolaridad integer
        , idu_carrera integer
        , idu_ciclo_escolar integer
        , idu_tipo_pago integer
        , prc_descuento integer not null default (0)
        , idu_motivo_descto integer not null default(0)
        , des_motivo_descto varchar not null default('')
    ) on commit drop;
    --);
    --return;
    if date_part('year', NOW()) = iCicloEscolar then
        -- Obtener las configuraciones de costos
        insert into tmp_costos_conceptos (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto)
            select  rev.idu_escuela
                , rev.idu_escolaridad
                , rev.idu_carrera
                , rev.idu_ciclo_escolar
                , rev.idu_tipo_pago
                , rev.importe_concepto
            from mov_detalle_revision_colegiaturas rev
                inner join tmp_escuelas_rfc as tmp on (rev.idu_escuela = tmp.idu_escuela)
            where rev.importe_concepto > 0;
        
        -- Obtner las configuraciones de descuentos
        insert into tmp_descuentos (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, prc_descuento, idu_motivo_descto, des_motivo_descto)
        select rev.idu_escuela
            , rev.idu_escolaridad
            , rev.idu_carrera
            , rev.idu_ciclo_escolar
            , rev.idu_tipo_pago
            , rev.prc_descuento
            , rev.idu_motivo
            , md.des_motivo
        from mov_detalle_revision_colegiaturas rev
            inner join tmp_escuelas_rfc as tmp on (rev.idu_escuela = tmp.idu_escuela)
            inner join cat_motivos_colegiaturas md on (rev.idu_motivo = md.idu_motivo)
        where rev.prc_descuento > 0;
    else
        -- Obtener las configuraciones de costos
        insert into tmp_costos_conceptos (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto)
            select rev.idu_escuela
                , rev.idu_escolaridad
                , rev.idu_carrera
                , rev.idu_ciclo_escolar
                , rev.idu_tipo_pago
                , rev.importe_concepto
            from his_detalle_revision_colegiaturas as rev
                inner join tmp_escuelas_rfc as tmp on (rev.idu_escuela = tmp.idu_escuela)
            where rev.idu_ciclo_escolar = iCicloEscolar
                and rev.importe_concepto > 0;
        
        -- Obtner las configuraciones de descuentos
        insert into tmp_descuentos (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, prc_descuento, idu_motivo_descto, des_motivo_descto)
        select rev.idu_escuela
            , rev.idu_escolaridad
            , rev.idu_carrera
            , rev.idu_ciclo_escolar
            , rev.idu_tipo_pago
            , rev.prc_descuento
            , rev.idu_motivo
            , md.des_motivo
        from his_detalle_revision_colegiaturas rev
            inner join tmp_escuelas_rfc as tmp on (rev.idu_escuela = tmp.idu_escuela)
            inner join cat_motivos_colegiaturas md on (rev.idu_motivo = md.idu_motivo)
        where rev.idu_ciclo_escolar = iCicloEscolar
            and rev.prc_descuento > 0;
    end if;
    
    -- Cálculos para obtener los descuentos
    --drop table if exists tmp_costos_escuela;
    --create table tmp_costos_escuela (idu_escuela integer
    create temp table tmp_costos_escuela (idu_escuela integer
        , idu_escolaridad integer
        , idu_carrera integer
        , idu_ciclo_escolar integer
        , idu_tipo_pago integer
        , importe_concepto numeric(12,2) not null default(0.0)
        , prc_descuento integer not null default (0)
        , idu_motivo_descto integer not null default (0)
        , des_motivo_descto varchar not null default('')
        , importe_con_descuento numeric(12,2) not null default(0.0)
        , prc_tolerancia integer not null default(0)
        , limite_inferior numeric(12,2) not null default(0.0)
        , limite_superior numeric(12,2) not null default(0.0)
    ) on commit drop;
    --);
    
    insert into tmp_costos_escuela (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto, prc_descuento, idu_motivo_descto, des_motivo_descto)
        select distinct cst.idu_escuela
            , cst.idu_escolaridad
            , cst.idu_carrera
            , cst.idu_ciclo_escolar
            , cst.idu_tipo_pago
            , cst.importe_concepto
            , coalesce(dsc.prc_descuento, 0)
            , coalesce(dsc.idu_motivo_descto, 0)
            , coalesce(dsc.des_motivo_descto, '')
        from tmp_costos_conceptos cst
            left join tmp_descuentos dsc on (cst.idu_escuela = dsc.idu_escuela 
                                            and cst.idu_escolaridad = dsc.idu_escolaridad
                                            and cst.idu_carrera = dsc.idu_carrera
                                            and cst.idu_ciclo_escolar = dsc.idu_ciclo_escolar
                                            and cst.idu_tipo_pago = dsc.idu_tipo_pago);
    
    -- Actualizar el porcentaje de tolerancia
    update tmp_costos_escuela set prc_tolerancia = pct_tolerancia
    from ctl_variables_colegiaturas;
    
    -- Aplicar descuentos a los importes de concepto
    update tmp_costos_escuela set importe_con_descuento = case when prc_descuento <= 0 then importe_concepto else importe_concepto - (importe_concepto * (prc_descuento::float / 100::float)) end;
    
    -- Actualizar límite inferior y límite superior
    update tmp_costos_escuela set limite_inferior = case when prc_tolerancia <= 0 then importe_con_descuento else importe_con_descuento - (importe_con_descuento * (prc_tolerancia::float / 100::float)) end
        , limite_superior = case when prc_tolerancia <= 0 then importe_con_descuento else importe_con_descuento + (importe_con_descuento * (prc_tolerancia::float / 100::float)) end;
    
    -- Obtener el detalle de las facturas para realizar la comparación
    --drop table if exists tmp_detalle_facturas_colegiaturas;
    --create table tmp_detalle_facturas_colegiaturas (idu_escuela integer
    create temp table tmp_detalle_facturas_colegiaturas (idu_escuela integer
        , idu_escolaridad integer
        , idu_carrera integer
        , idu_ciclo_escolar integer
        , idu_tipo_pago integer
        , importe_concepto numeric(12,2)
        , idfactura integer
    ) on commit drop;
    --);
    
    if exists (select 1 from stmp_detalle_facturas_colegiaturas where idfactura = iFactura) then
        insert into tmp_detalle_facturas_colegiaturas (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto, idfactura)
            select idu_escuela
                , idu_escolaridad
                , idu_carrera
                , idu_ciclo_escolar
                , idu_tipopago
                , importe_concepto
                , idfactura
            from stmp_detalle_facturas_colegiaturas
            where idfactura = iFactura;
    elsif exists (select 1 from mov_detalle_facturas_colegiaturas where idfactura = iFactura) then
        insert into tmp_detalle_facturas_colegiaturas (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto, idfactura)
            select idu_escuela
                , idu_escolaridad
                , idu_carrera
                , idu_ciclo_escolar
                , idu_tipopago
                , importe_concepto
                , idfactura
            from mov_detalle_facturas_colegiaturas
            where idfactura = iFactura;
    elsif exists (select 1 from his_detalle_facturas_colegiaturas where idfactura = iFactura) then
        insert into tmp_detalle_facturas_colegiaturas (idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_tipo_pago, importe_concepto, idfactura)
            select idu_escuela
                , idu_escolaridad
                , idu_carrera
                , idu_ciclo_escolar
                , idu_tipopago
                , importe_concepto
                , idfactura
            from his_detalle_facturas_colegiaturas
            where idfactura = iFactura;
    end if;
    
    /** Los motivos de revision son el tipo 4 de la cat_motivos_colegiaturas*/ 
    -- 9|4|ESCUELA NO EXISTE || ---> (Este estatus se activa cuando se da de alta la escuela en la configuración de beneficiarios)
    -- 10|4|NO EXISTE COSTO
    -- 11|4|LOS COSTOS NO COINCIDEN

    
    -- Validaciones
    iEstatus := 0;
    if not exists (select * from tmp_costos_escuela) or 
        not exists (select det.idu_escuela
                    , det.idu_escolaridad
                    , det.idu_carrera
                    , det.idu_ciclo_escolar
                    , det.idu_tipo_pago
                    , det.importe_concepto
                    , costos.limite_inferior
                    , costos.limite_superior
                from tmp_detalle_facturas_colegiaturas det
                    inner join tmp_costos_escuela as costos on (costos.idu_escuela = det.idu_escuela
                                                            and costos.idu_escolaridad = det.idu_escolaridad
                                                            and costos.idu_carrera = det.idu_carrera
                                                            and costos.idu_ciclo_escolar = det.idu_ciclo_escolar
                                                            and costos.idu_tipo_pago = det.idu_tipo_pago) ) then
        -- Motivo NO EXISTEN COSTOS
        iEstatus := 10;
    else
        -- Motivo LOS IMPORTES NO COINCIDEN
        if not exists (
                select det.idu_escuela
                    , det.idu_escolaridad
                    , det.idu_carrera
                    , det.idu_ciclo_escolar
                    , det.idu_tipo_pago
                    , det.importe_concepto
                    , costos.limite_inferior
                    , costos.limite_superior
                from tmp_detalle_facturas_colegiaturas det
                    inner join tmp_costos_escuela as costos on (costos.idu_escuela = det.idu_escuela
                                                            and costos.idu_escolaridad = det.idu_escolaridad
                                                            and costos.idu_carrera = det.idu_carrera
                                                            and costos.idu_ciclo_escolar = det.idu_ciclo_escolar
                                                            and costos.idu_tipo_pago = det.idu_tipo_pago)
                where det.importe_concepto between costos.limite_inferior and costos.limite_superior) then
            iEstatus := 11;
        end if;
    end if;
    
    if iEstatus > 0 then
        sEstatus := (SELECT des_motivo FROM cat_motivos_colegiaturas WHERE idu_motivo = iEstatus AND idu_tipo_motivo = 4 limit 1);
    else
        sEstatus := 'LOS COSTOS COINCIDEN';
    end if;
    
	FOR returnrec IN (SELECT iFactura, iEstatus, sEstatus) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_validar_costos_colegiaturas(integer) TO public;
GRANT EXECUTE ON FUNCTION fun_validar_costos_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_costos_colegiaturas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_validar_costos_colegiaturas(integer) TO postgres;
COMMENT ON FUNCTION fun_validar_costos_colegiaturas(integer) IS 'La función valida si existe costos o descuentos de la escuela que correspone la factura.';
