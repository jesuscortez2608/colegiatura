CREATE OR REPLACE FUNCTION fun_grabar_bitacora_suplentes(integer, integer, integer, date, date, integer, integer, integer)
  RETURNS void AS
$BODY$

DECLARE
	iEmpleado ALIAS FOR $1;
	iEmpleadoSuplente ALIAS FOR $2;
	iEmpleadoRegistro ALIAS FOR $3;
	cFechaInicial ALIAS FOR $4;
	cFechaFinal ALIAS FOR $5;
	iIdentificador ALIAS FOR $6;
	iCancelado ALIAS FOR $7;
	iEmpleadoCancela ALIAS FOR $8;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Guarda en la tabla mov_bitacora_suplentes
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_bitacora_suplentes(93902761,93902727,93902761,'20160915','20160930',1,0,0);	
		 SELECT * FROM fun_grabar_bitacora_suplentes(93902727,93902761,93902761,'20160915','20160930',1,0,0);	
	*/
BEGIN



	INSERT INTO mov_bitacora_suplentes (idu_empleado, idu_suplente, idu_empleado_registro, fec_registro, fec_inicial, fec_final, 
	opc_indefinido, opc_expirado, opc_cancelado, idu_empleado_cancelo)
	VALUES (iEmpleado, iEmpleadoSuplente, iEmpleadoRegistro,now(), cFechaInicial, cFechaFinal,
	iIdentificador,0,iCancelado, iEmpleadoCancela );

END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_bitacora_suplentes(integer, integer, integer, date, date, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_bitacora_suplentes(integer, integer, integer, date, date, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_bitacora_suplentes(integer, integer, integer, date, date, integer, integer, integer) TO sysetl;
