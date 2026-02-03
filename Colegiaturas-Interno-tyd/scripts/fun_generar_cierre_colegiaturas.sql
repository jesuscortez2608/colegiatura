DROP FUNCTION IF EXISTS fun_generar_cierre_colegiaturas(integer);

CREATE OR REPLACE FUNCTION fun_generar_cierre_colegiaturas(integer)
  RETURNS SETOF type_generar_cierre_colegiaturas AS
$BODY$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		delete from his_facturas_colegiaturas;
			delete from his_detalle_facturas_colegiaturas;
			delete from his_generacion_pagos_colegiaturas;
			delete from his_facturas_pagadas;
			delete from his_facturas_rechazadas;
		SELECT * FROM fun_generar_cierre_colegiaturas(95194185);
	------------------------------------------------------------------------------------------------------ */
	iUsuario alias for $1;
	returnrec type_generar_cierre_colegiaturas;
	iIduEstatus INTEGER;
	sDesEstatus VARCHAR(250);
	--iMovimientosRechazados INTEGER;
	iMovimientosPagados INTEGER = 0;
	iImporteFactura NUMERIC(15,2) = 0;
	iImportePagado NUMERIC(15,2) = 0;
	iGeneracionPagos integer;
	
	iCicloColegiaturas INTEGER;
	iIncentivosUltimoCiclo SMALLINT;
	iCierreUltimoCiclo SMALLINT;

	iColaboradores BIGINT;
	dFechaQuincena DATE = '1900-01-01';
