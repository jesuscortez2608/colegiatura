CREATE OR REPLACE FUNCTION fun_obtener_escuelas_revision(
IN ipage integer, 
IN ilimit integer, 
IN iconexion integer, 
IN iestado integer, 
IN imunicipio integer, 
IN ilocalidad integer, 
IN imotivo integer, 
IN iestatus_revision integer, 
IN imensaje integer, 
IN snom_escuela character varying, 
IN iescolaridad integer, 
IN srfc character varying, 
IN srazon_social character varying, 
IN sclave_sep character varying, 
IN iopcfechas integer, 
IN dfec_ini character varying, 
IN dfec_fin character varying, 
OUT records integer, 
OUT page integer, 
OUT pages integer, 
OUT id integer, 
OUT irevision integer, 
OUT sfecha_pendiente character, 
OUT idestado integer, 
OUT snom_estado character, 
OUT idmunicipio integer, 
OUT snom_municipio character, 
OUT idlocalidad integer, 
OUT snom_localidad character, 
OUT imotivo_revision integer, 
OUT snom_motivo_revision character, 
OUT iescuela integer, 
OUT snombre_escuela character, 
OUT srazonsocial character, 
OUT idescolaridad integer, 
OUT snom_escolaridad character, 
OUT srfc_sep character, 
OUT sclavesep character, 
OUT iestatusrevision integer, 
OUT snom_estatus_revision character, 
OUT imsg_blog integer, 
OUT icarrera integer, 
OUT scarrera character)
  RETURNS SETOF record AS
