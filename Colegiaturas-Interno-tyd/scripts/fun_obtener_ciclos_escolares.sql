CREATE OR REPLACE FUNCTION fun_obtener_ciclos_escolares()
  RETURNS SETOF type_ciclosescolare AS
$BODY$
DECLARE
	registros type_ciclosescolare;
	anioActual integer;
	anioAnteriores integer;
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 21/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa el ciclo actual y dos ciclos anteriores
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_ciclos_escolares()
		 select * from cat_ciclos_escolares
	*/
BEGIN
	--select * from mov_detalle_facturas_colegiaturas

	--select * from cat_ciclos_escolares


	anioActual:= cast((DATE_PART('year', now())) as integer);
	anioAnteriores:= anioActual-2;

	IF NOT EXISTS (SELECT idu_ciclo_escolar, des_ciclo_escolar from cat_ciclos_escolares WHERE idu_ciclo_escolar= anioActual) THEN
		INSERT INTO cat_ciclos_escolares (idu_ciclo_escolar, des_ciclo_escolar, fec_alta)
		select anioActual, cast(anioActual as varchar)||' - '|| cast(anioActual+1 as varchar), now();
	END IF;

	FOR registros IN SELECT idu_ciclo_escolar, des_ciclo_escolar from cat_ciclos_escolares 
		where idu_ciclo_escolar>=anioAnteriores and idu_ciclo_escolar<=anioActual order by idu_ciclo_escolar desc
	LOOP
		RETURN NEXT registros;
	END LOOP;
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_ciclos_escolares() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_ciclos_escolares() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_ciclos_escolares() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_ciclos_escolares() TO postgres;