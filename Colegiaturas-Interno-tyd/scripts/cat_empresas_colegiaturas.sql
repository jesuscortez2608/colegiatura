/*
	No. petición APS               : 16559.1
	Fecha                          : 20/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Componente                     : cat_empresas_colegiaturas.sql
    Descripción                    : Empresas que tendrán la prestación de colegiaturas
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_empresas_colegiaturas;
CREATE TABLE cat_empresas_colegiaturas (
    idu_empresa INTEGER, -- sapempresas.clave
    fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT(NOW()),
	idu_empleado_registro INTEGER NOT NULL
);

-- Índices
CREATE INDEX idx_cat_empresas_colegiaturas_idu_empresa ON cat_empresas_colegiaturas (idu_empresa);

-- Datos iniciales
INSERT INTO cat_empresas_colegiaturas(idu_empresa, idu_empleado_registro)
    VALUES (1, 95194185); -- COPPEL, S.A. DE C.V. 

INSERT INTO cat_empresas_colegiaturas(idu_empresa, idu_empleado_registro)
    VALUES (15, 95194185); -- AFORE COPPEL, S.A. DE C.V.

INSERT INTO cat_empresas_colegiaturas(idu_empresa, idu_empleado_registro)
    VALUES (16, 95194185); -- BANCOPPEL, S.A., INSTITUCIÓN DE BANCA MÚLTIPLE

