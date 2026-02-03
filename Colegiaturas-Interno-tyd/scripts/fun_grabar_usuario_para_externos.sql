CREATE OR REPLACE FUNCTION fun_grabar_usuario_para_externos(IN iempleado integer, IN iopc_empleado_bloqueado smallint, IN iopc_indefinido smallint, IN dfechainicial date, IN dfechafinal date, IN iusuario integer, OUT estado smallint, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
    declare
/*----------------------------------------
	No.Petición:			16559.1
	Fecha:				23/04/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Captura de Externos
	Ejemplo:			--select * from fun_grabar_usuario_para_externos(90025628, 0::smallint, 0::smallint, '04/20/2018', '04/21/2018', 98439677)
					--select * from fun_grabar_usuario_para_externos(90025628, 1::smallint, 1::smallint, '01/01/1900', '01/01/1900', 95194185)
					--select * from fun_grabar_usuario_para_externos (98439677, 0::SMALLINT, 1::SMALLINT, '1900/01/01', '1900/01/01', 98439677)
-----------------------------------------*/
	valor record;
	iEstatus integer;
	cMsg varchar(50);
begin
	create temp table tmp_Usuario(
	iEstado smallint not null default 0,
	cMensaje varchar(50) not null default ''
	)on commit drop;

	/*if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado) then
		if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado and opc_empleado_bloqueado != iOpc_empleado_bloqueado and opc_empleado_bloqueado = 1) then
			update	cat_usuarios_externos
			set	opc_empleado_bloqueado = 0
			where	idu_empleado = iEmpleado;
			iEstatus := 2;
			cMsg:= 'Usuario desbloqueado correctamente';
		end if;

		if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado and opc_empleado_bloqueado != iOpc_empleado_bloqueado and opc_empleado_bloqueado = 0) then
			update	cat_usuarios_externos
			set	opc_empleado_bloqueado = 1
			where	idu_empleado = iEmpleado;
			iEstatus := 2;
			cMsg:= 'Usuario bloqueado correctamente';
		end if;
	else*/
		if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado) then
			update	cat_usuarios_externos
			set	opc_empleado_bloqueado	=	iOpc_empleado_bloqueado
				,opc_indefinido		=	iOpc_indefinido
				,fec_inicial		=	dFechaInicial
				,fec_final		=	dFechaFinal
				,idu_empleado_registro	=	iUsuario
			where	idu_empleado		=	iEmpleado;
			iEstatus := 2;
			cMsg:= 'Usuario actualizado correctamente';
		else
			insert into	cat_usuarios_externos (idu_empleado, opc_empleado_bloqueado, opc_indefinido, 
					fec_inicial, fec_final, fec_registro, idu_empleado_registro)
			values	(iEmpleado, iOpc_empleado_bloqueado, iOpc_indefinido, dFechaInicial, dFechaFinal, now() ,iUsuario);
			iEstatus := 1;
			cMsg := 'Usuario registrado correctamente';
		end if;	
	--end if;

	insert into tmp_Usuario(iEstado, cMensaje) values(iEstatus, cMsg);

	for valor in (select iEstado, cMensaje from tmp_Usuario)
	loop
		estado := valor.iEstado;
		mensaje:= valor.cMensaje;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_usuario_para_externos(integer, smallint, smallint, date, date, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_usuario_para_externos(integer, smallint, smallint, date, date, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_usuario_para_externos(integer, smallint, smallint, date, date, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_usuario_para_externos(integer, smallint, smallint, date, date, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_usuario_para_externos(integer, smallint, smallint, date, date, integer) IS 'La función agrega o modifica un usuario para que pueda capturar facturas de externos.';  