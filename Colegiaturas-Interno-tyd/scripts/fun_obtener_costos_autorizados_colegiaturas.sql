drop function if exists fun_obtener_costos_autorizados_colegiaturas(integer, integer, integer, character varying, character varying, character varying);
drop type if exists type_obtener_costos_autorizados_colegiaturas;

CREATE TYPE type_obtener_costos_autorizados_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    iclave integer,
    num_beneficiario integer,
    nom_beneficiario character varying(150),
    num_parentesco integer,
    nom_parentesco character varying(50),
    num_escuela integer,
    nom_escuela character varying(100),
    rfc_escuela character varying(20),
    num_escolaridad integer,
    nom_escolaridad character varying(50),
    num_grado integer,
    nom_grado character varying(50),
    imp_inscripcion NUMERIC(12,2),
    imp_colegiatura NUMERIC(12,2),
    arc_costo character varying(100),
    fec_movimiento timestamp without time zone,
    num_gerente_autorizo integer,
    nom_gerente_autorizo character varying(150),
    nom_archivo character varying(60),
    idu_ciclo_escolar integer);
   
CREATE OR REPLACE FUNCTION fun_obtener_costos_autorizados_colegiaturas(integer, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_obtener_costos_autorizados_colegiaturas AS
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
     Ejemplo                        : Obtiene los datos de las configuraciones de costos autorizaradas por gerente

	select * from fun_obtener_costos_autorizados_colegiaturas(96777915,-1, -1, 'iclave', 'desc', 
	'*')

	
  ------------------------------------------------------------------------------------------------------ */
     iNumEmp ALIAS FOR $1;
     iRowsPerPage ALIAS FOR $2;
     iCurrentPage ALIAS FOR $3;
     sOrderColumn ALIAS FOR $4;
     sOrderType ALIAS FOR $5;
     sColumns ALIAS FOR $6;
     iStart INTEGER;
     iRecords INTEGER;
     iTotalPages INTEGER;
     sConsulta VARCHAR(3000);
     col RECORD;
     hojaazul INTEGER;
     
     returnrec type_obtener_costos_autorizados_colegiaturas;
     
BEGIN

	IF iRowsPerPage = -1 then
        iRowsPerPage := NULL;
	end if;
	if iCurrentPage = -1 then
        iCurrentPage := NULL;
	end if;
	
    create local temp table tmp_costo_colegiaturas_autorizadas
    (   
         iclave INTEGER not null default 0
        ,num_beneficiario INTEGER not null default 0
        ,nom_beneficiario VARCHAR(150) not null default ''
        ,num_parentesco INTEGER not null default 0
        ,nom_parentesco VARCHAR(50) not null default ''
        ,num_escuela INTEGER not null default 0
        ,nom_escuela VARCHAR(100) not null default ''
        ,rfc_escuela VARCHAR(20) not null default ''
        ,num_escolaridad INTEGER not null default 0
        ,nom_escolaridad VARCHAR(50) not null default ''
        ,num_grado INTEGER not null default 0
        ,nom_grado VARCHAR(50) not null default ''
        ,imp_inscripcion NUMERIC(12,2) NOT NULL default 0
        ,imp_colegiatura NUMERIC(12,2) NOT NULL default 0
        ,arc_costo VARCHAR(100) not null default ''
        ,fec_movimiento TIMESTAMP not null default '19000101'
        ,num_gerente_autorizo INTEGER not null default 0
        ,nom_gerente_autorizo VARCHAR(150) not null default ''
        ,nom_archivo varchar(60)
        ,idu_ciclo_escolar integer
        ,id_hojaazul integer

    ) on commit drop;    
	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE MOV_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas_autorizadas 
	(iclave,num_beneficiario,num_parentesco,num_escuela,num_escolaridad,num_grado,
	imp_inscripcion,imp_colegiatura,fec_movimiento,num_gerente_autorizo,id_hojaazul,  nom_archivo, idu_ciclo_escolar)
	select idu_costo,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,
	imp_colegiatura,fec_marco_estatus,idu_marco_estatus,beneficiario_hoja_azul, nom_archivo_alfresco, idu_ciclo_escolar
	FROM his_configuracion_costos
	WHERE idu_empleado=iNumEmp;
 
	--INSERTA DATOS BENEFICIARIOS HOJA AZUL
	update tmp_costo_colegiaturas_autorizadas 
	set nom_beneficiario = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
	from sapfamiliarhojas b 
	where tmp_costo_colegiaturas_autorizadas.num_beneficiario = b.keyx
	and tmp_costo_colegiaturas_autorizadas.id_hojaazul=1; 

	--INSERTA DATOS BENEFICIARIOS cat_beneficiarios_colegiaturas
	update tmp_costo_colegiaturas_autorizadas 
	set nom_beneficiario = (b.nom_beneficiario || ' ' || b.ape_paterno || ' ' || b.ape_materno)
	from cat_beneficiarios_colegiaturas b 
	where tmp_costo_colegiaturas_autorizadas.num_beneficiario = b.idu_beneficiario 
	and b.idu_empleado = iNumEmp and tmp_costo_colegiaturas_autorizadas.id_hojaazul=0; 

	--INSERTA DATOS PARENTESCO
	update tmp_costo_colegiaturas_autorizadas 
	set nom_parentesco = case when tmp_costo_colegiaturas_autorizadas.num_parentesco=11 then 'EL(ELLA) MISMO(A)' else c.des_parentesco  end 
	from cat_parentescos c 
	where tmp_costo_colegiaturas_autorizadas.num_parentesco = c.idu_parentesco;
	
	--INSERTA DATOS ESCUELA
	update tmp_costo_colegiaturas_autorizadas 
	set nom_escuela=d.nom_escuela
	from cat_escuelas_colegiaturas d
	where tmp_costo_colegiaturas_autorizadas.num_escuela = d.idu_escuela;

	--INSERTA DATOS ESCOLARIDAD
	update tmp_costo_colegiaturas_autorizadas 
	set nom_escolaridad=e.nom_escolaridad
	from cat_escolaridades e
	where tmp_costo_colegiaturas_autorizadas.num_escolaridad = e.idu_escolaridad;

	--INSERTA GRADO ESCOLAR
	update tmp_costo_colegiaturas_autorizadas 
	set nom_grado=f.nom_grado_escolar
	from cat_grados_escolares f
	where tmp_costo_colegiaturas_autorizadas.num_escolaridad = f.idu_escolaridad
	and tmp_costo_colegiaturas_autorizadas.num_grado = f.idu_grado_escolar;

	--INSERTA NOMBRE GERENTE
	update tmp_costo_colegiaturas_autorizadas 
	set nom_gerente_autorizo = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
	from sapcatalogoempleados b 
	where CAST(tmp_costo_colegiaturas_autorizadas.num_gerente_autorizo AS text) = b.numemp;

	--INSERTA RFC ESCUELA
	update tmp_costo_colegiaturas_autorizadas 
	set rfc_escuela = b.rfc_clave_sep
	from cat_escuelas_colegiaturas b
	where tmp_costo_colegiaturas_autorizadas.num_escuela = b.idu_escuela;

	---ACTUALIZA SI TIENE ARCHIVO
	update tmp_costo_colegiaturas_autorizadas 
	set arc_costo='<font color="#00A400" size="4"><b>&#8730;</b></font>'
	WHERE  TRIM(nom_archivo)!='';

	sConsulta := '';
	iRecords := (SELECT COUNT(*) FROM tmp_costo_colegiaturas_autorizadas);	
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
	    iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
	    iRecords := (SELECT COUNT(*) FROM tmp_costo_colegiaturas_autorizadas);
	    iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
    
		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_costo_colegiaturas_autorizadas
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
               
       ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_costo_colegiaturas_autorizadas ';
      END if;
        sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
        
        RAISE NOTICE 'notice %', sConsulta;

    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;