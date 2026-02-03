DROP FUNCTION IF EXISTS fun_obtener_listado_motivos(integer);
DROP TYPE IF EXISTS type_catmotivoscolegiaturas;

CREATE TYPE type_catmotivoscolegiaturas AS
   (idu_motivo integer,
    des_motivo character varying(100),
    idu_tipo_motivo integer,
    des_tipo_motivo character varying(35),
    fec_captura character varying(10),
    nom_empleado character varying(170),
    estatus character varying(15));

CREATE OR REPLACE FUNCTION fun_obtener_listado_motivos(integer)
  RETURNS SETOF type_catmotivoscolegiaturas AS
$BODY$
DECLARE
	nOpcion alias for $1;
	registros type_catMotivosColegiaturas;
  /*
     No. petición APS               : 8613.1
     Fecha                          : 02/09/2016
     Número empleado                : 93902761
     Nombre del empleado            : Nallely Machado
     Base de datos                  : administracion
     Servidor de pruebas            : 10.44.15.182
     Servidor de produccion         : 10.44.2.24
     Descripción del funcionamiento : Regresa los motivos que estan en la tabla cat_motivos_colegiaturas
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Motivos
     Ejemplo                        : 
         SELECT * FROM fun_obtener_Listado_Motivos(0);	
         SELECT * FROM fun_obtener_Listado_Motivos(1);
         SELECT * FROM fun_obtener_Listado_Motivos(2);
         
*/

BEGIN
	CREATE TEMPORARY TABLE tmp_motivos
	(
		idu_motivo integer,
		des_motivo character varying(100),
		idu_tipo_motivo integer,
		des_tipo_motivo character varying(35),
		fec_captura character varying(10),
		idu_empleado integer,
		nom_empleado character varying(160),
		estatus character varying(15)
	)on commit drop;

	if nOpcion=0 then --todos los motivos

		INSERT INTO tmp_motivos (idu_motivo, des_motivo, idu_tipo_motivo, fec_captura,idu_empleado, estatus )
		SELECT idu_motivo, des_motivo, idu_tipo_motivo,to_char(fec_captura,'dd/MM/yyyy'),idu_empleado_registro, case when estatus=1 THEN 'ACTIVO' ELSE 'BLOQUEADO' END 
		FROM cat_motivos_colegiaturas;
	else
		INSERT INTO tmp_motivos (idu_motivo, des_motivo, idu_tipo_motivo, fec_captura,idu_empleado, estatus )
		SELECT idu_motivo, des_motivo, idu_tipo_motivo,to_char(fec_captura,'dd/MM/yyyy'),idu_empleado_registro, case when estatus=1 THEN 'ACTIVO' ELSE 'BLOQUEADO' END 
		FROM cat_motivos_colegiaturas where estatus=1 and idu_tipo_motivo=nOpcion;
	end if; 


	UPDATE tmp_motivos SET des_tipo_motivo=TRIM(a.des_tipo_motivo) from cat_tipos_motivos a WHERE a.idu_tipo_motivo=tmp_motivos.idu_tipo_motivo;

	UPDATE tmp_motivos SET nom_empleado=a.numemp||' '||TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno) 
	from sapcatalogoempleados a WHERE a.numempn=tmp_motivos.idu_empleado;

	FOR registros IN 
		SELECT idu_motivo,des_motivo,idu_tipo_motivo,des_tipo_motivo,fec_captura,nom_empleado, estatus  FROM tmp_motivos ORDER BY idu_motivo 
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_motivos(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_motivos(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_motivos(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_motivos(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_motivos(integer) IS 'FUNCION PARA OBTENER EL LISTADO DE MOTIVOS.';
