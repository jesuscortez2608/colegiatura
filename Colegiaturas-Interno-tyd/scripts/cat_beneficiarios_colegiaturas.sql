/*
	No. petición APS               : 8613.1
	Fecha                          : 13/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS cat_beneficiarios_colegiaturas;
CREATE TABLE cat_beneficiarios_colegiaturas
(
	idu_empleado INTEGER NOT NULL DEFAULT 0,
	idu_beneficiario INTEGER NOT NULL DEFAULT 0,
	nom_beneficiario VARCHAR (50) NOT NULL DEFAULT '',
	ape_paterno VARCHAR (50) NOT NULL DEFAULT '',
	ape_materno VARCHAR (50) NOT NULL DEFAULT '',
	idu_parentesco INTEGER NOT NULL DEFAULT 0,
	opc_becado_especial  INTEGER NOT NULL DEFAULT 0,
	des_observaciones VARCHAR (300) NOT NULL DEFAULT '',
	fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL ,
	idu_empleado_registro INTEGER NOT NULL
);

-- Índices
CREATE INDEX idx_cat_beneficiarios_colegiaturas_idu_empleado ON cat_beneficiarios_colegiaturas (idu_empleado);
CREATE INDEX idx_cat_beneficiarios_colegiaturas_idu_beneficiario ON cat_beneficiarios_colegiaturas (idu_beneficiario);
CREATE INDEX idx_cat_beneficiarios_colegiaturas_idu_parentesco ON cat_beneficiarios_colegiaturas (idu_parentesco);

-- Documentación
comment on table cat_beneficiarios_colegiaturas is 'Catálogo de beneficiarios de Colegiaturas';

comment on column cat_beneficiarios_colegiaturas.idu_empleado is 'ID del colaborador al que pertenece el beneficiario'; 
comment on column cat_beneficiarios_colegiaturas.idu_beneficiario is 'ID del beneficiario, un consecutivo de beneficiario por colaborador'; 
comment on column cat_beneficiarios_colegiaturas.nom_beneficiario is 'Nombre del beneficiario'; 
comment on column cat_beneficiarios_colegiaturas.ape_paterno is 'Apellido paterno'; 
comment on column cat_beneficiarios_colegiaturas.ape_materno is 'Apellido materno'; 
comment on column cat_beneficiarios_colegiaturas.idu_parentesco is 'Parentesco con el colaborador, cat_parentescos.idu_parentesco'; 
comment on column cat_beneficiarios_colegiaturas.opc_becado_especial is 'Indica si fue marcado como beneficiario especial'; 
comment on column cat_beneficiarios_colegiaturas.des_observaciones is 'Observaciones generales para el beneficiario'; 
comment on column cat_beneficiarios_colegiaturas.fec_registro is 'Fecha de captura'; 
comment on column cat_beneficiarios_colegiaturas.idu_empleado_registro is 'Usuario que lo capturó'; 
