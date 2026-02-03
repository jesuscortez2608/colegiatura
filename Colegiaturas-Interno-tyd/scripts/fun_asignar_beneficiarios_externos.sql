CREATE OR REPLACE FUNCTION fun_asignar_beneficiarios_externos(IN iempleado integer, IN sbeneficiarios text, IN iusuario integer, OUT estado smallint, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
declare
	valor record;
	sQuery text;
	iEstado smallint;
	cMensaje varchar(150);
begin

	create temp table tmp_Asignados(
	iEstatus integer
	,cMsg varchar(150)
	)on Commit drop;
	--FecActual := select to_char(now(),'yyyy/mm/dd');

if exists(select idu_empleado from cat_usuarios_externos where idu_empleado = iEmpleado) then
	if(SELECT (cast (now() as date) between fec_inicial and fec_final or opc_indefinido = 1) and (opc_empleado_bloqueado != 1) from cat_usuarios_externos where idu_empleado = iEmpleado) then
		delete from mov_beneficiarios_asignados where idu_empleado = iEmpleado;

		sQuery := 'INSERT INTO	mov_beneficiarios_asignados(idu_empleado, idu_beneficiario, idu_empleado_registro)';
		sQuery := sQuery || 'SELECT ' || iEmpleado::varchar || 'AS idu_empleado';
		sQuery := sQuery || ', idu_beneficiario ';
		sQuery := sQuery || ', ' || iUsuario::varchar || 'AS idu_empleado_registro' ;
		sQuery := sQuery || ' FROM cat_beneficiarios_externos ';
		sQuery := sQuery || 'WHERE idu_beneficiario IN (' || sBeneficiarios || ') ';
		iEstado := 1;
		cMensaje := 'Beneficiarios asignados correctamente';

		execute(sQuery);
	else
		iEstado := 3;
		cMensaje:= 'El colaborador no tiene permisos vigentes';
	end iF;
else
	iEstado := 2;
	cMensaje:= 'El colaborador no tiene permisos asignados';
end if;

	insert into tmp_Asignados(iEstatus, cMsg) values (iEstado, cMensaje);

	for valor in (select iEstatus, cMsg from tmp_Asignados)
	loop
		estado := valor.iEstatus;
		mensaje:= valor.cMsg;
		return next;
	End loop;	
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  GRANT EXECUTE ON FUNCTION fun_asignar_beneficiarios_externos(integer, text, integer) TO sysinternet;
  GRANT EXECUTE ON FUNCTION fun_asignar_beneficiarios_externos(integer, text, integer) TO syspersonal;
  GRANT EXECUTE ON FUNCTION fun_asignar_beneficiarios_externos(integer, text, integer) TO sysetl;
  GRANT EXECUTE ON FUNCTION fun_asignar_beneficiarios_externos(integer, text, integer) TO postgres;
  COMMENT ON FUNCTION fun_asignar_beneficiarios_externos(integer, text, integer) IS 'La función asigna beneficiarios externos a un usuario que ha sido autorizado para externos.';