DROP FUNCTION IF EXISTS fun_grabar_escuelas_sep();

CREATE OR REPLACE FUNCTION fun_grabar_escuelas_sep()
  RETURNS integer AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613.1 Colegiaturas
	Fecha                          : 23/03/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal Postgres
	Descripción del funcionamiento : Copia las escuelas de la SEP a la tabla de escuelas
	Sistema                        : Colegiaturas
	Ejemplo                        :
        SELECT fun_grabar_escuelas_sep();
        delete from cat_escuelas_colegiaturas;
        delete from cat_estados_colegiaturas;
        delete from cat_municipios_colegiaturas;
        delete from cat_localidades_colegiaturas;
	------------------------------------------------------------------------------------------------------ */
	iUltimoFolio integer;
BEGIN
    create local temp table stmp_escuelas_colegiaturas (
        opc_tipo_escuela integer NOT NULL DEFAULT 0,
        rfc_clave_sep character varying(20) NOT NULL DEFAULT ' '::character varying,
        nom_escuela character varying(100) NOT NULL DEFAULT ' '::character varying,
        idu_escolaridad integer NOT NULL DEFAULT 0,
        opc_educacion_especial integer NOT NULL DEFAULT 0,
        opc_obligatorio_pdf integer NOT NULL DEFAULT 0,
        idu_tipo_deduccion integer NOT NULL DEFAULT 0,
        opc_escuela_bloqueada integer,
        clave_sep varchar(20) not null default (''),
        idu_estado INTEGER NOT NULL DEFAULT(0),
        nom_estado VARCHAR(60) not null default (''),
        idu_municipio INTEGER NOT NULL DEFAULT(0),
        nom_municipio VARCHAR(150) not null default (''),
        idu_localidad INTEGER NOT NULL DEFAULT(0),
        nom_localidad VARCHAR(150) not null default (''),
        fec_captura timestamp without time zone NOT NULL DEFAULT now(),
        id_empleado_registro integer NOT NULL DEFAULT 0,
        observaciones character varying(300) NOT NULL DEFAULT ' '::character varying
    ) on commit drop;
    
    INSERT INTO stmp_escuelas_colegiaturas (opc_tipo_escuela
        , rfc_clave_sep
        , nom_escuela
        , idu_escolaridad
        , opc_educacion_especial
        , opc_obligatorio_pdf
        , idu_tipo_deduccion
        , opc_escuela_bloqueada
        , clave_sep
        , idu_estado
        , nom_estado
        , idu_municipio
        , nom_municipio
        , idu_localidad
        , nom_localidad
        , fec_captura
        , id_empleado_registro
        , observaciones)
            select distinct case when stmp.control = 'PRIVADO' then 2 else 1 end as opc_tipo_escuela
                , case when stmp.control = 'PRIVADO' then '' else stmp.clave end as rfc_clave_sep
                , left(stmp.centro_educativo, 100) as nom_escuela
                , case WHEN stmp.nivel_educativo = 'PREESCOLAR' then 2
                    WHEN stmp.nivel_educativo = 'PRIMARIA' then 3
                    WHEN stmp.nivel_educativo = 'SECUNDARIA' then 4
                    when stmp.nivel_educativo = 'BACHILLERATO' then 5
                    when stmp.nivel_educativo = 'PROFESIONAL TÉCNICO' then 5
                    when stmp.nivel_educativo like 'LICENCIATURA%' then 6
                    when stmp.nivel_educativo like 'POSGRADO%' then 7
                  end as idu_escolaridad
                , 0 as opc_educacion_especial
                , 0 as opc_obligatorio_pdf
                , case when stmp.control = 'PRIVADO' then 1 else 2 end as idu_tipo_deduccion
                , 0 as opc_escuela_bloqueada
                , stmp.clave as clave_sep
                , stmp.clave_entidad
                , stmp.entidad
                , stmp.clave_mun_del
                , stmp.municipio
                , stmp.clave_localidad
                , stmp.localidad
                , now() as fec_captura
                , 95194185 as id_empleado_registro
                , '' as observaciones
            from stmp_escuelas_colegiaturas_sep stmp 
            where --esc.clave_sep is null and 
                --stmp.centro_educativo like '%ALVARO OBREGON%' and 
                (stmp.nivel_educativo = 'PREESCOLAR'
                    or stmp.nivel_educativo = 'PRIMARIA'
                    or stmp.nivel_educativo = 'SECUNDARIA'
                    or stmp.nivel_educativo = 'BACHILLERATO'
                    or stmp.nivel_educativo = 'PROFESIONAL TÉCNICO'
                    or stmp.nivel_educativo like 'LICENCIATURA%'
                    or stmp.nivel_educativo like 'POSGRADO%');
    
    delete from cat_escuelas_colegiaturas where clave_sep != '';
    iUltimoFolio := (select coalesce(max(idu_escuela),0) from cat_escuelas_colegiaturas);
    
    INSERT INTO cat_escuelas_colegiaturas (idu_escuela
        , opc_tipo_escuela
        , rfc_clave_sep
        , nom_escuela
        , razon_social
        , idu_escolaridad
        , opc_educacion_especial
        , opc_obligatorio_pdf
        , idu_tipo_deduccion
        , opc_escuela_bloqueada
        , clave_sep
        , idu_estado
        , idu_municipio
        , idu_localidad
        , fec_captura
        , id_empleado_registro
        , observaciones)
        select res.idu_escuela + iUltimoFolio
            , res.opc_tipo_escuela
            , res.rfc_clave_sep
            , res.nom_escuela
            , res.nom_escuela as razon_social
            , res.idu_escolaridad
            , res.opc_educacion_especial
            , res.opc_obligatorio_pdf
            , res.idu_tipo_deduccion
            , res.opc_escuela_bloqueada
            , res.clave_sep
            , res.idu_estado
            , res.idu_municipio
            , res.idu_localidad
            , res.fec_captura
            , res.id_empleado_registro
            , res.observaciones
        from (
            SELECT ROW_NUMBER() OVER (ORDER BY stmp.clave_sep asc) AS idu_escuela
                , stmp.opc_tipo_escuela
                , stmp.rfc_clave_sep
                , stmp.nom_escuela
                , stmp.idu_escolaridad
                , stmp.opc_educacion_especial
                , stmp.opc_obligatorio_pdf
                , stmp.idu_tipo_deduccion
                , stmp.opc_escuela_bloqueada
                , stmp.clave_sep
                , stmp.idu_estado
                , stmp.idu_municipio
                , stmp.idu_localidad
                , stmp.fec_captura
                , stmp.id_empleado_registro
                , stmp.observaciones
            from stmp_escuelas_colegiaturas stmp
                left join cat_escuelas_colegiaturas esc on (stmp.clave_sep = esc.clave_sep)
            where esc.clave_sep is null
        ) as res;
    
    -- Estados
    DELETE FROM cat_estados_colegiaturas;
    INSERT INTO cat_estados_colegiaturas (idu_estado, nom_estado, idu_empleado_registro)
        SELECT DISTINCT idu_estado
            , nom_estado
            , 95194185 as idu_empleado_registro
        FROM stmp_escuelas_colegiaturas
        ORDER BY idu_estado;
    
    -- Municipios
    DELETE FROM cat_municipios_colegiaturas;
    INSERT INTO cat_municipios_colegiaturas (idu_estado, idu_municipio, nom_municipio, idu_empleado_registro)
        SELECT DISTINCT idu_estado
            , idu_municipio
            , nom_municipio
            , 95194185 as idu_empleado_registro
        FROM stmp_escuelas_colegiaturas
        ORDER BY idu_estado, idu_municipio;
    
    -- Localidades
    DELETE FROM cat_localidades_colegiaturas;
    INSERT INTO cat_localidades_colegiaturas (idu_estado, idu_municipio, idu_localidad, nom_localidad, idu_empleado_registro)
        select distinct clave_entidad, clave_mun_del, clave_localidad, localidad
            , 95194185 idu_empleado_registro
        from stmp_escuelas_colegiaturas_sep
        order by clave_entidad, clave_mun_del, clave_localidad;
        
    RETURN 1;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_sep() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_sep() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_sep() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_sep() TO postgres;