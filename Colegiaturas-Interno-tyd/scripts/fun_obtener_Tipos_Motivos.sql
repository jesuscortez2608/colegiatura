CREATE TYPE type_cat_tipos_motivos AS
   (idu_tipo_motivo integer,
    des_tipo_motivo character varying(30));

CREATE OR REPLACE FUNCTION fun_obtener_tipos_motivos()
  RETURNS SETOF type_cat_tipos_motivos AS
$BODY$
DECLARE
  registros type_cat_tipos_motivos;
   /*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Descripción del funcionamiento : Consulta los tipos de motivos de la tabla cat_tipos_motivos
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Motivos
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_Tipos_Motivos();	
	*/  
BEGIN
	FOR registros IN SELECT idu_tipo_motivo, des_tipo_motivo from cat_tipos_motivos order by idu_tipo_motivo 
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_tipos_motivos() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_motivos() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_motivos() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_motivos() TO postgres;
COMMENT ON FUNCTION fun_obtener_tipos_motivos() IS 'OBTIENE LOS TIPOS DE MOTIVOS DE RECHAZO Y ACLARACION PARA COLEGIATURAS';
