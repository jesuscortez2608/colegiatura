--DROP FUNCTION IF EXISTS fun_obtener_estatus_facturas();
DROP FUNCTION IF EXISTS fun_obtener_estatus_facturas(INTEGER);
DROP TYPE IF EXISTS type_obtener_estatus_facturas;

CREATE TYPE type_obtener_estatus_facturas AS
   (estatus integer,
    nom_estatus character varying(30));
    
CREATE OR REPLACE FUNCTION fun_obtener_estatus_facturas(INTEGER)
  RETURNS SETOF type_obtener_estatus_facturas AS
$BODY$
declare 
	iTipo ALIAS FOR $1;
	registros type_obtener_estatus_facturas;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 05/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Regresa el catalogo de estatus de las facturas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Facturas
	     Ejemplo                        : 
		 select * from fun_obtener_estatus_facturas (0); -- eststus facturas
		 select * from fun_obtener_estatus_facturas (1); -- estatus reportes 
	*/
BEGIN


	FOR registros IN (SELECT idu_estatus, trim(nom_estatus) FROM CAT_ESTATUS_FACTURAS WHERE idu_tipo_estatus=iTipo order by idu_estatus) 
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_estatus_facturas(INTEGER) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_facturas(INTEGER) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_facturas(INTEGER) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_estatus_facturas(INTEGER) TO postgres;
