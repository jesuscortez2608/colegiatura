DROP TABLE IF EXISTS mov_bitacora_movimientos_colegiaturas;

CREATE TABLE mov_bitacora_movimientos_colegiaturas
(
  idu_tipo_movimiento integer,
  idu_factura integer NOT NULL,
  importe_original numeric(12,2),
  importe_pagado numeric(12,2),
  idu_empleado_bloqueado integer NOT NULL DEFAULT 0,
  opc_bloqueado integer NOT NULL DEFAULT 0,
  poliza_cancelacion character varying(15) NOT NULL DEFAULT ''::character varying,
  idu_empleado_especial integer NOT NULL DEFAULT 0,
  idu_beneficiario_especial integer NOT NULL DEFAULT 0,
  opc_beneficiario_especial smallint NOT NULL DEFAULT 0,
  des_justificacion_especial character varying(300) NOT NULL DEFAULT ''::character varying,
  des_justificacion character varying(300) NOT NULL DEFAULT ''::character varying,
  fec_registro timestamp without time zone NOT NULL DEFAULT now(),
  idu_empleado_registro integer NOT NULL
);

--Índices
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_fec_registro ON mov_bitacora_movimientos_colegiaturas (fec_registro);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_beneficiario_espec ON mov_bitacora_movimientos_colegiaturas (idu_beneficiario_especial);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_empleado_bloqueado ON mov_bitacora_movimientos_colegiaturas (idu_empleado_bloqueado);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_empleado_especial ON mov_bitacora_movimientos_colegiaturas (idu_empleado_especial);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_empleado_registro ON mov_bitacora_movimientos_colegiaturas (idu_empleado_registro);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_factura ON mov_bitacora_movimientos_colegiaturas (idu_factura);
CREATE INDEX ix_mov_bitacora_movimientos_colegiaturas_idu_tipo_movimiento ON mov_bitacora_movimientos_colegiaturas (idu_tipo_movimiento);

