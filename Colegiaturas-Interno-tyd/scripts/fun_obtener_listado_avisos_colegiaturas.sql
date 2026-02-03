DROP FUNCTION IF EXISTS fun_obtener_listado_avisos_colegiaturas();
DROP TYPE IF EXISTS type_fun_obtener_listado_avisos_colegiaturas;

CREATE TYPE type_fun_obtener_listado_avisos_colegiaturas AS
   (idu_aviso integer,
    des_aviso character varying(200),
    idu_opcion integer,
    des_opcion character varying(100),
    fec_ini timestamp without time zone,
    fec_fin timestamp without time zone,
    indefinido integer,
    empleado_capturo integer,
    nom_empleado character varying(50));

CREATE OR REPLACE FUNCTION fun_obtener_listado_avisos_colegiaturas()
  RETURNS SETOF type_fun_obtener_listado_avisos_colegiaturas AS
$BODY$
DECLARE
     /*
     No. petición APS               : 8613.1
     Fecha                          : 19/09/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento :
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Colegiaturas
     Ejemplo                        : Trae los datos para llenar el grid en configuracion de avisos para colaborador
	select * from fun_obtener_listado_avisos_colegiaturas();

  ------------------------------------------------------------------------------------------------------ */
     sConsulta VARCHAR(3000);
     returnrec type_fun_obtener_listado_avisos_colegiaturas;
BEGIN

    create local temp table tmp_avisos_colegiaturas
    (
        idu_aviso INTEGER
        ,des_aviso VARCHAR(200)
        ,idu_opcion integer
        ,des_opcion VARCHAR(100)
        ,fec_ini TIMESTAMP
        ,fec_fin TIMESTAMP
        ,indefinido INTEGER
        ,empleado_capturo INTEGER
        ,nom_empleado character varying(50)
    ) on commit drop;

	--INSERTA DATOS EN TABLA TEMPORAL
	INSERT INTO tmp_avisos_colegiaturas (idu_aviso,des_aviso,idu_opcion,fec_ini,fec_fin,indefinido,empleado_capturo)
	select idu_aviso,des_aviso,idu_opcion, fec_inicial,fec_final,opc_indefinido, idu_empleado_registro
	from mov_avisos_colegiaturas;
	
	--INSERTA DESCRIPCION DE OPCIONES DE COLEGIATURAS
	UPDATE tmp_avisos_colegiaturas 
	SET des_opcion = b.nom_opcion
	from mov_opciones_colegiaturas b
	where tmp_avisos_colegiaturas.idu_opcion = b.idu_opcion;

	UPDATE tmp_avisos_colegiaturas
	SET nom_empleado = (TRIM(e.nombre)||' '||TRIM(e.apellidopaterno)||' '||TRIM(e.apellidomaterno))
	FROM sapcatalogoempleados e
	WHERE tmp_avisos_colegiaturas.empleado_capturo = e.numempn;
	
	sConsulta:='select * from tmp_avisos_colegiaturas order by idu_opcion, idu_aviso';
	for returnrec in execute sConsulta loop
	RETURN NEXT returnrec;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE security definer;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_avisos_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_avisos_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_avisos_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_avisos_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_avisos_colegiaturas() IS 'La función obtiene el listado de avisos para llenar el grid en la opción de configuración de avisos para colaboradores';
