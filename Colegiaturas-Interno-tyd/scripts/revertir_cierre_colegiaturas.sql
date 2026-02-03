DROP FUNCTION IF EXISTS fun_revertir_cierre_colegiaturas(integer, DATE);
DROP TYPE IF EXISTS type_revertir_cierre_colegiaturas;

CREATE TYPE type_revertir_cierre_colegiaturas AS (resultado integer
    , mensaje varchar(50)
);

CREATE OR REPLACE FUNCTION fun_revertir_cierre_colegiaturas(integer, DATE)
RETURNS SETOF type_revertir_cierre_colegiaturas AS
$function$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT fun_revertir_cierre_colegiaturas(95194185::INTEGER, '20170313'::DATE);
	------------------------------------------------------------------------------------------------------ */
	iUsuario alias for $1;
	dFechaCierre alias for $2;
	returnrec type_revertir_cierre_colegiaturas;
begin
    insert into mov_detalle_facturas_colegiaturas(idu_empleado
        , fol_fiscal
        , idu_beneficiario
        , beneficiario_hoja_azul
        , idu_parentesco
        , idu_tipopago
        , prc_descuento
        , periodo
        , idu_escuela
        , idu_escolaridad
        , idu_grado_escolar
        , idu_ciclo_escolar
        , importe_concepto
        , importe_pagado
        , fec_registro
        , idu_empleado_registro
        , idfactura)
        select det.idu_empleado
            , det.fol_fiscal
            , det.idu_beneficiario
            , det.beneficiario_hoja_azul
            , det.idu_parentesco
            , det.idu_tipopago
            , det.prc_descuento
            , det.periodo
            , det.idu_escuela
            , det.idu_escolaridad
            , det.idu_grado_escolar
            , det.idu_ciclo_escolar
            , det.importe_concepto
            , det.importe_pagado
            , det.fec_registro
            , det.idu_empleado_registro
            , det.idfactura
        from his_detalle_facturas_colegiaturas det
            inner join his_facturas_colegiaturas mov on (det.idfactura = mov.idfactura)
        where mov.fec_cierre::date = dFechaCierre;

    insert into mov_facturas_colegiaturas(fol_fiscal
        , fol_factura
        , serie
        , fec_factura
        , idu_empleado
        , idu_centro
        , opc_pdf
        , idu_escuela
        , rfc_clave
        , importe_factura
        , importe_calculado
        , importe_pagado
        , idu_tipo_deduccion
        , idu_estatus
        , opc_modifico_pago
        , idu_motivo_rechazo
        , emp_marco_estatus
        , fec_marco_estatus
        , des_comentario_especial
        , des_aclaracion_costos
        , des_observaciones
        , fec_registro
        , idu_empleado_registro
        , opc_movimiento_traspaso
        , idu_empleado_traspaso
        , fec_movimiento_traspaso
        , poliza_cancelacion
        , poliza_clave
        , poliza_fecha
        , emp_cancelacion
        , des_justificacion_poliza
        , fec_cancelacion
        , nom_xml_recibo
        , nom_pdf_carta
        , xml_factura
        , idfactura)
        select fol_fiscal
            , fol_factura
            , serie
            , fec_factura
            , idu_empleado
            , idu_centro
            , opc_pdf
            , idu_escuela
            , rfc_clave
            , importe_factura
            , importe_calculado
            , importe_pagado
            , idu_tipo_deduccion
            , idu_estatus
            , opc_modifico_pago
            , idu_motivo_rechazo
            , iUsuario as emp_marco_estatus
            , now() as fec_marco_estatus
            , des_comentario_especial
            , des_aclaracion_costos
            , des_observaciones
            , fec_registro
            , idu_empleado_registro
            , opc_movimiento_traspaso
            , idu_empleado_traspaso
            , fec_movimiento_traspaso
            , poliza_cancelacion
            , poliza_clave
            , poliza_fecha
            , emp_cancelacion
            , des_justificacion_poliza
            , fec_cancelacion
            , nom_xml_recibo
            , nom_pdf_carta
            , xml_factura
            , idfactura
        from his_facturas_colegiaturas
        where fec_cierre::date = dFechaCierre;
        
    update mov_facturas_colegiaturas set opc_movimiento_traspaso = 0
        , idu_empleado_traspaso = 0
        , fec_movimiento_traspaso = '1900-01-01'::date
        , idu_estatus = 2
    where opc_movimiento_traspaso = 1;
    
    delete from his_detalle_facturas_colegiaturas det
    where det.idfactura in (select mov.idfactura from his_facturas_colegiaturas mov where mov.fec_cierre::date = dFechaCierre);
    
    delete from his_facturas_colegiaturas mov 
    where mov.fec_cierre::date = '2017-03-11';
    
    delete from his_generacion_pagos_colegiaturas
    where idu_generacion in (select idu_generacion_pagos from mov_generacion_cierre_colegiaturas where fec_cierre::date = dFechaCierre);
    
    delete from his_detalle_generacion_pagos_colegiaturas
    where idu_generacion in (select idu_generacion_pagos from mov_generacion_cierre_colegiaturas where fec_cierre::date = dFechaCierre);
    
    delete from his_facturas_pagadas
    where idu_generacion in (select idu_generacion_pagos from mov_generacion_cierre_colegiaturas where fec_cierre::date = dFechaCierre);
    
    delete from his_facturas_rechazadas
    where idu_generacion in (select idu_generacion_pagos from mov_generacion_cierre_colegiaturas where fec_cierre::date = dFechaCierre);
    
    delete from mov_generacion_cierre_colegiaturas
    where fec_cierre::date = dFechaCierre;
    
    FOR returnrec IN (select 1 as resultado, 'OK' as mensaje ) LOOP
		RETURN NEXT returnrec;
	END LOOP;
end;
$function$
LANGUAGE plpgsql VOLATILE;