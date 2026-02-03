DROP VIEW IF EXISTS view_his_rutas_pagos;


CREATE OR REPLACE VIEW view_his_rutas_pagos AS 
 SELECT DISTINCT his.idu_empleado,
    his.idu_centro,
    his.idfactura,
    his.idu_tipo_documento,
    his.idu_beneficiario_externo,
    his.idu_estatus,
    st.nom_estatus,
    his.idu_empresa,
    his.idu_escuela,
    his.idu_tipo_deduccion,
    his.fec_factura,
    his.fec_registro,
    his.fec_cierre,
    his.clv_rutapago,
    his.num_cuenta,
    his.importe_factura,
    det.prc_descuento,
    det.importe_concepto,
    his.importe_pagado,
    his.fol_fiscal,
    his.opc_modifico_pago,
    his.opc_movimiento_traspaso,
    his.idu_empleado_traspaso,
    his.fec_movimiento_traspaso,
    det.idu_ciclo_escolar
   FROM his_facturas_colegiaturas his
     LEFT JOIN cat_estatus_facturas st ON st.idu_estatus = his.idu_estatus
     LEFT JOIN ( SELECT DISTINCT his_detalle_facturas_colegiaturas.idu_empleado,
            his_detalle_facturas_colegiaturas.idfactura,
            his_detalle_facturas_colegiaturas.idu_escuela,
            his_detalle_facturas_colegiaturas.prc_descuento,
            his_detalle_facturas_colegiaturas.idu_ciclo_escolar,
            sum(his_detalle_facturas_colegiaturas.importe_concepto) AS importe_concepto
           FROM his_detalle_facturas_colegiaturas
          GROUP BY his_detalle_facturas_colegiaturas.idu_empleado, his_detalle_facturas_colegiaturas.idfactura, his_detalle_facturas_colegiaturas.idu_escuela, his_detalle_facturas_colegiaturas.prc_descuento, his_detalle_facturas_colegiaturas.idu_ciclo_escolar) det ON det.idfactura = his.idfactura AND det.idu_empleado = his.idu_empleado
  WHERE his.idu_beneficiario_externo = 0 AND (his.idu_tipo_documento = ANY (ARRAY[1, 3, 4]));