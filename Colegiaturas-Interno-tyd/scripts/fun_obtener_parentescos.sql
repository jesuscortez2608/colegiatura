DROP FUNCTION IF EXISTS fun_obtener_parentescos(integer);
DROP TYPE IF EXISTS type_parentescos;

CREATE TYPE type_parentescos AS
   (idu_parentesco integer,
    des_parentesco character varying(20));

CREATE OR REPLACE FUNCTION fun_obtener_parentescos(integer)
  RETURNS SETOF type_parentescos AS
$BODY$
 /*
	 No. petición APS               : 8613.1
	 Fecha                          : 15/09/2016
	 Número empleado                : 93902761
	 Nombre del empleado            : Nallely Machado
	 Base de datos                  : administracion
	 Servidor de pruebas            : 10.44.15.182
	 Servidor de produccion         : 10.44.2.29
	 Descripción del funcionamiento : Regresa los tipos de parentesco para subir factura y para agregar beneficiarios desde personal administracion (tipo 1)
	 Descripción del cambio         : NA
	 Sistema                        : Colegiaturas
	 Módulo                         : Subir factura Configuración de Empleados con Colegiatuta
	 Ejemplo                        : 
				SELECT * FROM fun_obtener_parentescos(1); --excluye los parentescos que estan en la hoha azul (hijo(a),esposo(a))
				SELECT * FROM fun_obtener_parentescos(0); --regresa todos los parentescos
	-------------------------------------------------------------------------------------------------------------------
	 No.Peticion			: 16559
	 Fecha				: 15/06/2018
	 Número empleado		: 98439677
	 Nombre empleado		: Rafael Ramos Gutierrez
	 Descripcion del cambio		: Se quito que dijera el mismo cuando era el idu 11, ya que decia empleado en la tabla y se cambio a que diga el mismo
*/
DECLARE
	iTipo alias for $1;
	registros type_parentescos;
	sSQL VARCHAR;
BEGIN
	sSQL:=( 'select idu_parentesco, des_parentesco from cat_parentescos ');
	if iTipo=1 then
		sSQL:=( sSQL||'where idu_parentesco in (3,4,11,10)');
	end if;
	sSQL:=( sSQL||' order by des_parentesco');
	FOR registros IN EXECUTE sSQL
	LOOP
		RETURN NEXT registros;
	END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_parentescos(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_parentescos(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_parentescos(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_parentescos(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_parentescos(integer) IS 'La función obtiene el listado de parentescos.';  
