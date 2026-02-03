CREATE TABLE mov_suplentes_colegiaturas
(
  id serial,
  idu_empleado integer NOT NULL,
  idu_suplente integer NOT NULL,
  idu_empleado_registro integer NOT NULL,
  fec_registro timestamp without time zone,
  fec_inicial timestamp without time zone,
  fec_final timestamp without time zone,
  opc_indefinido integer NOT NULL
);

-- Index: idx_mov_suplentes_colegiaturas_fec_final

-- DROP INDEX idx_mov_suplentes_colegiaturas_fec_final;

CREATE INDEX idx_mov_suplentes_colegiaturas_fec_final ON mov_suplentes_colegiaturas (fec_final );

-- Index: idx_mov_suplentes_colegiaturas_fec_inicial

-- DROP INDEX idx_mov_suplentes_colegiaturas_fec_inicial;

CREATE INDEX idx_mov_suplentes_colegiaturas_fec_inicial ON mov_suplentes_colegiaturas (fec_inicial );

-- Index: idx_mov_suplentes_colegiaturas_fec_registro

-- DROP INDEX idx_mov_suplentes_colegiaturas_fec_registro;

CREATE INDEX idx_mov_suplentes_colegiaturas_fec_registro ON mov_suplentes_colegiaturas (fec_registro );

-- Index: idx_mov_suplentes_colegiaturas_idu_empleado

-- DROP INDEX idx_mov_suplentes_colegiaturas_idu_empleado;

CREATE INDEX idx_mov_suplentes_colegiaturas_idu_empleado ON mov_suplentes_colegiaturas (idu_empleado );

-- Index: idx_mov_suplentes_colegiaturas_idu_empleado_registro

-- DROP INDEX idx_mov_suplentes_colegiaturas_idu_empleado_registro;

CREATE INDEX idx_mov_suplentes_colegiaturas_idu_empleado_registro ON mov_suplentes_colegiaturas (idu_empleado_registro );

-- Index: idx_mov_suplentes_colegiaturas_idu_suplente

-- DROP INDEX idx_mov_suplentes_colegiaturas_idu_suplente;

CREATE INDEX idx_mov_suplentes_colegiaturas_idu_suplente ON mov_suplentes_colegiaturas (idu_suplente );

-- Index: idx_mov_suplentes_colegiaturas_opc_indefinido

-- DROP INDEX idx_mov_suplentes_colegiaturas_opc_indefinido;

CREATE INDEX idx_mov_suplentes_colegiaturas_opc_indefinido ON mov_suplentes_colegiaturas (opc_indefinido );

