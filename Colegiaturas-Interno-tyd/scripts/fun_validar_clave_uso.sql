CREATE OR REPLACE FUNCTION fun_validar_clave_uso(character varying)
  RETURNS integer AS
$BODY$
declare

	ClaveUso ALIAS for $1;
	Estatus integer;
/*
---------------------------------------------------
	No. Peticion			: 16559
	Numero Empleado			: 98439677
	Nombre empleado			: Rafael Ramos Gutiérrez
	Sistema					: Colegiaturas
	Modulo					: Subir factura externo
	Ruta Tortoise			: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts/
	Servidor Productivo		: 10.44.2.183
	Servidor Desarrollo		: 10.44.114.75
	Ejemplo				: SELECT * FROM fun_validar_clave_uso('G13');
---------------------------------------------------
*/

begin
	if exists (select clv_uso from cat_claves_uso_permitidas where clv_uso = ClaveUso) then
		Estatus := 1;
	else
		Estatus := 0;
	end if;

	return Estatus as estatus;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_validar_clave_uso(character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_clave_uso(character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_validar_clave_uso(character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_validar_clave_uso(character varying) TO postgres;
COMMENT ON FUNCTION fun_validar_clave_uso(character varying) IS 'La función valida que la clave de uso de una factura sea la adecuada conforme a la configuración de claves de uso.'; 