CREATE OR REPLACE FUNCTION fun_grabar_estatus_limitado(integer, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE 
	
	nEmpleado alias for $1;
	nLimitado alias for $2;
	nEmpleadoRegistro alias for $3;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 28/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : actualiza el campo limitado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Aceptar / Rechazar Facturas
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_estatus_limitado(93902727,1,93902761); 
		 
	*/
BEGIN
	IF NOT EXISTS (SELECT IDU_EMPLEADO FROM cat_empleados_colegiaturas WHERE idu_empleado=nEmpleado) THEN
	
		INSERT INTO cat_empleados_colegiaturas (idu_empleado, opc_limitado, opc_cheque, opc_empleado_bloqueado, fec_registro, idu_empleado_registro)
		VALUES (nEmpleado, nLimitado, 0, 0, NOW(), nEmpleadoRegistro);
	ELSE
		UPDATE cat_empleados_colegiaturas SET opc_limitado=nLimitado WHERE idu_empleado=nEmpleado;

	END IF;	
	
	return 1;
end; 
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_estatus_limitado(integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_limitado(integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_limitado(integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_limitado(integer, integer, integer) TO postgres;