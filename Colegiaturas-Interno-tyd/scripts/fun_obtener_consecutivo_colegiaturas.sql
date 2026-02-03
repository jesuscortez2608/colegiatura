CREATE OR REPLACE FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer)
  RETURNS integer AS
$BODY$
declare

	nTipo alias for $1;
	nBusqueda alias for $2;
	nConsecutivo int;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 26/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Regresa el concecutivo del beneficiario
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_consecutivo_colegiaturas(1,93902761);
		  SELECT * FROM fun_obtener_consecutivo_colegiaturas(1,92100491);
	*/
begin
	nConsecutivo:=0;
	if nTipo=1 then
		nConsecutivo:= (select count(idu_empleado)+1 from cat_beneficiarios_colegiaturas where idu_empleado=nBusqueda);

	end if;
	return nConsecutivo;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_consecutivo_colegiaturas(integer, integer) IS 'La función obtiene un consecutivo de alguno de los catálogos de colegiaturas.';
