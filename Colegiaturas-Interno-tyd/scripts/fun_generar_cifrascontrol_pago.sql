 DROP FUNCTION IF EXISTS fun_generar_cifrascontrol_pago();
 drop type if exists type_generar_cifrascontrol_pago;

CREATE TYPE type_generar_cifrascontrol_pago AS
   (movimientos integer,
    empleados integer,
    importe_factura numeric(12,2),
    importe_pagado numeric(12,2),
    importe_ajuste numeric(12,2),
    importe_isr numeric(12,2));

CREATE OR REPLACE FUNCTION fun_generar_cifrascontrol_pago()
  RETURNS SETOF type_generar_cifrascontrol_pago AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613.1
	Fecha                          : 30/11/2016
	Número empleado                : 97695068
	Nombre del empleado            : Héctor Medina Escareño
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.2.89
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Procesos especiales
	Ejemplo                        : SELECT * FROM fun_generar_cifrascontrol_pago()
	------------------------------------------------------------------------------------------------------ 
	No. Peticion			: 16559.1
	Número empleado			: 98439677
	Nombre empleado			: Rafael Ramos Gutierrez
	Descripcion del cambio		: Se cambian las tablas de donde se toma la informacion para la generacion de cifras de control en la generación de pagos
	------------------------------------------------------------------------------------------------------ */
	returnrec type_generar_cifrascontrol_pago;
	TotalEmpleados integer;
	TotalMovtos integer;
BEGIN
	/* //=========/  TABLAS PARTICIPANTES  /==========//
	   select * from mov_generacion_pagos_colegiaturas;
	   select * from stmp_facturas_rechazadas;
	   SELECT * FROM cat_rutaspagos;
	*/
	TotalEmpleados := 0;
	TotalMovtos := 0;

	CREATE LOCAL TEMP TABLE tmp_generar_cifrascontrol_pago(
		idu_empleado integer,
		empleados integer,
		movimientos integer,
		importe_factura numeric(12, 2),
		importe_pagado numeric(12, 2),
		importe_ajuste numeric(12, 2),
		importe_isr numeric(12,2)
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE tmp_facturas_rechazadas(
		idu_empleado integer,
		importe_ajuste numeric(12, 2)
	)ON COMMIT DROP;
	
	INSERT INTO tmp_generar_cifrascontrol_pago(idu_empleado , importe_factura, importe_pagado, importe_ajuste, importe_isr)
	SELECT 
	idu_empleado
        , SUM(pg.importe_factura)
        , SUM(pg.importe_pagado)
        , 0
        , SUM(pg.importe_isr)
	FROM mov_generacion_pagos_colegiaturas pg
	GROUP BY idu_empleado;
	
	INSERT INTO tmp_facturas_rechazadas(idu_empleado,importe_ajuste)
	SELECT 	B.idu_empleado, SUM(A.importe_ajuste)
	FROM 	MOV_AJUSTES_FACTURAS_COLEGIATURAS A 
	INNER 	JOIN HIS_DETALLE_FACTURAS_COLEGIATURAS B ON A.idfactura=B.idfactura		
	GROUP 	BY  B.idu_empleado;

	UPDATE 	tmp_generar_cifrascontrol_pago SET importe_ajuste=B.importe_ajuste
	FROM 	tmp_facturas_rechazadas B
	WHERE	tmp_generar_cifrascontrol_pago.idu_empleado=B.idu_empleado;


	TotalEmpleados :=  COUNT(idu_empleado)from mov_detalle_generacion_pagos_colegiaturas ;
	TotalMovtos := COUNT(*) from tmp_generar_cifrascontrol_pago;

	update tmp_generar_cifrascontrol_pago
		set 	empleados = TotalEmpleados
			, movimientos = TotalMovtos;
	
	FOR returnrec 
	IN (SELECT empleados, movimientos, importe_factura, importe_pagado, importe_ajuste, importe_isr FROM tmp_generar_cifrascontrol_pago)
	LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_generar_cifrascontrol_pago() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_generar_cifrascontrol_pago() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_generar_cifrascontrol_pago() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_generar_cifrascontrol_pago() TO postgres;
COMMENT ON FUNCTION fun_generar_cifrascontrol_pago() IS 'La función obtiene las cifras de control que se obtiene durante la generación de pagos.';