CREATE OR REPLACE FUNCTION fun_grabar_motivo(integer, integer, character, integer)
  RETURNS integer AS
$BODY$
declare 
	iClaveMotivo ALIAS FOR $1;
	iTipoMotivo ALIAS FOR $2;
	cMotivo ALIAS FOR $3;
	iEmpleado ALIAS FOR $4;
	iMotivo integer;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 02/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Guarda un motivo en la tabla cat_motivos_colegiaturas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Motivos
	     Ejemplo                        : 
		 select * from fun_grabar_motivo (0,1,'PRUEBA',93902761);	
		select * from fun_grabar_motivo (1,1,'PRUEBA',93902761);
		 DROP FUNCTION fun_grabar_motivo(integer, integer, character(100), integer )	
	*/
begin

	IF EXISTS (SELECT * FROM cat_motivos_colegiaturas WHERE TRIM(des_motivo)=TRIM(cMotivo) AND idu_tipo_motivo= iTipoMotivo) THEN
		RETURN 0;
	ELSE	
		IF iClaveMotivo>0 THEN --ACTUALIZA
			UPDATE cat_motivos_colegiaturas SET idu_tipo_motivo=iTipoMotivo, des_motivo=upper( cMotivo),fec_captura=now(),idu_empleado_registro=iEmpleado  
			WHERE idu_motivo=iClaveMotivo;

		ELSE
			
			
			iMotivo:=(select idu_motivo+1 from cat_motivos_colegiaturas order by idu_motivo desc limit 1);
			INSERT INTO cat_motivos_colegiaturas (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro,estatus )
			SELECT iMotivo, iTipoMotivo,upper( cMotivo), now(), iEmpleado, 1;
		END IF;
		RETURN 1;
	END IF;	
END;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_motivo(integer, integer, character, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_motivo(integer, integer, character, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_motivo(integer, integer, character, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_motivo(integer, integer, character, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_motivo(integer, integer, character, integer) IS 'FUNCION PARA GRABAR MOTIVO';

