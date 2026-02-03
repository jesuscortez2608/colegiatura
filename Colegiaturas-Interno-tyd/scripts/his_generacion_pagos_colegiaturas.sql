/*
	No. petición APS               : 16559.1
	Fecha                          : 28/05/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : his_detalle_generacion_pagos_colegiaturas
------------------------------------------------------------------------------------------------------ */
DROP TABLE if exists his_generacion_pagos_colegiaturas;

CREATE TABLE his_generacion_pagos_colegiaturas (
  idu_empleado integer NOT NULL DEFAULT 0,
  idu_centro integer NOT NULL DEFAULT 0,
  idu_puesto integer NOT NULL DEFAULT 0,
  nom_empleado character varying(30) NOT NULL DEFAULT ''::character varying,
  ape_paterno character varying(30) NOT NULL DEFAULT ''::character varying,
  ape_materno character varying(30) NOT NULL DEFAULT ''::character varying,
  clv_rutapago integer NOT NULL DEFAULT 0,
  num_cuenta character varying(18) NOT NULL DEFAULT ''::character varying,
  num_sucursal integer NOT NULL DEFAULT 0,
  importe_factura numeric(12,2) NOT NULL DEFAULT 0,
  importe_pagado numeric(12,2) NOT NULL DEFAULT 0,
  importe_isr numeric(12,2) NOT NULL DEFAULT 0,
  fec_generacion timestamp without time zone NOT NULL DEFAULT now(),
  idu_empleado_generacion integer NOT NULL DEFAULT 0,
  idu_generacion integer NOT NULL DEFAULT 0, -- ID de la generación de pagos
  fec_quincena DATE NOT NULL DEFAULT('1900-01-01')
);

--Indices
CREATE INDEX idx_his_generacion_pagos_colegiaturas_ape_materno ON his_generacion_pagos_colegiaturas (ape_materno);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_ape_paterno ON his_generacion_pagos_colegiaturas (ape_paterno);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_clv_rutapago ON his_generacion_pagos_colegiaturas (clv_rutapago);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_fec_generacion ON his_generacion_pagos_colegiaturas (fec_generacion);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_idu_centro ON his_generacion_pagos_colegiaturas (idu_centro);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_idu_empleado ON his_generacion_pagos_colegiaturas (idu_empleado);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_idu_empleado_generacion ON his_generacion_pagos_colegiaturas(idu_empleado_generacion);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_idu_generacion ON his_generacion_pagos_colegiaturas (idu_generacion);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_idu_puesto ON his_generacion_pagos_colegiaturas (idu_puesto);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_nom_empleado ON his_generacion_pagos_colegiaturas (nom_empleado);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_num_cuenta ON his_generacion_pagos_colegiaturas (num_cuenta);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_num_sucursal ON his_generacion_pagos_colegiaturas (num_sucursal);
CREATE INDEX idx_his_generacion_pagos_colegiaturas_fec_quincena ON his_generacion_pagos_colegiaturas (fec_quincena);
