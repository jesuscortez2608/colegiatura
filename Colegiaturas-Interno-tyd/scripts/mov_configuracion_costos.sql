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
-- mov_configuracion_costos.sql
-- CREATE TABLE will create implicit sequence "mov_configuracion_costos_keyx_seq" for serial column "mov_configuracion_costos.keyx"
-- Definición
	DROP TABLE IF EXISTS mov_configuracion_costos;
	
	CREATE TABLE mov_configuracion_costos (idu_costo SERIAL
		, idu_empleado INTEGER NOT NULL DEFAULT(0)
		, beneficiario_hoja_azul INTEGER NOT NULL DEFAULT(0)
		, idu_beneficiario INTEGER NOT NULL DEFAULT(0)
		, idu_parentesco INTEGER NOT NULL DEFAULT(0)
		, idu_escuela INTEGER NOT NULL DEFAULT(0)
		, idu_escolaridad INTEGER NOT NULL DEFAULT(0)
		, idu_grado_escolar INTEGER NOT NULL DEFAULT(0)
		, idu_ciclo_escolar INTEGER NOT NULL DEFAULT(0)
		, imp_inscripcion NUMERIC(12,2) NOT NULL DEFAULT (0.00)
		, imp_colegiatura NUMERIC(12,2) NOT NULL DEFAULT (0.00)
		, estatus_configuracion INTEGER NOT NULL DEFAULT(0)
		, idu_marco_estatus INTEGER NOT NULL
		, fec_marco_estatus TIMESTAMP WITHOUT TIME ZONE
		, nom_archivo_alfresco varchar(60) not null default('')
	);
	 
-- Índices
	CREATE INDEX idx_mov_configuracion_costos_idu_costo ON mov_configuracion_costos (idu_costo);
	CREATE INDEX idx_mov_configuracion_costos_idu_empleado ON mov_configuracion_costos (idu_empleado);
	CREATE INDEX idx_mov_configuracion_costos_beneficiario_hoja_azul ON mov_configuracion_costos (beneficiario_hoja_azul);
	CREATE INDEX idx_mov_configuracion_costos_idu_beneficiario ON mov_configuracion_costos (idu_beneficiario);
	CREATE INDEX idx_mov_configuracion_costos_idu_parentesco ON mov_configuracion_costos (idu_parentesco);
	CREATE INDEX idx_mov_configuracion_costos_idu_escuela ON mov_configuracion_costos (idu_escuela);
	CREATE INDEX idx_mov_configuracion_costos_idu_escolaridad ON mov_configuracion_costos (idu_escolaridad);
	CREATE INDEX idx_mov_configuracion_costos_idu_grado_escolar ON mov_configuracion_costos (idu_grado_escolar);
	CREATE INDEX idx_mov_configuracion_costos_estatus_configuracion ON mov_configuracion_costos (estatus_configuracion);
	CREATE INDEX idx_mov_configuracion_costos_idu_marco_estatus ON mov_configuracion_costos (idu_marco_estatus);
	CREATE INDEX idx_mov_configuracion_costos_fec_marco_estatus ON mov_configuracion_costos (fec_marco_estatus);
	