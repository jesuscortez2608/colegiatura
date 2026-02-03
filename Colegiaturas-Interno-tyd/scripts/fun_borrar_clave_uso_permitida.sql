CREATE OR REPLACE FUNCTION fun_borrar_clave_uso_permitida(integer)
  RETURNS integer AS
$BODY$
-- ===================================================
-- Peticion					: 16559.1
-- Autor					: Rafael Ramos Gutiérrez 98439677
-- Fecha					: 28/03/2018
-- Descripción General		: borra una clave de uso del catálogo cat_claves_uso_permitidas.
-- Ruta Tortoise			: 
-- Sistema					: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos			: personal
-- Ejemplo					: SELECT * FROM fun_borrar_clave_uso_permitida(1)
-- ===================================================
declare
	ikeyx alias for $1;
	iresultado integer;
begin
	if exists (select clv_uso from cat_claves_uso_permitidas where keyx = ikeyx) then
		delete from cat_claves_uso_permitidas where keyx = ikeyx;
		iresultado := 1;
	else
		iresultado := 0;
	end if;

	return iresultado;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_borrar_clave_uso_permitida(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_borrar_clave_uso_permitida(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_borrar_clave_uso_permitida(integer) TO postgres;
GRANT EXECUTE ON FUNCTION fun_borrar_clave_uso_permitida(integer) TO sysetl;
COMMENT ON FUNCTION fun_borrar_clave_uso_permitida(integer) IS 'La función borra una clave de uso del catálogo cat_claves_uso_permitidas.';