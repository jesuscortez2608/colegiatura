/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		cat_tipos_deduccion
------------------------------------------------------------------------------------------------------ */
-- Definición
	DROP TABLE IF EXISTS mov_facturas_colegiaturas;
	
	CREATE TABLE mov_facturas_colegiaturas (idu_empresa INTEGER NOT NULL,
        fol_fiscal character varying(100),
        fol_factura character varying(50),
        serie character varying(20),
        fec_factura timestamp without time zone DEFAULT now(),
        des_metodo_pago VARCHAR(20) NOT NULL DEFAULT ('') ,
        fol_relacionado character varying(100),
        idu_motivo_revision INTEGER NOT NULL DEFAULT(0),
        idu_empleado integer NOT NULL DEFAULT 0,
        idu_beneficiario_externo INTEGER NOT NULL DEFAULT 0,
        idu_centro integer NOT NULL DEFAULT 0,
        opc_pdf integer NOT NULL,
        idu_escuela integer NOT NULL,
        rfc_clave character varying(20) NOT NULL,
        importe_factura numeric(12,2) NOT NULL DEFAULT 0,
        importe_calculado numeric(12,2) NOT NULL DEFAULT 0,
        importe_pagado numeric(12,2) NOT NULL DEFAULT 0,
        idu_tipo_documento INTEGER NOT NULL,
        idu_tipo_deduccion integer NOT NULL DEFAULT 0,
        idu_estatus integer NOT NULL,
        opc_modifico_pago smallint NOT NULL DEFAULT 0,
        idu_motivo_rechazo integer NOT NULL DEFAULT 0,
        emp_marco_estatus integer NOT NULL,
        fec_marco_estatus timestamp without time zone DEFAULT now(),
        des_comentario_especial text NOT NULL DEFAULT ''::text,
        des_aclaracion_costos text NOT NULL DEFAULT ''::text,
        des_observaciones text NOT NULL DEFAULT ''::text,
        fec_registro timestamp without time zone DEFAULT now(),
        idu_empleado_registro integer NOT NULL,
        opc_movimiento_traspaso smallint DEFAULT 0,
        idu_empleado_traspaso integer DEFAULT 0,
        fec_movimiento_traspaso timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
		nom_xml_recibo varchar(60) not null default(''),
        nom_pdf_carta varchar(60) not null default(''),
        xml_factura text,
        idfactura SERIAL
    );
	
-- Índices
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_empresa ON mov_facturas_colegiaturas (idu_empresa);
	CREATE INDEX idx_mov_facturas_colegiaturas_fol_fiscal ON mov_facturas_colegiaturas (fol_fiscal);
	CREATE INDEX idx_mov_facturas_colegiaturas_fol_factura ON mov_facturas_colegiaturas (fol_factura);
	CREATE INDEX idx_mov_facturas_colegiaturas_serie ON mov_facturas_colegiaturas (serie);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_empleado ON mov_facturas_colegiaturas (idu_empleado);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_centro ON mov_facturas_colegiaturas (idu_centro);
	CREATE INDEX idx_mov_facturas_colegiaturas_opc_pdf ON mov_facturas_colegiaturas (opc_pdf);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_tipo_documento ON mov_facturas_colegiaturas (idu_tipo_documento);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_escuela ON mov_facturas_colegiaturas (idu_escuela);
	CREATE INDEX idx_mov_facturas_colegiaturas_rfc_clave ON mov_facturas_colegiaturas (rfc_clave);
	CREATE INDEX idx_mov_facturas_colegiaturas_importe_factura ON mov_facturas_colegiaturas (importe_factura);
	CREATE INDEX idx_mov_facturas_colegiaturas_importe_calculado ON mov_facturas_colegiaturas (importe_calculado);
	CREATE INDEX idx_mov_facturas_colegiaturas_importe_pagado ON mov_facturas_colegiaturas (importe_pagado);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_estatus ON mov_facturas_colegiaturas (idu_estatus);
	CREATE INDEX idx_mov_facturas_colegiaturas_emp_marco_estatus ON mov_facturas_colegiaturas (emp_marco_estatus);
	CREATE INDEX idx_mov_facturas_colegiaturas_fec_marco_estatus ON mov_facturas_colegiaturas (fec_marco_estatus);
	CREATE INDEX idx_mov_facturas_colegiaturas_fec_registro ON mov_facturas_colegiaturas (fec_registro);
	CREATE INDEX idx_mov_facturas_colegiaturas_idu_empleado_registro ON mov_facturas_colegiaturas (idu_empleado_registro);
	CREATE INDEX idx_mov_facturas_colegiaturas_idfactura ON mov_facturas_colegiaturas (idfactura);

