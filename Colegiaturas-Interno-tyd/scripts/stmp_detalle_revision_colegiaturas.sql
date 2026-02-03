CREATE TABLE stmp_detalle_revision_colegiaturas
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
  idu_tipo_registro integer NOT NULL,
  keyx integer,
  idu_usuario integer
);
CREATE INDEX idx_stmp_detalle_revision_colegiaturas_idu_revision ON stmp_detalle_revision_colegiaturas (idu_revision);
CREATE INDEX idx_stmp_detalle_revision_colegiaturas_idu_usuario ON stmp_detalle_revision_colegiaturas (idu_usuario);
CREATE INDEX idx_stmp_detalle_revision_colegiaturas_keyx ON stmp_detalle_revision_colegiaturas(keyx);

