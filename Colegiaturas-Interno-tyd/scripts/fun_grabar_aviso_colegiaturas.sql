CREATE TYPE type_fun_grabar_aviso_colegiaturas AS
   (estado integer,
    mensaje character varying(100));

CREATE OR REPLACE FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer)
  RETURNS SETOF type_fun_grabar_aviso_colegiaturas AS
$BODY$
DECLARE

iaviso ALIAS FOR $1;
saviso ALIAS FOR $2;
dfecha_ini ALIAS FOR $3;
dfecha_fin ALIAS FOR $4;
iindefinido ALIAS FOR $5;
iopcion ALIAS FOR $6;
inum_agrego ALIAS FOR $7;

registro type_fun_grabar_aviso_colegiaturas;
estado integer;
iKeyxAviso integer;

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
     Ejemplo                        : Graba los avisos para colaboradores de colegiaturas

	select * from fun_grabar_aviso_colegiaturas(0,'ULTIMO DIA SUBIR FACTURAS','2016-11-17','2016-11-17',0,0,93902761)
	SELECT * FROM mov_avisos_colegiaturas
	SELECT * FROM his_avisos_colegiaturas
	DELETE FROM mov_avisos_colegiaturas
	DELETE FROM his_avisos_colegiaturas

	 ------------------------------------------------------
	 No. peticion APS				: 16559.1
	 Servidor de produccion			: 10.44.2.183
	 Servidor de pruebas			: 10.44.114.75	
	*/
 ------------------------------------------------------------------------------------------------------ 
 
	IF (EXISTS (SELECT idu_aviso FROM mov_avisos_colegiaturas
	WHERE  idu_aviso = iaviso)) then
	
		UPDATE mov_avisos_colegiaturas
		SET idu_aviso = iaviso,
		des_aviso = saviso,
		idu_opcion = iopcion,
		opc_indefinido = iindefinido,
		fec_inicial = dfecha_ini,
		fec_final = dfecha_fin,
		fec_registro=now(),
		idu_empleado_registro = inum_agrego
		WHERE idu_aviso = iaviso;

		INSERT INTO his_avisos_colegiaturas (idu_aviso, des_aviso, idu_opcion,opc_indefinido,fec_inicial,fec_final,fec_registro,idu_empleado_registro)
		SELECT idu_aviso,des_aviso,idu_opcion,opc_indefinido,fec_inicial,fec_final,fec_registro,idu_empleado_registro
		FROM mov_avisos_colegiaturas
		WHERE idu_aviso = iaviso;

		UPDATE his_avisos_colegiaturas SET opc_tipo_movimiento = 'U'
		WHERE idu_aviso = iaviso and des_aviso = saviso and idu_opcion = iopcion and opc_indefinido = iindefinido and fec_inicial = dfecha_ini and fec_final = dfecha_fin and idu_empleado_registro = inum_agrego;
		estado:=1;

	ELSE
		INSERT INTO mov_avisos_colegiaturas (des_aviso, idu_opcion,opc_indefinido,fec_inicial,fec_final,fec_registro,idu_empleado_registro)
		VALUES (saviso,iopcion,iindefinido,dfecha_ini,dfecha_fin,now(),inum_agrego) RETURNING idu_aviso INTO iKeyxAviso;

		INSERT INTO his_avisos_colegiaturas (idu_aviso,des_aviso, idu_opcion,opc_indefinido,fec_inicial,fec_final,fec_registro,idu_empleado_registro)
		SELECT idu_aviso,des_aviso, idu_opcion,opc_indefinido,fec_inicial,fec_final,fec_registro,idu_empleado_registro
		FROM mov_avisos_colegiaturas
		WHERE idu_aviso = iKeyxAviso;

		UPDATE his_avisos_colegiaturas SET opc_tipo_movimiento = 'I'
		WHERE idu_aviso = iKeyxAviso;
		
		estado:=0;

	end if;

	for registro in select estado, case when estado = 1 then 'Datos Actualizados Correctamente' when estado = 0 then 'Datos Guardados Correctamente'
	END
	loop
		return next registro;
	end loop;
	return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_aviso_colegiaturas(integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, integer) IS 'La función graba un mensaje de aviso para colaboradores.';