CREATE OR REPLACE FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer)
  RETURNS SETOF type_consulta_escuelarfc AS
$BODY$
DECLARE 
	nOpcion alias for $1;
	cRfc alias for $2;
	cNombre alias for $3;
	iEmpleado alias for $4;
	resultado type_consulta_escuelarfc;
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 04/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa 1 si el rfc de la escuela existe y 0 si no existe
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     
		select * from fun_consultar_escuela_rfc(1,'AILP790121','')
		select * from fun_consultar_escuela_rfc(2,'AILP790121','')
		select * from fun_consultar_escuela_rfc(3,'AILP790121','ALIBABA')
		select * from cat_escuelas_colegiaturas
	*/
	
BEGIN
	if(nOpcion=1) then --si existe rfc
		FOR resultado IN  (SELECT 'Ya existe el rfc', 1,0 from cat_escuelas_colegiaturas WHERE UPPER(RTRIM(RFC_CLAVE_SEP))=UPPER(RTRIM(cRfc)) limit 1 ) LOOP
			RETURN NEXT resultado;
		END LOOP;

	elsif(nOpcion=2) then --Busqueda de escuelas por rfc
		CREATE TEMPORARY TABLE tmp_Escuela(
			nomescuela varchar(100),
			iduescuela integer,
			pdf integer
		)on commit drop;	
		
		if (iEmpleado>0) then
			--select * from CAT_ESCUELAS_COLEGIATURAS
			insert 	into tmp_Escuela (nomescuela)
			SELECT 	distinct A.nom_escuela --, B.idu_escuela, A.opc_obligatorio_pdf
				--B.idu_beneficiario, B.opc_tipo_beneficiario, B.idu_escolaridad, B.idu_ciclo_escolar, B.idu_grado_escolar, B.idu_carrera
			FROM 	CAT_ESCUELAS_COLEGIATURAS A
			INNER 	JOIN CAT_ESTUDIOS_BENEFICIARIOS B ON A.idu_escuela=B.idu_escuela		
			WHERE 	A.rfc_clave_sep=cRfc
				AND B.idu_empleado=iEmpleado;
				
		else
			
			
			INSERT 	INTO tmp_Escuela(nomescuela)
			SELECT 	distinct (nom_escuela) 
			from 	CAT_ESCUELAS_COLEGIATURAS 
			WHERE 	UPPER(RTRIM(RFC_CLAVE_SEP))=UPPER(RTRIM(cRfc)) 
				AND OPC_ESCUELA_BLOQUEADA=0;

			INSERT 	INTO tmp_Escuela (nomescuela,iduescuela,pdf )
			SELECT 	'', 0, 0 
			from 	CAT_ESCUELAS_COLEGIATURAS 
			WHERE 	UPPER(RTRIM(RFC_CLAVE_SEP))=UPPER(RTRIM(cRfc)) 
				AND OPC_ESCUELA_BLOQUEADA=1 LIMIT 1;						
		end if;

		UPDATE 	tmp_Escuela SET iduescuela=a.idu_escuela, pdf=opc_obligatorio_pdf 
		from 	CAT_ESCUELAS_COLEGIATURAS a  
		WHERE 	UPPER(RTRIM(a.RFC_CLAVE_SEP))=UPPER(RTRIM(cRfc))
			and trim(upper(a.nom_escuela))=trim(upper(tmp_Escuela.nomescuela));
		
		
		FOR resultado IN  (SELECT nomescuela,iduescuela,pdf  from tmp_Escuela order by iduescuela) LOOP
			RETURN NEXT resultado;
		END LOOP;
	else --escolaridades de la escuela
		CREATE TEMPORARY TABLE tmp_Escolaridad(
			nomescolaridad varchar(100),
			iduescolaridad integer
		)on commit drop;
		FOR resultado IN  (
			SELECT distinct c.nom_escolaridad, e.idu_escolaridad,0 from cat_escuelas_colegiaturas e inner join cat_escolaridades c on e.idu_escolaridad=c.idu_escolaridad 
			where UPPER(RTRIM(e.RFC_CLAVE_SEP))=UPPER(RTRIM(cRfc)) and UPPER(RTRIM(e.nom_escuela))=UPPER(RTRIM(cNombre))) LOOP
			RETURN NEXT resultado;
		END LOOP;
	end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_consultar_escuela_rfc(integer, character varying, character varying, integer) IS 'La función consulta las escuelas por medio de su rfc.';  

