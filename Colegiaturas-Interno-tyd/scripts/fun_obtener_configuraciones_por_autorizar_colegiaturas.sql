DROP FUNCTION IF EXISTS fun_obtener_configuraciones_por_autorizar_colegiaturas(integer, integer, integer, character varying, character varying, character varying, integer);
DROP TYPE IF EXISTS type_obtener_configuraciones_por_autorizar_colegiaturas;

CREATE TYPE type_obtener_configuraciones_por_autorizar_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    iclave integer,
    num_empleado integer,
    nom_empleado character varying(150),
    num_beneficiario integer,
    nom_beneficiario character varying(100),
    num_parentesco integer,
    nom_parentesco character varying(50),
    num_escuela integer,
    nom_escuela character varying(100),
    num_escolaridad integer,
    nom_escolaridad character varying(50),
    num_grado integer,
    nom_grado character varying(50),
    imp_inscripcion integer,
    imp_colegiatura integer,
    estatus integer,
    fec_marco_estatus timestamp without time zone,
    ciclo integer,
    archivo character varying(60));

CREATE OR REPLACE FUNCTION fun_obtener_configuraciones_por_autorizar_colegiaturas(integer, integer, integer, character varying, character varying, character varying, integer)
  RETURNS SETOF type_obtener_configuraciones_por_autorizar_colegiaturas AS
$BODY$
DECLARE

     /*
     No. petición APS               : 8613.1
     Fecha                          : 17/11/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento :
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Colegiaturas
     Ejemplo                        : Obtiene los datos de las configuraciones de costos pendientes por autorizar
	select * from  fun_obtener_configuraciones_por_autorizar_colegiaturas(93902761,10, 1, 'iclave', 'desc', 
	'iclave,num_empleado,nom_empleado,num_beneficiario,nom_beneficiario,num_parentesco,nom_parentesco,num_escuela,nom_escuela,num_escolaridad,nom_escolaridad,num_grado,nom_grado,imp_inscripcion,imp_colegiatura,estatus,fec_marco_estatus'
	,0)

  ------------------------------------------------------------------------------------------------------ */
     iNumEmp ALIAS FOR $1;
     iRowsPerPage ALIAS FOR $2;
     iCurrentPage ALIAS FOR $3;
     sOrderColumn ALIAS FOR $4;
     sOrderType ALIAS FOR $5;
     sColumns ALIAS FOR $6;
     iFiltro ALIAS FOR $7;
     iStart INTEGER;
     iRecords INTEGER;
     iTotalPages INTEGER;
     sConsulta VARCHAR(3000);
     col RECORD;
      
     returnrec type_obtener_configuraciones_por_autorizar_colegiaturas;
     
