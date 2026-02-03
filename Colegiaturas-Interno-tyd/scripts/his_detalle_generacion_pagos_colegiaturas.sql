DROP TABLE if exists his_detalle_generacion_pagos_colegiaturas;

CREATE TABLE his_detalle_generacion_pagos_colegiaturas
(
  idu_generacion integer NOT NULL DEFAULT 0,
  fec_generacion timestamp without time zone NOT NULL DEFAULT now(),
  idu_empleado integer NOT NULL DEFAULT 0,
  clv_rutapago integer NOT NULL DEFAULT 0,
  idfactura integer NOT NULL DEFAULT 0,
  idu_ajuste integer NOT NULL DEFAULT 0,
  prc_descuento integer NOT NULL DEFAULT 0,
  importe_factura numeric(12,2) NOT NULL DEFAULT 0,
  importe_pagado numeric(12,2) NOT NULL DEFAULT 0
);
--Índices
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_clv_rutapago ON his_detalle_generacion_pagos_colegiaturas(clv_rutapago);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_fec_generacion ON his_detalle_generacion_pagos_colegiaturas(fec_generacion);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_idfactura ON his_detalle_generacion_pagos_colegiaturas(idfactura);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_idu_ajuste ON his_detalle_generacion_pagos_colegiaturas(idu_ajuste);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_idu_empleado ON his_detalle_generacion_pagos_colegiaturas(idu_empleado);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_idu_generacion ON his_detalle_generacion_pagos_colegiaturas(idu_generacion);
CREATE INDEX idx_his_detalle_generacion_pagos_colegiaturas_prc_descuento ON his_detalle_generacion_pagos_colegiaturas(prc_descuento);