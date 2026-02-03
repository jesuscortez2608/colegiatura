/*
	No. petición APS               : 16995.1 Mejoras al sistema de colegiaturas
	Fecha                          : 12/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Descripción                    : Tabla de control para el proceso de colegiaturas
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS ctl_proceso_colegiaturas;
CREATE TABLE ctl_proceso_colegiaturas (idu_ciclo INTEGER NOT NULL
    , mes INTEGER NOT NULL DEFAULT(0)
    , quincena SMALLINT NOT NULL
    , fec_traspaso TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('1900-01-01')
    , usr_traspaso INTEGER NOT NULL DEFAULT(0)
    , fec_pagos TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('1900-01-01')
    , usr_pagos INTEGER NOT NULL DEFAULT(0)
    , fec_incentivos TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('1900-01-01')
    , usr_incentivos INTEGER NOT NULL DEFAULT(0)
    , fec_cierre TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('1900-01-01')
    , usr_cierre INTEGER NOT NULL DEFAULT(0)
);

CREATE INDEX ix_ctl_proceso_colegiaturas_idu_ciclo ON ctl_proceso_colegiaturas(idu_ciclo);
CREATE INDEX ix_ctl_proceso_colegiaturas_mes ON ctl_proceso_colegiaturas(mes);
CREATE INDEX ix_ctl_proceso_colegiaturas_quincena ON ctl_proceso_colegiaturas(quincena);
