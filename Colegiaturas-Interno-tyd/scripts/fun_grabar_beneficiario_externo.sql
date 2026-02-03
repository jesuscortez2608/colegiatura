DROP FUNCTION IF EXISTS fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_beneficiario_externo(IN ibeneficiario integer, IN iempleado integer, IN snombreempleado character varying, IN idescuento integer, IN ibeneficiariobloqueado integer, IN iusuario integer, OUT estado integer, OUT mensaje character varying)
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
	Ejemplo:			--	select * from fun_grabar_beneficiario_externo (0, 98439677, 'RAFAEL RAMOS GUTIÉRREZ', 90, 0, 98439677)
	Ejemplo:			--	select * from fun_grabar_beneficiario_externo (0, 95194185, 'PAIMI ARIZMENDI LOPEZ', 90, 0, 98439677)
                    -- select * from fun_grabar_beneficiario_externo (0, 0, 'JUAN LOPEZ', 90, 0, 98439677)
					--	select * from fun_grabar_beneficiario_externo (1, 98439677, 'RAFAEL RAMOS GUTIÉRREZ', 99, 1, 98439677)
					--	select * from fun_grabar_beneficiario_externo (0, 0, 'JOSE LUIS RODRIGUEZ PEREZ', 80, 0, 95194185)
					DELETE FROM cat_beneficiarios_externos;
                    SELECT EXISTS(select *
                    from cat_beneficiarios_externos 
                    where idu_empleado = 0 AND 
                        TRIM(nom_empleado) = TRIM('RAFAEL RAMOS GUTIÉRREZ'));
-----------------------------------------*/
	valor	record;
	iEstatus integer;
	iIduBeneficiario INTEGER;
	cMsg varchar(150);
begin
	create temp table tmp_beneficiario(
		iEstado integer not null default 0,
		cMensaje varchar(150) not null default ''
	) on commit drop;
	RAISE NOTICE '%', sNombreEmpleado;

	if (iEmpleado > 0) then
		sNombreEmpleado := (select TRIM(nombre) || ' ' || TRIM(apellidopaterno) || ' ' || TRIM(apellidomaterno)  from sapcatalogoempleados where numempn = iEmpleado or numemp::integer = iEmpleado);
	end if;
	--IF exists(select numempn from sapcatalogoempleados where numempn = iEmpleado or numemp = 'iEmpleado'::varchar  /*and trim(sNombreEmpleado) = ' '*/) THEN
	--	sNombreEmpleado := (select TRIM(nombre) || ' ' || TRIM(apellidopaterno) || ' ' || TRIM(apellidomaterno)  from sapcatalogoempleados where (CASE WHEN numempn = 0 then numemp::integer end) = iEmpleado LIMIT 1);
	--END IF;
	RAISE NOTICE '%', sNombreEmpleado;
	if(iBeneficiario = 0) then
		if exists(select 1 from cat_beneficiarios_externos where idu_empleado = iEmpleado AND TRIM(nom_empleado) = TRIM(sNombreEmpleado)) then
			iEstatus := -2;
			cMsg := 'Ya existe un beneficiario externo con estas características';
		else
			if (iEmpleado > 0 AND exists(select numempn from sapcatalogoempleados where numempn = iEmpleado or numemp::INTEGER = iEmpleado) ) then
				insert into	cat_beneficiarios_externos (idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro)
				values		(iEmpleado, sNombreEmpleado, iDescuento, iBeneficiarioBloqueado, now(), iUsuario) RETURNING idu_beneficiario INTO iIduBeneficiario;

				/*
				update	cat_beneficiarios_externos a
				set	nom_empleado = b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno
				from	sapcatalogoempleados b
				where	a.idu_empleado = b.numempn;
				*/
				iEstatus := iIduBeneficiario;
				cMsg:= 'Beneficiario agregado exitosamente';
			else
				RAISE NOTICE '%', sNombreEmpleado;
				insert into	cat_beneficiarios_externos(idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro)
				values		(iEmpleado, sNombreEmpleado, iDescuento, iBeneficiarioBloqueado, now(), iUsuario) RETURNING idu_beneficiario INTO iIduBeneficiario;
				iEstatus := iIduBeneficiario;
				cMsg:= 'Beneficiario agregado exitosamente';
			end if;
		end if;
	else
		update 	cat_beneficiarios_externos
		set	prc_descuento = iDescuento,
			--opc_beneficiario_bloqueado = iBeneficiarioBloqueado, 
			fec_registro = now(),
			idu_empleado_registro = iUsuario
		where	idu_beneficiario = iBeneficiario;
		iEstatus := 2;
		cMsg := 'Beneficiario actualizado exitosamente';
	end if;
	insert into tmp_beneficiario(iEstado, cMensaje) values (iEstatus, cMsg);

	for valor in (select iEstado, cMensaje from tmp_beneficiario)
	loop
		estado := valor.iEstado;
		mensaje:= valor.cMensaje;
		return next;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_beneficiario_externo(integer, integer, character varying, integer, integer, integer) IS 'La función graba un beneficiario externo en la tabla cat_beneficiarios_externos.';
