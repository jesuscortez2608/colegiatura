CREATE OR REPLACE FUNCTION fun_cancelar_suplente_colegiaturas(integer, integer)
  RETURNS void AS
$BODY$

DECLARE
	iRegistro ALIAS FOR $1;
	iEmpleadoRegistro ALIAS FOR $2;
	
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Borra en la tabla mov_suplentes_colegiaturas e inserta en la mov_bitacora_suplentes
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Ejemplo                        : 
		 SELECT * FROM fun_cancelar_suplente_colegiaturas(7,93902727);	
	*/
BEGIN

	INSERT INTO mov_bitacora_suplentes (idu_empleado, idu_suplente, idu_empleado_registro, fec_registro, fec_inicial, fec_final, 
	opc_indefinido, opc_expirado, opc_cancelado, idu_empleado_cancelo)
	SELECT idu_empleado,idu_suplente,idu_empleado_registro, NOW(),fec_inicial,fec_final,
	opc_indefinido,0,1,iEmpleadoRegistro FROM mov_suplentes_colegiaturas 
	WHERE id=iRegistro;

	DELETE FROM mov_suplentes_colegiaturas WHERE id=iRegistro;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_cancelar_suplente_colegiaturas(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_cancelar_suplente_colegiaturas(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_cancelar_suplente_colegiaturas(integer, integer) TO sysetl;
