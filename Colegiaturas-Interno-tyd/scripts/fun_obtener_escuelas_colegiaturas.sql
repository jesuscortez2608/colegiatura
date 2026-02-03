DROP FUNCTION IF EXISTS fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer);
DROP TYPE IF EXISTS type_obtener_escuelas_colegiaturas;


CREATE TYPE type_obtener_escuelas_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    idu_escuela integer,
    rfc_clave_sep character varying(20),
    nom_escuela character varying(100),
    opc_tipo_escuela integer,
    nom_tipo_escuela character varying(15),
    idu_tipo_deduccion integer,
    nom_tipo_deduccion character varying(30),
    idu_escolaridad integer,
    nom_escolaridad character varying(30),
    idu_carrera integer,
    nom_carrera character varying(100),
    opc_educacion_especial integer,
    opc_obligatorio_pdf integer,
    opc_nota_credito smallint,
    opc_escuela_bloqueada integer,
    clave_sep character varying(20),
    fec_captura date,
    idu_empleado_registro integer,
    nom_empleado_registro character varying(150),
    observaciones character varying(300),
    idu_estado integer,
    nom_estado character varying(60),
    idu_municipio integer,
    nom_municipio character varying(150),
    idu_localidad integer,
    nom_localidad character varying(150));

CREATE OR REPLACE FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying DEFAULT 'nom_escuela'::character varying, character varying DEFAULT 'asc'::character varying, character varying DEFAULT '*'::character varying, integer DEFAULT 0)
  RETURNS SETOF type_obtener_escuelas_colegiaturas AS
$BODY$
DECLARE
    /*
    Fecha                          : 21/03/2017
    Número empleado                : 95194185
    Nombre del empleado            : Paimi Arizmendi Lopez
    Base de datos                  : Personal postgres
    Descripción del funcionamiento : Debe llenar el grid para actualizar el RFC de una escuela
    Sistema                        : Colegiaturas
    Módulo                         : Subir factura, escuela privada
    Ejemplo                        : 
        iTipoBusqueda: 1 - Por nombre, 2 - Por clave SEP
        select *
        from fun_obtener_escuelas_colegiaturas(25 -- Estado
            , 6 -- Municipio
            , 1 -- 1 Buscar por nombre; 2 Buscar por clave SEP
            , 'CAMPUS'
            , 2 -- Escuelas privadas
            , 0 -- Indica si se muestran escuelas con RFC configurado (0 No; 1 Si)
            
            , 10 -- Páginas del grid
            , 1 -- Página actual
            , 'nom_escuela' -- Campo por el que se ordena
            , 'asc' -- Tipo de orden
            , '*');
            
        SELECT *
			FROM fun_obtener_escuelas_colegiaturas(
				 0, 0, 1, 'TECNOLOGICO',0, 1
				, -1::integer
				, -1::integer			
				, 'idu_escuela'
				, 'asc'
				, '*')
        select * from cat_escuelas_colegiaturas where idu_estado = 25 and idu_municipio = 6 limit 100
  -------------------------------------------------------------------------------------------------
	Fecha			:	06/04/2018
	Colaborador		:	Rafael Ramos Gutierrez 98439677
	Sistema			:	Colegiaturas
	Modulo			:	Configuracion Escuela-Escolaridad
	Descripcion Cambio	:	Se agrego un nuevo parametro, para realizar busqueda por Localidad de la escuela
    ------------------------------------------------------------------------------------------------------ */
    iEstado alias for $1;
    iMunicipio alias for $2;
    iLocalidad alias for $3;
    iTipoBusqueda alias for $4;
    sTextoBusqueda alias for $5;
    iTipoEscuela alias for $6;
    iMostrarEscuelasConfiguradas alias for $7;
    
    iRowsPerPage alias for $8;
    iCurrentPage alias for $9;
    sOrderColumn alias for $10;
    sOrderType alias for $11;
    sColumns alias for $12;
    iAyuda alias for $13;
    iStart integer;
    iRecords integer;
    iTotalPages INTEGER;
    sConsulta varchar(3000);
    returnrec type_obtener_escuelas_colegiaturas;
    rec record;
