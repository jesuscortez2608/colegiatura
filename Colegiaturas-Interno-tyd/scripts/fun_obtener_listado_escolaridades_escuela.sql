DROP FUNCTION IF EXISTS fun_obtener_listado_escolaridades_escuela(integer);

CREATE OR REPLACE FUNCTION fun_obtener_listado_escolaridades_escuela(IN id_escuela integer, OUT idu_escolaridad integer, OUT nom_escolaridad character varying, OUT opc_carrera integer)
  RETURNS SETOF record AS
$BODY$
declare
  -- ===================================================
-- Peticion			: 16559.1
-- Autor			: Rafael Ramos Gutiérrez 98439677
-- Fecha			: 28/03/2018
-- Descripción General		: Obtiene las escolaridades de las escuelas.
-- Ruta Tortoise		:
-- Sistema			: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos		: personal
-- Ejemplo			: select * from fun_obtener_listado_escolaridades_escuela(260588)
--				  select * from fun_obtener_listado_escolaridades_escuela(0,'25DIT0002I')
-- Tablas Utilizadas		: cat_escolaridades
--				  cat_escuelas_colegiaturas
-- select *  from cat_escuelas_colegiaturas where idu_escolaridad = 0 limit 10
-- ===================================================
	iEscuela alias for $1;
	sClv_sep VARCHAR(20);
	intEscolaridad INTEGER;
	valor record;
begin
	sClv_sep := (SELECT  CASE WHEN clave_sep='' THEN rfc_clave_sep ELSE clave_sep END FROM cat_escuelas_colegiaturas WHERE idu_escuela =iEscuela limit 1);
	intEscolaridad := (SELECT  esc.idu_escolaridad FROM cat_escuelas_colegiaturas as esc WHERE esc.idu_escuela =iEscuela limit 1);
	
	create	temp	table	tmp_escolaridad(
		iEscolaridad	integer not null,
		sNomEscolaridad character varying (30) not null,
		iOpcCarrera INTEGER
	) on commit drop;
	
	if intEscolaridad > 0 then
		insert into	tmp_escolaridad(iEscolaridad, sNomEscolaridad, iOpcCarrera)
		select 		distinct esc.idu_escolaridad, esco.nom_escolaridad, esco.opc_carrera
		from 		cat_escuelas_colegiaturas esc
		left join 	cat_escolaridades esco on (esc.idu_escolaridad = esco.idu_escolaridad)
		where		rfc_clave_sep = sClv_sep or clave_sep=sClv_sep
		order 		by esc.idu_escolaridad;
	else
		insert into	tmp_escolaridad(iEscolaridad, sNomEscolaridad, iOpcCarrera)
		select 		distinct esc.idu_escolaridad, esco.nom_escolaridad, esco.opc_carrera
		from 		cat_escuelas_colegiaturas esc
		left join 	cat_escolaridades esco on (esc.idu_escolaridad = esco.idu_escolaridad)
		where		esco.idu_escolaridad > 0
		order 		by esc.idu_escolaridad;
	end if;
	
	for valor in (select
			iEscolaridad,
			sNomEscolaridad,
			iOpcCarrera
			from	tmp_escolaridad)
	loop
		idu_escolaridad	:=	valor.iEscolaridad;
		nom_escolaridad :=	valor.sNomEscolaridad;
		opc_carrera := valor.iOpcCarrera;
	return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_escuela(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_escuela(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_escuela(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades_escuela(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_escolaridades_escuela(integer) IS 'La función obtiene un listado de escolaridades disponibles en una escuela.';