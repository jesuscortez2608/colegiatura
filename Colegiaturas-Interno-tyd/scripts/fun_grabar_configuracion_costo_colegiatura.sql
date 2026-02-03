DROP FUNCTION IF EXISTS fun_grabar_configuracion_costo_colegiatura(integer, integer, integer, integer, integer, integer, numeric, numeric, integer, integer, character varying, integer);
DROP TYPE IF EXISTS type_grabar_configuracion_costo_colegiatura;

CREATE TYPE type_grabar_configuracion_costo_colegiatura AS
   (estado integer,
    mensaje character varying(100));

CREATE OR REPLACE FUNCTION fun_grabar_configuracion_costo_colegiatura(integer, integer, integer, integer, integer, integer, numeric, numeric, integer, integer, character varying, integer)
  RETURNS SETOF type_grabar_configuracion_costo_colegiatura AS
$BODY$
DECLARE  

id_empleado ALIAS FOR $1;
id_beneficiario ALIAS FOR $2;
id_parentesco ALIAS FOR $3;
id_escuela ALIAS FOR $4;
id_escolaridad ALIAS FOR $5;
id_grado ALIAS FOR $6;
inscripcion ALIAS FOR $7;
colegiatura ALIAS FOR $8;
estatus_configuracion ALIAS FOR $9;
id_marco_estatus ALIAS FOR $10;
nomArchivo ALIAS FOR $11;
idu_ciclo ALIAS FOR $12;

beneficiario_hojaazul integer default 0;

registro type_grabar_escuela_escolaridad;
estado integer;

BEGIN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 24/10/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de estudios
     Ejemplo                        : Graba las configuraciones de costo colegiatura
	select * from fun_grabar_configuracion_costo_colegiatura (93902761,0,1,3,16,5,1,2000,3000,1,97354678,'2016-10-24')
	SELECT * FROM mov_configuracion_costos
	DELETE FROM mov_configuracion_costos
	*/
 ------------------------------------------------------------------------------------------------------ 
 
	IF (EXISTS (SELECT idu_beneficiario,idu_escuela,idu_escolaridad FROM mov_configuracion_costos 
	WHERE idu_empleado = id_empleado and idu_beneficiario = id_beneficiario and idu_escuela = id_escuela and idu_escolaridad = id_escolaridad)) then
	
		UPDATE mov_configuracion_costos 
		SET idu_parentesco = id_parentesco, idu_grado_escolar = id_grado, imp_inscripcion = inscripcion,
		imp_colegiatura = colegiatura,fec_marco_estatus=now(), nom_archivo_alfresco= case when rtrim(nomArchivo)='' then nom_archivo_alfresco else rtrim(nomArchivo) end
		WHERE idu_empleado = id_empleado and idu_beneficiario = id_beneficiario 
		and idu_escuela = id_escuela and idu_escolaridad = id_escolaridad;
		estado:=1; 

	ELSE	
		if not exists (select idu_empleado from cat_beneficiarios_colegiaturas where idu_empleado=id_empleado and idu_beneficiario=id_beneficiario ) then
			beneficiario_hojaazul=1;
		end if;
		
		insert into mov_configuracion_costos (idu_empleado, beneficiario_hoja_azul, idu_beneficiario, 
		idu_parentesco, idu_escuela, idu_escolaridad, idu_grado_escolar, imp_inscripcion,
		imp_colegiatura, estatus_configuracion, idu_marco_estatus, fec_marco_estatus, nom_archivo_alfresco, idu_ciclo_escolar) 
		values (id_empleado, beneficiario_hojaazul,id_beneficiario, id_parentesco,
		id_escuela, id_escolaridad, id_grado, inscripcion, colegiatura, estatus_configuracion, id_marco_estatus, now(), nomArchivo, idu_ciclo);
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
  LANGUAGE plpgsql VOLATILE;