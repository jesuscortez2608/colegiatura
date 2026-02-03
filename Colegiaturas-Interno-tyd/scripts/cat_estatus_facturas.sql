
-- Definición
	DROP TABLE IF EXISTS cat_estatus_facturas;
	
	CREATE TABLE cat_estatus_facturas (idu_estatus INTEGER NOT NULL
		, nom_estatus VARCHAR(30) NOT NULL
		, fec_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
		, idu_empleado_registro INT NOT NULL
		, idu_tipo_estatus INTEGER NOT NULL);
	
-- Datos
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (0, 'PENDIENTE', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (1, 'EN PROCESO', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (2, 'ACEPTADA (POR PAGAR)', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (3, 'RECHAZADA', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (4, 'EN ACLARACION', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (5, 'EN REVISION', NOW(), 95194185, 0);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (6, 'PAGADA', NOW(), 95194185, 0);

	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (8, 'PROCESO', NOW(), 95194185, 1);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (9, 'AUTORIZADAS PARA PAGO', NOW(), 95194185, 1);
	INSERT INTO cat_estatus_facturas(idu_estatus, nom_estatus, fec_registro, idu_empleado_registro, idu_tipo_estatus) VALUES (10, 'PAGADO', NOW(), 95194185, 1);
	
-- Índices
	CREATE INDEX idx_cat_estatus_facturas_idu_estatus ON cat_estatus_facturas (idu_estatus);
	CREATE INDEX idx_cat_estatus_facturas_nom_estatus ON cat_estatus_facturas (nom_estatus);
	CREATE INDEX idx_cat_estatus_facturas_fec_registro ON cat_estatus_facturas (fec_registro);
	CREATE INDEX idx_cat_estatus_facturas_idu_empleado_registro ON cat_estatus_facturas (idu_empleado_registro);
	