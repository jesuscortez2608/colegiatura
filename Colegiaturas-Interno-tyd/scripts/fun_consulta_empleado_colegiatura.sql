DROP FUNCTION IF EXISTS fun_consulta_empleado_colegiatura(integer);
DROP TYPE IF EXISTS type_datosempleadocolegiatura;

CREATE TYPE type_datosempleadocolegiatura AS
   (especial integer,
    limitado integer,
    bloqueado integer,
    fec_registro date);

CREATE OR REPLACE FUNCTION fun_consulta_empleado_colegiatura(integer)
  RETURNS SETOF type_datosempleadocolegiatura AS
$BODY$
DECLARE
	iEmpleado  ALIAS FOR $1;
	registros type_datosempleadocolegiatura;
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 19/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Obtiene los datos del empleado bloqueado, limitado y cheque
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_consulta_empleado_colegiatura(98439677);
	----------------------------------------------------------------------------------------------
	     Peticion			: 16559.1
	     Fecha			: 28/11/2018
	     Colaborador		: 98439677 Rafael Ramos
	     Descripcion del cambio	: Se agrega la fecha de registro del colaborador al momento en que se le dio la prestacion de colegiaturas, agregandole 1 dia.
	*/
BEGIN
	
	IF EXISTS(Select idu_empleado from cat_empleados_colegiaturas where idu_empleado=iEmpleado) THEN
		FOR registros IN SELECT opc_especial, opc_limitado, opc_empleado_bloqueado, ( fec_registro::DATE + INTERVAL '1 day' )::DATE AS fec_registro from cat_empleados_colegiaturas where idu_empleado = iEmpleado
		LOOP
			RETURN NEXT registros;
		END LOOP;
	/*ELSE
		FOR registros IN SELECT 0, 1, 0
		LOOP
			RETURN NEXT registros;
		END LOOP;*/
	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consulta_empleado_colegiatura(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consulta_empleado_colegiatura(integer) TO syspersonal;
COMMENT ON FUNCTION fun_consulta_empleado_colegiatura(integer) IS 'La función obtiene los datos del colaborador de cuando se agrego como registro en la tabla cat_empleados_colegiaturas';