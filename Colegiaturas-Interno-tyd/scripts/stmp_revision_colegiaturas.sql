CREATE TABLE stmp_revision_colegiaturas
(
  idu_revision integer NOT NULL,
  idu_escuela integer NOT NULL,
  idu_motivo_revision smallint NOT NULL,
  idu_estatus_revision smallint NOT NULL,
  idu_usuario_captura integer NOT NULL,
  fec_captura timestamp without time zone NOT NULL,
  fec_revision timestamp without time zone NOT NULL,
  usuario_revision integer NOT NULL,
  idu_usuario integer NOT NULL
);

