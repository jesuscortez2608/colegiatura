DROP FUNCTION IF EXISTS fun_obtener_configuraciones_de_costos_por_empleado(integer, integer, integer, character varying, character varying, character varying);
DROP TYPE IF EXISTS type_obtener_configuracion_costo_colegiatura;

CREATE TYPE type_obtener_configuracion_costo_colegiatura AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    iclave integer,
    ibeneficiario integer,
    sbeneficiario character varying(150),
    iparentesco integer,
    sparentesco character varying(50),
    iescuela integer,
    sescuela character varying(100),
    iescolaridad integer,
    sescolaridad character varying(50),
    igrado integer,
    sgrado character varying(50),
    iinscripcion numeric(12,2),
    icolegiatura numeric(12,2),
    iestatus integer,
    fec_marco_estatus timestamp without time zone,
    arc_costo character varying(100),
    ciclo integer,
    archivo character varying(60));

    
CREATE OR REPLACE FUNCTION fun_obtener_configuraciones_de_costos_por_empleado(integer, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_obtener_configuracion_costo_colegiatura AS
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
     Ejemplo                        : 
	select * from  fun_obtener_configuraciones_de_costos_por_empleado(93902761 ,10, 1, 'iEstatus', 'desc',
							'iClave, iBeneficiario, sBeneficiario, iparentesco, sParentesco, iEscuela,sEscuela,iEscolaridad,sEscolaridad,iGrado,sGrado,iInscripcion,iColegiatura,iEstatus,fec_marco_estatus, ciclo, archivo')

	SELECT records
			, page
			, pages
			, id
			, iClave
			,iBeneficiario
			,sBeneficiario
			,iparentesco
			,sParentesco
			,iEscuela		
			,sEscuela	
			,iEscolaridad
			,sEscolaridad
			,iGrado
			,sGrado
			,iInscripcion
			,iColegiatura
			,iEstatus
			,fec_marco_estatus
			,arc_costo
			,ciclo
			,archivo
		FROM fun_obtener_configuraciones_de_costos_por_empleado(
			93902761::integer
 			, 20::integer
			, 1::integer			
			, 'iEstatus,fec_marco_estatus'
			, 'desc'
			, 'iClave,iBeneficiario,sBeneficiario,iparentesco,sParentesco ,iEscuela,sEscuela,iEscolaridad,sEscolaridad
,iGrado,sGrado,iInscripcion,iColegiatura, iEstatus, fec_marco_estatus, arc_costo, ciclo, archivo')


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
 
     returnrec type_obtener_configuracion_costo_colegiatura;
BEGIN

    create local temp table tmp_costo_colegiaturas
    (   
         iclave INTEGER
        ,ibeneficiario INTEGER
        ,sbeneficiario VARCHAR(150)
        ,iparentesco INTEGER
        ,sparentesco VARCHAR(50)
        ,iescuela INTEGER
        ,sescuela VARCHAR(100) 
        ,iescolaridad INTEGER
        ,sescolaridad VARCHAR(50) 
        ,igrado INTEGER
        ,sgrado VARCHAR(50)
        ,iinscripcion numeric(12,2)
        ,icolegiatura numeric(12,2)
        ,iestatus INTEGER
        ,num_empleadoAutorizo INTEGER
        ,fec_marco_estatus TIMESTAMP
        ,id_hojaazul integer
        ,arc_costo VARCHAR(100) not null default ''
	,ciclo integer
	,archivo character varying(60)
    ) on commit drop;

	--INSERTA CLAVE, ID_BENEFICIARIO,ID_ESCUELA, ID_ESCOLARIDAD, ID_GRADO, INSCRIPCION, COLEGIATURA Y ESTATUS DE MOV_CONFIGURACION_COSTOS
	INSERT INTO tmp_costo_colegiaturas (iClave,iBeneficiario,iparentesco,iEscuela,iEscolaridad,iGrado,iInscripcion,iColegiatura,iEstatus, num_empleadoAutorizo, fec_marco_estatus, id_hojaazul, ciclo, archivo)
	select idu_costo, idu_beneficiario, idu_parentesco, idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,imp_colegiatura,estatus_configuracion,idu_empleado,fec_marco_estatus, beneficiario_hoja_azul, idu_ciclo_escolar, nom_archivo_alfresco
	from mov_configuracion_costos 
	where idu_empleado=iNumEmp;

	INSERT INTO tmp_costo_colegiaturas (iClave,iBeneficiario,iparentesco,iEscuela,iEscolaridad,iGrado,iInscripcion,iColegiatura,iEstatus, num_empleadoAutorizo,fec_marco_estatus, id_hojaazul, ciclo, archivo)
	select idu_costo,idu_beneficiario,idu_parentesco,idu_escuela,idu_escolaridad,idu_grado_escolar,imp_inscripcion,imp_colegiatura,estatus_configuracion,idu_empleado,fec_marco_estatus, beneficiario_hoja_azul, idu_ciclo_escolar, nom_archivo_alfresco
	from his_configuracion_costos 
	where idu_empleado= iNumEmp;

	--INSERTA DATOS BENEFICIARIOS HOJA AZUL
	update tmp_costo_colegiaturas 
	set sbeneficiario = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
	from sapfamiliarhojas b 
	where tmp_costo_colegiaturas.ibeneficiario = b.keyx
	and tmp_costo_colegiaturas.num_empleadoAutorizo = b.numemp and tmp_costo_colegiaturas.id_hojaazul=1 and tmp_costo_colegiaturas.num_empleadoAutorizo=iNumEmp; 


	--INSERTA DATOS BENEFICIARIOS
	update tmp_costo_colegiaturas 
	set sbeneficiario = (b.nom_beneficiario || ' ' || b.ape_paterno || ' ' || b.ape_materno)
	from cat_beneficiarios_colegiaturas b 
	where tmp_costo_colegiaturas.ibeneficiario = b.idu_beneficiario 
	and tmp_costo_colegiaturas.num_empleadoAutorizo = b.idu_empleado and tmp_costo_colegiaturas.id_hojaazul=0 and tmp_costo_colegiaturas.num_empleadoAutorizo=iNumEmp; 


	--INSERTA DATOS PARENTESCO
	update tmp_costo_colegiaturas 
	set sparentesco = case when iparentesco=11 then 'EL(ELLA) MISMO(A)' ELSE  c.des_parentesco  END
	from cat_parentescos c 
	where tmp_costo_colegiaturas.iparentesco = c.idu_parentesco;

	--INSERTA DATOS ESCUELA
	update tmp_costo_colegiaturas 
	set sescuela=d.nom_escuela
	from cat_escuelas_colegiaturas d
	where tmp_costo_colegiaturas.iescuela = d.idu_escuela;

	--INSERTA DATOS ESCOLARIDAD
	update tmp_costo_colegiaturas 
	set sescolaridad=e.nom_escolaridad
	from cat_escolaridades e
	where tmp_costo_colegiaturas.iescolaridad = e.idu_escolaridad;

	--INSERTA GRADO ESCOLAR
	update tmp_costo_colegiaturas 
	set sgrado=f.nom_grado_escolar
	from cat_grados_escolares f
	where tmp_costo_colegiaturas.iescolaridad = f.idu_escolaridad
	and tmp_costo_colegiaturas.igrado = f.idu_grado_escolar;

	---ACTUALIZA SI TIENE ARCHIVO
	UPDATE tmp_costo_colegiaturas 
	SET arc_costo = '<font color="#00A400" size="4"><strong>&#8730;</strong></font>'
	WHERE TRIM(archivo)!='';

	sConsulta := '';
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
	    iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
	    iRecords := (SELECT COUNT(*) FROM tmp_costo_colegiaturas);
	    iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
    
		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_costo_colegiaturas
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
               
       ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_costo_colegiaturas ';
      END if;
        sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
        
        RAISE NOTICE 'notice %', sConsulta;

    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;