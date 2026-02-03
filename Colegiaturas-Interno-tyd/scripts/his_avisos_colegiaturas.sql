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
	DROP TABLE IF EXISTS his_avisos_colegiaturas;

	CREATE TABLE his_avisos_colegiaturas
	(
		idu_aviso integer NOT NULL DEFAULT 0,
		des_aviso character varying(200) NOT NULL,
		idu_opcion integer NOT NULL DEFAULT 0,
		opc_indefinido integer NOT NULL DEFAULT 0,
		opc_tipo_movimiento character varying(1) NOT NULL DEFAULT ''::character varying,
		fec_inicial timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
		fec_final timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
		fec_registro timestamp without time zone DEFAULT now(),
		idu_empleado_registro integer NOT NULL
	);
-- Indices
CREATE INDEX idx_his_avisos_colegiaturas_fec_final ON his_avisos_colegiaturas (fec_final);
CREATE INDEX idx_his_avisos_colegiaturas_fec_inicial ON his_avisos_colegiaturas (fec_inicial);
CREATE INDEX idx_his_avisos_colegiaturas_fec_registro ON his_avisos_colegiaturas(fec_registro);
CREATE INDEX idx_his_avisos_colegiaturas_idu_empleado_registro ON his_avisos_colegiaturas(idu_empleado_registro);
CREATE INDEX idx_his_avisos_colegiaturas_idu_opcion ON his_avisos_colegiaturas(idu_opcion);
CREATE INDEX idx_his_avisos_colegiaturas_opc_indefinido ON his_avisos_colegiaturas(opc_indefinido);

