CREATE TABLE mov_aplicacion_notas_credito
(
	idnotacredito integer NOT NULL DEFAULT 0,
	idfactura integer NOT NULL DEFAULT 0,
	importe_nota numeric NOT NULL DEFAULT 0,
	importe_factura numeric NOT NULL DEFAULT 0,
	prc_descuento integer NOT NULL DEFAULT 0,
	importe_calculado numeric NOT NULL DEFAULT 0,
	importe_aplicado numeric NOT NULL DEFAULT 0,
	importe_pagado numeric NOT NULL DEFAULT 0
);

CREATE INDEX idx_mov_aplicacion_notas_credito_idnotacredito ON mov_aplicacion_notas_credito (idnotacredito);
CREATE INDEX idx_mov_aplicacion_notas_credito_idfactura ON mov_aplicacion_notas_credito (idfactura);
CREATE INDEX idx_mov_aplicacion_notas_credito_importe_nota ON mov_aplicacion_notas_credito (importe_nota);
CREATE INDEX idx_mov_aplicacion_notas_credito_importe_factura ON mov_aplicacion_notas_credito (importe_factura);
CREATE INDEX idx_mov_aplicacion_notas_credito_prc_descuento ON mov_aplicacion_notas_credito (prc_descuento);
CREATE INDEX idx_mov_aplicacion_notas_credito_importe_calculado ON mov_aplicacion_notas_credito (importe_calculado);
CREATE INDEX idx_mov_aplicacion_notas_credito_importe_aplicado ON mov_aplicacion_notas_credito (importe_aplicado);
CREATE INDEX idx_mov_aplicacion_notas_credito_importe_pagado ON mov_aplicacion_notas_credito (importe_pagado);