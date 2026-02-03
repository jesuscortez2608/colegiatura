DROP FUNCTION if exists fun_obtener_tipos_revision();

CREATE OR REPLACE FUNCTION fun_obtener_tipos_revision(OUT idu_tipo_revision integer, OUT des_tipo_revision character varying)
  RETURNS SETOF record AS
$BODY$
declare
	/**-----------------------------------------------
		No. Peticion:		16559.1
		Fecha:			14/08/2018
		Colaborador:		98439677 Rafael Ramos
		Sistema:		Colegiaturas
		Modulo:			Bitacora Costos
		Ejemplo:	
			SELECT * FROM fun_obtener_tipos_revision();
	------------------------------------------------*/
	valor record;
	sQuery text;
begin
	create temporary table tmp_consulta(
		idu_tipo_revision integer
		, des_tipo_revision character varying
	)on commit drop;
	INSERT INTO tmp_consulta(idu_tipo_revision
				, des_tipo_revision)
			SELECT	A.idu_tipo_revision
				, A.des_tipo_revision
			FROM	cat_tipo_revision as A;
	for valor in (select
			A.idu_tipo_revision
			, A.des_tipo_revision
			from tmp_consulta A
			order by idu_tipo_revision)
	loop
		idu_tipo_revision :=	valor.idu_tipo_revision;
		des_tipo_revision :=	valor.des_tipo_revision;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_revision() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_revision() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_revision() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_revision() TO postgres;
COMMENT ON FUNCTION fun_obtener_tipos_revision() IS 'La funcion obtiene los tipos de revision del sistema de colegiaturas.';  