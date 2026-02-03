drop function if exists fun_generar_archivo_bancoppel(integer, date, date);
drop type if exists type_archivo_bancoppel;

CREATE TYPE type_archivo_bancoppel AS
   (linea character varying(219));

CREATE OR REPLACE FUNCTION fun_generar_archivo_bancoppel(integer, date, date)
  RETURNS SETOF type_archivo_bancoppel AS
$BODY$
DECLARE
	/*
	Fecha                          : 11/01/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : administracion
	Usuario de BD                  : sysgenexus
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.
	Descripción del funcionamiento : Obtiene las líneas que conformarán el archivo de pagos de
	                                 colegiaturas para bancoppel
	Descripción del cambio         : Raul Verdugo 22/12/2014:Se agrego insert a la tabla mov_datos_envio_sat para dejar registro de los movimientos
	Sistema                        : Colegiaturas 
	Módulo                         : Generación de archivo para bancoppel
	Ejemplo                        : 
		select * from fun_generar_archivo_bancoppel(95194185::integer, '20170118'::date, '20170120'::date);
		update his_generacion_pagos_colegiaturas set clv_rutapago = 6
		update mov_generacion_pagos_colegiaturas set clv_rutapago = 6
		-- reparar nombres de empleado
		update mov_generacionpagocolegiaturas set nom_apellidopaterno = emp.nom_empapellidopaterno,
			nom_apellidomaterno = emp.nom_empapellidomaterno,
			nom_empleado = emp.nom_empleado
		from cat_empleadoslinea_gx as emp 
		where emp.idu_empleado = num_empleado;
	------------------------------------------------------------------------------------------------------ */
	iEmpleado alias for $1;         -- Empleado que genera el archivo
	dFecha alias for $2;            -- Fecha de los movimientos
	dFechaAplicacion alias for $3;  -- Fecha de aplicación del pago
	iSecuencia integer = 0;
	iConsecutivo integer = 3;
	returnrec type_archivo_bancoppel;
	rec record;
	iRutaPago integer = 6;
