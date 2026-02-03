
/*
	No. petición APS               : 8613.1
	Fecha                          : 13/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_empleados_colegiaturas;
CREATE TABLE cat_empleados_colegiaturas
(
	idu_empleado INTEGER NOT NULL DEFAULT 0,
	opc_limitado INTEGER NOT NULL DEFAULT 0,
	opc_especial INTEGER NOT NULL DEFAULT 0,
	idu_rutapago integer not null default 0,
	opc_empleado_bloqueado INTEGER NOT NULL DEFAULT 0,
	opc_validar_costos SMALLINT NOT NULL DEFAULT 1,
	fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT('1900-01-01') ,
	idu_empleado_registro INTEGER NOT NULL
);

-- Índices
CREATE INDEX idx_cat_empleados_colegiaturas_id_empleado ON cat_empleados_colegiaturas (idu_empleado);
CREATE INDEX idx_cat_empleados_colegiaturas_opc_limitado ON cat_empleados_colegiaturas (opc_limitado);
CREATE INDEX idx_cat_empleados_colegiaturas_opc_especial ON cat_empleados_colegiaturas (opc_especial);
CREATE INDEX idx_cat_empleados_colegiaturas_idu_ruta_pago ON cat_empleados_colegiaturas (idu_rutapago);
CREATE INDEX idx_cat_empleados_colegiaturas_opc_empleado_bloqueado ON cat_empleados_colegiaturas (opc_empleado_bloqueado);
CREATE INDEX idx_cat_empleados_colegiaturas_fec_registro ON cat_empleados_colegiaturas (fec_registro);
CREATE INDEX idx_cat_empleados_colegiaturas_idu_empleado_registro ON cat_empleados_colegiaturas (idu_empleado_registro);


-- alter table cat_empleados_colegiaturas add opc_validar_costos SMALLINT NOT NULL DEFAULT 1
-- update cat_empleados_colegiaturas set opc_validar_costos = 0 
-- from sapcatalogoempleados
-- where sapcatalogoempleados.numempn = cat_empleados_colegiaturas.idu_empleado
--    and pueston in (32, 159);
