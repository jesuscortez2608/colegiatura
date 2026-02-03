DROP FUNCTION IF EXISTS fun_generar_traspaso_colegiaturas(integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_generar_traspaso_colegiaturas(integer, integer, integer)
  RETURNS SETOF type_fun_generar_traspaso_colegiaturas AS
$BODY$
   DECLARE

        iOpcion		ALIAS FOR $1; --0 Validar Traspaso 1--Hacer traspaso
        iEmpleado	ALIAS FOR $2;
        iQuincena	ALIAS FOR $3;
        registros type_fun_generar_traspaso_colegiaturas;
        iResultado INTEGER;
        iTotal numeric(12,2) default 0;
        
        iCicloColegiaturas INTEGER;
        iCierreUltimoCiclo SMALLINT;
        iGeneracionIncentivos SMALLINT;
	dFechaQuincena DATE = '1900-01-01';
	dFechaUltimaQuincena DATE = '1900-01-01';
	idUltimaGeneracionPagos INTEGER;
	iEnvioIncentivos SMALLINT;
	iColaboradores BIGINT;
         /*
	     No. petición APS               : 8613.1
	     Fecha                          : 21/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.28.114.75
	     Servidor de produccion         : 10.44.2.183
	     Descripción del funcionamiento : Valida si ya se realizo el traspaso, realiza el traspaso, o cuenta los movimientos que se van a traspasar
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Traspaso 
	     Ejemplo                        : 
		 SELECT * FROM fun_generar_traspaso_colegiaturas(0,93902761);
		 SELECT * FROM fun_generar_traspaso_colegiaturas(1,93902761);
		 SELECT * FROM fun_generar_traspaso_colegiaturas(2,93902761);
		 SELECT * FROM fun_generar_traspaso_colegiaturas(1, 95194185);
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	     No. Peticion		: 16559.1
	     Fecha			: 12/09/2018
	     Colaborador		: Rafael Ramos 98439677
	     Descripcion del cambio	: Se agrega nuevo parametro de quincena, para que en el caso que al traspasar facturas, no se seleccione alguna, esta se regresa al estatus anterior, y se valida por el timpo de quincena
					  en la que se encuentre al momento de realizar el traspaso.
	*/
BEGIN
    iCicloColegiaturas := (SELECT COALESCE(MAX(idu_ciclo), 0) FROM ctl_proceso_colegiaturas);
    iCierreUltimoCiclo := (select (case when fec_cierre::date > '1900-01-01' then 1 else 0 end)::smallint from ctl_proceso_colegiaturas where idu_ciclo = iCicloColegiaturas limit 1);
    iCierreUltimoCiclo := COALESCE(iCierreUltimoCiclo, 0::SMALLINT);
    iEnvioIncentivos   := (SELECT (CASE WHEN fec_incentivos::DATE > '1900-01-01' THEN 1 ELSE 0 END)::SMALLINT FROM ctl_proceso_colegiaturas WHERE idu_ciclo = iCicloColegiaturas LIMIT 1);
    iEnvioIncentivos   := COALESCE(iEnvioIncentivos, 0::SMALLINT);
    iColaboradores := 0;

	if date_part('day', now()::DATE) <= 15 then
	    -- Día 15 del mes
	    dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
	    dFechaQuincena = dFechaQuincena::DATE;
	else
	    -- Último día del mes
	    dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
	    dFechaQuincena = dFechaQuincena::DATE;
	end if;
    
	IF iOpcion=0 THEN -- VALIDA TRASPASO
		IF EXISTS(select * from mov_facturas_colegiaturas WHERE fec_movimiento_traspaso::DATE = NOW()::DATE limit 1)
		OR EXISTS(select * from mov_ajustes_facturas_colegiaturas WHERE fec_traspaso::DATE = NOW()::DATE limit 1) THEN
			iResultado:=1;
		ELSE
			iResultado:=0;
		END IF;
	ELSIF iOpcion=1 THEN -- REALIZAR TRASPASO
		UPDATE	mov_facturas_colegiaturas SET opc_movimiento_traspaso=1
			, idu_empleado_traspaso=iEmpleado
			, fec_movimiento_traspaso=now()
		from	stmp_traspaso_colegiaturas tmp
		where	tmp.idfactura = mov_facturas_colegiaturas.idfactura
			and tmp.marcado = 1
			and tmp.usuario = iEmpleado
			and mov_facturas_colegiaturas.idu_empleado_traspaso = 0;

		UPDATE	mov_ajustes_facturas_colegiaturas SET idu_usuario_traspaso = iEmpleado
			, fec_traspaso = now()
		from	stmp_traspaso_colegiaturas tmp
		where	tmp.idfactura = mov_ajustes_facturas_colegiaturas.idfactura
			and tmp.marcado = 1
			and tmp.usuario = iEmpleado;
		if exists (SELECT empleado from stmp_traspaso_colegiaturas where usuario = iEmpleado and marcado = 0) then
			if (iQuincena = 1) then
				update	mov_facturas_colegiaturas
				set	opc_movimiento_traspaso = 0
					, idu_empleado_traspaso = 0
					, fec_movimiento_traspaso = '19000101'
					, emp_marco_estatus = iEmpleado
					, fec_marco_estatus = NOW()
					, idu_estatus = 1
					, des_observaciones = ''
				from	stmp_traspaso_colegiaturas as tmp
				where	tmp.idfactura = mov_facturas_colegiaturas.idfactura
					ANd tmp.marcado = 0
					and tmp.usuario = iEmpleado
					and tmp.tiponomina in (1,3);

				update	mov_ajustes_facturas_colegiaturas
				set	idu_usuario_traspaso = 0
					, fec_traspaso = '19000101'
				from	stmp_traspaso_colegiaturas as tmp
				where	tmp.idfactura = mov_ajustes_facturas_colegiaturas.idfactura
					and tmp.marcado = 0
					and tmp.usuario = iEmpleado
					and tmp.tiponomina in (1,3);

				-- Regresar de estatus a NO PAGADO en la tabla ctl_importes_facturas_mes, las facturas que no se hayan traspasado.
				update	ctl_importes_facturas_mes set pagado = 0
				from	stmp_traspaso_colegiaturas as stmp
				where	ctl_importes_facturas_mes.idfactura = stmp.idfactura
					and stmp.marcado = 0
					and stmp.usuario = iEmpleado
					and stmp.tiponomina in (1,3);
					
			elsif (iQuincena = 2) then
				update	mov_facturas_colegiaturas
				set	opc_movimiento_traspaso = 0
					, idu_empleado_traspaso = 0
					, fec_movimiento_traspaso = '19000101'
					, emp_marco_estatus = iEmpleado
					, fec_marco_estatus = NOW()
					, idu_estatus = 1
					, des_observaciones = ''
				from	stmp_traspaso_colegiaturas as tmp
				where	tmp.idfactura = mov_facturas_colegiaturas.idfactura
					ANd tmp.marcado = 0
					and tmp.usuario = iEmpleado
					and tmp.tiponomina = 1;

				update	mov_ajustes_facturas_colegiaturas
				set	idu_usuario_traspaso = 0
					, fec_traspaso = '19000101'
				from	stmp_traspaso_colegiaturas as tmp
				where	tmp.idfactura = mov_ajustes_facturas_colegiaturas.idfactura
					and tmp.marcado = 0
					and tmp.usuario = iEmpleado
					and tmp.tiponomina = 1;
					
				-- Regresar de estatus a NO PAGADO en la tabla ctl_importes_facturas_mes, las facturas que no se hayan traspasado.
				update	ctl_importes_facturas_mes set pagado = 0
				from	stmp_traspaso_colegiaturas as stmp
				where	ctl_importes_facturas_mes.idfactura = stmp.idfactura
					and stmp.marcado = 0
					and stmp.usuario = iEmpleado
					and stmp.tiponomina = 1;
			end if;

		end if;

		iResultado := count(idfactura) from stmp_traspaso_colegiaturas where usuario=iEmpleado and marcado=1;
		iTotal := sum(importe_pago)from stmp_traspaso_colegiaturas where usuario=iEmpleado and marcado=1;
		
		if iCicloColegiaturas = 0 or (iCicloColegiaturas > 0 and iCierreUltimoCiclo = 1) then
		    -- Es el primer ciclo de colegiaturas, no se ha generado el traspaso
		    insert into ctl_proceso_colegiaturas (idu_ciclo, mes, quincena
			    , fec_traspaso, usr_traspaso
			    , fec_pagos, usr_pagos
			    , fec_incentivos, usr_incentivos
			    , fec_cierre, usr_cierre)
			values (iCicloColegiaturas + 1, to_char(now(), 'YYYYMM')::INTEGER, iQuincena
			    , now(), iEmpleado
			    , '19000101'::DATE, 0
			    , '19000101'::DATE, 0
			    , '19000101'::DATE, 0);
		else
		    update ctl_proceso_colegiaturas set mes = to_char(now(), 'YYYYMM')::INTEGER
			, quincena = iQuincena
			, fec_traspaso = now()
			, usr_traspaso = iEmpleado
			, fec_pagos = '19000101'::DATE
			, usr_pagos = 0
			, fec_incentivos = '19000101'::DATE
			, usr_incentivos = 0
			, fec_cierre = '19000101'::DATE
			, usr_cierre = 0
		    where idu_ciclo = iCicloColegiaturas;
		end if;
		
		/** =======================================
			REALIZAR REGISTRO DE MOVIMIENTO
				TABLA DE BITACORA
		======================================= **/

		iColaboradores := (SELECT COUNT(DISTINCT(empleado)) from stmp_traspaso_colegiaturas where usuario = iEmpleado and marcado=1);
		
		INSERT INTO bit_proceso_colegiaturas(id_movimiento,num_facturas, num_colaboradores, fec_quincena, id_usuario)
		VALUES(1, iResultado, iColaboradores, dFechaQuincena, iEmpleado);
		/** =======================================
		======================================= **/
		
	ELSIF iOpcion=2 THEN -- CONTAR LAS FACTURAS QUE EL USUARIO HA SELECCIONADO
		iResultado:=(select count(idfactura)from stmp_traspaso_colegiaturas where usuario=iEmpleado and marcado=1);
	ELSE
		iResultado:=0;
	END IF;

	IF (iOpcion = 3) THEN

		idUltimaGeneracionPagos := (SELECT COALESCE(MAX(idu_generacion),0) FROm his_generacion_pagos_colegiaturas LIMIT 1);

		dFechaUltimaQuincena := (SELECT fec_quincena FROM mov_generacion_pagos_colegiaturas where idu_generacion = (idUltimaGeneracionPagos + 1)::INTEGER LIMIT 1 );

		if ( dFechaQuincena::DATE > dFechaUltimaQuincena::DATE
			and iCierreUltimoCiclo = 0
			AND iEnvioIncentivos = 1 ) THEN
			iResultado := 0;
		ELSE
			iResultado := 1;
		END IF;
		
	END IF;
	
	FOR registros IN 
		SELECT COALESCE(iResultado, 0), COALESCE(iTotal, 0.0)
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_generar_traspaso_colegiaturas(INTEGER, INTEGER, INTEGER) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_generar_traspaso_colegiaturas(INTEGER, INTEGER, INTEGER) TO sysinternet;