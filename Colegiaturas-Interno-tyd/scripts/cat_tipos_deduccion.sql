
-- Definición
	DROP TABLE IF EXISTS cat_tipos_deduccion;
	
	CREATE TABLE cat_tipos_deduccion (idu_tipo INTEGER NOT NULL
		, nom_deduccion VARCHAR(30) NOT NULL
		, fec_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
		, idu_empleado_registro INT NOT NULL);
	
-- Datos
	INSERT INTO cat_tipos_deduccion(idu_tipo, nom_deduccion, fec_registro, idu_empleado_registro) VALUES (1, 'DEDUCIBLE', NOW(), 95194185);
	INSERT INTO cat_tipos_deduccion(idu_tipo, nom_deduccion, fec_registro, idu_empleado_registro) VALUES (2, 'NO DEDUCIBLE', NOW(), 95194185);
	INSERT INTO cat_tipos_deduccion(idu_tipo, nom_deduccion, fec_registro, idu_empleado_registro) VALUES (3, 'DEDUCIBLE CON IVA', NOW(), 95194185);
-- Índices
	CREATE INDEX idx_cat_tipos_deduccion_idu_tipo ON cat_tipos_deduccion (idu_tipo);
	CREATE INDEX idx_cat_tipos_deduccion_nom_deduccion ON cat_tipos_deduccion (nom_deduccion);
	CREATE INDEX idx_cat_tipos_deduccion_fec_registro ON cat_tipos_deduccion (fec_registro);
	CREATE INDEX idx_cat_tipos_deduccion_idu_empleado_registro ON cat_tipos_deduccion (idu_empleado_registro);
	