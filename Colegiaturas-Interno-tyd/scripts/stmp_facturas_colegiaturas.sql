DROP TABLE IF EXISTS stmp_facturas_colegiaturas;

CREATE TABLE stmp_facturas_colegiaturas
(
  fol_fiscal character varying(100),
  fol_factura character varying(50),
  serie character varying(20),
  fec_factura timestamp without time zone DEFAULT now(),
  idu_empleado integer NOT NULL,
  opc_pdf integer NOT NULL,
  idu_escuela integer NOT NULL,
  rfc_clave character varying(20) NOT NULL,
  importe_factura numeric(12,2) NOT NULL DEFAULT 0,
  idu_estatus integer NOT NULL,
  xml_factura text,
  fec_registro timestamp without time zone,
  idfactura SERIAL,
  idu_motivo_revision smallint DEFAULT 0,
  des_tipo_documento character varying(1) NOT NULL DEFAULT ''::character varying,
  des_metodo_pago character varying(3) NOT NULL DEFAULT ''::character varying,
  fol_relacionado character varying(50) NOT NULL DEFAULT ''::character varying
);
--Índices
CREATE INDEX idx_stmp_facturas_colegiaturas_des_metodo_pago ON stmp_facturas_colegiaturas (des_metodo_pago);
CREATE INDEX idx_stmp_facturas_colegiaturas_des_tipo_documento ON stmp_facturas_colegiaturas (des_tipo_documento);
CREATE INDEX idx_stmp_facturas_colegiaturas_fec_factura ON stmp_facturas_colegiaturas (fec_factura);
CREATE INDEX idx_stmp_facturas_colegiaturas_fec_registro ON stmp_facturas_colegiaturas (fec_registro);
CREATE INDEX idx_stmp_facturas_colegiaturas_fol_factura ON stmp_facturas_colegiaturas (fol_factura);
CREATE INDEX idx_stmp_facturas_colegiaturas_fol_fiscal ON stmp_facturas_colegiaturas (fol_fiscal);
CREATE INDEX idx_stmp_facturas_colegiaturas_fol_relacionado ON stmp_facturas_colegiaturas (fol_relacionado);
CREATE INDEX idx_stmp_facturas_colegiaturas_idfactura ON stmp_facturas_colegiaturas (idfactura);
CREATE INDEX idx_stmp_facturas_colegiaturas_idu_empleado ON stmp_facturas_colegiaturas (idu_empleado);
CREATE INDEX idx_stmp_facturas_colegiaturas_idu_escuela ON stmp_facturas_colegiaturas (idu_escuela);
CREATE INDEX idx_stmp_facturas_colegiaturas_idu_estatus ON stmp_facturas_colegiaturas (idu_estatus);
CREATE INDEX idx_stmp_facturas_colegiaturas_idu_motivo_revision ON stmp_facturas_colegiaturas (idu_motivo_revision);
CREATE INDEX idx_stmp_facturas_colegiaturas_importe_factura ON stmp_facturas_colegiaturas (importe_factura);
CREATE INDEX idx_stmp_facturas_colegiaturas_opc_pdf ON stmp_facturas_colegiaturas (opc_pdf);
CREATE INDEX idx_stmp_facturas_colegiaturas_rfc_clave ON stmp_facturas_colegiaturas (rfc_clave);
CREATE INDEX idx_stmp_facturas_colegiaturas_serie ON stmp_facturas_colegiaturas (serie);