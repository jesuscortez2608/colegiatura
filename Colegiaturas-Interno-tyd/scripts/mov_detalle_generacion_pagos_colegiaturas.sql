/*
	No. petición APS               : 16559.1
	Fecha                          : 
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */

drop table if exists mov_detalle_generacion_pagos_colegiaturas;

CREATE TABLE mov_detalle_generacion_pagos_colegiaturas
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
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_clv_rutapago ON mov_detalle_generacion_pagos_colegiaturas(clv_rutapago);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_fec_generacion ON mov_detalle_generacion_pagos_colegiaturas(fec_generacion);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_idfactura ON mov_detalle_generacion_pagos_colegiaturas(idfactura);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_idu_ajuste ON mov_detalle_generacion_pagos_colegiaturas(idu_ajuste);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_idu_empleado ON mov_detalle_generacion_pagos_colegiaturas(idu_empleado);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_idu_generacion ON mov_detalle_generacion_pagos_colegiaturas(idu_generacion);
CREATE INDEX idx_mov_detalle_generacion_pagos_colegiaturas_prc_descuento ON mov_detalle_generacion_pagos_colegiaturas(prc_descuento);
  
--Información

COMMENT ON TABLE mov_detalle_generacion_pagos_colegiaturas IS 'Tabla detalle de mov_generacion_pagos_colegiaturas';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.idu_generacion IS 'ID de la generación de pagos (mov_generacion_pagos_colegiaturas.idu_generacion)';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.fec_generacion IS 'Fecha de generación de pagos';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.idu_empleado IS 'ID del colaborador al que se generó el pago';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.clv_rutapago IS 'ID de la ruta de pago';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.idfactura IS 'ID de la factura';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.idu_ajuste IS 'ID del ajuste, en caso de que se trate de un ajuste de facturas. Por default cero (0)';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.prc_descuento IS 'Porcentaje de descuento';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.importe_factura IS 'Importe real de la factura';
COMMENT ON COLUMN mov_detalle_generacion_pagos_colegiaturas.importe_pagado IS 'Importe pagado';