CREATE TABLE his_revision_colegiaturas
(
  idu_revision integer,
  idu_escuela integer NOT NULL,
  idu_motivo_revision smallint NOT NULL,
  idu_estatus_revision smallint NOT NULL,
  idu_usuario_captura integer NOT NULL,
  fec_captura timestamp without time zone NOT NULL DEFAULT now(),
  fec_revision timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  usuario_revision integer NOT NULL DEFAULT 0
);

CREATE INDEX idx_his_revision_colegiaturas_fec_captura ON his_revision_colegiaturas (fec_captura);
CREATE INDEX idx_his_revision_colegiaturas_fec_revision ON his_revision_colegiaturas (fec_revision);
CREATE INDEX idx_his_revision_colegiaturas_idu_escuela ON his_revision_colegiaturas (idu_escuela);
CREATE INDEX idx_his_revision_colegiaturas_idu_idu_estatus_revision ON his_revision_colegiaturas (idu_estatus_revision);
CREATE INDEX idx_his_revision_colegiaturas_idu_idu_motivo_revision ON his_revision_colegiaturas (idu_motivo_revision);
CREATE INDEX idx_his_revision_colegiaturas_idu_revision ON his_revision_colegiaturas (idu_revision);
CREATE INDEX idx_his_revision_colegiaturas_idu_usuario_captura ON his_revision_colegiaturas (idu_usuario_captura);
CREATE INDEX idx_his_revision_colegiaturas_usuario_revision ON his_revision_colegiaturas (usuario_revision);

