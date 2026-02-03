CREATE OR REPLACE FUNCTION fun_obtener_rutas_pago()
  RETURNS SETOF type_obtener_rutas_pago AS
$BODY$
/*
	No. petición APS               : 8613.1
	Fecha                          : 22/11/2016
	Número empleado                : 97695068
	Nombre del empleado            : Héctor Medina
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.2.89
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Reportes
	Ejemplo                        :

	select id_rutapago,nom_rutapago from fun_obtener_rutas_pago();
	_________________________________________________________________
*/
DECLARE
	returnrec type_obtener_rutas_pago;
BEGIN
	FOR returnrec IN (SELECT idu_rutapago,nom_rutapago FROM cat_rutaspagos where idu_rutapago in (1,2,4,5,6) )
	LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_rutas_pago() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_rutas_pago() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_rutas_pago() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_rutas_pago() TO postgres;
