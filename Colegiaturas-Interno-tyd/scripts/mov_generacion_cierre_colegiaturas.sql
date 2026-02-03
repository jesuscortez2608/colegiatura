 DROP TABLE if exists mov_generacion_cierre_colegiaturas;

CREATE TABLE mov_generacion_cierre_colegiaturas
(
  idu_empleado integer,
  fec_cierre timestamp without time zone DEFAULT now(),
  idu_generacion_pagos integer
);
