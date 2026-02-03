CREATE OR REPLACE FUNCTION fun_cancelar_pagos_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying, timestamp without time zone, character varying)
  RETURNS void AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613
	Fecha                          : 20/01/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal - Postgres
	Servidor de pruebas            : 10.28.114.75
	Descripción del funcionamiento : Cancela un pago de colegiaturas
	Sistema                        : Colegiaturas Web
	Ejemplo                        : 
        SELECT fun_cancelar_pagos_colegiaturas(2,95194185,6,0,95194185,'1169877','4031','20161005','asdasdasd');
        select * from mov_bitacora_movimientos_colegiaturas order by fec_registro desc
	------------------------------------------------------------------------------------------------------ */
	iGeneracionPago alias for $1;
	iEmpleadoPago alias for $2;
	iRutaPago alias for $3;
	iEsHistorico alias for $4;
	iEmpleado alias for $5;
	sPolizaCancelacion alias for $6;
	sPolizaClave alias for $7;
	dPolizaFecha alias for $8;
	sJustificacion alias for $9;
BEGIN
	if (iEsHistorico = 1) then
        -- Cuando la factura se encuentra en histórico
        update his_generacion_pagos_colegiaturas set poliza_cancelacion = sPolizaCancelacion
            , poliza_clave = sPolizaClave
            , poliza_fecha = dPolizaFecha
            , emp_cancelacion = iEmpleado
            , des_justificacion_poliza = sJustificacion
            , fec_cancelacion = now()
        where idu_generacion = iGeneracionPago
            and idu_empleado = iEmpleadoPago
            and clv_rutapago = iRutaPago;
        
        update his_facturas_colegiaturas set idu_estatus = 6
            , emp_marco_estatus = iEmpleado
            , fec_marco_estatus = now()
            , poliza_cancelacion = sPolizaCancelacion
            , poliza_clave = sPolizaClave
            , poliza_fecha = dPolizaFecha
            , emp_cancelacion = iEmpleado
            , des_justificacion_poliza = sJustificacion
            , fec_cancelacion = now()
        from his_detalle_generacion_pagos_colegiaturas
        where his_detalle_generacion_pagos_colegiaturas.idfactura = his_facturas_colegiaturas.idfactura
            and his_detalle_generacion_pagos_colegiaturas.idu_generacion = iGeneracionPago
            and his_detalle_generacion_pagos_colegiaturas.idu_empleado = iEmpleadoPago
            and his_detalle_generacion_pagos_colegiaturas.clv_rutapago = iRutaPago;
        
        DELETE FROM mov_facturas_colegiaturas mov
            USING his_detalle_generacion_pagos_colegiaturas his
        WHERE mov.idfactura = his.idfactura
            and his.idu_generacion = iGeneracionPago
            and his.idu_empleado = iEmpleadoPago
            and his.clv_rutapago = iRutaPago;
        
        insert into mov_facturas_colegiaturas(fol_fiscal, fol_factura
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
            select his.fol_fiscal, his.fol_factura
                , his.serie
                , his.fec_factura
                , his.idu_empleado
                , his.idu_centro
                , his.opc_pdf
                , his.idu_escuela
                , his.rfc_clave
                , his.importe_factura
                , his.importe_calculado
                , his.importe_pagado
                , his.idu_tipo_deduccion
                , 2 as idu_estatus
                , his.opc_modifico_pago
                , his.idu_motivo_rechazo
                , iEmpleado as emp_marco_estatus
                , now() as fec_marco_estatus
                , his.des_comentario_especial
                , his.des_aclaracion_costos
                , his.des_observaciones
                , his.fec_registro
                , his.idu_empleado_registro
                , 0 as opc_movimiento_traspaso
                , 0 as idu_empleado_traspaso
                , '1900-01-01' as fec_movimiento_traspaso
                , his.poliza_cancelacion
                , his.poliza_clave
                , his.poliza_fecha
                , his.emp_cancelacion
                , his.des_justificacion_poliza
                , his.fec_cancelacion
                , his.nom_xml_recibo
                , his.nom_pdf_carta
                , his.xml_factura
                , his.idfactura
            from his_facturas_colegiaturas as his
                inner join his_detalle_generacion_pagos_colegiaturas as pagos on (his.idfactura = pagos.idfactura)
            where pagos.idu_generacion = iGeneracionPago
                and pagos.idu_empleado = iEmpleadoPago
                and pagos.clv_rutapago = iRutaPago;
            
        insert into mov_detalle_facturas_colegiaturas(idu_empleado
            , fol_fiscal
            , beneficiario_hoja_azul
            , idu_beneficiario
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
            , idfactura
            , keyx)
            select his.idu_empleado
                , his.fol_fiscal
                , his.beneficiario_hoja_azul
                , his.idu_beneficiario
                , his.idu_parentesco
                , his.idu_tipopago
                , his.prc_descuento
                , his.periodo
                , his.idu_escuela
                , his.idu_escolaridad
                , his.idu_grado_escolar
                , his.idu_ciclo_escolar
                , his.importe_concepto
                , his.importe_pagado
                , his.fec_registro
                , his.idu_empleado_registro
                , his.idfactura
                , his.keyx
            from his_detalle_facturas_colegiaturas as his
                inner join his_detalle_generacion_pagos_colegiaturas as pagos on (his.idfactura = pagos.idfactura)
            where pagos.idu_generacion = iGeneracionPago
                and pagos.idu_empleado = iEmpleadoPago
                and pagos.clv_rutapago = iRutaPago;
        --his_detalle_generacion_pagos_colegiaturas
        -- Actualizar la bitácora
        --cat_tipos_movimientos_bitacora -- 3|CANCELAR PAGO
        insert into mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento,idu_factura,importe_original,importe_pagado
            , idu_empleado_bloqueado, opc_bloqueado
            , poliza_cancelacion
            , idu_empleado_especial, idu_beneficiario_especial
            , fec_registro, idu_empleado_registro, des_justificacion, opc_beneficiario_especial)
            select 3 as idu_tipo_movimiento, gen.idfactura, gen.importe_factura, gen.importe_pagado
                , 0, 0
                , sPolizaCancelacion
                , 0, 0
                , now(), iEmpleado, sJustificacion, 0
            from his_detalle_generacion_pagos_colegiaturas as gen
                inner join his_facturas_colegiaturas as fact on (gen.idfactura = fact.idfactura)
            where gen.idu_generacion = iGeneracionPago
                and gen.idu_empleado = iEmpleadoPago
                and gen.clv_rutapago = iRutaPago;
	else
        -- Cuando la factura se encuentra aún en movimiento
        -- solo se actualizan ciertos datos
        update mov_generacion_pagos_colegiaturas set poliza_cancelacion = sPolizaCancelacion
            , poliza_clave = sPolizaClave
            , poliza_fecha = dPolizaFecha
            , emp_cancelacion = iEmpleado
            , des_justificacion_poliza = sJustificacion
            , fec_cancelacion = now()
        where idu_generacion = iGeneracionPago
            and idu_empleado = iEmpleadoPago
            and clv_rutapago = iRutaPago;
        
        update mov_facturas_colegiaturas set idu_estatus = 2
            , fec_marco_estatus = now()
            , opc_movimiento_traspaso = 0
            , idu_empleado_traspaso = 0
            , fec_movimiento_traspaso = '1900-01-01'
            , poliza_cancelacion = sPolizaCancelacion
            , poliza_clave = sPolizaClave
            , poliza_fecha = dPolizaFecha
            , emp_cancelacion = iEmpleado
            , des_justificacion_poliza = sJustificacion
            , fec_cancelacion = now()
        from mov_detalle_generacion_pagos_colegiaturas
        where mov_detalle_generacion_pagos_colegiaturas.idfactura = mov_facturas_colegiaturas.idfactura
            and mov_detalle_generacion_pagos_colegiaturas.idu_generacion = iGeneracionPago
            and mov_detalle_generacion_pagos_colegiaturas.idu_empleado = iEmpleadoPago
            and mov_detalle_generacion_pagos_colegiaturas.clv_rutapago = iRutaPago;
        --mov_detalle_generacion_pagos_colegiaturas
        
        -- Actualizar la bitácora
        --cat_tipos_movimientos_bitacora -- 3|CANCELAR PAGO
        insert into mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento,idu_factura,importe_original,importe_pagado
            , idu_empleado_bloqueado, opc_bloqueado
            , poliza_cancelacion
            , idu_empleado_especial, idu_beneficiario_especial
            , fec_registro, idu_empleado_registro, des_justificacion, opc_beneficiario_especial)
            select 3 as idu_tipo_movimiento, gen.idfactura, gen.importe_factura, gen.importe_pagado
                , 0, 0
                , sPolizaCancelacion
                , 0, 0
                , now(), iEmpleado, sJustificacion, 0
            from mov_detalle_generacion_pagos_colegiaturas as gen
                inner join mov_facturas_colegiaturas as fact on (gen.idfactura = fact.idfactura)
            where gen.idu_generacion = iGeneracionPago
                and gen.idu_empleado = iEmpleadoPago
                and gen.clv_rutapago = iRutaPago;
	end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
