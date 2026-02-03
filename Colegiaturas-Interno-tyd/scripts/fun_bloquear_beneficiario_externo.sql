CREATE OR REPLACE FUNCTION fun_bloquear_beneficiario_externo(IN ibeneficiario integer, IN iusuario integer, OUT estado smallint, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
/*
	No.Petición:			16559.1
	Fecha:				23/04/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Captura de Externos
	Ejemplo:			--	SELECT * FROM fun_bloquear_beneficiario_externo(72, 98439677)
*/
	valor record;
	iEstatus integer;
	cMsg character varying(50);
 begin

	create temp table tmp_beneficiario(
	iEstado smallint,
	cMensaje character varying(50)
	)on commit drop;

	if exists(select idu_empleado from cat_beneficiarios_externos where idu_beneficiario = iBeneficiario) then
		if(select opc_beneficiario_bloqueado from cat_beneficiarios_externos where idu_beneficiario = iBeneficiario)= 1 then
			update	cat_beneficiarios_externos
			set	opc_beneficiario_bloqueado = 0,
				idu_empleado_registro = iUsuario
			where	idu_beneficiario = iBeneficiario;
			
			-- Se rechazan las facturas del beneficiario (idu_estatus = 3)
			update	mov_facturas_colegiaturas
			set	idu_estatus = 0
				, des_observaciones = ''
				, fec_marco_estatus = now()
				, emp_marco_estatus = iUsuario
			where	idu_beneficiario_externo = iBeneficiario;
			
			iEstatus := 2;
			cMsg:='Se ha desbloqueado el beneficiario';
		else
			update	cat_beneficiarios_externos
			set	opc_beneficiario_bloqueado = 1,
				idu_empleado_registro = iUsuario
			where	idu_beneficiario = iBeneficiario;

			-- Se actualizan las facturas del externo a estatus PENDIENTE (0)
			update	mov_facturas_colegiaturas
			set	idu_estatus = 3
				, des_observaciones = 'RECHAZADA POR SISTEMA AL BLOQUEAR EL BENEFICIARIO'
				, fec_marco_estatus = now()
				, emp_marco_estatus = iUsuario
			where	idu_beneficiario_externo = iBeneficiario;
			iEstatus := 1;
			cMsg:='Se ha bloqueado el beneficiario';
		end if;
	end if;

	insert into tmp_beneficiario(iEstado, cMensaje) values (iEstatus, cMsg);

	for valor in (select iEstado, cMensaje from tmp_beneficiario)
	loop
		estado	:=	valor.iEstado;
		mensaje :=	valor.cMensaje;
		return next;
	end loop;
 end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_bloquear_beneficiario_externo(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_bloquear_beneficiario_externo(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_bloquear_beneficiario_externo(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_bloquear_beneficiario_externo(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_bloquear_beneficiario_externo(integer, integer) IS 'La función bloquea un beneficiario externo para que no aparezca en el listado de beneficiarios al dar de alta sus facturas.';  