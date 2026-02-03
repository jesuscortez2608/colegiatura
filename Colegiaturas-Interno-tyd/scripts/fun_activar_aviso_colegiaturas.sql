CREATE TYPE type_activar_aviso_colegiaturas AS
   (idu_aviso integer,
    mensaje text);

CREATE OR REPLACE FUNCTION fun_activar_aviso_colegiaturas(integer)
  RETURNS SETOF type_activar_aviso_colegiaturas AS
$BODY$
declare
	iOpcion ALIAS FOR $1;

	registros type_activar_aviso_colegiaturas;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 14/12/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Regresa los avisos para mostrar de una opcion
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : 
	     Ejemplo                        : select * from fun_activar_aviso_colegiaturas (1);
		 Tabla(s)						: mov_avisos_colegiaturas
		 ------------------------------------------------------
	*/

BEGIN

FOR registros IN (
		select idu_aviso, trim(des_aviso) from mov_avisos_colegiaturas
		where (cast(now() as date) between fec_inicial and fec_final or opc_indefinido=1) and (idu_opcion=iOpcion or idu_opcion=0)
		order by idu_aviso
		) LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_activar_aviso_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_activar_aviso_colegiaturas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_activar_aviso_colegiaturas(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_activar_aviso_colegiaturas(integer) TO postgres;
COMMENT ON FUNCTION fun_activar_aviso_colegiaturas(integer) IS 'La función obtiene los avisos activos para los colaboradores a partir de una opción del sistema.';
