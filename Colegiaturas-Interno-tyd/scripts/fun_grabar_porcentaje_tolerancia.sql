DROP FUNCTION IF EXISTS fun_grabar_porcentaje_tolerancia(integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_porcentaje_tolerancia(integer, integer)
  RETURNS smallint AS
$BODY$
DECLARE    
	nPorcentaje ALIAS FOR $1;
	nCapturo ALIAS FOR $2;

	/*    
		No. Peticion APS               : 16559.1
		Fecha                          : 16/11/2017
		Numero empleado                : 93902761
		Nombre del empleado            : Nallely Machado
		Base de datos                  : personal
		Servidor de pruebas            : 10.28.114.75
		Servidor de produccion         : 
		Descripcion del funcionamiento : Guarda el porcentaje de tolerancia
		Descripcion del cambio         : NA
		Sistema                        : Colegiaturas
		Modulo                         : Porcentaje de Toleracia
		Ejemplo                        : SELECT * FROM fun_grabar_porcentaje_tolerancia(10::INTEGER,93902761::INTEGER);
						 SELECT * FROM ctl_variables_colegiaturas
						 SELECT * FROM his_variables_colegiaturas
		/--------------------------------------------------------------------------------------------------------------------------------
		No. Peticion APS		: 16559.1
		Fecha				: 26/07/2018
		Empleado			: 98439677 - Ramos Gutiérrez Rafael
		BD				: Personal
		Descripcion del cambio		: Se agregan lineas para crear registro en la tabla mov_bitacora_costos al actualizar el porcentaje
		Sistema				: Colegiaturas
		Modulo				: Porcentaje de Tolerancia
		Ejemplo				: 
							SELECT fun_grabar_porcentaje_tolerancia(10,95194185)
		*/
BEGIN 
	UPDATE ctl_variables_colegiaturas SET pct_tolerancia=nPorcentaje, fec_registro=now(), idu_usuario_registro=nCapturo;

	insert into mov_bitacora_costos (idu_revision, idu_tipo_revision, porcentaje_tolerancia, fec_revision, idu_usuario)
	values(0, 4, nPorcentaje, now(), nCapturo);
	
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_porcentaje_tolerancia(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_porcentaje_tolerancia(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_porcentaje_tolerancia(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_porcentaje_tolerancia(integer, integer) TO postgres;