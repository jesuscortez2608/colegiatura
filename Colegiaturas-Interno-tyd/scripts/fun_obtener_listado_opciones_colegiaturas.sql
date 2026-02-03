CREATE TYPE type_fun_obtener_listado_opciones_colegiaturas AS
   (idu_opcion integer,
    snom_opcion character varying(100)
	);

CREATE OR REPLACE FUNCTION fun_obtener_listado_opciones_colegiaturas()
  RETURNS SETOF type_fun_obtener_listado_opciones_colegiaturas AS
$BODY$
DECLARE
     /*
     No. petición APS               : 8613.1
     Fecha                          : 01/11/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : Obtiene Datos para combo opcion de configuración de avisos
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Colegiaturas
     Ejemplo                        :
	select * from fun_obtener_listado_opciones_colegiaturas()
	------------------------------------------------------
	 No. peticion APS				: 16559.1
	 Servidor de produccion			: 10.44.2.183
	 Servidor de pruebas			: 10.44.114.75

  ------------------------------------------------------------------------------------------------------ */
	registros type_fun_obtener_listado_opciones_colegiaturas;
	begin

		FOR registros IN 

			select idu_opcion, nom_opcion
			from mov_opciones_colegiaturas
		LOOP
		RETURN NEXT registros;
		END LOOP;
		RETURN ;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_listado_opciones_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_opciones_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_opciones_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_opciones_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_opciones_colegiaturas() IS 'La función obtiene un listado de opciones de colegiaturas donde se mostrarán los avisos a los colaboradores.';