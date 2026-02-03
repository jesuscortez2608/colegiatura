CREATE OR REPLACE FUNCTION fun_replicar_costos_colegiaturas(OUT iResultado integer, OUT sMensaje VARCHAR)
 RETURNS SETOF record
AS $function$
DECLARE   
	rec record;
	sQuery TEXT;
	anio_actual integer;
	anio_anterior integer;
	ciclo_actual INTEGER;
	ciclo_anterior INTEGER;
	iRevision INTEGER;
	iEscuela INTEGER;
	iEscolaridad INTEGER;
	/*
	No. Peticion APS               : 8613.1
	Fecha                          : 29/10/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Replica los costos de colegiaturas
	Ejemplo                        :
        mov_revision_colegiaturas
        mov_detalle_revision_colegiaturas
        
        his_revision_colegiaturas
        select * from his_detalle_revision_colegiaturas
        
        select * from fun_replicar_costos_colegiaturas();
        
        select * from mov_detalle_revision_colegiaturas where idu_ciclo_escolar = 2019
	*/
BEGIN   
	anio_actual:= DATE_PART('year',CURRENT_DATE);
	anio_anterior := anio_actual -1;
	ciclo_actual := (select max(idu_ciclo_escolar) from mov_detalle_revision_colegiaturas);
	ciclo_anterior := ciclo_actual - 1;
	
	create local temp table tmp_revision_colegiaturas (
	--drop table if exists tmp_revision_colegiaturas;
	--create table tmp_revision_colegiaturas (
        idu_revision integer NOT NULL,
        idu_escuela integer NOT NULL,
        idu_motivo_revision smallint NOT NULL,
        idu_estatus_revision smallint NOT NULL,
        idu_usuario_captura integer NOT NULL,
        fec_captura timestamp without time zone NOT NULL DEFAULT now(),
        fec_revision timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
        fec_conclusion timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
        usuario_revision integer NOT NULL DEFAULT 0
    --);
    )on commit drop; 
	
	create local temp table tmp_detalle_revision_colegiaturas (
	--drop table if exists tmp_detalle_revision_colegiaturas;
	--create table tmp_detalle_revision_colegiaturas (
		idu_revision integer NOT NULL,
        idu_escuela integer NOT NULL,
        idu_ciclo_escolar integer NOT NULL,
        idu_escolaridad integer NOT NULL,
        idu_carrera integer NOT NULL DEFAULT 0,
        idu_tipo_pago integer NOT NULL,
        prc_descuento integer NOT NULL DEFAULT 0,
        idu_motivo integer NOT NULL,
        importe_concepto numeric(12,2),
        idu_usuario_registro integer NOT NULL DEFAULT 0,
        fec_registro date NOT NULL DEFAULT now(),
        keyx integer
	--);
	) on commit drop;
    
    ----
    -- Corregir revisiones guardadas en cero (mov_detalle_revision_colegiaturas.idu_revision = 0)
    -- Revisiones con movimientos en ciclo anterior (2018)
    -- Revisiones en tabla mov_detalle_revision_colegiaturas
    -- pero no existente en mov_revision_colegiaturas (idu_revision = 0 ó donde la escuela no coincide en la revisión)
    ----
    delete from tmp_revision_colegiaturas;
    delete from tmp_detalle_revision_colegiaturas;
    
    insert into tmp_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto
        , idu_usuario_registro, fec_registro, keyx)
        select det.idu_revision
            , det.idu_escuela
            , det.idu_ciclo_escolar
            , det.idu_escolaridad
            , det.idu_carrera
            , det.idu_tipo_pago
            , det.prc_descuento
            , det.idu_motivo
            , det.importe_concepto
            , det.idu_usuario_registro
            , det.fec_registro
            , det.keyx
        from mov_detalle_revision_colegiaturas det
        where det.idu_ciclo_escolar = anio_anterior
            and det.idu_revision not in (select idu_revision from mov_revision_colegiaturas);
	
	-- Borrar las revisiones que pudieran haberse creado con estos movimientos
	delete from mov_revision_colegiaturas where idu_revision in (select distinct idu_revision from tmp_detalle_revision_colegiaturas);
	delete from mov_detalle_revision_colegiaturas where keyx in (select keyx from tmp_detalle_revision_colegiaturas);
	
	iEscuela := 0;
    FOR rec IN (
        select idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto
            , idu_usuario_registro, fec_registro, keyx
        from tmp_detalle_revision_colegiaturas
        order by idu_escuela, idu_escolaridad)
	loop
        -- Crear movimientos de revisión por escuela-escolaridad
        -- con motivo 10, NO EXISTE COSTO
        -- estatus 2, REVISADOS (CONCLUIDOS)
        -- usuario captura 90025628 Palmira
        if iEscuela != rec.idu_escuela then
            iEscuela := rec.idu_escuela;
            
            insert into mov_revision_colegiaturas (idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura
                , fec_captura, fec_revision, fec_conclusion, usuario_revision)
                SELECT rec.idu_escuela
                    , 10 as idu_motivo_revision
                    , 2 idu_estatus_revision
                    , 90025628 idu_usuario_captura
                    , rec.fec_registro
                    , rec.fec_registro
                    , rec.fec_registro
                    , rec.idu_usuario_registro
                RETURNING idu_revision INTO iRevision;
        end if;
        
        raise notice 'Revisión : %', iRevision;
        
        insert into mov_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento
            , idu_motivo, importe_concepto, idu_usuario_registro, fec_registro)
            SELECT iRevision
                , rec.idu_escuela
                , rec.idu_ciclo_escolar
                , rec.idu_escolaridad
                , rec.idu_carrera
                , rec.idu_tipo_pago
                , rec.prc_descuento
                , rec.idu_motivo
                , rec.importe_concepto
                , rec.idu_usuario_registro
                , rec.fec_registro;
	end loop;
    
    -- Pasar al histórico revisiones concluídas en 2018
    -----------------------------------------------------------------------------------------------------
    delete from tmp_revision_colegiaturas;
    delete from tmp_detalle_revision_colegiaturas;
    
    insert into tmp_revision_colegiaturas (idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, fec_conclusion, usuario_revision)
        select mov.idu_revision
            , mov.idu_escuela
            , mov.idu_motivo_revision
            , mov.idu_estatus_revision
            , mov.idu_usuario_captura
            , mov.fec_captura 
            , mov.fec_revision 
            , mov.fec_conclusion
            , mov.usuario_revision
        from mov_revision_colegiaturas mov
        where date_part('year', mov.fec_conclusion) = anio_anterior;
        
    insert into tmp_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto
        , idu_usuario_registro, fec_registro, keyx)
        select det.idu_revision
            , det.idu_escuela
            , det.idu_ciclo_escolar
            , det.idu_escolaridad
            , det.idu_carrera
            , det.idu_tipo_pago
            , det.prc_descuento
            , det.idu_motivo
            , det.importe_concepto
            , det.idu_usuario_registro
            , det.fec_registro
            , det.keyx
        from mov_detalle_revision_colegiaturas det
            inner join tmp_revision_colegiaturas enc on (enc.idu_revision = det.idu_revision);
    
    insert into his_revision_colegiaturas(idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision)
        select idu_revision
            , idu_escuela
            , idu_motivo_revision
            , 2 idu_estatus_revision
            , idu_usuario_captura
            , fec_captura
            , fec_revision
            , usuario_revision
        from tmp_revision_colegiaturas;
        
    insert into his_detalle_revision_colegiaturas(idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, idu_usuario_registro, fec_registro, keyx)
        select idu_revision
            , idu_escuela
            , ciclo_anterior as idu_ciclo_escolar
            , idu_escolaridad
            , idu_carrera
            , idu_tipo_pago
            , prc_descuento
            , idu_motivo
            , importe_concepto
            , idu_usuario_registro
            , fec_registro
            , keyx
        from tmp_detalle_revision_colegiaturas;        
    
    delete from mov_revision_colegiaturas where idu_revision in (select idu_revision from tmp_revision_colegiaturas);
    delete from mov_detalle_revision_colegiaturas where keyx in (select keyx from tmp_detalle_revision_colegiaturas);
    
    FOR rec IN (
        select idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, fec_conclusion, usuario_revision
        from tmp_revision_colegiaturas)
	loop
		insert into mov_revision_colegiaturas(idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura
            , fec_captura, fec_revision, fec_conclusion, usuario_revision)
            SELECT rec.idu_escuela
                , rec.idu_motivo_revision
                , 2 as idu_estatus_revision
                , rec.idu_usuario_captura
                , now() fec_captura
                , now() fec_revision
                , now() fec_conclusion
                , rec.usuario_revision
            RETURNING idu_revision INTO iRevision;
        
        insert into mov_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento
            , idu_motivo, importe_concepto, idu_usuario_registro, fec_registro)
            SELECT iRevision
                , idu_escuela
                , anio_actual AS idu_ciclo_escolar
                , idu_escolaridad
                , idu_carrera
                , idu_tipo_pago
                , prc_descuento
                , idu_motivo
                , importe_concepto
                , idu_usuario_registro
                , now() as fec_registro
            FROM tmp_detalle_revision_colegiaturas
            WHERE idu_escuela = rec.idu_escuela;
	end loop;
    
    ----
    -- Revisiones con movimientos en ciclo anterior (2018)
    -- Revisiones en ambas tablas mov_revision_colegiaturas y mov_detalle_revision_colegiaturas
    ----
    delete from tmp_revision_colegiaturas;
    delete from tmp_detalle_revision_colegiaturas;
    
    insert into tmp_revision_colegiaturas (idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, fec_conclusion, usuario_revision)
        select DISTINCT mov.idu_revision
            , mov.idu_escuela
            , mov.idu_motivo_revision
            , mov.idu_estatus_revision
            , mov.idu_usuario_captura
            , mov.fec_captura 
            , mov.fec_revision 
            , mov.fec_conclusion
            , mov.usuario_revision
        from mov_revision_colegiaturas mov
            left join mov_detalle_revision_colegiaturas as det on (mov.idu_escuela = det.idu_escuela)
        where det.idu_ciclo_escolar = anio_anterior;
        
    insert into tmp_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto
        , idu_usuario_registro, fec_registro, keyx)
        select det.idu_revision
            , det.idu_escuela
            , det.idu_ciclo_escolar
            , det.idu_escolaridad
            , det.idu_carrera
            , det.idu_tipo_pago
            , det.prc_descuento
            , det.idu_motivo
            , det.importe_concepto
            , det.idu_usuario_registro
            , det.fec_registro
            , det.keyx
        from mov_detalle_revision_colegiaturas det
            inner join tmp_revision_colegiaturas enc on (enc.idu_escuela = det.idu_escuela);
    
    -- Pasar al histórico
    FOR rec IN (
        select idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, fec_conclusion, usuario_revision
        from tmp_revision_colegiaturas)
	loop
        insert into his_revision_colegiaturas(idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, usuario_revision)
            select rec.idu_revision
                , rec.idu_escuela
                , rec.idu_motivo_revision
                , 2 idu_estatus_revision
                , rec.idu_usuario_captura
                , rec.fec_captura
                , rec.fec_revision
                , rec.usuario_revision
            from tmp_revision_colegiaturas;
            
        insert into his_detalle_revision_colegiaturas(idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo, importe_concepto, idu_usuario_registro, fec_registro, keyx)
            select rec.idu_revision
                , idu_escuela
                , ciclo_anterior as idu_ciclo_escolar
                , idu_escolaridad
                , idu_carrera
                , idu_tipo_pago
                , prc_descuento
                , idu_motivo
                , importe_concepto
                , idu_usuario_registro
                , fec_registro
                , keyx
            from tmp_detalle_revision_colegiaturas
            where idu_escuela = rec.idu_escuela;
    end loop;
    
    delete from mov_revision_colegiaturas where idu_revision in (select idu_revision from tmp_revision_colegiaturas);
    delete from mov_detalle_revision_colegiaturas where keyx in (select keyx from tmp_detalle_revision_colegiaturas);
    
    -- Crear nuevos movimientos con ciclo escolar del año actual
	FOR rec IN (
        select idu_revision, idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura, fec_revision, fec_conclusion, usuario_revision
        from tmp_revision_colegiaturas)
	loop
		insert into mov_revision_colegiaturas(idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura
            , fec_captura, fec_revision, fec_conclusion, usuario_revision)
            SELECT rec.idu_escuela
                , rec.idu_motivo_revision
                , rec.idu_estatus_revision
                , rec.idu_usuario_captura
                , rec.fec_captura
                , rec.fec_revision
                , rec.fec_conclusion
                , rec.usuario_revision
            RETURNING idu_revision INTO iRevision;
        
        insert into mov_detalle_revision_colegiaturas (idu_revision, idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento
            , idu_motivo, importe_concepto, idu_usuario_registro, fec_registro)
            SELECT iRevision
                , idu_escuela
                , anio_actual AS idu_ciclo_escolar
                , idu_escolaridad
                , idu_carrera
                , idu_tipo_pago
                , prc_descuento
                , idu_motivo
                , importe_concepto
                , idu_usuario_registro
                , now() as fec_registro
            FROM tmp_detalle_revision_colegiaturas
            WHERE idu_escuela = rec.idu_escuela;
	end loop;
	
	FOR rec IN (
        SELECT 1::integer as resultado
            , 'Se concluyó la replicación de costos'::varcHAR as mensaje) loop
            iResultado := rec.resultado;
            sMensaje := rec.mensaje;
        return NEXT;
	end loop;
END;
$function$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_replicar_costos_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_replicar_costos_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_replicar_costos_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_replicar_costos_colegiaturas() TO postgres;