$BODY$
DECLARE    
    --cNom_tipo_factura character(25);
    --dFecha timestamp;    
    sQuery TEXT;    
    valor record;    
    sColumns VARCHAR(3000);
    iStart integer;
    iRecords integer;
    iTotalPages INTEGER;    
    
    /* --------------------------------------------------------------------------------     
    No.Petición: 16559
    Fecha: 14/06/2018
    Numero Empleado: 94827443
    Nombre Empleado: Omar Alejandro Lizarraga Hernandez
    BD: personal    
    Servidor Desarrollo: 10.44.114.75
    Servidor Productivo: 10.44.2.183
    Modulo: Colegiaturas
    Repositorio: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
    --------------------------------------------------------------------------------*/    
    BEGIN
        --TABLA TMP
        CREATE TEMP TABLE tmpRevision(
            revision integer,
            fecha_pendiente VARCHAR(10),
            fechapendiente VARCHAR(10), --para el order by
            estado integer,
            nom_estado varchar(60),
            municipio integer,
            nom_municipio varchar(150),
            localidad integer,
			nom_localidad varchar(150),
            motivo_revision integer,
            nom_motivo_revision varchar(30),
            estatus_revision integer,
            nom_estatus_revision varchar(20),
            escuela integer,
            nom_escuela varchar(100),
            razon_social varchar(150),
            escolaridad integer,
            nom_escolaridad varchar(30),
            carrera integer,
            nom_carrera varchar(100),
            rfc_clave_sep varchar(20),
            clave_sep varchar(20),
            fec_captura date,                   
            msg_blog integer,
            conexion integer            
        ) ON COMMIT DROP;

        --TABLA TEMPORAL FACTURAS
       CREATE TEMP TABLE tmpfacturas(            
            idfactura integer,
            idescuela integer
        )ON COMMIT DROP;

        --TABLA TEMPORAL ESCUELAS REVISION
       CREATE TEMP TABLE tmpEscuelaRevision(
            revision integer,
            fecha_pendiente VARCHAR(10),
            fechapendiente VARCHAR(10), --para el order by
            estado integer,
            nom_estado varchar(60),
            municipio integer,
            nom_municipio varchar(150),
            localidad integer,
            nom_localidad varchar(150),
            motivo_revision integer,
            nom_motivo_revision varchar(30),
            estatus_revision integer,
            nom_estatus_revision varchar(20),
            escuela integer,
            nom_escuela varchar(100),
            razon_social varchar(150),
            escolaridad integer,
            nom_escolaridad varchar(30),
            carrera integer,
            nom_carrera varchar(100),
            rfc_clave_sep varchar(20),
            clave_sep varchar(20),
            fec_captura date,            
            msg_blog integer,
            conexion integer
        ) ON COMMIT DROP;       
        
        --ESCUELAS EN REVISION    
        sQuery := 'INSERT INTO tmpRevision (revision, fecha_pendiente, fechapendiente, estado, municipio, localidad, motivo_revision, estatus_revision, escuela, nom_escuela, razon_social,escolaridad, carrera,rfc_clave_sep, clave_sep, fec_captura, msg_blog, conexion)
            SELECT     A.idu_revision, to_char(A.fec_captura, ''dd/mm/yyyy''), to_char(A.fec_captura, ''yyyymmdd'') as fecha, B.idu_estado, B.idu_municipio, B.idu_localidad,A.idu_motivo_revision, A.idu_estatus_revision,
		 A.idu_escuela, B.nom_escuela, B.razon_social, B.idu_escolaridad, B.idu_carrera, B.rfc_clave_sep, B.clave_sep, A.fec_captura, 0, ' ||  iconexion || '
            FROM     MOV_REVISION_COLEGIATURAS A
            JOIN     CAT_ESCUELAS_COLEGIATURAS B ON A.idu_escuela=B.idu_escuela
            WHERE    to_char(A.fec_captura,''yyyymmdd'') >=  ''' || dfec_ini || ''' AND to_char(A.fec_captura,''yyyymmdd'') <=''' || dfec_fin || '''';

          --ESTADO
	IF (iestado>0) THEN
	   sQuery := sQuery || ' AND B.idu_estado=' || iestado;
	END IF;
		
		--MUNICIPIO
        IF (imunicipio>0) THEN
            sQuery := sQuery || ' AND B.idu_municipio =' || imunicipio;
        END IF;

        --LOCALIDAD
        IF (ilocalidad>0) THEN
            sQuery := sQuery || ' AND B.idu_localidad =' || ilocalidad;
        END IF;
        
        --MOTIVO REVISION
        IF (imotivo>0) THEN
            sQuery := sQuery || ' AND A.idu_motivo_revision =' || imotivo;
        END IF;

        --ESTATUS REVISION
        IF (iestatus_revision>0) THEN
            sQuery := sQuery || ' AND A.idu_estatus_revision =' || iestatus_revision;
        END IF;

        --NOMBRE ESCUELA
        IF (snom_escuela!='') THEN
            sQuery := sQuery || ' AND B.nom_escuela LIKE ''%' || snom_escuela || '%''';
        END IF;

        --RAZON SOCIAL
        IF (srazon_social!='') THEN
            sQuery := sQuery || ' AND B.razon_social LIKE ''%' || srazon_social || '%''';
        END IF;

        --ESCOLARIDAD
        IF (iescolaridad>0) THEN
            sQuery := sQuery || ' AND B.idu_escolaridad =' || iescolaridad;
        END IF;

        --RFC
        IF (srfc!='') THEN
            sQuery := sQuery || ' AND B.rfc_clave_sep LIKE ''%' || srfc || '%''';
        END IF;        
        
        --CLAVE SEP
        IF (sclave_sep!='') THEN
            sQuery := sQuery || ' AND B.clave_sep LIKE ''%' || sclave_sep || '%''';
        END IF;

	--EJECUTAR
        raise notice '%', sQuery;
        execute sQuery;

        --FACTURAS DE LAS ESCUELAS    
        INSERT  INTO tmpfacturas
        SELECT	A.id_factura, B.idu_escuela
        FROM    MOV_BLOG_REVISION A
        JOIN    MOV_FACTURAS_COLEGIATURAS B ON A.id_factura=B.idfactura;

        --MSG BLOG
        UPDATE  tmpRevision SET msg_blog=1
        FROM    tmpfacturas B
        WHERE   tmpRevision.escuela=B.idescuela;        
             

        --ESTADOS COLEGIATURAS
        UPDATE  tmpRevision SET nom_estado=B.nom_estado
        FROM    CAT_ESTADOS_COLEGIATURAS B
        WHERE   tmpRevision.estado=B.idu_estado;

        --MUNICIPIOS COLEGIATURAS
        UPDATE  tmpRevision SET nom_municipio=B.nom_municipio
        FROM    CAT_MUNICIPIOS_COLEGIATURAS B
        WHERE   tmpRevision.estado=B.idu_estado 
		AND tmpRevision.municipio=B.idu_municipio;

        --LOCALIDAD
        UPDATE  tmpRevision SET nom_localidad=B.nom_localidad
        FROM    CAT_LOCALIDADES_COLEGIATURAS B
        WHERE   tmpRevision.estado=B.idu_estado 
		AND tmpRevision.municipio=B.idu_municipio 
		AND tmpRevision.localidad=B.idu_localidad;    

        --ESCOLARIDAD
        UPDATE  tmpRevision SET nom_escolaridad=B.nom_escolaridad
        FROM    CAT_ESCOLARIDADES B
        WHERE   tmpRevision.escolaridad=B.idu_escolaridad;

        --CARRERA
        UPDATE  tmpRevision SET nom_carrera=B.nom_carrera
        FROM    CAT_CARRERAS B
        WHERE   tmpRevision.carrera=B.idu_carrera;

        --MOTIVO REVISION
        UPDATE  tmpRevision SET nom_motivo_revision=B.des_motivo
        FROM    CAT_MOTIVOS_COLEGIATURAS B        
        WHERE   tmpRevision.motivo_revision=B.idu_motivo
		AND B.idu_tipo_motivo=4;

        --ESTATUS REVISION
        UPDATE   tmpRevision SET nom_estatus_revision=des_estatus_revision
        FROM     CAT_ESTATUS_REVISION B
        where    tmpRevision.estatus_revision=idu_estatus_revision;
       
        sQuery := 'INSERT INTO tmpEscuelaRevision (revision,fecha_pendiente,fechapendiente,estado,nom_estado,municipio,nom_municipio,localidad,nom_localidad,motivo_revision,nom_motivo_revision,estatus_revision,nom_estatus_revision,escuela,nom_escuela,razon_social,escolaridad,nom_escolaridad,carrera,nom_carrera,rfc_clave_sep,clave_sep,fec_captura,msg_blog,conexion)
            SELECT revision,fecha_pendiente,fechapendiente,estado,nom_estado,municipio,nom_municipio,localidad,nom_localidad,motivo_revision,nom_motivo_revision,estatus_revision,
