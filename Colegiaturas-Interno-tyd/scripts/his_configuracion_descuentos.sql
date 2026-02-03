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
-- his_configuracion_descuentos.sql
-- Definición
	DROP TABLE IF EXISTS his_configuracion_descuentos;
	CREATE TABLE his_configuracion_descuentos (idu_empleado integer,
	  idu_centro integer,
	  idu_puesto integer,
	  idu_seccion integer,
	  idu_escolaridad integer,
	  idu_parentesco integer,
	  por_porcentaje integer,
	  des_comentario character varying(300) NOT NULL DEFAULT ''::character varying,
	  fec_registro timestamp without time zone NOT NULL DEFAULT now(),
	  idu_empleado_registro integer NOT NULL
	);
	 
-- Índices
	CREATE INDEX idx_his_configuracion_descuentos_idu_centro ON his_configuracion_descuentos(idu_centro);
	CREATE INDEX idx_his_configuracion_descuentos_idu_empleado ON his_configuracion_descuentos(idu_empleado);
	CREATE INDEX idx_his_configuracion_descuentos_idu_puesto ON his_configuracion_descuentos(idu_puesto);

