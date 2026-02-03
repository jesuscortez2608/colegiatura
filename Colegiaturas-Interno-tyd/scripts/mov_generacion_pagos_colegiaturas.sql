/*
	No. petición APS               : 16559.1
	Fecha                          : 
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
---------------------------------------------------------------------------------------------------- */
drop table if exists mov_generacion_pagos_colegiaturas;

CREATE TABLE mov_generacion_pagos_colegiaturas
(
  idu_empleado integer NOT NULL DEFAULT 0, -- ID del colaborador al que se le genera el pago de colegiaturas
  idu_centro integer NOT NULL DEFAULT 0, -- ID del centro al que pertenece el colaborador
  idu_puesto integer NOT NULL DEFAULT 0, -- ID del puesto del colaborador
  nom_empleado character varying(30) NOT NULL DEFAULT ''::character varying, -- Nombre del colaborador
  ape_paterno character varying(30) NOT NULL DEFAULT ''::character varying, -- Apellido Paterno
  ape_materno character varying(30) NOT NULL DEFAULT ''::character varying, -- Apellido Materno
  clv_rutapago integer NOT NULL DEFAULT 0, -- ID de la ruta de pago cat_rutaspagos.idu_rutapago
  num_cuenta character varying(18) NOT NULL DEFAULT ''::character varying, -- Número del cuenta al que se deposita
  num_sucursal integer NOT NULL DEFAULT 0, -- Número de surcursal (relevante para Banamex)
  importe_factura numeric(12,2) NOT NULL DEFAULT 0, -- Importe original de las facturas
  importe_pagado numeric(12,2) NOT NULL DEFAULT 0, -- Importe total pagado
  importe_isr numeric(12,2) NOT NULL DEFAULT 0, -- Importe ISR
  fec_generacion timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de generación de pagos
  idu_empleado_generacion integer NOT NULL DEFAULT 0, -- ID del colaborador que generó los pagos
  idu_generacion integer NOT NULL DEFAULT 0, -- ID de la generación de pagos
  fec_quincena DATE NOT NULL DEFAULT('1900-01-01')
);

--Índices
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_ape_materno ON mov_generacion_pagos_colegiaturas(ape_materno);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_ape_paterno ON mov_generacion_pagos_colegiaturas(ape_paterno);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_clv_rutapago ON mov_generacion_pagos_colegiaturas(clv_rutapago);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_fec_generacion ON mov_generacion_pagos_colegiaturas(fec_generacion);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_idu_centro ON mov_generacion_pagos_colegiaturas(idu_centro);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_idu_empleado ON mov_generacion_pagos_colegiaturas(idu_empleado);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_idu_empleado_generacion ON mov_generacion_pagos_colegiaturas(idu_empleado_generacion);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_idu_generacion ON mov_generacion_pagos_colegiaturas(idu_generacion);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_idu_puesto ON mov_generacion_pagos_colegiaturas(idu_puesto);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_nom_empleado ON mov_generacion_pagos_colegiaturas(nom_empleado);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_num_cuenta ON mov_generacion_pagos_colegiaturas(num_cuenta);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_num_sucursal ON mov_generacion_pagos_colegiaturas(num_sucursal);
CREATE INDEX idx_mov_generacion_pagos_colegiaturas_fec_quincena ON mov_generacion_pagos_colegiaturas(fec_quincena);

--Información
COMMENT ON TABLE mov_generacion_pagos_colegiaturas IS 'Tabla de generación de pagos de Colegiaturas';  
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.idu_empleado IS 'ID del colaborador al que se le genera el pago de colegiaturas';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.idu_centro IS 'ID del centro al que pertenece el colaborador';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.idu_puesto IS 'ID del puesto del colaborador';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.nom_empleado IS 'Nombre del colaborador';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.ape_paterno IS 'Apellido Paterno';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.ape_materno IS 'Apellido Materno';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.clv_rutapago IS 'ID de la ruta de pago cat_rutaspagos.idu_rutapago';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.num_cuenta IS 'Número del cuenta al que se deposita';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.num_sucursal IS 'Número de surcursal (relevante para Banamex)';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.importe_factura IS 'Importe original de las facturas';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.importe_pagado IS 'Importe total pagado';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.importe_isr IS 'Importe ISR';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.fec_generacion IS 'Fecha de generación de pagos';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.idu_empleado_generacion IS 'ID del colaborador que generó los pagos';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.idu_generacion IS 'ID de la generación de pagos';
COMMENT ON COLUMN mov_generacion_pagos_colegiaturas.fec_quincena IS 'Quincena en que se generaron los pagos';