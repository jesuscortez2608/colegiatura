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
-- CREATE TABLE will create implicit sequence "mov_blog_aclaraciones_id_seq" for serial column "mov_blog_aclaraciones.id"
	DROP TABLE IF EXISTS mov_blog_aclaraciones;
	
	CREATE TABLE mov_blog_aclaraciones (id_factura INTEGER
		, idu_empleado_origen INTEGER NOT NULL
		, idu_empleado_destino INTEGER NOT NULL
		, comentario TEXT NOT NULL DEFAULT('')
		, opc_leido SMALLINT NOT NULL DEFAULT(0)
		, fec_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW());
	
-- Índices
	CREATE INDEX idx_mov_blog_aclaraciones_id_factura ON mov_blog_aclaraciones (id_factura);
	CREATE INDEX idx_mov_blog_aclaraciones_idu_empleado_origen ON mov_blog_aclaraciones (idu_empleado_origen);
	CREATE INDEX idx_mov_blog_aclaraciones_idu_empleado_destino ON mov_blog_aclaraciones (idu_empleado_destino);
	CREATE INDEX idx_mov_blog_aclaraciones_opc_leido ON mov_blog_aclaraciones (opc_leido);
	CREATE INDEX idx_mov_blog_aclaraciones_fec_registro ON mov_blog_aclaraciones (fec_registro);