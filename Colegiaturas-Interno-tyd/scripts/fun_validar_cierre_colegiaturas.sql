CREATE OR REPLACE FUNCTION fun_validar_cierre_colegiaturas(
    in iUsuario INTEGER
    , OUT iEstado INTEGER
    , OUT sMensaje CHARACTER VARYING)
    RETURNS SETOF RECORD AS
    $BODY$
    DECLARE
        valor RECORD;
        iCicloColegiaturas INTEGER;
        idUltimaGeneracionPagos INTEGER;
        iCierreUltimoCiclo INTEGER;
        iEnvioIncentivos INTEGER;
        dFechaUltimaQuincena DATE = '1900-01-01';
        dFechaQuincena DATE = '1900-01-01';
    BEGIN
        /** ========================================
        Peticion:
        Colaborador:    98439677 - Rafael Ramos
        Fecha:          05/02/2020
        Descripcion:    Funcion que valida si ya se realizo el cierre del proceso actual de colegiaturas
        Sistema:        Colegiaturas Web
        Modulo:         Aceptar/Rechazar Facturas
        Serv. Prod.:    10.44.2.183
        Serv. Des.:     10.28.114.75
        BD:             Personal
        Ejemplo:
            SELECT * FROM fun_validar_cierre_colegiaturas(91432391::INTEGER)
        ========================================= */

        CREATE TEMPORARY TABLE tmp_resultado(
            status INTEGER NOT NULL DEFAULT 0
            , msg CHARACTER VARYING(100) NOT NULL DEFAULT ''
        )ON COMMIT DROP;

        iCicloColegiaturas  := (SELECT COALESCE(MAX(idu_ciclo), 0) FROM ctl_proceso_colegiaturas);
        iCierreUltimoCiclo  := (SELECT (CASE WHEN fec_cierre::DATE > '1900-01-01' THEN 1 ELSE 0 END)::INTEGER FROM ctl_proceso_colegiaturas WHERE idu_ciclo = iCicloColegiaturas LIMIT 1);
        iCierreUltimoCiclo  := COALESCE(iCierreUltimoCiclo, 0)::INTEGER;
        iEnvioIncentivos    := (SELECT (CASE WHEN fec_incentivos::DATE > '1900-01-01' THEN 1 ELSE 0 END)::INTEGER FROM ctl_proceso_colegiaturas WHERE idu_ciclo = iCicloColegiaturas LIMIT 1);
        iEnvioIncentivos    := COALESCE(iEnvioIncentivos, 0)::INTEGER;

        if date_part('day', now()::DATE) <= 15 then
            -- Día 15 del mes
            dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
            dFechaQuincena = dFechaQuincena::DATE;
        else
            -- Último día del mes
            dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
            dFechaQuincena = dFechaQuincena::DATE;
        end if;

        idUltimaGeneracionPagos := (SELECT COALESCE(MAX(idu_generacion), 0)::INTEGER FROM his_generacion_pagos_colegiaturas LIMIT 1);

        dFechaUltimaQuincena := (SELECT fec_quincena FROM mov_generacion_pagos_colegiaturas WHERE idu_generacion = (idUltimaGeneracionPagos + 1)::INTEGER LIMIT 1);

        IF (dFechaQuincena::DATE > dFechaUltimaQuincena::DATE
            AND iCierreUltimoCiclo = 0
            AND iEnvioIncentivos = 1) THEN
            INSERT INTO tmp_resultado (status, msg)
            VALUES(0, 'No se ha generado el Cierre de Colegiaturas del último proceso');
        ELSE
            INSERT INTO tmp_resultado (status, msg)
            VALUES(1, 'Puede continuar con el proceso');
        END IF;

        FOR valor IN(SELECT status, msg FROM tmp_resultado)
        LOOP
            iEstado     := valor.status;
            sMensaje    := valor.msg;
        RETURN NEXT;
        END LOOP;
    END;
    $BODY$
    LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_validar_cierre_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_cierre_colegiaturas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_validar_cierre_colegiaturas(integer) TO sysetl;
COMMENT ON FUNCTION fun_validar_cierre_colegiaturas(integer) IS 'La función valida si se realizo el cierre de colegiaturas con la tabla ctl_proceso_colegiaturas';