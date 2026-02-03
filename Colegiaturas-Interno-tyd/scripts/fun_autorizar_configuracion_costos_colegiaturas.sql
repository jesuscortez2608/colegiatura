CREATE TYPE type_fun_autorizar_configuracion_costos_colegiaturas AS
   (estado integer,
    mensaje character varying(100));

CREATE OR REPLACE FUNCTION fun_autorizar_configuracion_costos_colegiaturas(integer, integer, integer)
  RETURNS SETOF type_fun_autorizar_configuracion_costos_colegiaturas AS
$BODY$
DECLARE    

id_clave ALIAS FOR $1;
num_empleado ALIAS FOR $2;
num_emp_autorizo ALIAS FOR $3;

registro type_fun_autorizar_configuracion_costos_colegiaturas;
estado integer;

BEGIN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 15/11/2016
     Número empleado                : 96753269
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Costos
     Ejemplo                        : Cambia el estatus a autorizado de una configuración de costos de colegiaturas
		
	select * from fun_autorizar_configuracion_costos_colegiaturas (1, 93902761, 93902761)
	select * from mov_configuracion_costos
	select * from his_configuracion_costos

	select * from fun_autorizar_configuracion_costos_colegiaturas(4,93902761, 93902761)
	
	*/
	
 ------------------------------------------------------------------------------------------------------ 
 
		UPDATE mov_configuracion_costos 
		SET  estatus_configuracion = 1,
		idu_marco_estatus = num_emp_autorizo,
		fec_marco_estatus = now()
		WHERE idu_costo = id_clave and idu_empleado = num_empleado;

		INSERT INTO his_configuracion_costos (idu_costo,idu_empleado,beneficiario_hoja_azul,idu_beneficiario,
		idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,imp_colegiatura,
		estatus_configuracion,idu_marco_estatus,fec_marco_estatus, nom_archivo_alfresco, idu_ciclo_escolar)
		SELECT idu_costo,idu_empleado,beneficiario_hoja_azul,idu_beneficiario,
		idu_parentesco,idu_escuela,idu_escolaridad, idu_grado_escolar,imp_inscripcion,imp_colegiatura,
		estatus_configuracion,idu_marco_estatus,fec_marco_estatus, nom_archivo_alfresco, idu_ciclo_escolar
		FROM mov_configuracion_costos
		WHERE idu_costo = id_clave and idu_empleado = num_empleado;
		
		DELETE FROM mov_configuracion_costos 
		WHERE idu_costo=id_clave and idu_empleado = num_empleado;
		estado:=0; 

	for registro in select estado, case when estado = 0 then 'Datos Validados Correctamente' else 'Ocurrio un error al validar los datos'
	END
	loop
		return next registro;
	end loop;
	return;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;