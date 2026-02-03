CREATE OR REPLACE FUNCTION fun_obtener_tipos_deduccion()
  RETURNS SETOF type_obtener_tipos_deduccion AS
$BODY$
     /*
     No. petición APS               : 8613.1
     Fecha                          : 28/10/2016
     Número empleado                : 96753269
     Nombre del empleado            : Nallely Machado
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : Regresa los tipos de deduccion de la tabla cat_tipos_deduccion
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Autorizar o rechazar facturas
     Ejemplo                        :
		select * from   fun_obtener_tipos_deduccion()
  ------------------------------------------------------------------------------------------------------ */
DECLARE
     regristros type_obtener_tipos_deduccion;
BEGIN
	for regristros in (SELECT idu_tipo, nom_deduccion FROM CAT_TIPOS_DEDUCCION order by idu_tipo)  LOOP
	RETURN NEXT regristros; 
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_tipos_deduccion() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_deduccion() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_deduccion() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_deduccion() TO postgres;
