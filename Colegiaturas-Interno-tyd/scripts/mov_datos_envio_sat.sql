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
	Descripción                    : Tabla para almacenar los registros de pagos
------------------------------------------------------------------------------------------------------ */

drop table if exists mov_datos_envio_sat;
CREATE TABLE mov_datos_envio_sat (clv_cuenta_origen character varying(50) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la cuenta bancaria origen.
    clv_banco_origen character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica al banco de la cuenta bancaria origen.
    clv_sucursal_origen character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la sucursal origen.
    imp_monto character varying(20) NOT NULL DEFAULT ''::character varying, -- Importe de la factura del empleado.
    clv_cuenta_destino character varying(50) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la cuenta bancaria destino.
    clv_banco_destino character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica al banco de la cuenta bancaria destino.
    clv_sucursal_destino character varying(10) NOT NULL DEFAULT ''::character varying, -- Número que identifica a la sucursal destino.
    fec_transferencia character varying(10) NOT NULL DEFAULT ''::character varying, -- Fecha en que se realizó la transferencia.
    num_empleado character varying(10) NOT NULL DEFAULT ''::character varying, -- Número de empleado al que corresponde la factura.
    nom_empleado character varying(150) NOT NULL DEFAULT ''::character varying, -- Nombre de empleado al que corresponde la factura.
    clv_rfc_empleado character varying(13) NOT NULL DEFAULT ''::character varying, -- Clave del RFC del empleado al que corresponde la factura.
    clv_salida integer NOT NULL DEFAULT 0, -- Número que identifica que tipo de salida es el dinero que se esta mandando depositar al destino
    num_empleado_capturo integer NOT NULL DEFAULT 0, -- Número de empleado que capturó el registro en el catálogo.
    fec_capturo date NOT NULL DEFAULT now() -- Fecha de en que se dio de alta en el catálogo.
);

CREATE INDEX idx_mov_datos_envio_sat_clv_cuenta_origen ON mov_datos_envio_sat (clv_cuenta_origen);
CREATE INDEX idx_mov_datos_envio_sat_clv_banco_origen ON mov_datos_envio_sat (clv_banco_origen);
CREATE INDEX idx_mov_datos_envio_sat_clv_sucursal_origen ON mov_datos_envio_sat (clv_sucursal_origen);
CREATE INDEX idx_mov_datos_envio_sat_clv_cuenta_destino ON mov_datos_envio_sat (clv_cuenta_destino);
CREATE INDEX idx_mov_datos_envio_sat_clv_banco_destino ON mov_datos_envio_sat (clv_banco_destino);
CREATE INDEX idx_mov_datos_envio_sat_clv_sucursal_destino ON mov_datos_envio_sat (clv_sucursal_destino);
CREATE INDEX idx_mov_datos_envio_sat_fec_transferencia ON mov_datos_envio_sat (fec_transferencia);
CREATE INDEX idx_mov_datos_envio_sat_num_empleado ON mov_datos_envio_sat (num_empleado);
CREATE INDEX idx_mov_datos_envio_sat_clv_rfc_empleado ON mov_datos_envio_sat (clv_rfc_empleado);
CREATE INDEX idx_mov_datos_envio_sat_clv_salida ON mov_datos_envio_sat (clv_salida);
CREATE INDEX idx_mov_datos_envio_sat_num_empleado_capturo ON mov_datos_envio_sat (num_empleado_capturo);
CREATE INDEX idx_mov_datos_envio_sat_fec_capturo ON mov_datos_envio_sat (fec_capturo);

