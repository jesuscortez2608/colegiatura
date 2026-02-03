
CREATE OR REPLACE FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer)
  RETURNS character AS
$BODY$
declare
	iOpcion ALIAS FOR $1;
	empleado ALIAS FOR $2;
	centro ALIAS FOR $3;
	puesto ALIAS FOR $4;
	seccion ALIAS FOR $5;
	escolaridad ALIAS FOR $6;
	parentesco ALIAS FOR $7;
	porcentaje ALIAS FOR $8; 
	cComentario  ALIAS FOR $9; 
	empleadoELimino  ALIAS FOR $10; 
	
	msg char(50);
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 24/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de escuelas
     Ejemplo                        : Elimina Configuracion de Descuentos especiales
				      select * from fun_eliminar_configuracion_de_descuentos()
  ------------------------------------------------------------------------------------------------------ */

	begin
		
		IF iOpcion = 1 then
			INSERT INTO his_configuracion_descuentos (idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro)
			SELECT idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco, por_porcentaje, cComentario, now(), empleadoELimino 
			FROM ctl_configuracion_descuentos WHERE idu_empleado=empleado and idu_escolaridad=escolaridad and idu_parentesco = parentesco;

			delete from ctl_configuracion_descuentos 
			where idu_empleado=empleado
			and idu_escolaridad=escolaridad
			and idu_parentesco = parentesco;
			msg='Registro eliminado correctamente';
	
		ELSIF  iOpcion = 2 then
			INSERT INTO his_configuracion_descuentos (idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro)
			SELECT idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco,por_porcentaje, cComentario, now(), empleadoELimino 
			FROM ctl_configuracion_descuentos WHERE idu_puesto=puesto
			and idu_seccion = seccion
			and idu_escolaridad = escolaridad
			and idu_parentesco = parentesco;
			
			delete from ctl_configuracion_descuentos 
			where idu_puesto=puesto
			and idu_seccion = seccion
			and idu_escolaridad = escolaridad
			and idu_parentesco = parentesco;
			msg='Registro eliminado correctamente';
		
		ELSIF  iOpcion = 3 then

			INSERT INTO his_configuracion_descuentos (idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro)
			SELECT idu_empleado, idu_centro, idu_puesto, idu_seccion, idu_escolaridad, idu_parentesco, por_porcentaje, cComentario, now(), empleadoELimino 
			FROM ctl_configuracion_descuentos WHERE idu_centro=centro
			and idu_puesto = puesto
			and idu_escolaridad = escolaridad
			and idu_parentesco = parentesco;
			
			delete from ctl_configuracion_descuentos 
			where idu_centro=centro
			and idu_puesto = puesto
			and idu_escolaridad = escolaridad
			and idu_parentesco = parentesco;
			msg='Registro eliminado correctamente';
		else
			msg='Registro no existe ó ya fue eliminado';
		end if;

		return msg;
	end;
	$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) IS 'FUNCION PARA ELIMINAR LA CONFIGURACION DE DESCUENTOS.';
