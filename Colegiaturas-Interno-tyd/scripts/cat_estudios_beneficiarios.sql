/*
	No. petición APS               : 16559
	Fecha                          : 07/06/2018
	Número empleado                : 94827443
	Nombre del empleado            : Omar Lizárraga
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.114.75
	Servidor de produccion         : 10.44.2.183
		
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_estudios_beneficiarios;
CREATE TABLE cat_estudios_beneficiarios
(
  idu_configuracion serial, 
  idu_empleado integer NOT NULL DEFAULT 0,
  idu_beneficiario integer NOT NULL DEFAULT 0,
  idu_escuela integer NOT NULL DEFAULT 0,
  idu_escolaridad integer NOT NULL DEFAULT 0,
  idu_carrera integer NOT NULL DEFAULT 0,
  idu_ciclo_escolar integer NOT NULL DEFAULT 0,
  idu_grado_escolar integer NOT NULL DEFAULT 0,
  opc_tipo_beneficiario integer NOT NULL DEFAULT 0,
  fec_registro timestamp without time zone NOT NULL,
  idu_empleado_registro integer NOT NULL
);

--Indices
CREATE INDEX idx_cat_estudios_beneficiarios_idu_beneficiario ON cat_estudios_beneficiarios (idu_beneficiario);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_carrera ON cat_estudios_beneficiarios (idu_carrera);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_ciclo_escolar ON cat_estudios_beneficiarios (idu_ciclo_escolar);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_empleado ON cat_estudios_beneficiarios (idu_empleado);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_escolaridad ON cat_estudios_beneficiarios (idu_escolaridad);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_escuela ON cat_estudios_beneficiarios (idu_escuela);
CREATE INDEX idx_cat_estudios_beneficiarios_idu_grado_escolar ON cat_estudios_beneficiarios (idu_grado_escolar);
CREATE INDEX idx_cat_estudios_beneficiarios_opc_tipo_beneficiario ON cat_estudios_beneficiarios (opc_tipo_beneficiario);
