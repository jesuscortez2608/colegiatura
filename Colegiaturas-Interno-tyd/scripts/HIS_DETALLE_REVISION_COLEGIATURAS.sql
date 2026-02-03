CREATE TABLE his_detalle_revision_colegiaturas
(
  idu_revision integer NOT NULL,
  idu_escuela integer NOT NULL,
  idu_ciclo_escolar integer NOT NULL,
  idu_escolaridad integer NOT NULL,
  idu_carrera integer NOT NULL DEFAULT 0,
  idu_tipo_pago integer NOT NULL,
  prc_descuento integer NOT NULL DEFAULT 0,
  idu_motivo integer NOT NULL,
  importe_concepto numeric(12,2),
  idu_usuario_registro integer NOT NULL DEFAULT 0,
  fec_registro date NOT NULL DEFAULT now(),
  keyx integer
);

CREATE INDEX idx_his_detalle_revision_colegiaturas_fec_registro ON his_detalle_revision_colegiaturas (fec_registro);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_carrera ON his_detalle_revision_colegiaturas (idu_carrera);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_ciclo_escolar ON his_detalle_revision_colegiaturas (idu_ciclo_escolar);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_escolaridad ON his_detalle_revision_colegiaturas (idu_escolaridad);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_escuela ON his_detalle_revision_colegiaturas (idu_escuela);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_motivo ON his_detalle_revision_colegiaturas (idu_motivo);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_revision ON his_detalle_revision_colegiaturas (idu_revision);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_tipo_pago ON his_detalle_revision_colegiaturas (idu_tipo_pago);
CREATE INDEX idx_his_detalle_revision_colegiaturas_idu_usuario_registro ON his_detalle_revision_colegiaturas (idu_usuario_registro);
CREATE INDEX idx_his_detalle_revision_colegiaturas_keyx ON his_detalle_revision_colegiaturas(keyx);

