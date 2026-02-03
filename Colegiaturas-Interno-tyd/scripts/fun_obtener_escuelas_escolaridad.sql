DROP FUNCTION IF EXISTS fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer);
DROP TYPE IF EXISTS type_obtener_escuelas_escolaridad;

CREATE TYPE type_obtener_escuelas_escolaridad AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    idu_escuela integer,
    rfc_clave_sep character varying(20),
    nom_escuela character varying(100),
    nom_tipo_escuela character varying(10),
    nom_escolaridad character varying(30),
    escuela_especial character varying(100),
    obligatorio_pdf character varying(100),
    escuela_bloqueada character varying(100),
    fec_registro date,
    idu_empleado_registro integer,
    empleado_registro character varying(170),
    idu_tipo_escuela integer,
    idu_escolaridad integer,
    opc_educacion_especial integer,
    opc_obligatorio_pdf integer,
    opc_escuela_bloqueada integer,
    observaciones character varying(300),
    idu_tipo_deduccion integer,
    des_tipo_deduccion character varying(30),
    idu_estado integer,
    nom_estado character varying(150),
    idu_municipio integer,
    nom_municipio character varying(150),
    idu_localidad integer,
    nom_localidad character varying(150));

CREATE OR REPLACE FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer)
  RETURNS SETOF type_obtener_escuelas_escolaridad AS
$BODY$
DECLARE
/*
	No. petición APS               : 8613.1
	Fecha                          : 19/09/2016
	Número empleado                : 96753269
	Nombre del empleado            : Jesús Ramón Vega Taboada
	Base de datos                  : administracion
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento :
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Colegiaturas
	Ejemplo                        :
			SELECT * FROM fun_obtener_escuelas_escolaridad('CLUB', 0,
								10, 1,'nom_escuela','asc',
							'idu_escuela, rfc_clave_sep,nom_escuela,nom_tipo_escuela,nom_escolaridad,escuela_especial,
							obligatorio_pdf,escuela_bloqueada,fec_registro,empleado_registro,idu_tipo_escuela,idu_escolaridad,
							opc_educacion_especial,opc_obligatorio_pdf,opc_escuela_bloqueada,observaciones,idu_tipo_deduccion,
							des_tipo_deduccion',
							1);
*/
     cTerm ALIAS FOR $1;
     opc_tipo_escuela ALIAS FOR $2;
     
     iRowsPerPage ALIAS FOR $3;
     iCurrentPage ALIAS FOR $4;
     sOrderColumn ALIAS FOR $5;
     sOrderType ALIAS FOR $6;
     sColumns ALIAS FOR $7;
     iAyuda ALIAS FOR $8;
     iStart INTEGER;
     iRecords INTEGER;
     iTotalPages INTEGER;
     sConsulta VARCHAR(3000);
     col RECORD;
 
     returnrec type_obtener_escuelas_escolaridad;
