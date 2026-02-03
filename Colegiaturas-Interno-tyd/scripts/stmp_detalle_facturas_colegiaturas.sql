/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : 
	Ejemplo						   :	
------------------------------------------------------------------------------------------------------ */
-- stmp_detalle_facturas_colegiaturas.sql
-- Definición
	DROP TABLE IF EXISTS stmp_detalle_facturas_colegiaturas;
	
	CREATE TABLE stmp_detalle_facturas_colegiaturas (idu_empleado INTEGER NOT NULL
		, fol_fiscal VARCHAR(100)
		, beneficiario_hoja_azul INTEGER NOT NULL DEFAULT (0)
		, idu_beneficiario INTEGER NOT NULL
		, idu_parentesco INTEGER NOT NULL
		, idu_tipopago INTEGER NOT NULL
		, prc_descuento INTEGER NOT NULL
		, periodo VARCHAR(150) NOT NULL DEFAULT('')
		, idu_escuela INTEGER NOT NULL
		, idu_escolaridad INTEGER NOT NULL
		, idu_carrera INTEGER NOT NULL DEFAULT(0)
		, idu_grado_escolar INTEGER NOT NULL
		, idu_ciclo_escolar INTEGER NOT NULL
		, importe_concepto NUMERIC(12,2) default (0)
		, idfactura INTEGER NOT NULL
		, keyx SERIAL);
		
	-- 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52
	-- enero,febrero,marzo,abril,mayo,junio,julio,agosto,septiembre,octubre,noviembre,diciembre
	
-- Índices
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_empleado ON stmp_detalle_facturas_colegiaturas (idu_empleado);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_fol_fiscal ON stmp_detalle_facturas_colegiaturas (fol_fiscal);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_beneficiario ON stmp_detalle_facturas_colegiaturas (idu_beneficiario);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_parentesco ON stmp_detalle_facturas_colegiaturas (idu_parentesco);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_tipopago ON stmp_detalle_facturas_colegiaturas (idu_tipopago);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_periodo ON stmp_detalle_facturas_colegiaturas (periodo);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_escuela ON stmp_detalle_facturas_colegiaturas (idu_escuela);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_escolaridad ON stmp_detalle_facturas_colegiaturas (idu_escolaridad);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_carrera ON stmp_detalle_facturas_colegiaturas (idu_carrera);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_grado_escolar ON stmp_detalle_facturas_colegiaturas (idu_grado_escolar);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idu_ciclo_escolar ON stmp_detalle_facturas_colegiaturas (idu_ciclo_escolar);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_importe_concepto ON stmp_detalle_facturas_colegiaturas (importe_concepto);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_idfactura ON stmp_detalle_facturas_colegiaturas (idfactura);
	CREATE INDEX idx_stmp_detalle_facturas_colegiaturas_keyx ON stmp_detalle_facturas_colegiaturas (keyx);
	