BEGIN

    iCicloColegiaturas := (SELECT COALESCE(MAX(idu_ciclo), 0) FROM ctl_proceso_colegiaturas);
    iIncentivosUltimoCiclo := (select (case when fec_incentivos::date > '1900-01-01' then 1 else 0 end)::smallint from ctl_proceso_colegiaturas where idu_ciclo = iCicloColegiaturas limit 1);
    iCierreUltimoCiclo := (select (case when fec_cierre::date > '1900-01-01' then 1 else 0 end)::smallint from ctl_proceso_colegiaturas where idu_ciclo = iCicloColegiaturas limit 1);
    iIncentivosUltimoCiclo := COALESCE(iIncentivosUltimoCiclo, 0::SMALLINT);
    iCierreUltimoCiclo := COALESCE(iCierreUltimoCiclo, 0::SMALLINT);

    iColaboradores := 0;

	if date_part('day', now()::DATE) <= 15 then
		-- Día 15 del mes
		dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
	else
		-- Último día del mes
		dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
	end if;
    
    if iCicloColegiaturas = 0 or iCierreUltimoCiclo = 1 or iIncentivosUltimoCiclo = 0 then
        iIduEstatus := -3;
        sDesEstatus := 'Es necesaria la generación de incentivos para generar el cierre';
        FOR returnrec IN (
            select iIduEstatus
                , sDesEstatus
                , iMovimientosPagados
                , iImporteFactura
                , iImportePagado
        ) LOOP
            RETURN NEXT returnrec;
        END LOOP;
        return;
    end if;
    
	iMovimientosPagados := (SELECT COUNT(*) FROM mov_detalle_generacion_pagos_colegiaturas);
	iMovimientosPagados := COALESCE(iMovimientosPagados,0);
	--iMovimientosRechazados := (SELECT COUNT(*) FROM mov_facturas_rechazadas);
	iImporteFactura := (SELECT SUM(importe_factura) FROM mov_detalle_generacion_pagos_colegiaturas);
	iImportePagado := (SELECT SUM(importe_pagado) FROM mov_detalle_generacion_pagos_colegiaturas);
	iGeneracionPagos := (SELECT max(idu_generacion) from his_generacion_pagos_colegiaturas);
	iGeneracionPagos := coalesce(iGeneracionPagos, 0) + 1;
	
	if (iMovimientosPagados = 0) then
		iIduEstatus := -2;
		sDesEstatus := 'No se encontraron movimientos para realizar el cierre';
	else
		-- Pasar datos de la mov_facturas_colegiaturas a his_facturas_colegiaturas
		insert into his_facturas_colegiaturas(fol_fiscal
			, fol_factura
			, serie
			, fec_factura
			, des_metodo_pago
			, fol_relacionado
			, idu_empleado
			, idu_beneficiario_externo
			, idu_centro
			, idu_empresa
			, idu_puesto
			, opc_pdf
			, idu_escuela
			, rfc_clave
			, importe_factura
			, importe_calculado
			, importe_pagado
			, tope_mensual
			, idu_tipo_documento
			, idu_tipo_deduccion
			, idu_estatus
			, opc_modifico_pago
			, idu_motivo_rechazo
			, emp_marco_estatus
			, fec_marco_estatus
			, fec_cierre
			, des_comentario_especial
			, des_aclaracion_costos
			, des_observaciones
			, fec_registro
			, opc_movimiento_traspaso
			, idu_empleado_traspaso
			, fec_movimiento_traspaso
			, idu_empleado_registro
			, nom_xml_recibo
			, nom_pdf_carta
			, xml_factura
			, idfactura
			, clv_rutapago
			, num_cuenta)
		select mov.fol_fiscal
			, mov.fol_factura
			, mov.serie
			, mov.fec_factura
			, mov.des_metodo_pago
			, COALESCE(mov.fol_relacionado, '')
			, mov.idu_empleado
			, mov.idu_beneficiario_externo
			, emp.centron
			, emp.empresa
			, emp.pueston
			, mov.opc_pdf
			, mov.idu_escuela
			, mov.rfc_clave
			, mov.importe_factura
			, mov.importe_calculado
			, mov.importe_pagado
			, 0 as tope_mensual
			, mov.idu_tipo_documento
			, mov.idu_tipo_deduccion
			, case when mov.opc_movimiento_traspaso = 1 then 6 else mov.idu_estatus end as idu_estatus
			, mov.opc_modifico_pago
			, mov.idu_motivo_rechazo
			, iUsuario as emp_marco_estatus
			, now() as fec_marco_estatus
			, now() as fec_cierre
			, mov.des_comentario_especial
			, mov.des_aclaracion_costos
			, mov.des_observaciones
			, mov.fec_registro
			, mov.opc_movimiento_traspaso
			, mov.idu_empleado_traspaso
			, mov.fec_movimiento_traspaso
			, mov.idu_empleado_registro
			, mov.nom_xml_recibo
			, mov.nom_pdf_carta
			, mov.xml_factura
			, mov.idfactura
			, (case when emp.controlpago = '' then 0 else emp.controlpago::INTEGER end)
			, (case when emp.numerotarjeta = '' then '0' else emp.numerotarjeta end)
		from mov_facturas_colegiaturas mov 
		inner join sapcatalogoempleados emp on(mov.idu_empleado = emp.numempn 
							or 'mov.idu_empleado'::char = emp.numemp)
		where mov.opc_movimiento_traspaso = 1
		or (mov.idu_estatus = 3 and date_part('day',now() - mov.fec_registro::date) >= 90); -- incluir las facturas rechazadas con más de 3 meses de antigüedad (fec_captura)

		insert into his_detalle_facturas_colegiaturas(
			idu_empleado
			, fol_fiscal
			, idu_beneficiario
			, beneficiario_hoja_azul
			, idu_parentesco
			, idu_tipopago
			, prc_descuento
			, periodo
			, idu_escuela
			, idu_escolaridad
			, idu_grado_escolar
			, idu_ciclo_escolar
			, importe_concepto
			, importe_pagado
			, fec_registro
			, idu_empleado_registro
			, idfactura
			, idu_carrera
			, keyx)
		select det.idu_empleado
			, det.fol_fiscal
			, det.idu_beneficiario
			, det.beneficiario_hoja_azul
			, det.idu_parentesco
			, det.idu_tipopago
			, det.prc_descuento
			, det.periodo
			, det.idu_escuela
			, det.idu_escolaridad
			, det.idu_grado_escolar
			, det.idu_ciclo_escolar
			, det.importe_concepto
			, det.importe_pagado
			, det.fec_registro
			, det.idu_empleado_registro
			, det.idfactura
			, det.idu_carrera
			, det.keyx
		from mov_detalle_facturas_colegiaturas det
			inner join mov_facturas_colegiaturas mov on (det.idfactura = mov.idfactura)
		where mov.opc_movimiento_traspaso = 1;
		
		-- Pasar datos de la mov_generacion_pagos_colegiaturas a his_generacion_pagos_colegiaturas
		insert into his_generacion_pagos_colegiaturas(idu_empleado
			, idu_centro
			, idu_puesto
			, nom_empleado
			, ape_paterno
			, ape_materno
			, clv_rutapago
			, num_cuenta
			, num_sucursal
			, importe_factura
			, importe_pagado
			, importe_isr
			, fec_generacion
			, fec_quincena
			, idu_empleado_generacion
			, idu_generacion)
			select idu_empleado
				, idu_centro
				, idu_puesto
				, nom_empleado
				, ape_paterno
				, ape_materno
				, clv_rutapago
				, num_cuenta
				, num_sucursal
				, importe_factura
				, importe_pagado
				, importe_isr
				, fec_generacion
				, fec_quincena
				, idu_empleado_generacion
				, idu_generacion
			from mov_generacion_pagos_colegiaturas;
        
		insert into his_detalle_generacion_pagos_colegiaturas(
				idu_generacion
				, fec_generacion
				, idu_empleado
				, clv_rutapago
				, idfactura
				, idu_ajuste
				, prc_descuento
				, importe_factura
				, importe_pagado)
		select idu_generacion
			, fec_generacion
			, idu_empleado
			, clv_rutapago
			, idfactura
			, idu_ajuste
			, prc_descuento
			, importe_factura
			, importe_pagado
            from mov_detalle_generacion_pagos_colegiaturas;
		
		-- Pasar la tabla mov_ajustes_facturas_colegiaturas a his_ajustes_facturas_colegiaturas
		insert into his_ajustes_facturas_colegiaturas(idu_ajuste
				, idfactura
				, importe_factura
				, importe_pagado
				, pct_ajuste
				, importe_ajuste
				, des_observaciones
				, idu_usuario_traspaso
				, fec_traspaso
				, idu_usuario_registro
				, fec_registro
				, idu_usuario_cierre
				, fec_cierre)
		select	idu_ajuste
			, idfactura
			, importe_factura
			, importe_pagado
			, pct_ajuste
			, importe_ajuste
			, des_observaciones
			, idu_usuario_traspaso
			, fec_traspaso
			, idu_usuario_registro
			, fec_registro
			, iUsuario as idu_usuario_cierre
			, now() as fec_cierre
		from	mov_ajustes_facturas_colegiaturas
		where	idu_usuario_traspaso > 0;
		
		delete from mov_detalle_facturas_colegiaturas
		where idfactura in (select idfactura from mov_facturas_colegiaturas where opc_movimiento_traspaso = 1);

		-- Borrar también las facturas rechazadas con más de 3 meses de antigüedad
		delete from mov_facturas_colegiaturas
		where opc_movimiento_traspaso = 1
		or (idu_estatus = 3 and (select date_part('day',now() - fec_registro::date) >= 90));

		delete from	mov_ajustes_facturas_colegiaturas 
		where		idu_usuario_traspaso > 0;

		iColaboradores := (SELECT COUNT(DISTINCT(idu_empleado)) FROM mov_generacion_pagos_colegiaturas);
		
		DELETE FROM mov_generacion_pagos_colegiaturas;
		delete from mov_detalle_generacion_pagos_colegiaturas;
		
		--- ACTUALIZA EL TOPE DE LAS FACTURAS TRASPASADAS
		update his_facturas_colegiaturas set tope_mensual = cast((a.sueldo/2)/100 as numeric)
		from sapcatalogoempleados a where a.numempn= his_facturas_colegiaturas.idu_empleado and tope_mensual=0;

		insert into mov_generacion_cierre_colegiaturas (idu_empleado, fec_cierre, idu_generacion_pagos)
			values (iUsuario, now(), iGeneracionPagos);
		
		iIduEstatus := 1;
		sDesEstatus := 'Cierre finalizado exitosamente';

		/** =======================================
			REALIZAR REGISTRO DE MOVIMIENTO
				TABLA DE BITACORA
		======================================= **/

		INSERT INTO bit_proceso_colegiaturas(id_movimiento, num_facturas, num_colaboradores, fec_quincena, id_usuario)
		VALUES(6, iMovimientosPagados, iColaboradores , dFechaQuincena, iUsuario);
		/** =======================================
		======================================= **/
			
			-- Finalizar el proceso
		-------------------------------------------------------
		update ctl_proceso_colegiaturas set fec_cierre = now()
		    , usr_cierre = iUsuario
		where idu_ciclo = iCicloColegiaturas;
	end if;
	
	FOR returnrec IN (
		select iIduEstatus
			, sDesEstatus
			, iMovimientosPagados
			, iImporteFactura
			, iImportePagado
	) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_generar_cierre_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_generar_cierre_colegiaturas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_generar_cierre_colegiaturas(integer) TO sysetl;
COMMENT ON FUNCTION fun_generar_cierre_colegiaturas(integer) IS 'La función genera cierre de colegiaturas';