BEGIN
     IF iRowsPerPage = -1 then
        iRowsPerPage := NULL;
    end if;
    if iCurrentPage = -1 then
        iCurrentPage := NULL;
    end if;
    
    create local temp table tmp_escuelas_escolaridad  
    (   
         opc_type_escuela INTEGER
        ,idu_escuela INTEGER
        ,rfc_clave_sep VARCHAR(20)
        ,nom_escuela VARCHAR(100)
        ,nom_tipo_escuela VARCHAR(10) -- Si opc_tipo_escuela = 1, "PUBLICA"; Si opc_tipo_escuela = 2, "PRIVADA"
        ,nom_escolaridad VARCHAR(30)
        
        ,escuela_especial VARCHAR(100) -- Si opc_educacion_especial = 1, "SI"; si opc_educacion_especial = 0, "NO"
        ,obligatorio_pdf VARCHAR(100) -- Si opc_obligatorio_pdf = 1, "SI"; si opc_obligatorio_pdf = 0, "NO"
        ,escuela_bloqueada VARCHAR(100) -- Si opc_escuela_bloqueada = 1, "SI"; si opc_escuela_bloqueada = 0, "NO"

        ,fec_registro DATE 
        ,empleado_registro VARCHAR(170) -- Número de empleado y Nombre completo; ej. "95194185 PAIMI ARIZMENDI LOPEZ"
        ,idu_tipo_escuela INTEGER
        ,idu_escolaridad INTEGER
        ,opc_educacion_especial INTEGER
        ,opc_obligatorio_pdf INTEGER
        ,opc_escuela_bloqueada INTEGER
        ,observaciones VARCHAR(300)
        ,idu_tipo_deduccion INTEGER
        ,des_tipo_deduccion VARCHAR(30)
        ,idu_empleado_registro INTEGER
    ) on commit drop;

      if iAyuda=1 then
	       sConsulta := 'SELECT DISTINCT ON (nom_escuela) nom_escuela, idu_escuela, rfc_clave_sep
	       , fec_captura AS fec_registro
		, opc_tipo_escuela AS idu_tipo_escuela
		, idu_escolaridad AS idu_escolaridad
		, opc_educacion_especial AS opc_educacion_especial
		, opc_obligatorio_pdf AS opc_obligatorio_pdf
		, opc_escuela_bloqueada AS opc_escuela_bloqueada
		, observaciones AS observaciones
		, idu_tipo_deduccion AS idu_tipo_deduccion
		, CASE WHEN idu_tipo_deduccion=1 THEN '''||'DEDUCIBLE'||'''  WHEN idu_tipo_deduccion=2 THEN '''||'NO DEDUCIBLE'||''' ELSE '''||'DEDUCIBLE CON IVA'||''' END AS des_tipo_deduccion
		, id_empleado_registro as idu_empleado_registro
	    FROM cat_escuelas_colegiaturas
	    where opc_escuela_bloqueada=0 and trim(rfc_clave_sep) || trim(nom_escuela) like ''%' || cTerm || '%'' ';
	else
		sConsulta := 'SELECT idu_escuela, rfc_clave_sep
		, nom_escuela
		, fec_captura AS fec_registro
		, opc_tipo_escuela AS idu_tipo_escuela
		, idu_escolaridad AS idu_escolaridad
		, opc_educacion_especial AS opc_educacion_especial
		, opc_obligatorio_pdf AS opc_obligatorio_pdf
		, opc_escuela_bloqueada AS opc_escuela_bloqueada
		, observaciones AS observaciones
		, idu_tipo_deduccion AS idu_tipo_deduccion
		, CASE WHEN idu_tipo_deduccion=1 THEN '''||'DEDUCIBLE'||'''  WHEN idu_tipo_deduccion=2 THEN '''||'NO DEDUCIBLE'||''' ELSE '''||'DEDUCIBLE CON IVA'||''' END AS des_tipo_deduccion
		, id_empleado_registro as idu_empleado_registro
		FROM cat_escuelas_colegiaturas
		where  trim(rfc_clave_sep) || trim(nom_escuela) like ''%' || cTerm || '%'' ';
	end if;
	
	if opc_tipo_escuela<>0 then
		sConsulta :=sConsulta||' and opc_tipo_escuela= '||opc_tipo_escuela;
	end if;

        for col in execute sConsulta loop
        insert into tmp_escuelas_escolaridad (
                 idu_escuela
                ,rfc_clave_sep
                ,nom_escuela                 
                ,fec_registro                 
                ,idu_tipo_escuela
                ,idu_escolaridad
                ,opc_educacion_especial
                ,opc_obligatorio_pdf
                ,opc_escuela_bloqueada
                ,observaciones
                ,idu_tipo_deduccion
                ,des_tipo_deduccion
                ,idu_empleado_registro)
        values (
                 col.idu_escuela
                ,col.rfc_clave_sep
                ,col.nom_escuela                 
                ,col.fec_registro             
                ,col.idu_tipo_escuela
                ,col.idu_escolaridad
                ,col.opc_educacion_especial
                ,col.opc_obligatorio_pdf
                ,col.opc_escuela_bloqueada
                ,col.observaciones
                ,col.idu_tipo_deduccion
                ,col.des_tipo_deduccion
                ,col.idu_empleado_registro);
    end loop;

	-- Mostrar Check (simbolo de palomita)
	UPDATE tmp_escuelas_escolaridad SET nom_tipo_escuela = case when idu_tipo_escuela = 1 then 'PUBLICA' ELSE 'PRIVADA' END,
		escuela_especial = case when opc_educacion_especial = 1 then '<font color="#00A400" size="4"><strong>&#8730;</strong></font>' ELSE '' END,
		obligatorio_pdf = case when opc_obligatorio_pdf = 1 then '<font color="#00A400" size="4"><strong>&#8730;</strong></font>' ELSE '' END,
		escuela_bloqueada = case when opc_escuela_bloqueada = 1 then '<font color="#00A400" size="4"><strong>&#8730;</strong></font>' ELSE '' END;

    ---CONCATENACION DE LAS ESCOLARIDADES---
    UPDATE tmp_escuelas_escolaridad SET nom_escolaridad = TRIM(cat_escolaridades.nom_escolaridad)
    FROM cat_escolaridades
    WHERE cat_escolaridades.idu_escolaridad = tmp_escuelas_escolaridad.idu_escolaridad;
    
	
    ---CONCATENACION DE EL EMPLEADO QUE REGISTRA---
    UPDATE tmp_escuelas_escolaridad SET empleado_registro = CAST(sapcatalogoempleados.numempn AS VARCHAR)
        || ' ' || TRIM(sapcatalogoempleados.nombre)
        || ' ' || TRIM(sapcatalogoempleados.apellidopaterno)
        || ' ' || TRIM(sapcatalogoempleados.apellidomaterno)
    FROM sapcatalogoempleados
    WHERE sapcatalogoempleados.numempn = tmp_escuelas_escolaridad.idu_empleado_registro;
    iRecords := (SELECT COUNT(*) FROM tmp_escuelas_escolaridad);	
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
	    iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
	    iRecords := (SELECT COUNT(*) FROM tmp_escuelas_escolaridad);
	    iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
    
		if (opc_tipo_escuela=0)  then
		
			sConsulta := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_escuelas_escolaridad
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
                else
			sConsulta := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_escuelas_escolaridad
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' and idu_tipo_escuela=' || opc_tipo_escuela ;	
                end if;
       ELSE
		if (opc_tipo_escuela=0) then
			sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_escuelas_escolaridad ';
		else 
			sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || '  FROM tmp_escuelas_escolaridad WHERE idu_tipo_escuela=' || opc_tipo_escuela;
		end if;
      END if;
        sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
        
        RAISE NOTICE 'notice %', sConsulta;


    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_escuelas_escolaridad(character varying, integer, integer, integer, character varying, character varying, character varying, integer) IS 'FUNCION PARA OBTENER ESCUELAS ESCOLARIDAD.';
