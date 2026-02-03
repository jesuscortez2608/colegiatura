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
	DROP TABLE IF EXISTS cat_usuarios_externos;
	
	CREATE TABLE cat_usuarios_externos
	(
		idu_empleado integer NOT NULL,
		opc_empleado_bloqueado SMALLINT NOT NULL DEFAULT (0),
		opc_indefinido SMALLINT NOT NULL DEFAULT (0),
		fec_inicial timestamp without time zone DEFAULT ('1900-01-01'),
		fec_final timestamp without time zone DEFAULT ('1900-01-01'),
		fec_registro timestamp without time zone DEFAULT now(),
		idu_empleado_registro integer NOT NULL
	);
	
-- Datos
INSERT INTO cat_usuarios_externos (idu_empleado, opc_indefinido, fec_inicial, fec_final, fec_registro, idu_empleado_registro)
    VALUES (90025628, 1, '1900-01-01'::DATE, '1900-01-01'::DATE, NOW(), 95194185);

-- Índices
CREATE INDEX idx_cat_usuarios_externos_idu_empleado ON cat_usuarios_externos(idu_empleado);
CREATE INDEX idx_cat_usuarios_externos_opc_indefinido ON cat_usuarios_externos(opc_indefinido);
CREATE INDEX idx_cat_usuarios_externos_fec_inicial ON cat_usuarios_externos(fec_inicial);
CREATE INDEX idx_cat_usuarios_externos_fec_final ON cat_usuarios_externos(fec_final);
CREATE INDEX idx_cat_usuarios_externos_fec_registro ON cat_usuarios_externos(fec_registro);
CREATE INDEX idx_cat_usuarios_externos_idu_empleado_registro ON cat_usuarios_externos(idu_empleado_registro);
