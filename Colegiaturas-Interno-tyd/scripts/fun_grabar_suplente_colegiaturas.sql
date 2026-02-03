DROP FUNCTION IF EXISTS fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer)
  RETURNS smallint AS
$BODY$

DECLARE
	
	iEmpleado ALIAS FOR $1;
	iEmpleadoSuplente ALIAS FOR $2;
	iEmpleadoRegistro ALIAS FOR $3;
	cFechaInicial ALIAS FOR $4;
	cFechaFinal ALIAS FOR $5;
	iIdentificador ALIAS FOR $6;
	iId ALIAS FOR $7;
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Guarda en la tabla mov_suplentes_colegiaturas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Modifica			    : Omar Lizarraga 94827443
	     Descripcion		    : Se valida primero si existe ese suplente con ese empleado, si no existe entonces guarda o modifica
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_suplente_colegiaturas(93902727,93902761,93902761,'20160915','20160930',1,0);	
		 SELECT * FROM fun_grabar_suplente_colegiaturas(93902761,93902727,93902761,'20160915','20160930',1,1);	
	*/
	BEGIN
		IF EXISTS (SELECT idu_empleado FROM MOV_SUPLENTES_COLEGIATURAS where idu_empleado=iEmpleado and idu_suplente=iEmpleadoSuplente and fec_inicial=cFechaInicial and fec_final=cFechaFinal) THEN
			RETURN 0;
		ELSE
			IF iId=0 THEN --INSERTA UN REGISTRO NUEVO
				INSERT 	INTO mov_suplentes_colegiaturas (idu_empleado, idu_suplente, idu_empleado_registro, fec_registro, fec_inicial, fec_final, opc_indefinido)
				VALUES 	(iEmpleado, iEmpleadoSuplente, iEmpleadoRegistro,now(), cFechaInicial, cFechaFinal,iIdentificador);
				RETURN 	1;
			ELSE --MODIFICA
				UPDATE 	mov_suplentes_colegiaturas SET idu_suplente=iEmpleadoSuplente, idu_empleado_registro=iEmpleadoRegistro, fec_registro=now(), fec_inicial=cFechaInicial, fec_final=cFechaFinal, opc_indefinido=iIdentificador 
				WHERE 	id=iId;
				RETURN 1;
			END IF;		
		END IF;
	END;

$BODY$
  LANGUAGE PLPGSQL VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_suplente_colegiaturas(integer, integer, integer, date, date, integer, integer)IS 'La función graba los permisos de suplencia';