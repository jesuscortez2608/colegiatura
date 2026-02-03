CREATE OR REPLACE FUNCTION fun_obtener_tipos_pagos()
  RETURNS SETOF type_tipopago AS
$BODY$
DECLARE
	registros type_tipoPago;
		/*
	     No. petición APS               : 8613.1
	     Fecha                          : 21/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los tipos de pagos
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_tipos_pagos()
	*/
BEGIN

	FOR registros IN SELECT idu_tipo_pago, des_tipo_pago,mes_tipo_pago  from cat_tipos_pagos order by idu_tipo_pago ASC
	LOOP
		RETURN NEXT registros;
	END LOOP;
 END;
 $BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_tipos_pagos() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_pagos() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_pagos() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_pagos() TO postgres;