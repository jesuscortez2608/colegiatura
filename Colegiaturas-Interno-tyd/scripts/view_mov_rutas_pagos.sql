DROP VIEW if exists view_mov_rutas_pagos;


CREATE OR REPLACE VIEW view_mov_rutas_pagos AS 
 SELECT DISTINCT det.idu_empleado,
    mov.idu_centro,
    mov.idfactura,
    mov.idu_tipo_documento,
    mov.idu_beneficiario_externo,
    sap.empresa AS idu_empresa,
    mov.idu_estatus,
    st.nom_estatus,
    mov.idu_escuela,
    mov.idu_tipo_deduccion,
    mov.fec_factura::date AS fec_factura,
    mov.fec_registro,
    mov.fec_marco_estatus,
    mov.emp_marco_estatus,
    '1900-01-01'::date AS fec_cierre,
        CASE
            WHEN btrim(sap.controlpago::text) = ''::text THEN '0'::bpchar
            ELSE sap.controlpago
        END::integer AS clv_rutapago,
    det.prc_descuento,
    sap.numerotarjeta AS num_cuenta,
    mov.importe_factura,
    det.importe_concepto,
    mov.importe_pagado,
    mov.fol_fiscal,
    mov.opc_modifico_pago,
    mov.opc_movimiento_traspaso,
    mov.idu_empleado_traspaso,
    mov.fec_movimiento_traspaso
   FROM mov_facturas_colegiaturas mov
     LEFT JOIN cat_estatus_facturas st ON st.idu_estatus = mov.idu_estatus
     JOIN sapcatalogoempleados sap ON sap.numempn = mov.idu_empleado
     JOIN ( SELECT DISTINCT mov_detalle_facturas_colegiaturas.idu_empleado,
            mov_detalle_facturas_colegiaturas.idfactura,
            mov_detalle_facturas_colegiaturas.idu_escuela,
            mov_detalle_facturas_colegiaturas.prc_descuento,
            sum(mov_detalle_facturas_colegiaturas.importe_concepto) AS importe_concepto
           FROM mov_detalle_facturas_colegiaturas
          GROUP BY mov_detalle_facturas_colegiaturas.idu_empleado, mov_detalle_facturas_colegiaturas.idfactura, mov_detalle_facturas_colegiaturas.idu_escuela, mov_detalle_facturas_colegiaturas.prc_descuento) det ON det.idu_empleado = mov.idu_empleado AND det.idfactura = mov.idfactura
  WHERE mov.idu_beneficiario_externo = 0 AND (mov.idu_tipo_documento = ANY (ARRAY[1, 3, 4]))
  ORDER BY mov.idfactura;