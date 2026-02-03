DROP FUNCTION IF EXISTS fun_obtener_beneficiarios_hojaazul(integer, text);
DROP TYPE IF EXISTS type_beneficiarios_colegiaturas;

CREATE TYPE type_beneficiarios_colegiaturas AS
   (nom_nombre character varying(20),
    ape_paterno character varying(20),
    ape_materno character varying(20),
    fec_nacimiento date,
    parentesco integer,
    keyx integer);

CREATE OR REPLACE FUNCTION fun_obtener_beneficiarios_hojaazul(integer, text)
  RETURNS SETOF type_beneficiarios_colegiaturas AS
$BODY$
   DECLARE

        iEmpleado      ALIAS FOR $1;
        cBeneficiarios ALIAS FOR $2;
        registro       type_beneficiarios_colegiaturas;
        cSql text;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 20/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Regresa los beneficiarios de la hoja azul de un empleado que contengan el apellido del empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_beneficiarios_hojaazul(91047781,'0 '); 
		 SELECT * FROM fun_obtener_beneficiarios_hojaazul(95194185,'0 '); 
		SELECT * FROM fun_obtener_beneficiarios_hojaazul(91047781,'7425080, 7425077, 7425078, 7425079'); 	 
	*/
	
BEGIN

	
	IF (TRIM(cBeneficiarios)='0') THEN --BUSCAR LOS BENEFICIARIOS DEL EMPLEADO 
		FOR registro IN 
			
			SELECT LTRIM(RTRIM(a.Nombre)),LTRIM(RTRIM(a.ApellidoPaterno)),LTRIM(RTRIM(a.ApellidoMaterno)), a.fechanacimiento, a.parentesco,a.keyx
			FROM sapfamiliarhojas a INNER JOIN sapcatalogoempleados e on a.numemp=e.numempn
			WHERE  a.numemp = iEmpleado AND (a.Parentesco in (4) AND CASE e.apellidopaterno when '' then rtrim(e.apellidomaterno) else rtrim(e.apellidopaterno) end in (LTRIM(RTRIM(a.ApellidoPaterno)),LTRIM(RTRIM(a.ApellidoMaterno)))
			or a.Parentesco in (3))
			order by a.parentesco desc
			
		LOOP
			RETURN NEXT registro;
		END LOOP;
	ELSE	
		cSql:='SELECT LTRIM(RTRIM(a.Nombre)),LTRIM(RTRIM(a.ApellidoPaterno)),LTRIM(RTRIM(a.ApellidoMaterno)), a.fechanacimiento, a.parentesco,a.keyx
		FROM sapfamiliarhojas a INNER JOIN sapcatalogoempleados e on a.numemp=e.numempn 
		WHERE  a.numemp ='|| iEmpleado||' AND a.keyx in ('||cBeneficiarios||') AND (a.Parentesco in (4) AND CASE e.apellidopaterno when '||''''''||' then rtrim(e.apellidomaterno) else rtrim(e.apellidopaterno) end in (LTRIM(RTRIM(a.ApellidoPaterno)),LTRIM(RTRIM(a.ApellidoMaterno)))
		or a.Parentesco in (3)) order by a.parentesco desc';
		--RAISE NOTICE ' Consulta %',cSql;
		FOR registro IN execute cSql
		LOOP
			RETURN NEXT registro;
		END LOOP;
	END IF;			
	RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_hojaazul(integer, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_hojaazul(integer, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_hojaazul(integer, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_hojaazul(integer, text) TO postgres;
