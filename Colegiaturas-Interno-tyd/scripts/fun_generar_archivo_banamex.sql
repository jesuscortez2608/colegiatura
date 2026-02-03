drop function if exists fun_generar_archivo_banamex(integer, date);
drop type if exists type_archivo_banamex;

CREATE TYPE type_archivo_banamex AS
   (linea character varying(300));
   
CREATE OR REPLACE FUNCTION fun_generar_archivo_banamex(integer, date)
  RETURNS SETOF type_archivo_banamex AS
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
	                                 colegiaturas para Banamex
	Descripción del cambio         : Raul Verdugo 22/12/2014:Se agrego insert a la tabla mov_datos_envio_sat para dejar registro de los movimientos
	Sistema                        : Colegiaturas 
	Módulo                         : Generación de archivo para Banamex
	Ejemplo                        : 
		select * from fun_generar_archivo_banamex(95194185::integer, '20170310'::date);
		select * from fun_generar_archivo_banamex(95194185::integer, '20161222'::date);
		select * from fun_generar_archivo_banamex(95194185::integer, '20130627'::date);
		update his_generacion_pagos_colegiaturas set clv_rutapago = 2
		update mov_generacion_pagos_colegiaturas set clv_rutapago = 2
		-- his_generacion_pagos_colegiaturas
        -- mov_generacion_pagos_colegiaturas
		-- reparar nombres de empleado
		update mov_generacionpagocolegiaturas set nom_apellidopaterno = emp.nom_empapellidopaterno,
			nom_apellidomaterno = emp.nom_empapellidomaterno,
			nom_empleado = emp.nom_empleado
		from cat_empleadoslinea_gx as emp 
		where emp.idu_empleado = num_empleado;
	------------------------------------------------------------------------------------------------------ */
	iEmpleado alias for $1; -- Empleado que genera el archivo
	dFecha alias for $2;    -- Fecha de los movimientos
	returnrec type_archivo_banamex;
	iRutaPago integer = 2;