BEGIN

    create local temp table tmp_costo_colegiaturas_por_autorizar
    (   
         iclave INTEGER
        ,num_empleado INTEGER
        ,nom_empleado VARCHAR(150)
        ,num_beneficiario INTEGER
        ,nom_beneficiario VARCHAR(100)
        ,num_parentesco INTEGER
        ,nom_parentesco VARCHAR(50)
        ,num_escuela INTEGER
        ,nom_escuela VARCHAR(100) 
        ,num_escolaridad INTEGER
        ,nom_escolaridad VARCHAR(50) 
        ,num_grado INTEGER
        ,nom_grado VARCHAR(50)
        ,imp_inscripcion INTEGER
        ,imp_colegiatura INTEGER
        ,estatus INTEGER
        ,fec_marco_estatus TIMESTAMP
        ,hoja_azul integer
        , ciclo integer
        ,archivo varchar(60)

    ) on commit drop;    

	IF (iFiltro = 1) THEN 
	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE MOV_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas_por_autorizar (iclave,num_empleado,num_beneficiario,num_parentesco,num_escuela,
	num_escolaridad,num_grado,imp_inscripcion,imp_colegiatura,estatus,fec_marco_estatus,hoja_azul, ciclo,archivo)
	select idu_costo,idu_empleado,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,
	imp_colegiatura,estatus_configuracion,fec_marco_estatus, beneficiario_hoja_azul, idu_ciclo_escolar, nom_archivo_alfresco
	from mov_configuracion_costos 
	where idu_empleado=iNumEmp;

	ELSIF (iFiltro = 2) THEN 
	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE HIS_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas_por_autorizar (iclave,num_empleado,num_beneficiario,num_parentesco,num_escuela,
	num_escolaridad,num_grado,imp_inscripcion,imp_colegiatura,estatus,fec_marco_estatus,hoja_azul, ciclo,archivo)
	select idu_costo,idu_empleado,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,
	imp_colegiatura,estatus_configuracion,fec_marco_estatus, beneficiario_hoja_azul, idu_ciclo_escolar, nom_archivo_alfresco
	from his_configuracion_costos 
	where idu_empleado=iNumEmp;

	ELSIF (iFiltro = 0) THEN 

	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE MOV_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas_por_autorizar (iclave,num_empleado,num_beneficiario,num_parentesco,num_escuela,
	num_escolaridad,num_grado,imp_inscripcion,imp_colegiatura,estatus,fec_marco_estatus, hoja_azul, ciclo,archivo)
	select idu_costo,idu_empleado,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,
	imp_colegiatura,estatus_configuracion,fec_marco_estatus, beneficiario_hoja_azul,idu_ciclo_escolar, nom_archivo_alfresco
	from mov_configuracion_costos 
	where idu_empleado=iNumEmp;

	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE HIS_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas_por_autorizar (iclave,num_empleado,num_beneficiario,num_parentesco,num_escuela,
	num_escolaridad,num_grado,imp_inscripcion,imp_colegiatura,estatus,fec_marco_estatus, hoja_azul,  ciclo,archivo)
	select idu_costo,idu_empleado,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,
	imp_colegiatura,estatus_configuracion,fec_marco_estatus, beneficiario_hoja_azul, idu_ciclo_escolar, nom_archivo_alfresco
	from his_configuracion_costos 
	where idu_empleado=iNumEmp;

	END IF;	

	--INSERTA NOMBRE EMPLEADO
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_empleado = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
	from sapcatalogoempleados b 
	where CAST(tmp_costo_colegiaturas_por_autorizar.num_empleado AS text) = b.numemp;

	--INSERTA DATOS BENEFICIARIOS HOJA AZUL
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_beneficiario = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
	from sapfamiliarhojas b 
	where tmp_costo_colegiaturas_por_autorizar.num_beneficiario = b.keyx
	and tmp_costo_colegiaturas_por_autorizar.num_empleado = b.numemp and tmp_costo_colegiaturas_por_autorizar.hoja_azul=1; 

	
	--INSERTA DATOS BENEFICIARIOS
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_beneficiario = (b.nom_beneficiario || ' ' || b.ape_paterno || ' ' || b.ape_materno)
	from cat_beneficiarios_colegiaturas b 
	where tmp_costo_colegiaturas_por_autorizar.num_beneficiario = b.idu_beneficiario 
	and tmp_costo_colegiaturas_por_autorizar.num_empleado = b.idu_empleado and tmp_costo_colegiaturas_por_autorizar.hoja_azul=0;

	--INSERTA DATOS PARENTESCO
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_parentesco = case when tmp_costo_colegiaturas_por_autorizar.num_parentesco=11 then 'EL(ELLA) MISMO(A)' else c.des_parentesco  end
	from cat_parentescos c 
	where tmp_costo_colegiaturas_por_autorizar.num_parentesco = c.idu_parentesco;
	
	--INSERTA DATOS ESCUELA
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_escuela=d.nom_escuela
	from cat_escuelas_colegiaturas d
	where tmp_costo_colegiaturas_por_autorizar.num_escuela = d.idu_escuela;

	--INSERTA DATOS ESCOLARIDAD
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_escolaridad=e.nom_escolaridad
	from cat_escolaridades e
	where tmp_costo_colegiaturas_por_autorizar.num_escolaridad = e.idu_escolaridad;

	--INSERTA GRADO ESCOLAR
	update tmp_costo_colegiaturas_por_autorizar 
	set nom_grado=f.nom_grado_escolar
	from cat_grados_escolares f
	where tmp_costo_colegiaturas_por_autorizar.num_escolaridad = f.idu_escolaridad
	and tmp_costo_colegiaturas_por_autorizar.num_grado = f.idu_grado_escolar;

	sConsulta := '';
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
	    iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
	    iRecords := (SELECT COUNT(*) FROM tmp_costo_colegiaturas_por_autorizar);
	    iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
    
		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_costo_colegiaturas_por_autorizar
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
               
       ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_costo_colegiaturas_por_autorizar ';
      END if;
        sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
        
        RAISE NOTICE 'notice %', sConsulta;

    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;