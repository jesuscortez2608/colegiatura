/*
	No. petición APS               : 16559.1
	Fecha                          : 22/05/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : his_ajustes_facturas_colegiaturas
------------------------------------------------------------------------------------------------------ */
CREATE TABLE his_ajustes_facturas_colegiaturas
(
  idu_ajuste integer NOT NULL,
  idfactura integer NOT NULL,
  importe_factura numeric(12,2) NOT NULL,
  importe_pagado numeric(12,2) NOT NULL,
  pct_ajuste integer NOT NULL,
  importe_ajuste numeric(12,2) NOT NULL,
  des_observaciones text NOT NULL DEFAULT ''::text,
  idu_usuario_traspaso integer NOT NULL DEFAULT 0,
  fec_traspaso timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  idu_usuario_registro integer NOT NULL,
  fec_registro timestamp without time zone DEFAULT now(),
  idu_usuario_cierre integer NOT NULL,
  fec_cierre timestamp without time zone DEFAULT now()
);

--Índices
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_fec_cierre ON his_ajustes_facturas_colegiaturas (fec_cierre );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_fec_registro ON his_ajustes_facturas_colegiaturas (fec_registro );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_fec_traspaso ON his_ajustes_facturas_colegiaturas (fec_traspaso );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_idfactura ON his_ajustes_facturas_colegiaturas (idfactura );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_idu_ajuste ON his_ajustes_facturas_colegiaturas (idu_ajuste );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_idu_usuario_cierre ON his_ajustes_facturas_colegiaturas (idu_usuario_cierre );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_idu_usuario_registro ON his_ajustes_facturas_colegiaturas (idu_usuario_registro );
CREATE INDEX idx_his_ajustes_facturas_colegiaturas_idu_usuario_traspaso ON his_ajustes_facturas_colegiaturas (idu_usuario_traspaso );

--Documentación
COMMENT ON TABLE his_ajustes_facturas_colegiaturas IS 'Tabla de ajustes para facturas pagadas (Histórico, solo ajustes pagados)';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.idu_ajuste IS 'Identificador único de la tabla, correspondiente al valor del campo mov_ajustes_facturas_colegiaturas.idu_ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.idfactura IS 'Identificador numérico de la factura en his_facturas_colegiaturas.idfactura';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.importe_factura IS 'Importe original de la factura his_facturas_colegiaturas.importe_factura';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.importe_pagado IS 'Importe pagado de la factura his_facturas_colegiaturas.importe_pagado + sumatoria(his_ajustes_facturas_colegiaturas.importe_ajuste)';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.pct_ajuste IS 'Porcentaje del ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.importe_ajuste IS 'Importe del ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.des_observaciones IS 'Observaciones o justificación del ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.idu_usuario_traspaso IS 'Usuario que realizó el traspaso de colegiaturas donde se incluyó el ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.fec_traspaso IS 'Fecha en que se realizó el traspaso';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.idu_usuario_registro IS 'ID del usuario que registró el ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.fec_registro IS 'Fecha en que el usuario registó el ajuste';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.idu_usuario_cierre IS 'ID del usuario que generó el cierre';
COMMENT ON COLUMN his_ajustes_facturas_colegiaturas.fec_cierre IS 'Fecha de generación del cierre de colegiaturas';




