DROP FUNCTION IF EXISTS fun_obtener_listado_empresas_colegiaturas();

CREATE OR REPLACE FUNCTION fun_obtener_listado_empresas_colegiaturas(OUT idu_empresa integer, OUT nom_empresa character varying, OUT nom_legal character varying, OUT rfc character varying)
  RETURNS SETOF record AS
$BODY$
declare
	/*===================================================================
		No. Peticion :		16559.1
		Colaborador :		98439677 Rafael Ramos
		Fecha:			24/08/2018
		BD:			Personal
		Sistema:		Colegiaturas
		Modulo:			Reporte Acumulado de Colegiaturas
		Ejemplo:
			SELECT * FROM fun_obtener_listado_empresas_colegiaturas();
	===================================================================*/
	valor record;
begin
	for valor in (SELECT	ec.idu_empresa
				, ec.nom_empresa
				, ec.nom_legal
				, ec.rfc
			FROM	view_empresas_colegiaturas as ec
			order	by ec.idu_empresa)
	loop
		idu_empresa	:= valor.idu_empresa;
		nom_empresa	:= valor.nom_empresa;
		nom_legal	:= valor.nom_legal;
		rfc		:= valor.rfc;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_empresas_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_empresas_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_empresas_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_empresas_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_empresas_colegiaturas() IS 'La función obtiene el listado de empresas a las que se les han pagado la prestacion de colegiaturas.';  