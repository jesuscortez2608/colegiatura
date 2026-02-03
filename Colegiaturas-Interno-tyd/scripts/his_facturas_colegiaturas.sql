DROP TABLE IF EXISTS his_facturas_colegiaturas;

CREATE TABLE his_facturas_colegiaturas
(
  fol_fiscal character varying(100), -- Folio fiscal (XML TimbreFiscalDigital / UUID)
  fol_factura character varying(50), -- Folio de la factura (XML Comprobante / Folio)
  serie character varying(20), -- Número de serie (XML Comprobante / Serie)
  fec_factura timestamp without time zone DEFAULT now(), -- Fecha del documento (XML Comprobante / Fecha)
  des_metodo_pago character varying(20) NOT NULL DEFAULT ''::character varying, -- Método de pago especificado en el XML
  fol_relacionado character varying(100) NOT NULL DEFAULT ''::character varying, -- Folio relacionado, en caso de que el XML corresponda a un abono de otro documento
  idu_empleado integer NOT NULL, -- ID del colaborador al que pertenece la factura
  clv_rutapago integer NOT NULL DEFAULT 0,
  num_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  idu_beneficiario_externo integer NOT NULL DEFAULT 0, -- ID del beneficiario externo al que pertenece la factura
  idu_centro integer NOT NULL DEFAULT 0, -- ID del centro del colaborador
  idu_puesto integer NOT NULL DEFAULT 0, -- ID del puesto del colaborador al momento de pagarse la factura
  idu_empresa integer NOT NULL DEFAULT 0, -- ID de la Empresa a la que pertenece el colaborador al momento de pagarse la factura
  opc_pdf integer NOT NULL, -- Indica si se incluyó el PDF en la captura
  idu_escuela integer NOT NULL, -- ID de la escuela cat_escuelas_colegiaturas.idu_escuela
  rfc_clave character varying(20) NOT NULL, -- RFC del emisor de la factura (XML Comprobante / Emisor / Rfc)
  importe_factura numeric(12,2) NOT NULL DEFAULT 0, -- Importe total de factura (XML Comprobante / Total)
  importe_calculado numeric(12,2) NOT NULL DEFAULT 0, -- Importe calculado con el porcentaje de descuento
  importe_pagado numeric(12,2) NOT NULL DEFAULT 0, -- Importe pagado finalmente, puede diferir del importe calculado porque el usuario puede modificar el importe a pagar
  tope_mensual numeric(12,2) NOT NULL DEFAULT 0, -- Sueldo mensual del colaborador sin despensa, dividido entre 2
  idu_tipo_documento integer NOT NULL, -- Tipo de documento cat_tipo_documento.idu_tipo_documento
  idu_tipo_deduccion integer NOT NULL DEFAULT 0, -- Tipo de deducción del documento cat_tipos_deduccion.idu_tipo
  idu_estatus integer NOT NULL, -- Estatus del documento cat_estatus_facturas
  opc_modifico_pago smallint NOT NULL DEFAULT 0, -- Indica si el usuario modificó el pago manualmente
  idu_motivo_rechazo integer NOT NULL DEFAULT 0, -- ID del motivo de rechazo de la factura
  emp_marco_estatus integer NOT NULL, -- ID del colaborador que marcó el estatus
  fec_marco_estatus timestamp without time zone DEFAULT now(), -- Fecha en que el colaborador marcó el estatus
  fec_cierre timestamp without time zone DEFAULT now(), -- Fecha de cierre
  des_comentario_especial text NOT NULL DEFAULT ''::text, -- Comentario especial
  des_aclaracion_costos text NOT NULL DEFAULT ''::text, -- Comentario de aclaración de los costos
  des_observaciones text NOT NULL DEFAULT ''::text, -- Observaciones
  fec_registro timestamp without time zone DEFAULT now(), -- Fecha de captura
  opc_movimiento_traspaso smallint DEFAULT 0, -- Indica si la factura fue traspasada
  idu_empleado_traspaso integer DEFAULT 0, -- ID del colaborador que realizó el traspaso
  fec_movimiento_traspaso timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone, -- Fecha de traspaso del movimiento
  idu_empleado_registro integer NOT NULL, -- ID del usuario que capturó el documento
  xml_factura text, -- Texto del XML
  nom_xml_recibo character varying(60) NOT NULL DEFAULT ''::character varying,
  nom_pdf_carta character varying(60) NOT NULL DEFAULT ''::character varying,
  idfactura bigint NOT NULL -- ID de la factura, consecutivo de la tabla mov_facturas_colegiaturas.idfactura (SERIAL)
);
COMMENT ON TABLE his_facturas_colegiaturas
  IS 'Histórico de facturas de colegiaturas';
