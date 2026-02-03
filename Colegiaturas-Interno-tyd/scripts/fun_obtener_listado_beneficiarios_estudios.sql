DROP FUNCTION IF EXISTS fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer);
DROP TYPE IF EXISTS type_beneficiarios_estudio;

CREATE TYPE type_beneficiarios_estudio AS
   (idu_empleado integer,
    idu_beneficiario integer,
    fec_registro character varying(10),
    por_descuento double precision,
    idu_escuela integer,
    nom_rfc_escuela character varying(20),
    nom_nombre_escuela character varying(100),
    idu_escolaridad integer,
    des_escolaridad character varying(30));

CREATE OR REPLACE FUNCTION fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer)
  RETURNS SETOF type_beneficiarios_estudio AS
$BODY$
DECLARE  
	iEmpleado alias for $1;	
	iCentro alias for $2;	
	iPuesto alias for $3;	
	iSeccion alias for $4;	
	iBeneficiario alias for $5;	
	registros type_beneficiarios_estudio;
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 13/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los estudios de un beneficiario de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_listado_beneficiarios_estudios(93902761,230468,77,55, 1);	
	*/
BEGIN

	CREATE TEMPORARY TABLE tmp_EstudiosBeneficiarios
	(
		idu_empleado integer not null default 0,
		idu_beneficiario integer not null default 0,
		idu_parentesco integer not null default 0,
		fec_registro varchar(10) not null default '',
		por_descuento INT  not null default 0,
		idu_escuela integer  not null default 0,
		nom_rfc_escuela varchar(20) not null default '',
		nom_nombre_escuela varchar(100) not null default '',
		idu_escolaridad integer  not null default 0,
		des_escolaridad varchar(30) not null default ''
	)on commit drop;
	
	INSERT 	INTO tmp_EstudiosBeneficiarios (idu_empleado,idu_beneficiario,idu_parentesco, idu_escuela,idu_escolaridad, fec_registro )
	select 	e.idu_empleado,e.idu_beneficiario, b.idu_parentesco, e.idu_escuela, e.idu_escolaridad, to_char(e.fec_registro,'dd/MM/yyyy')
	from 	cat_estudios_beneficiarios e 
	inner 	join cat_beneficiarios_colegiaturas b on e.idu_beneficiario=b.idu_beneficiario and e.idu_empleado=b.idu_empleado
	where 	e.idu_empleado=iEmpleado 
		and e.idu_beneficiario= iBeneficiario
		and e.opc_tipo_beneficiario=1;
	
	update 	tmp_EstudiosBeneficiarios set des_escolaridad=b.nom_escolaridad from cat_escolaridades b
	where 	tmp_EstudiosBeneficiarios.idu_escolaridad=b.idu_escolaridad;

	update 	tmp_EstudiosBeneficiarios set nom_rfc_escuela=a.rfc_clave_sep, nom_nombre_escuela=a.nom_escuela  from cat_escuelas_colegiaturas a
	where	tmp_EstudiosBeneficiarios.idu_escuela= a.idu_escuela;

	--PORCENTAJE DESCUENTO POR EMPLEADO
	UPDATE 	tmp_EstudiosBeneficiarios set por_descuento=a.por_porcentaje from ctl_configuracion_descuentos a 
	where 	tmp_EstudiosBeneficiarios.idu_empleado=iEmpleado and tmp_EstudiosBeneficiarios.idu_empleado=a.idu_empleado 
		and (tmp_EstudiosBeneficiarios.idu_escolaridad=a.idu_escolaridad or a.idu_escolaridad=0) and tmp_EstudiosBeneficiarios.idu_parentesco=a.idu_parentesco;

	--PORCENTAJE DESCUENTO POR PUESTO SECCION
	UPDATE 	tmp_EstudiosBeneficiarios set por_descuento=a.por_porcentaje from ctl_configuracion_descuentos a 
	where 	a.idu_puesto=iPuesto and (a.idu_seccion=iSeccion or a.idu_seccion=0) and tmp_EstudiosBeneficiarios.idu_parentesco=a.idu_parentesco
		and (tmp_EstudiosBeneficiarios.idu_escolaridad=a.idu_escolaridad or a.idu_escolaridad=0) and tmp_EstudiosBeneficiarios.por_descuento=0;
	
	--PORCENTAJE DESCUENTO POR CENTRO
	UPDATE 	tmp_EstudiosBeneficiarios set por_descuento=a.por_porcentaje from ctl_configuracion_descuentos a 
	where 	a.idu_centro=iCentro and (a.idu_puesto=iPuesto or a.idu_puesto=0) and tmp_EstudiosBeneficiarios.idu_parentesco=a.idu_parentesco
		and (tmp_EstudiosBeneficiarios.idu_escolaridad=a.idu_escolaridad or a.idu_escolaridad=0) and tmp_EstudiosBeneficiarios.por_descuento=0;

		
	--SI NO CUENTA CON CONFIGURACION DE DESCUENTO DEJAR 50%
	UPDATE 	tmp_EstudiosBeneficiarios set por_descuento=50 where Tmp_EstudiosBeneficiarios.por_descuento=0;
	
	FOR registros IN (
		SELECT  idu_empleado, idu_beneficiario,fec_registro,por_descuento,idu_escuela,nom_rfc_escuela,nom_nombre_escuela,idu_escolaridad,des_escolaridad
		from tmp_EstudiosBeneficiarios order by fec_registro
		) LOOP
		RETURN NEXT registros;
	END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios_estudios(integer, integer, integer, integer, integer) TO postgres;