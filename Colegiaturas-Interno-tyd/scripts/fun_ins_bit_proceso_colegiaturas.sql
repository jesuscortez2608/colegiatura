DROP FUNCTION IF EXISTS fun_ins_bit_proceso_colegiaturas(integer, integer, INTEGER);
DROP FUNCTION IF EXISTS fun_ins_bit_proceso_colegiaturas(integer, integer);

CREATE OR REPLACE FUNCTION fun_ins_bit_proceso_colegiaturas(
IN imovimiento integer
, IN iusuario integer
, OUT iestado integer
, OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
    valor RECORD;
    dFechaQuincena DATE = '1900-01-01';
    cNomMovimiento CHARACTER VARYING(100) NOT NULL DEFAULT '';
BEGIN
    /** ========================================
        Peticion:
        Colaborador:    98439677 - Rafael Ramos
        Fecha:          10/02/2020
        Descripcion:    Funcion que guarda un movimiento en la tabla bit_proceso_colegiaturas
        Sistema:        Colegiaturas Web
        Modulo:         General
        Serv. Prod.:    10.44.2.183
        Serv. Des.:     10.28.114.75
        BD:             Personal
        Ejemplo:
            
    ========================================= */
    CREATE TEMPORARY TABLE tmp_resultado(
        status INTEGER NOT NULL DEFAULT 0
        , msg CHARACTER VARYING(100) NOT NULL DEFAULT ''
    )ON COMMIT DROP;

    cNomMovimiento := (SELECT LTRIM(RTRIM(UPPER(nom_movimiento))) FROM cat_movimientos_proceso_colegiaturas WHERE id_movimiento = iMovimiento );

    if date_part('day', now()::DATE) <= 15 then
        -- Día 15 del mes
        dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
        dFechaQuincena = dFechaQuincena::DATE;
    else
        -- Último día del mes
        dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
        dFechaQuincena = dFechaQuincena::DATE;
    end if;

    INSERT INTO bit_proceso_colegiaturas (id_movimiento
                                        , fec_movimiento
                                        , num_facturas
                                        , num_colaboradores
                                        , fec_quincena
                                        , id_usuario)
                    VALUES( iMovimiento
                            , NOW()
                            , 0
                            , 0
                            , dFechaQuincena
                            , iUsuario);
    IF EXISTS (SELECT 1 FROM bit_proceso_colegiaturas WHERE id_movimiento = iMovimiento and fec_movimiento::DATE = NOW()::DATE) THEN
        INSERT INTO tmp_resultado(status, msg) 
        VALUES(1, 'MOVIMIENTO "' || cNomMovimiento || '" GUARDADO CORRECTAMENTE');
    END IF;

    FOR valor IN (SELECT status, msg FROM tmp_resultado)
    LOOP
        iEstado := valor.status;
        sMensaje:= valor.msg;
    RETURN NEXT;
    END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_ins_bit_proceso_colegiaturas(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_ins_bit_proceso_colegiaturas(integer, integer) TO sysinternet;
