DROP FUNCTION IF EXISTS fun_obtener_facturas_por_estatus(integer);
DROP TYPE IF EXISTS type_obtener_facturas_por_estatus;

CREATE TYPE type_obtener_facturas_por_estatus AS (idu_estatus INTEGER
	, nom_estatus VARCHAR(30)
	, fec_marco_estatus TIMESTAMP WITHOUT TIME ZONE
	, emp_marco_estatus INTEGER
	, nom_marco_estatus VARCHAR(150)
	, idu_empleado INTEGER
	, nom_empleado VARCHAR(150)
	, fol_fiscal VARCHAR(100)
	, idu_rutapago INTEGER
	, nom_rutapago VARCHAR(30)
	, opc_cheque INTEGER
	, rfc_clave_sep VARCHAR(20)
	, nom_escuela VARCHAR(100)
	, importe_factura NUMERIC(12,2)
	, importe_calculado NUMERIC(12,2)
	, importe_pagado NUMERIC(12,2)
	, des_observaciones TEXT
);

CREATE OR REPLACE FUNCTION fun_obtener_facturas_por_estatus(integer)
RETURNS SETOF type_obtener_facturas_por_estatus AS
$function$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 04/11/2016
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : Colegiaturas
	Módulo                         : Seguimiento de facturas por gerente
	Ejemplo                        : 
		
	------------------------------------------------------------------------------------------------------ */
	iParam alias for $1;
	returnrec type_obtener_facturas_por_estatus;
BEGIN
	FOR returnrec IN (
		
		) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$function$
LANGUAGE plpgsql VOLATILE;