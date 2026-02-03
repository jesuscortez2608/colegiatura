DROP VIEW IF EXISTS view_his_detalle_rutas_pagos;



CREATE OR REPLACE VIEW view_his_detalle_rutas_pagos AS 
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
    mov.fec_cierre::date AS fec_cierre,
    mov.clv_rutapago,
    mov.num_cuenta,
    mov.opc_modifico_pago,
    det.prc_descuento,
    mov.importe_factura,
    mov.importe_pagado AS importe_pagado_factura,
    det.importe_concepto,
    det.importe_pagado AS importe_pagado_concepto
   FROM his_facturas_colegiaturas mov
     JOIN sapcatalogoempleados sap ON sap.numempn = mov.idu_empleado
     JOIN his_detalle_facturas_colegiaturas det ON det.idu_empleado = mov.idu_empleado AND det.idfactura = mov.idfactura;