-- Documentación
    comment on table mov_facturas_colegiaturas is 'Tabla de facturas registradas para el sistema de Colegiaturas';
    
    comment on column mov_facturas_colegiaturas.idu_empresa is 'ID de la empresa a la que pertenece el colaborador'; 
    comment on column mov_facturas_colegiaturas.fol_fiscal is 'Folio fiscal de la factura (XML / Complemento / Timbre Fiscal / UUID';
    comment on column mov_facturas_colegiaturas.fol_factura is 'Campo Folio del XML / Comprobante / Folio'; 
    comment on column mov_facturas_colegiaturas.serie is 'Campo Serie del XML / Comprobante / Serie'; 
    comment on column mov_facturas_colegiaturas.fec_factura is 'XML / Comprobante / Fecha'; 
    comment on column mov_facturas_colegiaturas.des_metodo_pago IS 'XML / Comprobante / MetodoPago';
    comment on column mov_facturas_colegiaturas.fol_relacionado IS 'XML / Complemento / Pagos / DoctoRelacionado';
    comment on column mov_facturas_colegiaturas.idu_motivo_revision IS 'ID del motivo de revisión (cat_motivos_colegiaturas.idu_motivo donde idu_tipo_motivo = 4 - Motivos de revisión)';
    comment on column mov_facturas_colegiaturas.idu_empleado is 'ID del Colaborador al que pertenece la factura'; 
    comment on column mov_facturas_colegiaturas.idu_centro is 'ID del centro del colaborador';
    comment on column mov_facturas_colegiaturas.opc_pdf is 'Indica si al subir la factura se incluyó el PDF'; 
    comment on column mov_facturas_colegiaturas.idu_escuela is 'ID de la Escuela (cat_escuelas_colegiaturas.idu_escuela)'; 
    comment on column mov_facturas_colegiaturas.rfc_clave is 'RFC de la Escuela (cat_escuelas_colegiaturas.rfc_clave_sep)'; 
    comment on column mov_facturas_colegiaturas.importe_factura is 'Importe de la factura (XML / Comprobante / Total)'; 
    comment on column mov_facturas_colegiaturas.importe_calculado is 'Importe de la factura menos el descuento'; 
    comment on column mov_facturas_colegiaturas.importe_pagado is 'Importe que se pagó realmente'; 
    comment on column mov_facturas_colegiaturas.idu_tipo_documento is 'ID de tipo de documento (cat_tipo_documento)'; 
    comment on column mov_facturas_colegiaturas.idu_tipo_deduccion is 'ID de tipo de deducción (cat_tipos_deduccion)'; 
    comment on column mov_facturas_colegiaturas.idu_estatus is 'ID del estatus de la factura'; 
    comment on column mov_facturas_colegiaturas.opc_modifico_pago is 'Indica si Personal Administración modificó manualmente el pago (opción Aceptar/Rechazar Factura)'; 
    comment on column mov_facturas_colegiaturas.idu_motivo_rechazo is 'ID del motivo de rechazo (cat_motivos_colegiaturas.idu_motivo donde idu_tipo_motivo = 1 - Rechazo )'; 
    comment on column mov_facturas_colegiaturas.emp_marco_estatus is 'ID del empleado que grabó el estatus'; 
    comment on column mov_facturas_colegiaturas.fec_marco_estatus is 'Fecha en que se modificó el estatus de la factura'; 
    comment on column mov_facturas_colegiaturas.des_comentario_especial is 'Comentario especial'; 
    comment on column mov_facturas_colegiaturas.des_aclaracion_costos is 'Aclaración de costos'; 
    comment on column mov_facturas_colegiaturas.des_observaciones is 'Observaciones generales'; 
    comment on column mov_facturas_colegiaturas.fec_registro is 'Fecha de captura'; 
    comment on column mov_facturas_colegiaturas.idu_empleado_registro is 'Usuario que captura'; 
    comment on column mov_facturas_colegiaturas.opc_movimiento_traspaso is 'Indica si la factura fue traspasada (Procesos especiales / Traspaso de movimientos)'; 
    comment on column mov_facturas_colegiaturas.idu_empleado_traspaso is 'ID del usuario que hizo el traspaso'; 
    comment on column mov_facturas_colegiaturas.fec_movimiento_traspaso is 'Fecha en que se realizó el traspaso de esta factura'; 
    comment on column mov_facturas_colegiaturas.xml_factura is 'XML de la factura'; 
    comment on column mov_facturas_colegiaturas.idfactura is 'Identificador único del registro (SERIAL o keyx)'; 
