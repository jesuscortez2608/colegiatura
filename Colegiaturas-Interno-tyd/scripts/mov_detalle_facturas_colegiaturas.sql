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
-- mov_detalle_facturas_colegiaturas.sql
-- Definición

	DROP TABLE IF EXISTS mov_detalle_facturas_colegiaturas;
	
	CREATE TABLE mov_detalle_facturas_colegiaturas (idu_empleado INTEGER NOT NULL
		, fol_fiscal VARCHAR(100) NOT NULL DEFAULT ('')
		, idu_beneficiario INTEGER NOT NULL
		, beneficiario_hoja_azul INTEGER NOT NULL DEFAULT (0)
		, idu_parentesco INTEGER NOT NULL
		, idu_tipopago INTEGER NOT NULL
		, prc_descuento INTEGER NOT NULL
		, periodo VARCHAR(150) NOT NULL DEFAULT('')
		, idu_escuela INTEGER NOT NULL
		, idu_escolaridad INTEGER NOT NULL
		, idu_carrera integer not null default(0)
		, idu_grado_escolar INTEGER NOT NULL
		, idu_ciclo_escolar INTEGER NOT NULL
		, importe_concepto NUMERIC(12,2) not null DEFAULT(0)
		, importe_pagado NUMERIC(12,2) not null DEFAULT(0)
		, fec_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
		, idu_empleado_registro INTEGER NOT NULL
		, idfactura INT NOT NULL
		, keyx SERIAL);
	
	-- 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52
	-- enero,febrero,marzo,abril,mayo,junio,julio,agosto,septiembre,octubre,noviembre,diciembre
    
-- Índices 
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_empleado ON mov_detalle_facturas_colegiaturas (idu_empleado);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_fol_fiscal ON mov_detalle_facturas_colegiaturas (fol_fiscal);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_beneficiario ON mov_detalle_facturas_colegiaturas (idu_beneficiario);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_parentesco ON mov_detalle_facturas_colegiaturas (idu_parentesco);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_tipopago ON mov_detalle_facturas_colegiaturas (idu_tipopago);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_periodo ON mov_detalle_facturas_colegiaturas (periodo);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_escuela ON mov_detalle_facturas_colegiaturas (idu_escuela);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_escolaridad ON mov_detalle_facturas_colegiaturas (idu_escolaridad);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_grado_escolar ON mov_detalle_facturas_colegiaturas (idu_grado_escolar);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_ciclo_escolar ON mov_detalle_facturas_colegiaturas (idu_ciclo_escolar);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_importe_concepto ON mov_detalle_facturas_colegiaturas (importe_concepto);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_fec_registro ON mov_detalle_facturas_colegiaturas (fec_registro);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idu_empleado_registro ON mov_detalle_facturas_colegiaturas (idu_empleado_registro);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_idfactura ON mov_detalle_facturas_colegiaturas (idfactura);
	CREATE INDEX idx_mov_detalle_facturas_colegiaturas_keyx ON mov_detalle_facturas_colegiaturas (keyx);
	