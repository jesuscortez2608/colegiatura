DROP FUNCTION IF EXISTS fun_generar_pagos_colegiaturas(integer);

CREATE OR REPLACE FUNCTION fun_generar_pagos_colegiaturas(integer)
  RETURNS SETOF type_fun_generar_pagos_colegiaturas AS
$BODY$
declare
/**
	Fecha:			07/08/2018
	ColabORadOR:		98439677 Rafael Ramos
	Sistema:		Colegiaturas
	Modulo:			Generar Pagos
	Descripcion del cambio: Se modIFico estructura, y se valida que tome los ajustes en cuenta, una vez hayan sido traspasados
        SELECT * FROM fun_generar_pagos_colegiaturas(95194185::integer)
        UPDATE mov_facturas_colegiaturas set idu_empresa = 1
        mov_detalle_facturas_colegiaturas
	ModIFica: Omar Alejandro Lizárraga Hernández 94827443
	Fecha: 21-05-2019
	Descripción: Se rechazan las facturas de la tabla stmp_empleados_baja donde vienen los empleados dados de baja de la HE
        
**/

iUsuario ALIAS fOR $1;
IFacturas_traspasadas integer;
IFacturas_rechazadas integer;
iEmpleados_baja integer;
iGeneracion_Pagos integer = 0;
sumImpORteFactura numeric(12,2);
sumImpORtePagado numeric(12,2);

iCicloColegiaturas INTEGER;
iTraspasoUltimoCiclo SMALLINT;
iCierreUltimoCiclo SMALLINT;
iColaboradores BIGINT;

dFechaQuincena DATE = '1900-01-01';

returnrec type_fun_generar_pagos_colegiaturas;

