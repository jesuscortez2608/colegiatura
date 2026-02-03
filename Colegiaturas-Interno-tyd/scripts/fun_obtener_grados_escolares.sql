CREATE OR REPLACE FUNCTION fun_obtener_grados_escolares(integer)
  RETURNS SETOF type_obtener_grados_escolares AS
$BODY$
DECLARE 
	iEscolaridad alias for $1;
	registros type_obtener_grados_escolares;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 19/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Obtiene los grados correspondientes a una escolaridad
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_grados_escolares(3);	
		 SELECT * FROM fun_obtener_grados_escolares(4);	
	*/
BEGIN
	FOR registros IN SELECT idu_grado_escolar, nom_grado_escolar from cat_grados_escolares where idu_escolaridad=iEscolaridad ORDER BY  idu_grado_escolar
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_grados_escolares(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_grados_escolares(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_grados_escolares(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_grados_escolares(integer) TO postgres;