COMMENT ON COLUMN his_facturas_colegiaturas.fol_fiscal IS 'Folio fiscal (XML TimbreFiscalDigital / UUID)';
COMMENT ON COLUMN his_facturas_colegiaturas.fol_factura IS 'Folio de la factura (XML Comprobante / Folio)';
COMMENT ON COLUMN his_facturas_colegiaturas.serie IS 'Número de serie (XML Comprobante / Serie)';
COMMENT ON COLUMN his_facturas_colegiaturas.fec_factura IS 'Fecha del documento (XML Comprobante / Fecha)';
COMMENT ON COLUMN his_facturas_colegiaturas.des_metodo_pago IS 'Método de pago especificado en el XML';
COMMENT ON COLUMN his_facturas_colegiaturas.fol_relacionado IS 'Folio relacionado, en caso de que el XML corresponda a un abono de otro documento';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_empleado IS 'ID del colaborador al que pertenece la factura';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_beneficiario_externo IS 'ID del beneficiario externo al que pertenece la factura';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_centro IS 'ID del centro del colaborador';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_puesto IS 'ID del puesto del colaborador al momento de pagarse la factura';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_empresa IS 'ID de la Empresa a la que pertenece el colaborador al momento de pagarse la factura';
COMMENT ON COLUMN his_facturas_colegiaturas.opc_pdf IS 'Indica si se incluyó el PDF en la captura';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_escuela IS 'ID de la escuela cat_escuelas_colegiaturas.idu_escuela';
COMMENT ON COLUMN his_facturas_colegiaturas.rfc_clave IS 'RFC del emisor de la factura (XML Comprobante / Emisor / Rfc)';
COMMENT ON COLUMN his_facturas_colegiaturas.importe_factura IS 'Importe total de factura (XML Comprobante / Total)';
COMMENT ON COLUMN his_facturas_colegiaturas.importe_calculado IS 'Importe calculado con el porcentaje de descuento';
COMMENT ON COLUMN his_facturas_colegiaturas.importe_pagado IS 'Importe pagado finalmente, puede diferir del importe calculado porque el usuario puede modificar el importe a pagar';
COMMENT ON COLUMN his_facturas_colegiaturas.tope_mensual IS 'Sueldo mensual del colaborador sin despensa, dividido entre 2';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_tipo_documento IS 'Tipo de documento cat_tipo_documento.idu_tipo_documento';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_tipo_deduccion IS 'Tipo de deducción del documento cat_tipos_deduccion.idu_tipo';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_estatus IS 'Estatus del documento cat_estatus_facturas';
COMMENT ON COLUMN his_facturas_colegiaturas.opc_modifico_pago IS 'Indica si el usuario modificó el pago manualmente';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_motivo_rechazo IS 'ID del motivo de rechazo de la factura';
COMMENT ON COLUMN his_facturas_colegiaturas.emp_marco_estatus IS 'ID del colaborador que marcó el estatus';
COMMENT ON COLUMN his_facturas_colegiaturas.fec_marco_estatus IS 'Fecha en que el colaborador marcó el estatus';
COMMENT ON COLUMN his_facturas_colegiaturas.fec_cierre IS 'Fecha de cierre';
COMMENT ON COLUMN his_facturas_colegiaturas.des_comentario_especial IS 'Comentario especial';
COMMENT ON COLUMN his_facturas_colegiaturas.des_aclaracion_costos IS 'Comentario de aclaración de los costos';
COMMENT ON COLUMN his_facturas_colegiaturas.des_observaciones IS 'Observaciones';
COMMENT ON COLUMN his_facturas_colegiaturas.fec_registro IS 'Fecha de captura';
COMMENT ON COLUMN his_facturas_colegiaturas.opc_movimiento_traspaso IS 'Indica si la factura fue traspasada';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_empleado_traspaso IS 'ID del colaborador que realizó el traspaso';
COMMENT ON COLUMN his_facturas_colegiaturas.fec_movimiento_traspaso IS 'Fecha de traspaso del movimiento';
COMMENT ON COLUMN his_facturas_colegiaturas.idu_empleado_registro IS 'ID del usuario que capturó el documento';
COMMENT ON COLUMN his_facturas_colegiaturas.xml_factura IS 'Texto del XML';
COMMENT ON COLUMN his_facturas_colegiaturas.idfactura IS 'ID de la factura, consecutivo de la tabla mov_facturas_colegiaturas.idfactura (SERIAL)';

