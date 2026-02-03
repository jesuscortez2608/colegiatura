CREATE OR REPLACE FUNCTION fun_obtener_periodos_pagos(integer)
  RETURNS SETOF type_periodos_pagos AS
$BODY$
DECLARE
	iTipoPago ALIAS FOR $1;
	registros type_periodos_pagos;
	
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 21/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los periodos de pagos de un tipo de pago
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_periodos_pagos(1)
	*/
BEGIN
	FOR registros IN SELECT idu_periodo, des_periodo  from CAT_PERIODOS_PAGOS where idu_tipo_periodo=iTipoPago order by idu_periodo asc
	LOOP
		RETURN NEXT registros;
	END LOOP;
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_periodos_pagos(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_periodos_pagos(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_periodos_pagos(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_periodos_pagos(integer) TO postgres;
