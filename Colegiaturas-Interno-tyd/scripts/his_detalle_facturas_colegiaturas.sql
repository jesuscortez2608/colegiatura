/*
	No. petición APS               : 16559.1
	Fecha                          : 
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */
drop table if exists his_detalle_facturas_colegiaturas;

CREATE TABLE his_detalle_facturas_colegiaturas
(
  idu_empleado integer NOT NULL,
  fol_fiscal character varying(100) NOT NULL DEFAULT ''::character varying,
  idu_beneficiario integer NOT NULL,
  beneficiario_hoja_azul integer NOT NULL DEFAULT 0,
  idu_parentesco integer NOT NULL,
  idu_tipopago integer NOT NULL,
  prc_descuento integer NOT NULL,
  periodo character varying(150) NOT NULL DEFAULT ''::character varying,
  idu_escuela integer NOT NULL,
  idu_escolaridad integer NOT NULL,
  idu_carrera integer NOT NULL DEFAULT 0,
  idu_grado_escolar integer NOT NULL,
  idu_ciclo_escolar integer NOT NULL,
  importe_concepto numeric(12,2) NOT NULL DEFAULT 0,
  importe_pagado numeric(12,2) NOT NULL DEFAULT 0,
  fec_registro timestamp without time zone DEFAULT now(),
  idu_empleado_registro integer NOT NULL,
  idfactura integer NOT NULL,
  keyx integer NOT NULL
);

--Índices  
CREATE INDEX idx_his_detalle_facturas_colegiaturas_fec_registro ON his_detalle_facturas_colegiaturas(fec_registro);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idfactura ON his_detalle_facturas_colegiaturas(idfactura);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_beneficiario ON his_detalle_facturas_colegiaturas(idu_beneficiario);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_ciclo_escolar ON his_detalle_facturas_colegiaturas(idu_ciclo_escolar);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_empleado ON his_detalle_facturas_colegiaturas(idu_empleado);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_empleado_registro ON his_detalle_facturas_colegiaturas(idu_empleado_registro);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_escolaridad ON his_detalle_facturas_colegiaturas(idu_escolaridad);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_escuela ON his_detalle_facturas_colegiaturas(idu_escuela);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_grado_escolar ON his_detalle_facturas_colegiaturas(idu_grado_escolar);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_parentesco ON his_detalle_facturas_colegiaturas(idu_parentesco);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_idu_tipopago ON his_detalle_facturas_colegiaturas(idu_tipopago);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_importe_concepto ON his_detalle_facturas_colegiaturas(importe_concepto);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_keyx ON his_detalle_facturas_colegiaturas(keyx);
CREATE INDEX idx_his_detalle_facturas_colegiaturas_periodo ON his_detalle_facturas_colegiaturas(periodo);