BEGIN
	create local temp table tmp_archivo (
		linea varchar(219)
	) on commit drop;
	
	/* (tipo_registro = 1) Encabezado
	------------------------------------------------- */
		iSecuencia := iSecuencia + 1;
		insert into tmp_archivo (linea)
			select '1'::varchar -- tipo_registro
				|| lpad(trim(iSecuencia::varchar), 5, '0') -- secuencia
				|| 'E' -- sentido (Egreso)
				|| to_char(dFecha,'mm') || to_char(dFecha::date,'dd') || to_char(dFecha::date,'yyyy') -- fecha_pago dFecha
				|| left('16000000012         ', 16) -- cuenta
				|| to_char(dFechaAplicacion,'mm') || to_char(dFechaAplicacion,'dd') || to_char(dFechaAplicacion,'yyyy'); -- fecha_pago dFecha
	/* Cuerpo del archivo
	------------------------------------------------- */
		if NOT exists(select * from his_generacion_pagos_colegiaturas where fec_generacion::DATE = dFecha::DATE and clv_rutapago = iRutaPago and opc_cheque = 0 limit 1) then
            for rec in (
				select mov.idu_empleado
					, mov.nom_empleado
					, mov.ape_paterno
					, mov.ape_materno
					, mov.num_cuenta
					, sum(mov.importe_pagado) as importe_pagado
				from mov_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date <= dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				GROUP BY mov.idu_empleado, mov.nom_empleado, mov.ape_paterno, mov.ape_materno, mov.num_cuenta ) loop
				
				iSecuencia := iSecuencia + 1;
				insert into tmp_archivo (linea)
					select '2'::varchar -- tipo_registro
						|| lpad(trim(iSecuencia::varchar), 5, '0') -- secuencia
						|| left(rec.idu_empleado::varchar, 7) -- num_empleado (7 digitos)
						|| ' ' -- espacio en blanco
						|| rpad(trim(rec.ape_paterno), 30, ' ') -- apellido paterno
						|| rpad(trim(rec.ape_materno), 20, ' ') -- apellido paterno
						|| rpad(trim(rec.nom_empleado), 30, ' ') -- nombre del empleado
						|| rpad(trim(rec.num_cuenta), 16, ' ') -- número de tarjeta
						|| '04' -- concepto
						|| lpad(trim(((rec.importe_pagado * 100)::INTEGER)::varchar), 18, '0'); -- importe de la factura
			end loop;
			/* Totales
			------------------------------------------------- */
			iSecuencia := iSecuencia + 1;
			insert into tmp_archivo (linea)
				select '3'::varchar -- tipo_registro
					|| lpad(trim(iSecuencia::varchar), 5, '0') -- secuencia
					|| lpad(count(distinct mov.idu_empleado)::varchar,5,'0') -- número de empleados
					|| lpad(trim(sum((mov.importe_pagado * 100)::INTEGER)::varchar), 18, '0') -- importe
				from mov_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date <= dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0;
            
            /*Insertar los datos en la tabla para dejar los registros
            ------------------------------------------------- */
            DELETE from mov_datos_envio_sat
            WHERE LTRIM(RTRIM(clv_banco_origen)) = cast(iRutaPago AS CHAR)
                AND fec_transferencia::DATE = dFecha::date;
            
            insert into mov_datos_envio_sat(clv_cuenta_origen,clv_banco_origen,clv_sucursal_origen,imp_monto,clv_cuenta_destino,clv_banco_destino,clv_sucursal_destino,
                        fec_transferencia,num_empleado,nom_empleado,clv_salida,num_empleado_capturo,fec_capturo)
            select b.clv_cuenta_origen,b.clv_banco_origen,b.clv_sucursal_origen,a.importe_pagado::varchar,a.num_cuenta,CAST(iRutaPago AS CHAR),a.num_sucursal
                ,dFecha,a.idu_empleado,a.ape_paterno ||' '|| a.ape_materno ||' '|| a.nom_empleado,'1',iEmpleado,NOW()
            from mov_generacion_pagos_colegiaturas AS a
                inner join cat_datos_bancos as b on a.clv_rutapago = cast(b.clv_banco_origen as int)
            where b.clv_salida = 1
                and a.clv_rutapago =  iRutaPago
                and a.fec_generacion::date = dFecha::date
                and a.fec_cancelacion::date = '1900-01-01'::date
                and a.opc_cheque = 0;
			
			update mov_datos_envio_sat set clv_rfc_empleado = rfc
            from sapcatalogoempleados
            where mov_datos_envio_sat.num_empleado = sapcatalogoempleados.numemp;
		else
			for rec in (
				select mov.idu_empleado
					, mov.ape_paterno
					, mov.ape_materno
					, mov.nom_empleado
					, mov.num_cuenta
					, sum(mov.importe_pagado) as importe_pagado
				from his_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				GROUP BY mov.idu_empleado, mov.ape_paterno, mov.ape_materno, mov.nom_empleado, mov.num_cuenta ) loop
				
				iSecuencia := iSecuencia + 1;
				insert into tmp_archivo (linea)
					select '2'::varchar -- tipo_registro
						|| lpad(trim(iSecuencia::varchar), 5, '0') -- secuencia
						|| left(rec.idu_empleado::varchar, 7) -- num_empleado (7 digitos)
						|| ' ' -- espacio en blanco
						|| rpad(trim(rec.ape_paterno), 30, ' ') -- apellido paterno
						|| rpad(trim(rec.ape_materno), 20, ' ') -- apellido paterno
						|| rpad(trim(rec.nom_empleado), 30, ' ') -- nombre del empleado
						|| rpad(trim(rec.num_cuenta), 16, ' ') -- número de tarjeta
						|| '04' -- concepto
						|| lpad(trim(((rec.importe_pagado * 100)::INTEGER)::varchar), 18, '0'); -- importe pagado
			end loop;
			
			/* Totales
			------------------------------------------------- */
			iSecuencia := iSecuencia + 1;
			insert into tmp_archivo (linea)
				select '3'::varchar -- tipo_registro
					|| lpad(trim(iSecuencia::varchar), 5, '0') -- secuencia
					|| lpad(count(distinct mov.idu_empleado)::varchar,5,'0') -- número de empleados
					|| lpad(trim(sum((mov.importe_pagado * 100)::INTEGER)::varchar), 18, '0') -- importe
				from his_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0;
		end if;
	/* Devolver el resultado
	------------------------------------------------- */
	FOR returnrec IN (
		select linea
		from tmp_archivo
	) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;