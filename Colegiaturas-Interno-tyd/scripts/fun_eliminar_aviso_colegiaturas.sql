CREATE TYPE type_fun_eliminar_aviso_colegiaturas AS
   (estado integer,
    mensaje character varying(100));

CREATE OR REPLACE FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer)
  RETURNS SETOF type_fun_eliminar_aviso_colegiaturas AS
$BODY$
DECLARE

clave_aviso ALIAS FOR $1;
smensaje ALIAS FOR $2;
iopcion ALIAS FOR $3;
indefinido ALIAS FOR $4;
fec_ini ALIAS FOR $5;
fec_fin ALIAS FOR $6;
NumEmpElimino ALIAS FOR $7;

registro type_fun_eliminar_aviso_colegiaturas;
estado integer;

BEGIN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 02/11/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de estudios
     Ejemplo                        : Elimina los avisos para colaboradores de colegiaturas

	select * from fun_eliminar_aviso_colegiaturas(83,'PRUEBA 1.1',2,0,'07/11/2016',11/11/2016,93902761);
	SELECT * FROM mov_avisos_colegiaturas
	SELECT * FROM his_avisos_colegiaturas
	------------------------------------------------------
		 No. peticion APS				: 16559.1
		 Servidor de produccion			: 10.44.2.183
		 Servidor de pruebas			: 10.44.114.75	
	*/
 ------------------------------------------------------------------------------------------------------
	INSERT INTO his_avisos_colegiaturas (idu_aviso, des_aviso, idu_opcion, opc_indefinido, fec_inicial, fec_final, fec_registro, idu_empleado_registro, opc_tipo_movimiento)
	VALUES(clave_aviso, smensaje, iopcion, indefinido, fec_ini, fec_fin, now(), NumEmpElimino, 'D');

	DELETE FROM mov_avisos_colegiaturas
	WHERE idu_aviso=clave_aviso;
	estado:=0;

	FOR registro IN SELECT estado, CASE WHEN estado = 0 THEN 'Datos Eliminados Correctamente' WHEN estado = 1 THEN 'Ocurrio un problema'
	END
	LOOP
		RETURN NEXT registro;
	END LOOP;
	return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_aviso_colegiaturas(integer, character varying, integer, integer, timestamp without time zone, timestamp without time zone, integer) IS 'La función elimina una configuración de aviso y la manda al histórico.';