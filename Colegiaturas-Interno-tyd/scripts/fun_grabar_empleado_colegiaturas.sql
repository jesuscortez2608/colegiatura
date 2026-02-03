DROP FUNCTION if exists fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying)
  RETURNS integer AS
$BODY$
/*
	No. petición APS               : 8613.1
	Fecha                          : 13/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Inserta o actualiza un empleado en la tabla cat_empleados_colegiaturas
	==============================================================================================================
	Número empleado                : 97695068
	Modifico		       : Hector Medina Escareño
	Descripción del cambio         : Se registrara en la bitacora "mov_bitacora_movimientos_colegiaturas" cuando a un empleado se le cambie el estatus de bloqueado.
	==============================================================================================================
	Número empleado		       : 98439677
	Fecha			       : 26/03/2018
	Modifico		       : Rafael Ramos Gutiérrez
	Descripción del cambio	       : Se registra en la bitacora "mov_bitacora_movimientos_colegiaturas" cuando a un empleado se le cambie el estatus de especial
	==============================================================================================================
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Empleados con Colegiatuta
	Ejemplo                        : 
	
				SELECT * FROM fun_grabar_empleado_colegiaturas(97695068, 1, 0, 1, 93902761);

		-- // === TABLAS INVOLUCRADAS === // --
		-- SELECT * FROM cat_empleados_colegiaturas WHERE opc_empleado_bloqueado = 1;
		-- SELECT * FROM cat_tipos_movimientos_bitacora;  	// -- Tabla catalogo de Movimientos.
		-- SELECT * FROM mov_bitacora_movimientos_colegiaturas; // -- Registro de movimientos. -- BITACORA
		-- SELECT * FROM cat_empleados_colegiaturas WHERE opc_especial = 1;
*/
DECLARE
	iEmpleado alias for $1;
	iLimitado alias for $2;
	iEspecial alias for $3;
	iBloqueado alias for $4;
	iCapturo alias for $5;
	sJustificacionBloqueo alias for $6;
	sJustificacionEspecial alias for $7;
	iDiasAntiguedad INTEGER;
	resultado int;
BEGIN
	IF EXISTS (select idu_empleado FROM cat_empleados_colegiaturas WHERE idu_empleado = iEmpleado) THEN
		--// ACTUALIZAR EMPLEADO //--
		
		-- Validar si el Estatus de 'Bloqueado' ha cambiado.
		IF NOT EXISTS(SELECT idu_empleado FROM cat_empleados_colegiaturas WHERE idu_empleado = iEmpleado AND opc_empleado_bloqueado = iBloqueado) THEN
			-- El empleado tiene el estatus bloqueado diferente al actual, por lo tanto se registra en la bitacora.
			INSERT INTO mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento, idu_factura, idu_empleado_bloqueado, opc_bloqueado, idu_empleado_registro, des_justificacion)
			VALUES(2, 0, iEmpleado, iBloqueado, iCapturo, sJustificacionBloqueo);
		END IF;

		-- Validar si el Estatus de "Especial", ha cambiado.
		if exists(select idu_empleado from cat_empleados_colegiaturas where idu_empleado = iEmpleado and opc_especial != iEspecial and opc_especial = 1) then
			insert into mov_bitacora_movimientos_colegiaturas (idu_tipo_movimiento, idu_factura, idu_empleado_especial, opc_bloqueado, idu_empleado_registro, des_justificacion_especial)
			values(5, 0, iEmpleado, iBloqueado, iCapturo, sJustificacionEspecial);
		END IF;
		
		if exists(select idu_empleado from cat_empleados_colegiaturas where idu_empleado = iEmpleado and opc_especial != iEspecial and opc_especial = 0) then
			insert into mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento, idu_factura, idu_empleado_especial, opc_bloqueado, idu_empleado_registro,  des_justificacion_especial)
			values(4, 0, iEmpleado, iBloqueado, iCapturo, sJustificacionEspecial);
		end if;

		-- Actualizar el registro del empleado
		UPDATE cat_empleados_colegiaturas
		SET opc_limitado = iLimitado,
			opc_especial = iEspecial,
			opc_empleado_bloqueado = iBloqueado,
			idu_empleado_registro = iCapturo,
			fec_registro = now()
		WHERE idu_empleado = iEmpleado;
		resultado:= 2;
	ELSE
		--// INSERTAR NUEVO EMPLEADO //--
		-- Insertar los datos del nuevo empleado.
		INSERT INTO cat_empleados_colegiaturas(idu_empleado,opc_limitado, opc_especial, opc_empleado_bloqueado, fec_registro, idu_empleado_registro)
		VALUES (iEmpleado, iLimitado, iEspecial, iBloqueado, now(),iCapturo);

		if(iEspecial = 1)then
			insert into mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento, idu_factura, idu_empleado_especial, idu_empleado_registro, des_justificacion_especial)
			values (4, 0, iEmpleado, iCapturo, sJustificacionEspecial);
		end if;
		if(iBloqueado = 1)then
			insert into mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento, idu_factura, idu_empleado_bloqueado, opc_bloqueado, idu_empleado_registro, des_justificacion)
			values (2, 0, iEmpleado, iBloqueado, iCapturo, sJustificacionBloqueo);
		end if;

		update	cat_empleados_colegiaturas set idu_rutapago = cast (emp.controlpago as integer)
		from	sapcatalogoempleados emp
		where	emp.numempn = iEmpleado;
		resultado:= 1;

		iDiasAntiguedad := (SELECT date_part('day',now() - fechaalta) from sapcatalogoempleados where numempn = iEmpleado);
					--SELECT date_part('day',now() - fechaalta) from sapcatalogoempleados where numempn = 97293628
		--iDiasAntiguedad := (select now()::date- fechaalta::Date from sapcatalogoempleados where numempn = iEmpleado);

		IF iDiasAntiguedad <= 365 THEN
			insert into mov_bitacora_movimientos_colegiaturas (idu_tipo_movimiento, idu_empleado_especial, idu_empleado_registro, idu_factura)
			values(7, iEmpleado, iCapturo, 0);
		END IF;

	END IF;
		if iBloqueado=1 then
		update mov_facturas_colegiaturas set idu_estatus = 3
			, emp_marco_estatus = iCapturo
			, fec_marco_estatus = now()
			, des_observaciones = 'RECHAZADA POR SISTEMA AL BLOQUEAR AL COLABORADOR: "' || sJustificacionBloqueo || '"'
		WHERE idu_estatus in (0,1,2,4) and idu_empleado=iEmpleado and idu_beneficiario_externo = 0;

	end if;

	RETURN resultado;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_grabar_empleado_colegiaturas(integer, integer, integer, integer, integer, character varying, character varying) IS 'Graba colaboradores para beneficio de prestacion de colegiatura, asi como graba a aquellos,
colaboradores que tienen el beneficio antes de cumplir con el año de antiguedad';