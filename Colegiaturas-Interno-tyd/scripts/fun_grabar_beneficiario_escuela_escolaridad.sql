DROP FUNCTION IF EXISTS fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE  
	iConfiguracion alias for $1;
	iEmpleado alias for $2;	
	iBeneficiario alias for $3;
	iEscuela alias for $4;
	iEscolaridad alias for $5;
	iCicloEscolar alias for $6;	
	iGrado alias for $7;	
	iTipoBeneficiario alias for $8;
	iCapturo alias for $9;	
	iCarrera alias for $10;

	resultado int;	
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 13/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Guarda una escolaridad de un beneficiario
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_beneficiario_escuela_escolaridad(93902761,1,1,2,3,93902761);	
		 SELECT * FROM fun_grabar_beneficiario_escuela_escolaridad(93902761,1,6,4,1,93902761);	
	---------------------------------------------------------------------------------------------------------
		No. peticion APS		: 16559.1
		Fecha				: 23/04/2018
		Número empleado			: 98439677
		Empleado			: Rafael Ramos Gutiérrez
		Descripcion del cambio		: Se cambio el valor de la condicional de iEscolaridad (6 a 7) ya que 7 es el valor de maestria, que solo se aplica al colaborador
	*/
BEGIN
	IF EXISTS (	SELECT 	idu_empleado 
			FROM 	cat_estudios_beneficiarios
			WHERE 	idu_empleado=iEmpleado 
				AND idu_beneficiario= iBeneficiario 
				AND idu_escuela=iEscuela 
				AND idu_escolaridad=iEscolaridad 
				AND idu_carrera = iCarrera
				AND idu_grado_escolar=iGrado ) THEN
		resultado:=0;
	ELSE	
		IF (iEscolaridad=7 AND (SELECT IDU_PARENTESCO FROM CAT_BENEFICIARIOS_COLEGIATURAS WHERE IDU_EMPLEADO=iEmpleado AND IDU_BENEFICIARIO=iBeneficiario)!=11) THEN
			resultado:=-2;
		elsif (iEscolaridad=7 AND (SELECT PARENTESCO FROM SAPFAMILIARHOJAS WHERE numemp=iEmpleado AND keyx=iBeneficiario)!=11) THEN
			resultado:=-2;
		ELSE
			IF (iConfiguracion=0) THEN
				INSERT 	INTO cat_estudios_beneficiarios (idu_empleado, idu_beneficiario, idu_escuela, idu_escolaridad, idu_carrera, idu_ciclo_escolar, idu_grado_escolar,fec_registro, opc_tipo_beneficiario, idu_empleado_registro)
				SELECT 	iEmpleado, iBeneficiario, iEscuela, iEscolaridad, iCarrera, iCicloEscolar, iGrado,now(),iTipoBeneficiario,iCapturo;	

				--UPDATE 	cat_escuelas_colegiaturas SET idu_escolaridad=iEscolaridad                    
				--WHERE 	idu_escuela=iEscuela AND idu_escolaridad=0;
			ELSE
				UPDATE 	    cat_estudios_beneficiarios SET idu_escuela=iEscuela
					    , idu_escolaridad=iEscolaridad
					    , idu_ciclo_escolar=iCicloEscolar
					    , idu_grado_escolar=iGrado 
					    , idu_carrera=iCarrera 
					    , fec_registro = now()
					    , idu_empleado_registro = iCapturo
				WHERE 	idu_configuracion=iConfiguracion;
			END IF;
			
			resultado:=1;
		END IF;	
		
	END IF;
	RETURN resultado;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_beneficiario_escuela_escolaridad(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer) IS 'La función graba los estudios de los beneficiarios.';
