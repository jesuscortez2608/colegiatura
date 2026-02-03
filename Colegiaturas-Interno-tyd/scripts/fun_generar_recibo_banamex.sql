drop function if exists fun_generar_recibo_banamex(integer, date);
drop type if exists type_recibo_banamex;

CREATE TYPE type_recibo_banamex AS
   (linea character varying(219));
   
CREATE OR REPLACE FUNCTION fun_generar_recibo_banamex(integer, date)
  RETURNS SETOF type_recibo_banamex AS
$BODY$
DECLARE
	/*
	Fecha                          : 19/01/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Postgres Administracion
	Usuario de BD                  : sysgenexus
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 
	Descripción del funcionamiento : Obtiene las líneas que conformarán el recibo de pagos de
	                                 colegiaturas para Banamex
	Descripción del cambio         : No aplica
	Sistema                        : Colegiaturas
	Módulo                         : Generación de recibo para Banamex
	Ejemplo                        : 
		select linea from fun_generar_recibo_banamex(95194185::integer, '20170310'::date);
		
		update his_generacion_pagos_colegiaturas set clv_rutapago = 6
		where fec_generacion::date = '20131129'::date
	------------------------------------------------------------------------------------------------------ */
	iEmpleado alias for $1; -- Empleado que genera el archivo
	dFecha alias for $2;    -- Fecha de los movimientos
	iRutaPago integer = 2;
	cNombreArchivoGenerado varchar(50);
	returnrec type_recibo_banamex;
BEGIN
	create local temp table tmp_archivo (
		linea varchar(219)
	) on commit drop;
	
	insert into tmp_archivo (linea) values ('');
	insert into tmp_archivo (linea) values ('    COLEGIATURAS');
	insert into tmp_archivo (linea) values ('        ');
	insert into tmp_archivo (linea) values ('        ');
	
	-- Nombre del archivo generado para Banamex (0012013112204.dat)
	cNombreArchivoGenerado := '001' || to_char(dFecha::date,'yyyy') || to_char(dFecha,'mm') || to_char(dFecha,'dd') || '04.dat';
	insert into tmp_archivo (linea) values ('          REPORTE DE MOVIMIENTOS GENERADOS A PAGO CON TARJETA BANAMEX: ' || cNombreArchivoGenerado);
	insert into tmp_archivo (linea) values ('');
	
	if exists(select * from his_generacion_pagos_colegiaturas where fec_generacion::date = dFecha::date and clv_rutapago = iRutaPago and opc_cheque = 0 limit 1) then
		-- Total de empleados
		insert into tmp_archivo (linea)
				select '                         TOTAL DE EMPLEADOS : '::varchar -- tipo_registro
					|| lpad(count(distinct mov.idu_empleado)::varchar,5,'0') -- número de empleados
				from his_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
		
		-- Total de cuentas
		insert into tmp_archivo (linea)
				select '                         TOTAL DE CUENTAS   : '::varchar -- tipo_registro
					|| lpad(count(distinct mov.num_cuenta)::varchar,5,'0') -- número de cuentas
				from his_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
		
		-- Importe del pago generado
		insert into tmp_archivo (linea)
				select '                         IMPORTE DEL PAGO GENERADO : '::varchar -- tipo_registro
					|| to_char(sum(mov.importe_pagado::float), '999G999G999D99')-- importe de facturas
				from his_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
	ELSE
		-- Total de empleados
		insert into tmp_archivo (linea)
				select '                         TOTAL DE EMPLEADOS : '::varchar -- tipo_registro
					|| lpad(count(distinct mov.idu_empleado)::varchar,5,'0') -- número de empleados
				from mov_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
				
		-- Total de cuentas
		insert into tmp_archivo (linea)
				select '                         TOTAL DE CUENTAS   : '::varchar -- tipo_registro
					|| lpad(count(distinct mov.num_cuenta)::varchar,5,'0') -- número de cuentas
				from mov_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
		
		-- Importe del pago generado
		insert into tmp_archivo (linea)
				select '                         IMPORTE DEL PAGO GENERADO : '::varchar -- tipo_registro
					|| to_char(sum(mov.importe_pagado::float), '999G999G999D99')-- importe de facturas
				from mov_generacion_pagos_colegiaturas mov
				where mov.clv_rutapago = iRutaPago
					and mov.fec_generacion::date = dFecha::date
					and mov.fec_cancelacion::date = '1900-01-01'::date
					and mov.opc_cheque = 0
				group by mov.clv_rutapago, mov.fec_generacion;
	END IF;
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