CREATE OR REPLACE FUNCTION fun_obtener_rfc_empresa(integer)
  RETURNS character varying AS
$BODY$
declare
/*
	No.Petición:			16559.1
	Fecha:					16/05/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:						PERSONAL    
	Servidor:				10.44.2.183
	Sistema:				Colegiaturas
	Ejemplo:				fun_obtener_rfc_empresa(1)
*/
	iEmpresa	ALIAS for $1;
	iRFC varchar(20);
begin
	if exists(select 1 from sapempresas where clave = iEmpresa) then
		iRFC:= (SElect rfc from sapempresas where clave = iEmpresa);
	else
		iRFC := 'No se encuentra';
	end if;

	return iRFC as rfc;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_rfc_empresa(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_rfc_empresa(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_rfc_empresa(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_rfc_empresa(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_rfc_empresa(integer) IS 'La función obtiene el RFC de una empresa en base a la clave.';   