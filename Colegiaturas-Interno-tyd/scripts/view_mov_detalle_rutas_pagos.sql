DROP VIEW IF EXISTS view_mov_detalle_rutas_pagos;


CREATE OR REPLACE VIEW view_mov_detalle_rutas_pagos AS 
 SELECT DISTINCT det.idu_empleado,
    mov.idu_centro,
    det.idu_beneficiario,
    mov.idfactura,
    mov.idu_estatus,
    det.idu_escuela,
    det.idu_escolaridad,
    det.idu_tipopago,
    det.periodo,
    mov.idu_tipo_deduccion,
    mov.fec_factura,
    '1900-01-01'::date AS fec_cierre,
        CASE
            WHEN btrim(sap.controlpago::text) = ''::text THEN '0'::bpchar
            ELSE sap.controlpago
        END::integer AS clv_rutapago,
    sap.numerotarjeta AS num_cuenta,
    mov.opc_modifico_pago,
    det.prc_descuento,
    mov.importe_factura,
    mov.importe_pagado AS importe_pagado_factura,
    det.importe_concepto,
    det.importe_pagado AS importe_pagado_concepto,
    det.idu_ciclo_escolar
   FROM mov_facturas_colegiaturas mov
     JOIN cat_empleados_colegiaturas emp ON mov.idu_empleado = emp.idu_empleado
     JOIN sapcatalogoempleados sap ON sap.numempn = emp.idu_empleado
     JOIN mov_detalle_facturas_colegiaturas det ON det.idu_empleado = mov.idu_empleado AND det.idfactura = mov.idfactura;