BEGIN
	DELETE from mov_datos_envio_sat
	WHERE LTRIM(RTRIM(clv_banco_origen)) = cast(iRutaPago AS CHAR)
	AND date(fec_transferencia) = dFecha;

	create local temp table tmp_archivo (
		linea varchar(300)
	)on commit drop;
	
	--mov_generacionpagocolegiaturas
	--create table tmp_archivo(linea varchar(219));
	--drop table tmp_archivo;
	
	/* (tipo_registro = 1) Cifras de control
	------------------------------------------------- */
    insert into tmp_archivo (linea)
        select '1'::varchar -- tipo_registro
            || '000009096644'::varchar -- numero_cliente
            || to_char(dFecha,'dd') || to_char(dFecha,'mm') || to_char(dFecha,'yy') -- fecha_pago
            || '0003'::varchar -- secuencia
            || 'COPPEL S.A. DE C.V.                                     ' -- nombre_empresa
            || '05'::varchar -- naturaleza
            || repeat(' ', 40) -- instrucciones
            || 'B'::varchar -- version
            || '0'::varchar -- volumen
            || '0'::varchar; -- caracteristicas
            
    if not exists(select * from his_generacion_pagos_colegiaturas where fec_generacion::DATE = dFecha::DATE and clv_rutapago = iRutaPago and opc_cheque = 0 limit 1) then
        /* (tipo_registro = 2) Datos globales 
        ------------------------------------------------- */
        insert into tmp_archivo (linea)
            select '2'::varchar -- tipo_registro
                || '1'::varchar -- clave_operacion
                || '001'::varchar -- clave_moneda
                || right('000000000000000000' || sum((mov.importe_pagado * 100)::INTEGER)::varchar, 18) -- importe
                || '01'::varchar -- tipo_cuenta
                || '0441'::varchar -- numero_sucursal
                || '00000000000001669136' -- numero_cuenta
                || repeat(' ', 20) -- espacio_blanco
            from mov_generacion_pagos_colegiaturas mov
            where mov.clv_rutapago = iRutaPago
                and mov.fec_generacion::DATE <= dFecha::date
                and mov.fec_cancelacion::date = '1900-01-01'::date
                and mov.opc_cheque = 0;
                
        /* (tipo_registro = 3) Registros de datos 
        ------------------------------------------------- */
            insert into tmp_archivo (linea)
                select '3'::varchar -- tipo_registro
                    || '0'::varchar -- clave_operacion
                    || '001'::varchar -- clave_moneda
                    || lpad(trim(sum((mov.importe_pagado * 100)::INTEGER)::varchar), 18, '0') --importe
                    || case when mov.num_sucursal = 0 then '03' else '01' end -- tipo_cuenta
                    || lpad(trim(mov.num_sucursal::varchar), 4, '0') -- numero_sucursal
                    || lpad(trim(mov.num_cuenta::varchar), 16, '0') -- numero_cuenta
                    || '    ' -- 4 espacios en blanco
                    || lpad(trim(mov.idu_empleado::varchar), 10, '0') -- referencia_ope (numero del empleado)
                    || repeat(' ', 30) -- 30 espacios en blanco
                    || rpad( trim(mov.ape_paterno) || ' ' || trim(mov.ape_materno) || ' ' || trim(mov.nom_empleado) || 'NULL', 98, ' ') -- beneficiario (nombre del empleado)
                    || case when mov.num_sucursal = 0 then repeat(' ', 24)
                            || '00' -- cve_estado 
                            || '0000' -- cve_ciudad
                            || repeat('0', 4) 
                        else repeat('0', 30) 
                            || repeat('0', 4)
                        end -- cve_banco
                from mov_generacion_pagos_colegiaturas mov
                where mov.clv_rutapago = iRutaPago
                    and mov.fec_generacion::DATE <= dFecha::DATE
                    and mov.fec_cancelacion::date = '1900-01-01'::date
                    and mov.opc_cheque = 0
                GROUP BY mov.idu_empleado, mov.num_sucursal, mov.num_cuenta, mov.ape_paterno, mov.ape_materno, mov.nom_empleado;
                
        /* (tipo_registro = 4) Total 
        ------------------------------------------------- */
            insert into tmp_archivo (linea)
                select '4'::varchar -- tipo_registro
                    || '001'::varchar -- clave_moneda
                    || lpad(count(distinct mov.idu_empleado)::varchar,6,'0') -- numero_abonos
                    || lpad(sum((mov.importe_pagado * 100)::INTEGER)::varchar,18,'0') -- importe_abonos
                    || lpad('1', 6, '0')-- numero_cargos
                    || lpad(sum((mov.importe_pagado * 100)::INTEGER)::varchar,18,'0') -- importe_cargos
                from mov_generacion_pagos_colegiaturas mov
                where mov.clv_rutapago = iRutaPago
                    and mov.fec_generacion::DATE <= dFecha::DATE
                    and mov.fec_cancelacion::date = '1900-01-01'::date
                    and mov.opc_cheque = 0;
                    
        /*
          Insertar los datos en la tabla para dejar
          los registros
        ------------------------------------------------- */
            insert into mov_datos_envio_sat(clv_cuenta_origen,clv_banco_origen,clv_sucursal_origen,imp_monto
                        ,clv_cuenta_destino,clv_banco_destino,clv_sucursal_destino
                        ,fec_transferencia,num_empleado,nom_empleado
                        ,clv_salida,num_empleado_capturo,fec_capturo)
                select b.clv_cuenta_origen,b.clv_banco_origen,b.clv_sucursal_origen,(a.importe_pagado * 100)::INTEGER
                    ,a.num_cuenta,CAST(iRutaPago AS CHAR),a.num_sucursal
                    ,dFecha,a.idu_empleado,a.ape_paterno ||' '|| a.ape_materno ||' '|| a.nom_empleado
                    ,'1',iEmpleado,NOW()
                from mov_generacion_pagos_colegiaturas AS a 
                    inner join cat_datos_bancos as b on a.clv_rutapago = cast(b.clv_banco_origen as int)
                where b.clv_salida = 1
                    and a.clv_rutapago =  iRutaPago
                    and a.fec_generacion::DATE = dFecha
                    and a.fec_cancelacion::date = '1900-01-01'::date
                    and a.opc_cheque = 0;
            
            update mov_datos_envio_sat set clv_rfc_empleado = sapcatalogoempleados.rfc
            from sapcatalogoempleados
            where mov_datos_envio_sat.clv_rfc_empleado = ''
                and mov_datos_envio_sat.num_empleado = sapcatalogoempleados.numemp;
    else
        /* (tipo_registro = 2) Datos globales 
        ------------------------------------------------- */
        insert into tmp_archivo (linea)
            select '2'::varchar -- tipo_registro
                || '1'::varchar -- clave_operacion
                || '001'::varchar -- clave_moneda
                || right('000000000000000000' || sum((importe_pagado * 100)::INTEGER)::varchar, 18) -- importe
                || '01'::varchar -- tipo_cuenta
                || '0441'::varchar -- numero_sucursal
                || '00000000000001669136' -- numero_cuenta
                || repeat(' ', 20) -- espacio_blanco
            from his_generacion_pagos_colegiaturas mov
            where mov.clv_rutapago = iRutaPago
                and mov.fec_generacion::DATE = dFecha::DATE
                and mov.fec_cancelacion::date = '1900-01-01'::date
                and mov.opc_cheque = 0;
                
        /* (tipo_registro = 3) Registros de datos 
        ------------------------------------------------- */
            insert into tmp_archivo (linea)
                select '3'::varchar -- tipo_registro
                    || '0'::varchar -- clave_operacion
                    || '001'::varchar -- clave_moneda
                    || lpad(trim(sum((mov.importe_pagado * 100)::INTEGER)::varchar), 18, '0') --importe
                    || case when mov.num_sucursal = 0 then '03' else '01' end -- tipo_cuenta
                    || lpad(trim(mov.num_sucursal::varchar), 4, '0') -- numero_sucursal
                    || lpad(trim(mov.num_cuenta::varchar), 16, '0') -- numero_cuenta
                    || '    ' -- 4 espacios en blanco
                    || lpad(trim(mov.idu_empleado::varchar), 10, '0') -- referencia_tope (numero del empleado)
                    || repeat(' ', 30) -- 30 espacios en blanco
                    || rpad( trim(mov.ape_paterno) || ' ' || trim(mov.ape_materno) || ' ' || trim(mov.nom_empleado) || 'NULL', 98, ' ') -- beneficiario (nombre del empleado)
                    || case when mov.num_sucursal = 0 then repeat(' ', 24)
                            || '00' -- cve_estado 
                            || '0000' -- cve_ciudad
                            || repeat('0', 4) 
                        else repeat('0', 30) 
                            || repeat('0', 4)
                        end -- cve_banco
                from his_generacion_pagos_colegiaturas mov
                where mov.clv_rutapago = iRutaPago
                    and mov.fec_generacion::DATE = dFecha::DATE
                    and mov.fec_cancelacion::date = '1900-01-01'::date
                    and mov.opc_cheque = 0
                GROUP BY mov.idu_empleado, mov.num_sucursal, mov.num_cuenta, mov.ape_paterno, mov.ape_materno, mov.nom_empleado;
                
        /* (tipo_registro = 4) Total 
        ------------------------------------------------- */
            insert into tmp_archivo (linea)
                select '4'::varchar -- tipo_registro
                    || '001'::varchar -- clave_moneda
                    || lpad(count(distinct mov.idu_empleado)::varchar,6,'0') -- numero_abonos
                    || lpad(sum((mov.importe_pagado * 100)::INTEGER)::varchar,18,'0') -- importe_abonos
                    || lpad('1', 6, '0')-- numero_cargos
                    || lpad(sum((mov.importe_pagado * 100)::INTEGER)::varchar,18,'0') -- importe_cargos
                from his_generacion_pagos_colegiaturas mov
                where mov.clv_rutapago = iRutaPago
                    and mov.fec_generacion::DATE = dFecha::DATE
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