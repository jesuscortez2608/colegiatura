CREATE TYPE type_fun_obtener_descuentos_colegiaturas AS
   (prc_descuento integer,
    des_descuento character varying(10));

CREATE OR REPLACE FUNCTION fun_obtener_descuentos_colegiaturas()
  RETURNS SETOF type_fun_obtener_descuentos_colegiaturas AS
$BODY$
DECLARE 	
registro type_fun_obtener_descuentos_colegiaturas;
 /*
	No. petición APS               : 8613.1
	Fecha                          : 13/05/2017
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Regresa los porcentajes de descuento que se usaran en el sistema de colegiaturas
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Descuentos
	Ejemplo                        : select * from fun_obtener_descuentos_colegiaturas()
*/

BEGIN
FOR registro IN SELECT prc_descuento, des_descuento FROM cat_descuentos_colegiaturas ORDER BY prc_descuento ASC
LOOP
	RETURN NEXT registro;
END LOOP;
return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_descuentos_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_descuentos_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_descuentos_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_descuentos_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_descuentos_colegiaturas() IS 'La función obtiene un listado de los porcentajes de descuento que están guardados en la tabla cat_descuentos_colegiaturas.';