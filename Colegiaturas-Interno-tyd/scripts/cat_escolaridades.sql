/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		
------------------------------------------------------------------------------------------------------ */

-- Definición
	DROP TABLE IF EXISTS cat_escolaridades;
	 
	CREATE TABLE cat_escolaridades (idu_escolaridad SERIAL
		, nom_escolaridad VARCHAR(30) NOT NULL
		, opc_carrera INTEGER NOT NULL DEFAULT (0)
		, fec_captura TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
		, idu_empleado_registro INT NOT NULL);
	
-- Datos
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('GUARDERIA MATERNAL', 	0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('KINDER', 			    0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('PRIMARIA', 		    0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('SECUNDARIA', 		    0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('PREPARATORIA', 	    0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('PROFESIONAL', 		    1, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('MAESTRÍA', 		    1, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('INGLÉS', 			    0, NOW(), 95194185);
	INSERT INTO cat_escolaridades(nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) VALUES ('OTRO IDIOMA', 		    0, NOW(), 95194185);

-- Índices
	CREATE INDEX idx_cat_escolaridades_idu_escolaridad ON cat_escolaridades (idu_escolaridad);
	CREATE INDEX idx_cat_escolaridades_nom_escolaridad ON cat_escolaridades (nom_escolaridad);
	CREATE INDEX idx_cat_escolaridades_opc_carrera ON cat_escolaridades (opc_carrera);
CREATE INDEX idx_cat_escolaridades_fec_captura ON cat_escolaridades (fec_captura);
CREATE INDEX idx_cat_escolaridades_idu_empleado_registro ON cat_escolaridades (idu_empleado_registro);