BEGIN
	IFacturas_traspasadas := 0;
	IFacturas_rechazadas := 0;
	iEmpleados_baja := 0;
	iColaboradores := 0;

	iCicloColegiaturas := (SELECT COALESCE(MAX(idu_ciclo), 0) FROM ctl_proceso_colegiaturas);
	iTraspasoUltimoCiclo := (SELECT (case when fec_traspaso::date > '1900-01-01' then 1 else 0 END)::smallint FROM ctl_proceso_colegiaturas WHERE idu_ciclo = iCicloColegiaturas limit 1);
	iCierreUltimoCiclo := (SELECT (case when fec_cierre::date > '1900-01-01' then 1 else 0 END)::smallint FROM ctl_proceso_colegiaturas WHERE idu_ciclo = iCicloColegiaturas limit 1);
	iTraspasoUltimoCiclo := COALESCE(iTraspasoUltimoCiclo, 0::SMALLINT);
	iCierreUltimoCiclo := COALESCE(iCierreUltimoCiclo, 0::SMALLINT);

	IF iCicloColegiaturas = 0 OR iCierreUltimoCiclo = 1 OR iTraspasoUltimoCiclo = 0 then
	    FOR returnrec in(
		SELECT 	iGeneracion_Pagos
			, IFacturas_traspasadas
			, IFacturas_rechazadas
			, iEmpleados_baja
			, -1 as estatus
			, 'Debe generar el traspaso antes de generar los pagos' as mensaje
		)LOOP
		    RETURN NEXT returnrec;
	    END LOOP;
	    
	    return;
	END IF;

	IF date_part('day', now()::DATE) <= 15 then
	    -- Día 15 del mes
	    dFechaQuincena = (SELECT date_trunc('month', now()::date) + interval '14 day');
	else
	    -- Último día del mes
	    dFechaQuincena := (SELECT date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
	END IF;

	IFacturas_traspasadas := (SELECT COUNT(*) FROM MOV_FACTURAS_COLEGIATURAS WHERE opc_movimiento_traspaso = 1);
	IFacturas_traspasadas := IFacturas_traspasadas + (SELECT COUNT(*) FROM mov_ajustes_facturas_colegiaturas WHERE idu_usuario_traspaso > 0);
	iGeneracion_Pagos := (SELECT coalesce(MAX(idu_generacion), 0) + 1 FROM his_generacion_pagos_colegiaturas);

	--TABLA DE MOVIMIENTOS DE PAGOS
	DELETE FROM mov_generacion_pagos_colegiaturas;
	DELETE FROM mov_detalle_generacion_pagos_colegiaturas;

	DELETE FROM stmp_facturas_rechazadas;

	CREATE TEMP TABLE tmp_pagos (
		idu_empleado INTEGER
		, impORte_factura NUMERIC(12,2)
		, impORte_pagado NUMERIC(12,2)
		, idfactura integer
		, idu_ajuste integer
		, prc_descuento integer
		, tipo_registro INTEGER
	) ON COMMIT DROP;

-- ObteniENDo los impORtes de las facturas traspasadas
	INSERT INTO tmp_pagos(idu_empleado, impORte_factura, impORte_pagado, idfactura, idu_ajuste, prc_descuento, tipo_registro)
	SELECT 	idu_empleado
			, impORte_factura
			, impORte_pagado
			, idfactura
			, 0 as idu_ajuste
			, round((impORte_pagado * 100)/impORte_factura)::integer as prc_descuento
			, 1 as tipo_registro
	FROM 	MOV_FACTURAS_COLEGIATURAS
	WHERE 	idu_beneficiario_externo = 0
			and opc_movimiento_traspaso = 1;
    
-- ObteniENDo impORtes de los ajustes
	INSERT 	INTO tmp_pagos(idu_empleado, impORte_factura, impORte_pagado, idfactura, idu_ajuste, prc_descuento, tipo_registro)
	SELECT 	his.idu_empleado
			, aj.impORte_factura
			, aj.impORte_ajuste
			, aj.idfactura
			, aj.idu_ajuste
			, aj.pct_ajuste
			, 2 as tipo_registro
	FROM 	MOV_AJUSTES_FACTURAS_COLEGIATURAS as aj
	INNER 	JOIN his_facturas_colegiaturas as his on (his.idfactura = aj.idfactura)
	WHERE 	aj.idu_usuario_traspaso > 0;

-- Rechazar las facturas pOR bajas de empleados
	CREATE temp table tmp_rechazadas(
		idu_generacion integer
		, idfactura integer
		, idu_ajuste INTEGER
		, idu_empleado integer
		, prc_descuento integer
		, clv_rutapago integer
		, impORte_factura numeric(12,2)
		, impORte_pagado numeric(12,2)
	)on commit drop;

	--TABLA TEMPORAL EMPLEADOS CANCELADOS HE
	create temp table tmp_empleados_cancelados_he(
		numemp integer,	
		clv_rutapago integer	
	)on commit drop;	

	INSERT 	INTO tmp_rechazadas(idu_generacion, idfactura, idu_ajuste, idu_empleado, impORte_factura, impORte_pagado, prc_descuento, clv_rutapago)
	SELECT 	iGeneracion_Pagos
			, pag.idfactura
			, pag.idu_ajuste
			, pag.idu_empleado
			, pag.impORte_factura
			, pag.impORte_pagado
			, pag.prc_descuento
			, (case when EMP.controlpago = '' then '0' else EMP.controlpago END)::integer
	FROM 	tmp_pagos as pag
	INNER 	JOIN sapcatalogoempleados EMP on (emp.numempn = pag.idu_empleado)
	WHERE 	EMP.cancelado != '' and EMP.cancelado != '0';

	--EMPLEADOS CANCELADOS EN LA HE
	INSERT 	INTO tmp_empleados_cancelados_he (numemp,clv_rutapago)
	SELECT 	A.numemp, (case when B.controlpago = '' then '0' else B.controlpago END)::integer
	FROM 	stmp_empleados_baja A
	INNER	JOIN sapcatalogoempleados B on A.numemp=B.numemp::integer
	WHERE 	A.usuario=iUsuario;

	--FACTURAS DE LOS EMPLEADOS CANCELADOS DE LA HE
	INSERT 	INTO tmp_rechazadas(idu_generacion, idfactura, idu_ajuste, idu_empleado, impORte_factura, impORte_pagado, prc_descuento)
	SELECT 	iGeneracion_Pagos
		, pag.idfactura
		, pag.idu_ajuste
		, pag.idu_empleado
		, pag.impORte_factura
		, pag.impORte_pagado
		, pag.prc_descuento
		--, (case when EMP.controlpago = '' then '0' else EMP.controlpago END)::integer
		--,EMP.clv_rutapago
	FROM 	tmp_pagos as pag
	INNER 	JOIN tmp_empleados_cancelados_he EMP on (emp.numemp = pag.idu_empleado);
	
	--UPDATE TMP_RECHAZADAS set controlpago='0' WHERE controlpago='';	

	iEmpleados_baja := (SELECT COUNT(distinct idu_empleado) FROM tmp_rechazadas);
	IFacturas_rechazadas := (SELECT COUNT(*) FROM tmp_rechazadas);

	UPDATE	mov_facturas_colegiaturas set idu_estatus = 3
		, emp_marco_estatus = iUsuario
		, fec_marco_estatus = NOW()
		, opc_movimiento_traspaso = 0
		, idu_empleado_traspaso = 0
		, fec_movimiento_traspaso = '19000101'
		, des_observaciones = 'MOVIMIENTO RECHAZADO POR BAJA DE COLABORADOR'
	FROM	tmp_rechazadas as rec
	WHERE	rec.idfactura = mov_facturas_colegiaturas.idfactura;

	DELETE 	FROM MOV_AJUSTES_FACTURAS_COLEGIATURAS 
	WHERE 	idu_ajuste in (SELECT idu_ajuste FROM tmp_rechazadas WHERE idu_ajuste > 0);

-- INSERTar en stmp_facturas_rechazadas el detalle de los movimientos rechazados
	INSERT INTO stmp_facturas_rechazadas (idu_generacion, idfactura, idu_ajuste, idu_empleado, prc_descuento, clv_rutapago, impORte_factura, impORte_pagado)
	SELECT 	idu_generacion
			, idfactura
			, idu_ajuste
			, idu_empleado
			, prc_descuento
			, clv_rutapago
			, impORte_factura
			, impORte_pagado
	FROM 	tmp_rechazadas;
    
-- BORrar de los pagos las facturas canceladas
	DELETE FROM tmp_pagos WHERE idu_empleado in (SELECT idu_empleado FROM tmp_rechazadas);

	iColaboradores := (SELECT COUNT(DISTINCT(idu_empleado)) FROM tmp_pagos);


-- Actualizar la empresa del colabORadOR a la que pertenezca al momento de generar el pago de colegiaturas en la MOV_FACTURAS_COLEGIATURAS
	UPDATE	mov_facturas_colegiaturas set idu_empresa = Emp.empresa
	FROM	sapcatalogoempleados Emp
	INNER 	JOIN tmp_pagos tmp on (Emp.numempn = tmp.idu_empleado)
	WHERE	mov_facturas_colegiaturas.idu_empleado = Emp.numempn;

-- ObteniENDo totales de los pagos de colegiaturas
	INSERT 	INTO mov_generacion_pagos_colegiaturas(idu_generacion, fec_quincena, idu_empleado, impORte_factura, impORte_pagado)
	SELECT 	iGeneracion_Pagos
			, dFechaQuincena
			, idu_empleado
			, sum(impORte_factura) as impORte_factura
			, sum(impORte_pagado)
	FROM 	tmp_pagos
	GROUP 	BY idu_empleado
	ORDER 	BY idu_empleado;

	INSERT 	INTO mov_detalle_generacion_pagos_colegiaturas(idu_generacion,fec_generacion,idu_empleado,clv_rutapago,idfactura,idu_ajuste,prc_descuento,impORte_factura,impORte_pagado)
	SELECT 	iGeneracion_Pagos
			, now()
			, idu_empleado
			, 0 as clv_rutapago
			, idfactura
			, idu_ajuste
			, prc_descuento
			, impORte_factura
			, impORte_pagado
	FROM 	tmp_pagos
	ORDER 	BY idu_empleado, idfactura;

	UPDATE	mov_generacion_pagos_colegiaturas set nom_empleado = trim(EMP.nombre)
			, ape_paterno = trim(EMP.apellidopaterno)
			, ape_materno = trim(EMP.apellidomaterno)
			, idu_centro = EMP.centron
			, idu_puesto = EMP.pueston
			, clv_rutapago = EMP.controlpago::INTEGER
			, num_cuenta = trim(EMP.numerotarjeta)
			, num_sucursal = (case when EMP.sucursal = '' then '0' else EMP.sucursal END)::INTeger
			, fec_generacion = now()
			, idu_empleado_generacion = iUsuario
			, idu_generacion = iGeneracion_Pagos
	FROM	sapcatalogoempleados EMP
	WHERE	mov_generacion_pagos_colegiaturas.idu_empleado = EMP.numempn;


-- Actualizar el proceso
-------------------------------------------------------
	UPDATE 	ctl_proceso_colegiaturas set fec_pagos = now()
			, usr_pagos = iUsuario
	WHERE 	idu_ciclo = iCicloColegiaturas;

	/** =======================================
		REALIZAR REGISTRO DE MOVIMIENTO
			TABLA DE BITACORA
	======================================= **/
		INSERT INTO bit_proceso_colegiaturas(id_movimiento, num_facturas, num_colaboradores, fec_quincena, id_usuario)
		VALUES(2, IFacturas_traspasadas - IFacturas_rechazadas, iColaboradores , dFechaQuincena, iUsuario);
	/** =======================================
	======================================= **/

	FOR returnrec IN(
		SELECT iGeneracion_Pagos
			, IFacturas_traspasadas
			, IFacturas_rechazadas
			, iEmpleados_baja
			, 1 as estatus
			, 'Pagos generados' as mensaje
	)LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_generar_pagos_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_generar_pagos_colegiaturas(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_generar_pagos_colegiaturas(integer) TO sysetl;
COMMENT ON FUNCTION fun_generar_pagos_colegiaturas(integer) IS 'La función genera los pagos de colegiaturas';