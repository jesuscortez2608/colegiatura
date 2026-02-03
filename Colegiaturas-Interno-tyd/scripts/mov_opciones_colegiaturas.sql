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
	DROP TABLE IF EXISTS mov_opciones_colegiaturas;
	
	CREATE TABLE mov_opciones_colegiaturas
	(
		idu_opcion integer NOT NULL,
		nom_opcion character varying(50) NOT NULL,
		fec_registro timestamp without time zone DEFAULT now(),
		idu_empleado_registro integer NOT NULL
	);
-- Datos
INSERT INTO mov_opciones_colegiaturas(idu_opcion, nom_opcion, fec_registro, idu_empleado_registro) VALUES (1, 'Subir facturas de escuela privada', NOW(), 95194185);
INSERT INTO mov_opciones_colegiaturas(idu_opcion, nom_opcion, fec_registro, idu_empleado_registro) VALUES (2, 'Seguimiento de facturas por colaborador', NOW(), 95194185);
INSERT INTO mov_opciones_colegiaturas(idu_opcion, nom_opcion, fec_registro, idu_empleado_registro) VALUES (3, 'Autorizar facturas por gerente', NOW(), 95194185);
	
-- Índices	
CREATE INDEX idx_mov_opciones_colegiaturas_fec_registro ON mov_opciones_colegiaturas(fec_registro);
CREATE INDEX idx_mov_opciones_colegiaturas_idu_empleado_registro ON mov_opciones_colegiaturas(idu_empleado_registro);
CREATE INDEX idx_mov_opciones_colegiaturas_idu_opcion ON mov_opciones_colegiaturas(idu_opcion);
CREATE INDEX idx_mov_opciones_colegiaturas_nom_opcion ON mov_opciones_colegiaturas(nom_opcion);

