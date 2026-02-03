/*
	No. petición APS               : 16559.1
	Fecha                          : 28/05/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : cat_rutaspagos
------------------------------------------------------------------------------------------------------ */
CREATE TABLE mov_facturas_pagadas
(
  idu_generacion integer,
  idfactura integer,
  idu_empleado integer,
  prc_descuento integer,
  opc_cheque integer,
  clv_rutapago integer,
  importe_factura numeric(12,2),
  importe_pagado numeric(12,2)
);

--Indices
CREATE INDEX idx_mov_facturas_pagadas_clv_rutapago ON mov_facturas_pagadas (clv_rutapago);
CREATE INDEX idx_mov_facturas_pagadas_idfactura ON mov_facturas_pagadas (idfactura);
CREATE INDEX idx_mov_facturas_pagadas_idu_empleado ON mov_facturas_pagadas (idu_empleado);
CREATE INDEX idx_mov_facturas_pagadas_idu_generacion ON mov_facturas_pagadas (idu_generacion);
CREATE INDEX idx_mov_facturas_pagadas_opc_cheque ON mov_facturas_pagadas (opc_cheque);
CREATE INDEX idx_mov_facturas_pagadas_prc_descuento ON mov_facturas_pagadas (prc_descuento);

