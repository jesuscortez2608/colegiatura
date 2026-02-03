DROP FUNCTION if exists fun_obtener_listado_beneficiarios(integer);
drop type if exists type_listado_beneficiarios;

CREATE TYPE type_listado_beneficiarios AS
   (idu_beneficiario integer,
    nom_nombre character varying(50),
    ape_paterno character varying(50),
    ape_materno character varying(50),
    idu_parentesco integer,
    des_parentesco character varying(20),
    idu_especial integer,
    des_especial character varying(2),
    des_observacion character varying(300),
    id_estudios integer,
    des_estudios character varying(2));

CREATE OR REPLACE FUNCTION fun_obtener_listado_beneficiarios(integer)
  RETURNS SETOF type_listado_beneficiarios AS
$BODY$
DECLARE  
	iEmpleado alias for $1;	
	registros type_listado_beneficiarios;
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 13/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los beneficiarios de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_listado_beneficiarios(93902761);	
	-----------------------------------------------------------------------
		Peticion: 		16559.1
		Fecha:			25/07/2018
		Colaborador:		98439677 Rafael Ramos
		Descripcion del cambio:	Se modifico linea de descripcion de parentesco
	-----------------------------------------------------------------------*/
BEGIN

	CREATE TEMPORARY TABLE tmp_Beneficiarios
	(
		idu_empleado integer not null default 0,
		idu_beneficiario integer not null default 0,
		nom_nombre varchar(50) not null default '',
		ape_paterno varchar(50) not null default '',
		ape_materno varchar(50) not null default '',
		idu_parentesco integer  not null default 0,
		des_parentesco varchar (20) not null default '',
		idu_especial integer  not null default 0,
		des_observacion varchar(300) not null default '',  
		id_estudios integer  not null default 0

	)on commit drop;

	--INSERTA BENEFICIARIOS CON ESTUDIOS
	INSERT 	INTO tmp_Beneficiarios (idu_empleado,idu_beneficiario,id_estudios )
	select 	idu_empleado,idu_beneficiario,count(idu_beneficiario) 
	from 	cat_estudios_beneficiarios 
	where 	idu_empleado=iEmpleado AND opc_tipo_beneficiario=1
	group 	by idu_empleado,idu_beneficiario ;

	--INSERTA BENEFICIARIOS SIN ESTUDIOS
	INSERT 	INTO tmp_Beneficiarios(idu_empleado,idu_beneficiario,id_estudios)
	select 	idu_empleado,idu_beneficiario, 0 from cat_beneficiarios_colegiaturas 
	where 	idu_empleado=iEmpleado 
			and idu_beneficiario not in (select idu_beneficiario from tmp_Beneficiarios);


	update 	tmp_Beneficiarios set nom_nombre=TRIM(a.nom_beneficiario), ape_paterno=TRIM(a.ape_paterno), ape_materno=TRIM(a.ape_materno),
			idu_parentesco=a.idu_parentesco, idu_especial= a.opc_becado_especial, des_observacion=a.des_observaciones 
	from 	cat_beneficiarios_colegiaturas a inner join tmp_Beneficiarios b
			on b.idu_empleado=a.idu_empleado and b.idu_beneficiario=a.idu_beneficiario
	where 	b.idu_empleado=iEmpleado and tmp_Beneficiarios.idu_beneficiario=a.idu_beneficiario;

	update 	tmp_Beneficiarios set des_parentesco =  p.des_parentesco
	from 	cat_parentescos p 
	inner 	join  tmp_Beneficiarios b on  b.idu_parentesco=p.idu_parentesco 
	where 	tmp_Beneficiarios.idu_beneficiario=b.idu_beneficiario;

	FOR registros IN (
		SELECT  idu_beneficiario,nom_nombre,ape_paterno,ape_materno,idu_parentesco,
		des_parentesco,idu_especial, case when idu_especial=1 then 'SI' ELSE 'NO' END,des_observacion,id_estudios,  case when id_estudios>1 THEN 'SI' ELSE 'NO' END 
		from tmp_Beneficiarios order by idu_beneficiario
		) LOOP
		RETURN NEXT registros;
	END LOOP;
	
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_beneficiarios(integer) IS 'La función obtiene un listado de los beneficiarios beneficiarios de un colaborador.';