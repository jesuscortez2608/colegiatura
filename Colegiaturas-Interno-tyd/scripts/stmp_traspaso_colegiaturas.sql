DROP TABLE if exists stmp_traspaso_colegiaturas;

CREATE TABLE stmp_traspaso_colegiaturas
(
  ottp integer NOT NULL DEFAULT 0, -- Indica si la factura tiene más de un periodo de pago (si en mov_detalle_facturas_colegiaturas tiene más de un registro)
  empleado integer NOT NULL DEFAULT 0, -- ID del colaborador a quien pertenece la factura
  nomempleado character varying(150) NOT NULL DEFAULT ''::character varying, -- Nombre del colaborador
  clv_tipo_registro integer NOT NULL DEFAULT 1, -- 1 Factura mensual, 2 Ajuste de facturas
  tiponomina integer NOT NULL DEFAULT 1, -- 1 Empleado; 3 Directivo
  des_tipo_registro character varying(20) NOT NULL DEFAULT 'PAGO'::character varying, -- 1 "PAGO", 2 "AJUSTE"
  beneficiario_hoja_azul integer NOT NULL DEFAULT 0, -- Indica si el beneficiario inicial es de la hoja azul
  beneficiario integer NOT NULL DEFAULT 0, -- ID del primer beneficiario de la factura en mov_detalle_facturas_colegiaturas (his_detalle_facturas_colegiaturas si es un ajuste)
  nombeneficiario character varying(150) NOT NULL DEFAULT ''::character varying, -- Nombre del primer beneficiario de la factura en mov_detalle_facturas_colegiaturas (his_detalle_facturas_colegiaturas si es un ajuste)
  facturafiscal character varying(100) NOT NULL DEFAULT ''::character varying, -- mov_facturas_colegiaturas.fol_fiscal (his_facturas_colegiaturas.fol_fiscal si es un ajuste)
  fechafactura date, -- mov_facturas_colegiaturas.fec_factura(his_facturas_colegiaturas.fec_factura si es un ajuste)
  idciclo integer NOT NULL DEFAULT 0, -- mov_detalle_facturas_colegiaturas.idu_ciclo_escolar(his_detalle_facturas_colegiaturas.idu_ciclo_escolar si es un ajuste)
  nomciclo character varying(30) NOT NULL DEFAULT ''::character varying, -- cat_ciclos_escolares.des_ciclo_escolar
  fechacaptura date, -- mov_facturas_colegiaturas.fec_registro (mov_ajustes_facturas_colegiaturas.fec_registro)
  idtipopago integer NOT NULL DEFAULT 0, -- mov_detalle_facturas_colegiaturas.idu_tipopago
  tipopago character varying(20) NOT NULL DEFAULT ''::character varying,
  periodo character varying(150) NOT NULL DEFAULT ''::character varying, -- mov_detalle_facturas_colegiaturas.periodo
  des_periodo text NOT NULL DEFAULT ''::character varying, -- los nombres de los periodos (cat_periodos_pagos.des_periodo)
  importe_fac numeric(12,2), -- mov_facturas_colegiaturas.importe_factura
  importe_pago numeric(12,2), -- mov_facturas_colegiaturas.importe_pagado (mov_ajustes_facturas_colegiaturas.importe_ajuste)
  idestudio integer NOT NULL DEFAULT 0, -- mov_detalle_facturas_colegiaturas.idu_escolaridad(his_detalle_facturas_colegiaturas.idu_escolaridad si es un ajuste)
  estudio character varying(30) NOT NULL DEFAULT ''::character varying, -- cat_escolaridades.nom_escolaridad
  idescuela integer NOT NULL DEFAULT 0, -- mov_detalle_facturas_colegiaturas.idu_escuela(his_detalle_facturas_colegiaturas.idu_escuela si es un ajuste)
  escuela character varying(100) NOT NULL DEFAULT ''::character varying, -- cat_escuelas_colegiaturas.nom_escuela
  rfc character varying(20) NOT NULL DEFAULT ''::character varying, -- sapcatalogoempleados.rfc
  descuento integer NOT NULL DEFAULT 0, -- mov_detalle_facturas_colegiaturas.prc_descuento (mov_ajustes_facturas_colegiaturas.pct_ajuste)
  iddeduccion integer NOT NULL DEFAULT 0, -- mov_facturas_colegiaturas.idu_tipo_deduccion(his_facturas_colegiaturas.idu_tipo_deduccion si es un ajuste)
  deduccion character varying(30) NOT NULL DEFAULT ''::character varying, -- cat_tipos_deduccion.nom_deduccion
  observaciones text NOT NULL DEFAULT ''::text, -- mov_facturas_colegiaturas.des_observaciones (mov_ajustes_facturas_colegiaturas.des_observaciones si es un ajuste)
  idrutapago integer NOT NULL DEFAULT 0, -- sapcatalogoempleados.controlpago
  rutapago character varying NOT NULL DEFAULT ''::character varying, -- cat_rutaspagos.nom_rutapago
  numtarjeta character varying(16) NOT NULL DEFAULT ''::character varying, -- sapcatalogoempleados.numerotarjeta
  idfactura integer NOT NULL DEFAULT 0, -- mov_facturas_colegiaturas.id_factura (mov_ajustes_facturas_colegiaturas.id_factura si es un ajuste)
  marcado integer NOT NULL DEFAULT 0, -- stmp_traspaso_colegiaturas.marcado, indica si el usuario marcó el registro en la pantalla de traspasos
  usuario integer NOT NULL DEFAULT 0 -- stmp_traspaso_colegiaturas.usuario, número de colaborador del usuario que está haciendo el traspaso
);

