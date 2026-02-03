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
	DROP TABLE IF EXISTS stmp_beneficiarios_externos;
	
	CREATE TABLE stmp_beneficiarios_externos (
		idu_empleado integer NOT NULL,
		idu_beneficiario INTEGER NOT NULL,
		fec_registro timestamp without time zone DEFAULT now(),
		idu_empleado_registro integer NOT NULL
	);
	
-- Índices
CREATE INDEX idx_stmp_beneficiarios_externos_idu_empleado ON stmp_beneficiarios_externos(idu_empleado);
CREATE INDEX idx_stmp_beneficiarios_externos_idu_beneficiario ON stmp_beneficiarios_externos(idu_beneficiario);
CREATE INDEX idx_stmp_beneficiarios_externos_fec_registro ON stmp_beneficiarios_externos(fec_registro);
CREATE INDEX idx_stmp_beneficiarios_externos_idu_empleado_registro ON stmp_beneficiarios_externos(idu_empleado_registro);
