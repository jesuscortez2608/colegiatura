CREATE OR REPLACE FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer)
  RETURNS integer AS
$BODY$
  -- ===================================================
-- Peticion				: 16559.1
-- Autor				: Rafael Ramos Gutiérrez 98439677
-- Fecha				: 28/03/2018
-- Descripción General	:  guarda las claves de uso permitidas en las facturas de colegiaturas.
-- Ruta Tortoise		:
-- Sistema				: Colegiaturas
-- Servidor Productivo	: 10.44.2.183
-- Servidor Desarrollo	: 10.44.114.75
-- Base de Datos		: personal
-- Ejemplo				: select * from fun_guardar_claves_uso_permitidas (0,'R18', 'DEFINIDA', 98439677)
-- Tablas Utilizadas	: cat_claves_uso_permitidas
-- ===================================================
declare
	ikeyx		ALIAS FOR $1;
	sclv_uso	ALIAS for $2;
	sdes_uso	ALIAS for $3;
	iidu_empleado_registro ALIAS for $4;
	estado integer;
	mensaje character varying;

	iresultado integer;
begin
	if(ikeyx = 0) then
		if exists(select clv_uso from cat_claves_uso_permitidas where clv_uso ilike  sclv_uso) then
			iresultado := -1;
		else
			insert into cat_claves_uso_permitidas(clv_uso, des_uso, idu_empleado_registro)
			values (sclv_uso, sdes_uso, iidu_empleado_registro);
			iresultado := 1;
		end if;
	else
		if NOT exists (SELECT clv_uso FROM cat_claves_uso_permitidas WHERE clv_uso ilike sclv_uso and keyx!=ikeyx) then
			update	cat_claves_uso_permitidas
			set	clv_uso = sclv_uso,
				des_uso = sdes_uso,
				idu_empleado_registro = iidu_empleado_registro,
				fec_registro = now()
			where	keyx = ikeyx;
			iresultado := 2;
		else
			iresultado := -1;
		end if;
	end if;
	return iresultado;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_guardar_claves_uso_permitidas(integer, character varying, character varying, integer) IS 'La función guarda las claves de uso permitidas en las facturas de colegiaturas.';  