--ÍNDICES
CREATE INDEX idx_his_facturas_colegiaturas_emp_marco_estatus ON his_facturas_colegiaturas (emp_marco_estatus);
CREATE INDEX idx_his_facturas_colegiaturas_fec_marco_estatus ON his_facturas_colegiaturas (fec_marco_estatus);
CREATE INDEX idx_his_facturas_colegiaturas_fec_registro ON his_facturas_colegiaturas (fec_registro);
CREATE INDEX idx_his_facturas_colegiaturas_fol_factura ON his_facturas_colegiaturas (fol_factura);
CREATE INDEX idx_his_facturas_colegiaturas_fol_fiscal ON his_facturas_colegiaturas (fol_fiscal);
CREATE INDEX idx_his_facturas_colegiaturas_idfactura ON his_facturas_colegiaturas (idfactura);
CREATE INDEX idx_his_facturas_colegiaturas_idu_beneficiario_externo ON his_facturas_colegiaturas (idu_beneficiario_externo);
CREATE INDEX idx_his_facturas_colegiaturas_idu_centro ON his_facturas_colegiaturas (idu_centro);
CREATE INDEX idx_his_facturas_colegiaturas_idu_empleado ON his_facturas_colegiaturas (idu_empleado);
CREATE INDEX idx_his_facturas_colegiaturas_idu_empleado_registro ON his_facturas_colegiaturas (idu_empleado_registro);
CREATE INDEX idx_his_facturas_colegiaturas_idu_empresa ON his_facturas_colegiaturas (idu_empresa);
CREATE INDEX idx_his_facturas_colegiaturas_idu_escuela ON his_facturas_colegiaturas (idu_escuela);
CREATE INDEX idx_his_facturas_colegiaturas_idu_estatus ON his_facturas_colegiaturas (idu_estatus);
CREATE INDEX idx_his_facturas_colegiaturas_idu_puesto ON his_facturas_colegiaturas (idu_puesto);
CREATE INDEX idx_his_facturas_colegiaturas_importe_calculado ON his_facturas_colegiaturas (importe_calculado);
CREATE INDEX idx_his_facturas_colegiaturas_importe_factura ON his_facturas_colegiaturas (importe_factura);
CREATE INDEX idx_his_facturas_colegiaturas_importe_pagado ON his_facturas_colegiaturas (importe_pagado);
CREATE INDEX idx_his_facturas_colegiaturas_opc_pdf ON his_facturas_colegiaturas (opc_pdf);
CREATE INDEX idx_his_facturas_colegiaturas_rfc_clave ON his_facturas_colegiaturas (rfc_clave);
CREATE INDEX idx_his_facturas_colegiaturas_serie ON his_facturas_colegiaturas (serie);