BEGIN
    IF iRowsPerPage = -1 then
        iRowsPerPage := NULL;
    end if;
    if iCurrentPage = -1 then
        iCurrentPage := NULL;
    end if;
    
    IF TRIM(sColumns) = '*' THEN
        sColumns := 'idu_escuela,rfc_clave_sep,nom_escuela
                ,opc_tipo_escuela,nom_tipo_escuela
                ,idu_tipo_deduccion,nom_tipo_deduccion
                ,idu_escolaridad,nom_escolaridad,idu_carrera,nom_carrera
                ,opc_educacion_especial,opc_obligatorio_pdf,opc_nota_credito,opc_escuela_bloqueada
                ,clave_sep
                ,fec_captura,idu_empleado_registro,nom_empleado_registro
                ,observaciones
                ,idu_estado,nom_estado,idu_municipio,nom_municipio, idu_localidad, nom_localidad';
    END IF;

--    drop table tmp_escuelascolegiaturas
    create local temp table tmp_escuelascolegiaturas (idu_escuela integer
        , rfc_clave_sep character varying(20)
        , nom_escuela character varying(100)
        , opc_tipo_escuela integer
        , nom_tipo_escuela varchar(15)
        , idu_tipo_deduccion integer
        , nom_tipo_deduccion varchar(30)
        , idu_escolaridad integer       
        , nom_escolaridad varchar(30)
        , idu_carrera integer
        , nom_carrera varchar(100)
        , opc_educacion_especial integer
        , opc_obligatorio_pdf integer
        , opc_nota_credito smallint
        , opc_escuela_bloqueada integer
        , clave_sep character varying(20)
        , fec_captura date
        , idu_empleado_registro integer
        , nom_empleado_registro VARCHAR(150)
        , observaciones varchar(300)
        , idu_estado integer
        , nom_estado varchar(60)
        , idu_municipio integer
        , nom_municipio varchar(150)
        , idu_localidad integer
        , nom_localidad varchar(150)
    ) on commit drop;
    
    sConsulta := 'insert into tmp_escuelascolegiaturas (idu_escuela, rfc_clave_sep, nom_escuela, opc_tipo_escuela, nom_tipo_escuela, idu_tipo_deduccion
            , idu_escolaridad, idu_carrera, opc_educacion_especial, opc_obligatorio_pdf, opc_nota_credito, opc_escuela_bloqueada
            , clave_sep
            , fec_captura
            , idu_empleado_registro
            , observaciones
            , idu_estado            
            , idu_municipio
            , idu_localidad
            )
            select idu_escuela
                , rfc_clave_sep
                , nom_escuela
                , opc_tipo_escuela
                , case when opc_tipo_escuela = 1 then ''PUBLICA'' else ''PRIVADA'' end as nom_tipo_escuela
                , idu_tipo_deduccion
                , idu_escolaridad, idu_carrera, opc_educacion_especial, opc_obligatorio_pdf, opc_nota_credito, opc_escuela_bloqueada
                , clave_sep
                , fec_captura
                , id_empleado_registro
                , observaciones
                , idu_estado               
                , idu_municipio
                , idu_localidad               
            from cat_escuelas_colegiaturas
            where 1 = 1 ';

         

          --select * from cat_estados_colegiaturas limit 1
          --select * from cat_municipios_colegiaturas limit 1
          --select * from cat_localidades_colegiaturas limit 1
    
    if iEstado > -1 then
        sConsulta := sConsulta || 'and idu_estado = ' || iEstado::varchar || ' ';
    end if;
    
    if iMunicipio > -1 then
        sConsulta := sConsulta || 'and idu_municipio = ' || iMunicipio::varchar || ' ';
    end if;

    if iLocalidad > -1 then
	sConsulta := sConsulta || 'and idu_localidad = ' || iLocalidad::varchar || ' ';
    end if;
    
    if iTipoEscuela > 0 then
        sConsulta := sConsulta || 'and opc_tipo_escuela = ' || iTipoEscuela::VARCHAR || ' ';
    end if;
    
    if iMostrarEscuelasConfiguradas = 0 then
        sConsulta := sConsulta || 'and rfc_clave_sep = '''' ';
    end if;
    
    if iTipoBusqueda = 1 then
        -- Buscar por nombre
        sConsulta := sConsulta || 'and nom_escuela like ''%' || sTextoBusqueda || '%'' ';
    else
        -- Buscar por clave sep
        sConsulta := sConsulta || 'and (clave_sep like ''%' || sTextoBusqueda || '%''  or rfc_clave_sep like ''%' || sTextoBusqueda || '%'' )';
    end if;

    IF iAyuda=1 THEN
	sConsulta := sConsulta || 'and opc_escuela_bloqueada=0 ';
    END IF;
	
    
    raise notice '%', sConsulta;
    execute sConsulta;

	--select * from tmp_escuelascolegiaturas
	UPDATE tmp_escuelascolegiaturas SET nom_estado= B.nom_estado 
	FROM   cat_estados_colegiaturas B 
	WHERE  tmp_escuelascolegiaturas.idu_estado=B.idu_estado;

	UPDATE tmp_escuelascolegiaturas SET nom_municipio= B.nom_municipio
	FROM   cat_municipios_colegiaturas B 
	WHERE  tmp_escuelascolegiaturas.idu_estado=B.idu_estado
	       and tmp_escuelascolegiaturas.idu_municipio=B.idu_municipio;

	update	tmp_escuelascolegiaturas set nom_localidad=B.nom_localidad
	from	cat_localidades_colegiaturas B
	where	tmp_escuelascolegiaturas.idu_estado=B.idu_estado
		and	tmp_escuelascolegiaturas.idu_municipio=B.idu_municipio
		and	tmp_escuelascolegiaturas.idu_localidad=B.idu_localidad;

	UPDATE tmp_escuelascolegiaturas SET nom_carrera= B.nom_carrera
	FROM   cat_carreras B 
	WHERE  tmp_escuelascolegiaturas.idu_carrera=B.idu_carrera;

	update tmp_escuelascolegiaturas set nom_escolaridad = cat_escolaridades.nom_escolaridad
	from   cat_escolaridades
	where  cat_escolaridades.idu_escolaridad = tmp_escuelascolegiaturas.idu_escolaridad;

	update tmp_escuelascolegiaturas set nom_tipo_deduccion = cat_tipos_deduccion.nom_deduccion
	from   cat_tipos_deduccion
	where  cat_tipos_deduccion.idu_tipo = tmp_escuelascolegiaturas.idu_tipo_deduccion;
    
	update tmp_escuelascolegiaturas set nom_empleado_registro = trim(sapcatalogoempleados.nombre) || ' ' || trim(sapcatalogoempleados.apellidopaterno) || ' ' || trim(sapcatalogoempleados.apellidomaterno)
	from   sapcatalogoempleados
	where  sapcatalogoempleados.numempn = tmp_escuelascolegiaturas.idu_empleado_registro;
    
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
        iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
        iRecords := (SELECT COUNT(*) FROM tmp_escuelascolegiaturas);
        iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
        
        sConsulta := '
            select ' || CAST(iRecords AS VARCHAR) || ' AS records
                , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
                , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
                , id
                , ' || sColumns || '
            from (
                    SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
                    FROM tmp_escuelascolegiaturas
                    ) AS t
            where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
    ELSE
        sConsulta := 'SELECT 0 records, 0 page, 0 pages, 0 id, ' || sColumns || ' FROM tmp_escuelascolegiaturas ';
    END if;
    sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
    
    RAISE NOTICE 'notice %', sConsulta;
    
    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_escuelas_colegiaturas(integer, integer, integer, integer, character varying, integer, integer, integer, integer, character varying, character varying, character varying, integer) IS 'OBTIENE LAS ESCUELAS PUBLICAS Y PRIVADAS.'; 