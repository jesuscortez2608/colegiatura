DROP FUNCTION if exists fun_imprimir_rechazos_generacion_pagos();
drop type if exists type_imprimir_rechazos_generacion_pagos;

CREATE TYPE type_imprimir_rechazos_generacion_pagos AS
   (num_empleado integer,
    nombre_empleado character varying(50),
    idfactura integer,
    idu_ajuste integer,
    folio_factura character varying(100),
    importe_factura numeric(12,2),
    importe_pagado numeric(12,2));

CREATE OR REPLACE FUNCTION fun_imprimir_rechazos_generacion_pagos()
  RETURNS SETOF type_imprimir_rechazos_generacion_pagos AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 01/12/2016
	Número empleado                : 97695068
	Nombre del empleado            : Héctor Medina Escareño
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.2.89
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Procesos especiales
	Ejemplo                        : SELECT * FROM fun_imprimir_rechazos_generacion_pagos()
	------------------------------------------------------------------------------------------------------ 
	Peticion				: 16559.1
	Fecha					: 31/05/2018
	Número empleado			: 98439677
	Nombre del empleado		: Rafael Ramos Gutiérrez
	Descripcion del cambio	: Se modificaron campos, se agrego el id del ajuste de la factura

	*/
	returnrec type_imprimir_rechazos_generacion_pagos;
BEGIN
	/* //==========/ TABLAS PARTICIPANTES /==========//
	   select * from mov_generacion_pagos_colegiaturas;
	   select * from mov_facturas_colegiaturas;
	   select * from mov_facturas_rechazadas;
	   select * from sapcatalogoempleados limit(10);
	*/
	
	CREATE LOCAL TEMP TABLE tmp_imprimir_rechazos_generacion_pagos(
		num_empleado integer,
		nombre_empleado character varying(50),
		idfactura integer,
		idu_ajuste INTEGER,
		folio_factura character varying(100),
		importe_factura numeric(12, 2),
		importe_pagado numeric(12, 2)
	)ON COMMIT DROP;

	INSERT INTO tmp_imprimir_rechazos_generacion_pagos(num_empleado, idfactura, idu_ajuste, importe_factura,importe_pagado)
	SELECT idu_empleado, fr.idfactura, fr.idu_ajuste, fr.importe_factura, fr.importe_pagado
	FROM stmp_facturas_rechazadas fr;

	-- Agregar datos de campos de relacion de empleado
	UPDATE tmp_imprimir_rechazos_generacion_pagos
	SET num_empleado = e.numempn,
		nombre_empleado = TRIM(e.nombre)||' '||TRIM(e.apellidopaterno)||' '||TRIM(e.apellidomaterno)
	FROM sapcatalogoempleados e
	WHERE e.numempn = tmp_imprimir_rechazos_generacion_pagos.num_empleado;

	-- Agregar el folio de la factura
	UPDATE tmp_imprimir_rechazos_generacion_pagos
	SET folio_factura = fc.fol_fiscal
	FROM mov_facturas_colegiaturas fc
	WHERE tmp_imprimir_rechazos_generacion_pagos.idfactura = fc.idfactura;

	UPDATE tmp_imprimir_rechazos_generacion_pagos
	SET folio_factura = fc.fol_fiscal
	FROM his_facturas_colegiaturas fc
	WHERE tmp_imprimir_rechazos_generacion_pagos.idfactura = fc.idfactura;
	
	FOR returnrec 
	IN (SELECT num_empleado, nombre_empleado, idfactura, idu_ajuste, folio_factura, importe_factura, importe_pagado FROM tmp_imprimir_rechazos_generacion_pagos)
	LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_imprimir_rechazos_generacion_pagos() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_imprimir_rechazos_generacion_pagos() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_imprimir_rechazos_generacion_pagos() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_imprimir_rechazos_generacion_pagos() TO postgres;
COMMENT ON FUNCTION fun_imprimir_rechazos_generacion_pagos() IS 'La función obtiene los pagos rechazados que se originaron de la generación de pagos.';  