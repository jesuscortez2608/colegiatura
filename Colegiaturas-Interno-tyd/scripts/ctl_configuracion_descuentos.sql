
/*
	No. petición APS               : 8613.1
	Fecha                          : 21/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		 
------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS ctl_configuracion_descuentos;
CREATE TABLE ctl_configuracion_descuentos(

	idu_empleado integer,
	idu_centro integer,
	idu_puesto integer,
	idu_seccion integer,
	idu_escolaridad integer, 
	idu_parentesco integer,
	por_porcentaje integer,
	des_comentario varchar (300) not null default '',
	fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	idu_empleado_registro INTEGER NOT NULL
);
CREATE INDEX idx_ctl_configuracion_descuentos_idu_empleado ON ctl_configuracion_descuentos (idu_empleado);
CREATE INDEX idx_ctl_configuracion_descuentos_idu_puesto ON ctl_configuracion_descuentos (idu_puesto);
CREATE INDEX idx_ctl_configuracion_descuentos_idu_centro ON ctl_configuracion_descuentos (idu_centro);


 