nom_estatus_revision,escuela,nom_escuela,razon_social,escolaridad,nom_escolaridad,carrera,nom_carrera,rfc_clave_sep,clave_sep,fec_captura,msg_blog,conexion FROM tmpRevision WHERE conexion=' || iconexion ;
       
        --MSG BLOG
        if (imensaje!=0) THEN --TODOS
            IF ((imensaje=2)) THEN
                imensaje=0;                
            END IF;
            sQuery := sQuery || ' AND msg_blog =' || imensaje;
        END IF;

        --EJECUTAR
        raise notice '%', sQuery;
        execute sQuery; 
        --
        iStart := (iLimit * iPage) - iLimit + 1;
        iRecords := (SELECT COUNT(*) FROM tmpEscuelaRevision);
        iTotalPages := ceiling(iRecords / (iLimit * 1.0));
        
        sColumns := 'revision,fecha_pendiente,fechapendiente,estado,nom_estado,municipio,nom_municipio,localidad, nom_localidad, motivo_revision,nom_motivo_revision,escuela,nom_escuela,razon_social,escolaridad,nom_escolaridad,carrera,nom_carrera,rfc_clave_sep,clave_sep,estatus_revision,nom_estatus_revision,msg_blog,conexion';
        
        sQuery := '
            SELECT ' || CAST(iRecords AS VARCHAR) || ' AS records
            , ' || CAST(iPage AS VARCHAR) || ' AS page
            , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
            , id
            , ' || sColumns || '
            FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY fechapendiente ASC) AS id, ' || sColumns || '
                FROM tmpEscuelaRevision
                ) AS t
            WHERE  t.conexion= ' || iConexion || ' and t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
        
        --
        FOR valor IN EXECUTE (sQuery)
        LOOP
            records:=valor.records;
            page:=valor.page;
            pages:=valor.pages;
            id:=valor.id;
            irevision:=valor.revision;
            sfecha_pendiente:=valor.fecha_pendiente;
            idestado:=valor.estado;
            snom_estado:=valor.nom_estado;
            idmunicipio:=valor.municipio;
            snom_municipio:=valor.nom_municipio;
            idlocalidad:=valor.localidad;
            snom_localidad:=valor.nom_localidad;
            imotivo_revision:=valor.motivo_revision;
            snom_motivo_revision:=valor.nom_motivo_revision;
            iescuela:=valor.escuela;
            snombre_escuela:=valor.nom_escuela;
            srazonsocial:=valor.razon_social;
            idescolaridad:=valor.escolaridad;
            snom_escolaridad:=valor.nom_escolaridad;
            srfc_sep:=valor.rfc_clave_sep;
            sclavesep:=valor.clave_sep;
            iestatusrevision:=valor.estatus_revision;
            snom_estatus_revision:=valor.nom_estatus_revision;
            imsg_blog:=valor.msg_blog;
            icarrera:=valor.carrera;
            scarrera:=valor.nom_carrera;            
        RETURN NEXT;
        END LOOP;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer, character varying, character varying, character varying, integer, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer, character varying, character varying, character varying, integer, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer, character varying, character varying, character varying, integer, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer, character varying, character varying, character varying, integer, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_escuelas_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer, character varying, character varying, character varying, integer, character varying, character varying)IS 'La función obtiene las escuelas que se encuentra en revisión';

