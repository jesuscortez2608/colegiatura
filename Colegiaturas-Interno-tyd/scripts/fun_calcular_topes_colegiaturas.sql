CREATE OR REPLACE FUNCTION fun_calcular_topes_colegiaturas (integer, integer)
 RETURNS SETOF type_calcula_topes_colegiaturas AS
$BODY$
declare 
	iNumEmp ALIAS FOR $1;
	iSueldo ALIAS FOR $2;
	nSueldo numeric(9,2);
	cSueldo varchar(20);
	cTopeAnual varchar(20);
	cTopeMensual varchar(20);
	
	registros type_calcula_topes_colegiaturas;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 05/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Regresa los topes de colegiaturas de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Facturas
	     Ejemplo                        : 
		 select * from fun_calcular_topes_colegiaturas (93902761,1000000);
	*/
	
BEGIN
	cSueldo :=cast(rtrim(to_char((iSueldo)/100,'999,999,999,999.99')) as char(20));
	cTopeAnual:= cast(rtrim(to_char((iSueldo*6)/100,'999,999,999,999.99')) as char(20));
	cTopeMensual:= cast(rtrim(to_char((iSueldo/2)/100,'999,999,999,999.99')) as char(20));
	
	FOR registros IN 
	(
		SELECT  trim(cSueldo), trim(cTopeAnual), trim(cTopeMensual)
	) 
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_calcular_topes_colegiaturas (integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_calcular_topes_colegiaturas (integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_calcular_topes_colegiaturas (integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_calcular_topes_colegiaturas (integer, integer) TO postgres;
COMMENT ON FUNCTION fun_calcular_topes_colegiaturas (integer, integer) IS 'Regresa los topes de colegiaturas de un empleado';