-- Informacion
COMMENT ON TABLE stmp_traspaso_colegiaturas
  IS 'Tabla auxiliar para el traspaso de movimientos en Colegiaturas';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.ottp IS 'Indica si la factura tiene más de un periodo de pago (si en mov_detalle_facturas_colegiaturas tiene más de un registro)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.empleado IS 'ID del colaborador a quien pertenece la factura';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.nomempleado IS 'Nombre del colaborador';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.clv_tipo_registro IS '1 Factura mensual, 2 Ajuste de facturas';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.tiponomina IS '1 Empleado; 3 Directivo';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.des_tipo_registro IS '1 "PAGO", 2 "AJUSTE"';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.beneficiario_hoja_azul IS 'Indica si el beneficiario inicial es de la hoja azul';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.beneficiario IS 'ID del primer beneficiario de la factura en mov_detalle_facturas_colegiaturas (his_detalle_facturas_colegiaturas si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.nombeneficiario IS 'Nombre del primer beneficiario de la factura en mov_detalle_facturas_colegiaturas (his_detalle_facturas_colegiaturas si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.facturafiscal IS 'mov_facturas_colegiaturas.fol_fiscal (his_facturas_colegiaturas.fol_fiscal si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.fechafactura IS 'mov_facturas_colegiaturas.fec_factura(his_facturas_colegiaturas.fec_factura si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idciclo IS 'mov_detalle_facturas_colegiaturas.idu_ciclo_escolar(his_detalle_facturas_colegiaturas.idu_ciclo_escolar si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.nomciclo IS 'cat_ciclos_escolares.des_ciclo_escolar';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.fechacaptura IS 'mov_facturas_colegiaturas.fec_registro (mov_ajustes_facturas_colegiaturas.fec_registro)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idtipopago IS 'mov_detalle_facturas_colegiaturas.idu_tipopago';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.periodo IS 'mov_detalle_facturas_colegiaturas.periodo';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.des_periodo IS 'los nombres de los periodos (cat_periodos_pagos.des_periodo)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.importe_fac IS 'mov_facturas_colegiaturas.importe_factura';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.importe_pago IS 'mov_facturas_colegiaturas.importe_pagado (mov_ajustes_facturas_colegiaturas.importe_ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idestudio IS 'mov_detalle_facturas_colegiaturas.idu_escolaridad(his_detalle_facturas_colegiaturas.idu_escolaridad si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.estudio IS 'cat_escolaridades.nom_escolaridad';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idescuela IS 'mov_detalle_facturas_colegiaturas.idu_escuela(his_detalle_facturas_colegiaturas.idu_escuela si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.escuela IS 'cat_escuelas_colegiaturas.nom_escuela';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.rfc IS 'sapcatalogoempleados.rfc';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.descuento IS 'mov_detalle_facturas_colegiaturas.prc_descuento (mov_ajustes_facturas_colegiaturas.pct_ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.iddeduccion IS 'mov_facturas_colegiaturas.idu_tipo_deduccion(his_facturas_colegiaturas.idu_tipo_deduccion si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.deduccion IS 'cat_tipos_deduccion.nom_deduccion';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.observaciones IS 'mov_facturas_colegiaturas.des_observaciones (mov_ajustes_facturas_colegiaturas.des_observaciones si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idrutapago IS 'sapcatalogoempleados.controlpago';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.rutapago IS 'cat_rutaspagos.nom_rutapago';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.numtarjeta IS 'sapcatalogoempleados.numerotarjeta';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.idfactura IS 'mov_facturas_colegiaturas.id_factura (mov_ajustes_facturas_colegiaturas.id_factura si es un ajuste)';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.marcado IS 'stmp_traspaso_colegiaturas.marcado, indica si el usuario marcó el registro en la pantalla de traspasos';
COMMENT ON COLUMN stmp_traspaso_colegiaturas.usuario IS 'stmp_traspaso_colegiaturas.usuario, número de colaborador del usuario que está haciendo el traspaso';

-- Indices
CREATE INDEX ix_stmp_traspaso_colegiaturas_marcado ON stmp_traspaso_colegiaturas(marcado);
CREATE INDEX ix_stmp_traspaso_colegiaturas_usuario ON stmp_traspaso_colegiaturas(usuario);