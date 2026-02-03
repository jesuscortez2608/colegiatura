DROP TABLE if exists ctl_variables_colegiaturas;

CREATE TABLE ctl_variables_colegiaturas
(
  pct_tolerancia integer NOT NULL DEFAULT 0,
  fec_registro timestamp without time zone NOT NULL DEFAULT now(),
  idu_usuario_registro integer NOT NULL DEFAULT 0
);

--Valores Iniciales
INSERT INTO ctl_variables_colegiaturas(pct_tolerancia, fec_registro, idu_usuario_registro) VALUES(20, now(), 95194185);