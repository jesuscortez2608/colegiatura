CREATE OR REPLACE FUNCTION fun_validar_usuario_externo(IN iempleado integer, OUT estado smallint, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
declare
/*
	No.Petición:			16559.1
	Fecha:				
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:						PERSONAL    
	Servidor:				10.44.2.183
	Sistema:				Colegiaturas
	Ejemplo:				SELECT * FROM fun_validar_usuario_externo(95194185)
*/
	valor record;
	sQuery text;
	iEstado smallint;
	cMensaje varchar(150);
begin
	create temp table tmp_Valida(
	iEstatus smallint
	, cMsg varchar(150)
	)on commit drop;

	if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado) then
		if(select(opc_empleado_bloqueado = 1) from cat_usuarios_externos where idu_empleado = iEmpleado) then
			iEstado := -1;
			cMensaje:= 'Usuario bloqueado.';
		else
			if(select (opc_empleado_bloqueado = 0 and opc_indefinido = 0) and (cast(now() as date) between fec_inicial and fec_final) or (opc_indefinido = 1) from cat_usuarios_externos where idu_empleado = iEmpleado) then
				iEstado := 1;
				cMensaje:= 'Usuario activo.';
			else
				iEstado := -2;
				cMensaje:= 'El usuario está inactivo';
			end if;
			
		end if;
	else
		iEstado := 0;
		cMensaje:= 'El usuario no tiene permisos asignados';
	end if;
	
	insert into tmp_Valida(iEstatus, cMsg) values (iEstado, cMensaje);

	for valor in (select iEstatus, cMsg from tmp_Valida)
	loop
		estado := valor.iEstatus;
		mensaje:= valor.cMsg;
		return next;
	end loop;	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_validar_usuario_externo(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_usuario_externo(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_validar_usuario_externo(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_validar_usuario_externo(integer) TO postgres;
COMMENT ON FUNCTION fun_validar_usuario_externo(integer) IS 'La función valida si el usuario que captura facturas de externos,

    está bloqueado o desbloqueado
    si está asignado por tiempo indefinido o por rango de fechas
    y si está asignado por rango de fechas, si está vigente su permiso para captura';