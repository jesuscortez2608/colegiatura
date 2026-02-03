/*
	No. petición APS               : 8613
	Fecha                          : 10/01/2017
	Autor                          : Raul Ahumada, para generación de archivos de pagos de colegiaturas
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Sistema                        : Colegiaturas
	Módulo                         : Generar archivos para banco
	Descripción                    : Tabla que contiene los datos de número de cuenta, 
	                                 número de sucursal del banco origen para el archivo 
	                                 que se envía al SAT.
------------------------------------------------------------------------------------------------------ */
drop table if exists cat_datos_bancos;
CREATE TABLE cat_datos_bancos
(
  clv_banco_origen character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica al banco de la cuenta bancaria origen.
  clv_cuenta_origen character varying(50) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la cuenta bancaria origen.
  clv_sucursal_origen character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la sucursal origen.
  clv_salida integer NOT NULL DEFAULT 0, -- Número que identifica que tipo de salida de dinero.
  num_empleado_capturo integer NOT NULL DEFAULT 0, -- Número de empleado que capturó el registro en el catálogo.
  fec_capturo date NOT NULL DEFAULT now() -- Fecha de en que se dio de alta en el catálogo.
);
COMMENT ON TABLE cat_datos_bancos
  IS 'Tabla que contiene los datos de número de cuenta, número de sucursal del banco origen para el archivo que se envía al SAT.';
COMMENT ON COLUMN cat_datos_bancos.clv_banco_origen IS 'Número que identifica al banco de la cuenta bancaria origen.';
COMMENT ON COLUMN cat_datos_bancos.clv_cuenta_origen IS 'Número que identifica a la cuenta bancaria origen.';
COMMENT ON COLUMN cat_datos_bancos.clv_sucursal_origen IS 'Número que identifica a la sucursal origen.';
COMMENT ON COLUMN cat_datos_bancos.clv_salida IS 'Número que identifica que tipo de salida de dinero.';
COMMENT ON COLUMN cat_datos_bancos.num_empleado_capturo IS 'Número de empleado que capturó el registro en el catálogo.';
COMMENT ON COLUMN cat_datos_bancos.fec_capturo IS 'Fecha de en que se dio de alta en el catálogo.';

insert into cat_datos_bancos (clv_banco_origen, clv_cuenta_origen, clv_sucursal_origen, clv_salida, num_empleado_capturo, fec_capturo) values (2,'00000000000001669136','0441',1,92100491,'2015-01-02');
insert into cat_datos_bancos (clv_banco_origen, clv_cuenta_origen, clv_sucursal_origen, clv_salida, num_empleado_capturo, fec_capturo) VALUES (4,'00000000065500421641','0442',1,92100491,'2015-01-02');
insert into cat_datos_bancos (clv_banco_origen, clv_cuenta_origen, clv_sucursal_origen, clv_salida, num_empleado_capturo, fec_capturo) VALUES (5,'00000000001458587027','0443',1,92100491,'2015-01-02');
insert into cat_datos_bancos (clv_banco_origen, clv_cuenta_origen, clv_sucursal_origen, clv_salida, num_empleado_capturo, fec_capturo) VALUES (6,'00000000016000000012','0444',1,92100491,'2015-01-02');
insert into cat_datos_bancos (clv_banco_origen, clv_cuenta_origen, clv_sucursal_origen, clv_salida, num_empleado_capturo, fec_capturo) VALUES (2,'00000000000001669136','0441',2,92100491,'2015-01-02');