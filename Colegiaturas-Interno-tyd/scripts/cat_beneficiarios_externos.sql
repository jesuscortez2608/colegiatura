/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 98439677
	Nombre del empleado            : Rafael Ramos Gutierrez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 
	Servidor de produccion         : 
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : Colegiaturas
	Módulo                         : Administración de empleados externos
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		
------------------------------------------------------------------------------------------------------ */
-- Definición
	DROP TABLE IF EXISTS cat_beneficiarios_externos;
	
	CREATE TABLE cat_beneficiarios_externos (
        idu_beneficiario SERIAL,
		idu_empleado integer NOT NULL,
		nom_empleado VARCHAR(150) NOT NULL DEFAULT(''),
		prc_descuento INTEGER NOT NULL DEFAULT(50),
		opc_beneficiario_bloqueado SMALLINT NOT NULL DEFAULT(0),
		fec_registro timestamp without time zone DEFAULT now(),
		idu_empleado_registro integer NOT NULL
	);
	
-- Índices
CREATE INDEX idx_cat_beneficiarios_externos_idu_beneficiario ON cat_beneficiarios_externos(idu_beneficiario);
CREATE INDEX idx_cat_beneficiarios_externos_idu_empleado ON cat_beneficiarios_externos(idu_empleado);
CREATE INDEX idx_cat_beneficiarios_externos_fec_registro ON cat_beneficiarios_externos(fec_registro);
CREATE INDEX idx_cat_beneficiarios_externos_idu_empleado_registro ON cat_beneficiarios_externos(idu_empleado_registro);