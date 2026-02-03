CREATE OR REPLACE FUNCTION fun_realizar_calculos_escenarios(
IN iempleado integer, 
IN iidfactura integer, 
OUT ifactura integer, 
OUT nimportereal numeric, 
OUT nimporte_mes numeric, 
OUT nimporte_semana numeric, 
OUT nimporte_tomar numeric, 
OUT nimporte_concepto numeric, 
OUT ntope_mensual numeric, 
OUT nimporte_calculado numeric, 
OUT itipo_periodo integer, 
OUT nperiodo_meses numeric, 
OUT inum_periodos integer, 
OUT iprc_descuento integer)
  RETURNS SETOF record AS
$BODY$
DECLARE   
	valor record;
	sQuery TEXT;
	anio_actual integer;
	/*===========================================================================================================    
	No. Peticion APS               : 8613.1
	Fecha                          : 11/10/2018
	Número empleado                : 94827443
	Nombre del empleado            : Omar Alejandro Lizárraga Hernández 
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Guarda los datos de la factura en la tabla tenporal 
	ModIFica		       : Omar Alejandro Lizárraga Hernández 94827443
	Peticion		       : 16559
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Suplentes
	Ejemplo                        : 

		SELECT * FROM fun_realizar_calculos_escenarios (94827443, 0)		
		

		itipodoc=2 Es Nota de Credito
	===========================================================================================================*/
BEGIN   
	
	create local temp table tmp_Importes
	( 	
		Factura integer, 
		importeReal numeric (12,2),
		importe_mes numeric (12,2),
		importe_semana numeric (12,2),
		importe_tomar numeric (12,2),
		importe_concepto numeric (12,2), --importe modIFicado
		tope_mensual numeric (12,2), 
		importe_calculado numeric (12,2),
		tipo_periodo integer,
		periodo_meses numeric (12,2),
		num_periodos integer,
		prc_descuento INTEGER,
		meses_trabajados integer,
		tope_anual numeric (12,2),
		keyx integer
	)on commit drop; 
	
	--
	create local temp table tmp_periodos
	(
		idfactura integer,
		periodo character varying,
		tipo_pago integer,
		meses_pago numeric (12,2),
		num_meses numeric (12,2),
		importe_concepto numeric (12,2),
		keyx integer		
	)on commit drop; 

	--
	create local temp table tmp_periodos_factura
	( 	
		idfactura integer,
		num_periodos integer,
		keyx integer
	)on commit drop;

	--
	create local temp table tmp_importe_calculado
	( 	
		idfactura integer,
		importe_concepto numeric (12,2),
		importe_calculado numeric (12,2)
	)on commit drop;
		
	anio_actual:= DATE_PART('year',CURRENT_DATE);

/*------------------------------------------------------------
--ELIMINAR TABLAS
drop table tmp_Importes;
drop table tmp_periodos;
drop table tmp_periodos_factura;
drop table tmp_importe_calculado;
	
DELETE FROM tmp_Importes;
DELETE FROM tmp_periodos;
DELETE FROM tmp_periodos_factura;
DELETE FROM tmp_importe_calculado;

tmp_Importes;
tmp_periodos;
tmp_periodos_factura;
tmp_importe_calculado;
------------------------------------------------------------*/

	--INSERTAR IMPORTES DETALLE 
	sQuery :=  '
	INSERT 	INTO tmp_Importes (Factura, importeReal, importe_semana, importe_concepto, importe_calculado, tipo_periodo, prc_descuento, keyx)
	SELECT 	idfactura, importe_concepto, 0.00, 0.00, 0.00, idu_tipopago,  prc_descuento, keyx 
	FROM 	MOV_DETALLE_FACTURAS_COLEGIATURAS 	
	WHERE 	idu_empleado= ' || iempleado;

	
	raise notice '%', sQuery;
	execute sQuery;
	
	--PERIODOS POR FACTURA
	INSERT 	INTO tmp_periodos (idfactura, periodo, tipo_pago, keyx)
	SELECT 	idfactura, regexp_split_to_table(periodo, ','),idu_tipopago, keyx
	FROM	MOV_DETALLE_FACTURAS_COLEGIATURAS
	WHERE 	idu_empleado= iempleado;
	
	--NUMERO DE PERIODOS POR FACTURA
	INSERT 	INTO tmp_periodos_factura (idfactura, num_periodos,keyx)
	SELECT 	idfactura, count(periodo),keyx
	FROM 	tmp_periodos
	GROUP	BY idfactura, keyx;

	--NUMERO DE PERIODOS
	UPDATE	tmp_Importes SET num_periodos=B.num_periodos
	FROM	tmp_periodos_factura B
	WHERE	tmp_Importes.Factura=B.idfactura
			AND tmp_Importes.keyx=B.keyx;
	
	--TOPE MENSUAL
	UPDATE	tmp_Importes SET tope_mensual= (A.sueldo/2)/100.00
	FROM 	SAPCATALOGOEMPLEADOS A	
	WHERE 	numempn= iempleado;

	
	--MESES TRABAJADOS 
	IF (anio_actual - (SELECT DATE_PART('year', fechaalta)  FROM sapcatalogoempleados WHERE numempn=iempleado ) > 2) then  
		--SI ES MAS DE UN AÑO
		UPDATE  tmp_Importes SET meses_trabajados=12;
					
	ELSIF (SELECT DATE_PART('year', fechaalta + INTERVAL '1 YEAR')  FROM sapcatalogoempleados WHERE numempn=iempleado )=anio_actual THEN
		--SI ES DEL AÑO PASADO
		UPDATE	tmp_Importes SET meses_trabajados=11 + (DATE_PART('month', now()) - DATE_PART('month', B.fechaalta)) 
		FROM 	sapcatalogoempleados B
		WHERE 	numempn=iempleado
				AND DATE_PART('YEAR',B.fechaalta)!=anio_actual;
	ELSE
		--SI ES DEL MISMO AÑO		
		UPDATE	tmp_Importes SET meses_trabajados=1+(DATE_PART('month', now()) - DATE_PART('month', B.fechaalta)) 
		FROM 	sapcatalogoempleados B
		WHERE 	numempn=iempleado
			AND DATE_PART('YEAR',B.fechaalta)=anio_actual;
	END IF;

		
	--TOPE ANUAL
	UPDATE	tmp_Importes SET tope_anual=tope_mensual*meses_trabajados; 
	
	--PERIODO MESES
	UPDATE	tmp_Importes SET periodo_meses = B.mes_tipo_pago
	FROM	CAT_TIPOS_PAGOS B
	WHERE	tmp_Importes.tipo_periodo=B.idu_tipo_pago;

	--PERIODO MESES
	UPDATE	tmp_periodos SET meses_pago=B.mes_tipo_pago
	FROM 	CAT_TIPOS_PAGOS B
	WHERE	tmp_periodos.tipo_pago=B.idu_tipo_pago;

	--NUMERO DE MESES
	UPDATE	tmp_periodos SET num_meses=meses_pago*B.num_periodos
	FROM 	tmp_Importes B
	WHERE	tmp_periodos.keyx=B.keyx
			AND tmp_periodos.idfactura=B.factura;

	--IMPORTE FACTURA X MES CUANDO ES SEMANA
	UPDATE	tmp_Importes SET importe_mes=(1.00/(periodo_meses*num_periodos))*importeReal
	WHERE	periodo_meses<1.00;

	--IMPORTE FACTURA X MES 
	UPDATE	tmp_Importes SET importe_mes=(importeReal/(periodo_meses*num_periodos))
	WHERE	periodo_meses>=1.00;

	--IMPORTE SEMANA
	UPDATE	tmp_Importes SET importe_semana=(importeReal/num_periodos)
	WHERE	periodo_meses<1.00;
	

	--IMPORTE TOMAR = TOPE MENSUAL PERIODO SEMANAL
	UPDATE	tmp_Importes SET importe_tomar=(tope_mensual/4)*num_periodos
	WHERE	tope_mensual<=importe_semana*4
			AND periodo_meses<1.00;		

	--IMPORTE TOMAR = IMPORTE FACTURA PERIODO SEMANAL
	UPDATE	tmp_Importes SET importe_tomar=importereal
	WHERE	tope_mensual>=importe_semana*4
			AND periodo_meses<1.00;
			
	--IMPORTE TOMAR TOPE MENSUAL PERIODO MESES	
	UPDATE	tmp_Importes SET importe_tomar=tope_mensual*(periodo_meses*num_periodos)
	WHERE	tope_mensual<=importe_mes
		AND periodo_meses>=1.00;
 
	--IMPORTE TOMAR IMPORTE MES PERIODO MESES	
	UPDATE	tmp_Importes SET importe_tomar=importe_mes*(periodo_meses*num_periodos)
	WHERE	tope_mensual>=importe_mes
		AND periodo_meses>=1.00;

	--SUMAR 4 CENTAVOS IMPORTE TOMAR 
	UPDATE 	tmp_Importes SET importe_tomar=importe_tomar+0.04 		
	WHERE	(importereal-importe_tomar)<=0.04
		and importe_tomar!=(tope_mensual*periodo_meses)
		AND periodo_meses>=1.00;

	--IMPORTE TOMAR = IMPORTE REAL CUANDO EXCEDA EL IMPORTE REAL
	UPDATE 	tmp_Importes SET importe_tomar=importereal
	WHERE	importereal<importe_tomar;

	--SUMAR 4 CENTAVOS IMPORTE TOMAR CUANDO LE FALTEN CENTAVOS PERIODO MES
	UPDATE 	tmp_Importes SET importe_tomar=importe_tomar+0.04 
	WHERE 	((tope_mensual*(periodo_meses*num_periodos))-importe_tomar)<=0.04
			and importe_tomar!=(tope_mensual*periodo_meses)
			AND periodo_meses>=1.00;

	--SUMAR 4 CENTAVOS IMPORTE TOMAR 
	UPDATE 	tmp_Importes SET importe_tomar=importe_tomar+0.04 
	WHERE 	(tope_mensual)-(importe_tomar*num_periodos)<=0.04
		and (importe_tomar*num_periodos)!=tope_mensual
		AND periodo_meses<1.00;

/*		
--MODIFICAR IMPORTE TOMAR CUANDO EXCEDE EL IMPORTE REAL PERIODO MESES
UPDATE 	tmp_Importes SET importe_tomar=importereal
WHERE	importe_tomar>(tope_mensual*periodo_meses)
--WHERE	importe_tomar>(tope_mensual*num_periodos)
	and  periodo_meses>=1.00;*/

	--MODIFICAR IMPORTE TOMAR CUANDO IMPORTE TOMAR SOBREPASA TOPE MENSUAL X (NUM_PERIODOS * PERIODO MESES)
	UPDATE 	tmp_Importes SET importe_tomar=(tope_mensual*(periodo_meses*num_periodos))
	WHERE	importe_tomar>tope_mensual*(periodo_meses*num_periodos)
	--WHERE	--importe_tomar>(tope_mensual*(periodo_meses*num_periodos))
		--importereal>
		and  periodo_meses>=1.00;

	--MODIFICAR IMPORTE TOMAR CUANDO EXCEDE EL IMPORTE REAL PERIODO SEMANA
	UPDATE 	tmp_Importes SET importe_tomar=importereal
	WHERE	(importe_tomar*num_periodos)>tope_mensual
		and  periodo_meses<1.00;


	--MODIFICAR IMPORTE TOMAR CUANDO SOBREPASA EL TOPE ANUAL
	UPDATE	tmp_Importes SET importe_tomar=importe_tomar+0.04 
	WHERE	((tope_anual-importe_tomar))<=0.04;

	--MODIFICAR IMPORTE TOMAR CUANDO SOBREPASA EL TOPE ANUAL
	UPDATE	tmp_Importes SET importe_tomar=tope_anual
	WHERE	importe_tomar>tope_anual;

			

	IF (iidfactura>0)then --SUBIR FACTURA, 
		
		UPDATE	tmp_Importes SET importe_concepto=importe_semana*num_periodos
		WHERE	periodo_meses<1.00;

		--
		UPDATE 	tmp_Importes SET importe_concepto=importe_concepto+0.04
		WHERE	(importe_tomar-importe_concepto)<=0.04;			

		UPDATE 	tmp_Importes SET importe_concepto=importe_tomar
		WHERE	importe_concepto>importe_tomar;

		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES MES
		UPDATE	tmp_Importes SET importe_concepto=importe_tomar --*num_periodos
		WHERE	periodo_meses>=1.00;

		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES MES
		UPDATE	tmp_periodos SET importe_concepto=B.importe_tomar
		FROM	tmp_Importes B
		WHERE	tmp_periodos.idfactura=B.factura 
			AND tmp_periodos.keyx=B.keyx
			AND periodo_meses>=1.00;

		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES SEMANA
		UPDATE	tmp_periodos SET importe_concepto=(importe_tomar/(1.00/periodo_meses))*num_periodos
		FROM	tmp_Importes B
		WHERE	tmp_periodos.idfactura=B.factura 
			AND tmp_periodos.keyx=B.keyx
			AND periodo_meses<1.00;		

		--CONTROL DE IMPORTES DE FACTURAS POR MES
		INSERT 	INTO ctl_importes_facturas_mes (idfactura,idu_tipo_pago,idu_periodo,mes_pagado,importe_mes,importe_concepto,anio,keyx)
		SELECT 	B.idfactura, A.idu_tipo_pago,A.idu_periodo, regexp_split_to_table(A.mes_pago, ',')::int, (B.importe_concepto/B.num_meses), B.importe_concepto, anio_actual, B.keyx
		FROM 	CAT_MESES_PAGOS A
		INNER	JOIN tmp_periodos B on A.idu_tipo_pago=B.tipo_pago 
			AND A.idu_periodo=B.periodo::int
			AND B.idfactura=iidfactura
			AND idu_tipo_pago!=7;	

		--CONTROL DE IMPORTES DE FACTURAS POR SEMANA
		INSERT 	INTO ctl_importes_facturas_mes (idfactura,idu_tipo_pago,idu_periodo,mes_pagado,importe_mes,importe_concepto,anio,keyx)
		SELECT 	B.idfactura, A.idu_tipo_pago,A.idu_periodo, regexp_split_to_table(A.mes_pago, ',')::int 
			--,(B.importe_concepto*B.num_meses)
			,(B.importe_concepto/B.num_meses)/(1.00/B.meses_pago)
			, B.importe_concepto, anio_actual, B.keyx
		FROM 	CAT_MESES_PAGOS A
		INNER	JOIN tmp_periodos B on A.idu_tipo_pago=B.tipo_pago 
			AND A.idu_periodo=B.periodo::int
			AND B.idfactura=iidfactura
			--and ctl_importes_facturas_mes.numemp=iempleado
			AND idu_tipo_pago=7;
		
		--MODIFICAR EMPLEADO Y CICLO ESCOLAR EN CTL IMPORTES
		UPDATE 	ctl_importes_facturas_mes SET numemp=B.idu_empleado, ciclo_escolar=B.idu_ciclo_escolar
		FROM 	MOV_DETALLE_FACTURAS_COLEGIATURAS B
		WHERE	ctl_importes_facturas_mes.idfactura=B.idfactura 
			--and MOV_DETALLE_FACTURAS_COLEGIATURAS.idu_empleado=iempleado
			and ctl_importes_facturas_mes.idfactura=iidfactura
			AND ctl_importes_facturas_mes.keyx=B.keyx;
		
		
	ELSE  -- ACEPTAR RECHAZAR FACTURA
	
		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES SEMANA
		UPDATE	tmp_Importes SET importe_concepto=B.importe_concepto
		FROM	MOV_DETALLE_FACTURAS_COLEGIATURAS B
		WHERE	tmp_Importes.Factura=B.idfactura
			AND tmp_Importes.keyx=B.keyx;

		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES MES
		UPDATE	tmp_periodos SET importe_concepto=B.importe_tomar
		FROM	tmp_Importes B
		WHERE	tmp_periodos.idfactura=B.factura 
			AND tmp_periodos.keyx=B.keyx
			AND periodo_meses>=1.00;

		--IMPORTE CONCEPTO Ó MODIFICADO CUANDO ES SEMANA
		UPDATE	tmp_periodos SET importe_concepto=B.importe_concepto
		FROM	tmp_Importes B
		WHERE	tmp_periodos.idfactura=B.factura 
			AND tmp_periodos.keyx=B.keyx
			AND periodo_meses<1.00;

		--MOIFICAR IMPORTES POR MES CUANDO ES SEMANA
		UPDATE	ctl_importes_facturas_mes 
		SET 	idu_tipo_pago=A.idu_tipo_pago
			--,idu_periodo=B.periodo::numeric(12,2)
			--,mes_pagado=regexp_split_to_table(A.mes_pago, ',')::int
			,importe_mes= (B.importe_concepto/B.num_meses)/(1.00/B.meses_pago)
			--(B.importe_concepto/B.num_meses)/(1.00/B.meses_pago)
			,importe_concepto=B.importe_concepto			
		FROM 	CAT_MESES_PAGOS A
		INNER	JOIN tmp_periodos B on A.idu_tipo_pago=B.tipo_pago 
			AND A.idu_periodo=B.periodo::int			
			AND idu_tipo_pago=7
		WHERE	ctl_importes_facturas_mes.idfactura=B.idfactura
			--and ctl_importes_facturas_mes.numemp=iempleado
			AND ctl_importes_facturas_mes.keyx=B.keyx;

		--MOIFICAR IMPORTES POR MES CUANDO ES MES
		UPDATE	ctl_importes_facturas_mes 
		SET 	idu_tipo_pago=A.idu_tipo_pago
			--,idu_periodo=B.periodo::numeric(12,2)
			--,mes_pagado=regexp_split_to_table(A.mes_pago, ',')::int
			,importe_mes= (B.importe_concepto/B.num_meses)
			,importe_concepto=B.importe_concepto			
		FROM 	CAT_MESES_PAGOS A
		INNER	JOIN tmp_periodos B on A.idu_tipo_pago=B.tipo_pago 
			aND A.idu_periodo=B.periodo::int			
			aND idu_tipo_pago!=7
		WHERE	ctl_importes_facturas_mes.idfactura=B.idfactura
			--and ctl_importes_facturas_mes.numemp=iempleado
			AND ctl_importes_facturas_mes.keyx=B.keyx;		
	END IF;	
---------------------------------------------------------------------------------------------------------------------
	
---------------------------------------------------------------------------------------------------------------------
	--IMPORTE CALCULADO
	UPDATE	tmp_Importes SET importe_calculado = importe_concepto * (prc_descuento/100.00);	

	--IMPORTE CALCULADO
	INSERT	INTO tmp_importe_calculado (idfactura, importe_concepto, importe_calculado)
	SELECT  Factura, sum(importe_concepto), sum(importe_calculado)
	FROM	tmp_Importes
	GROUP	BY Factura;

	--MODIFICAR FACTURA
	UPDATE 	MOV_FACTURAS_COLEGIATURAS SET importe_calculado=B.importe_calculado, importe_pagado=B.importe_calculado
	FROM	tmp_importe_calculado B
	WHERE 	MOV_FACTURAS_COLEGIATURAS.idfactura=B.idfactura
		and MOV_FACTURAS_COLEGIATURAS.idu_empleado=iempleado;
		

	
	--MODIFICAR FACTURA CUANDO PASA EL TOPE ANUAL
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET importe_concepto=B.importe_concepto, importe_pagado=B.importe_calculado
	FROM	tmp_Importes B
	WHERE 	MOV_DETALLE_FACTURAS_COLEGIATURAS.idfactura=B.factura
		AND MOV_DETALLE_FACTURAS_COLEGIATURAS.idu_empleado=iempleado
		AND MOV_DETALLE_FACTURAS_COLEGIATURAS.keyx=B.keyx;
		

	FOR valor IN (SELECT Factura, importeReal, importe_mes, importe_semana, importe_tomar, importe_concepto, tope_mensual, importe_calculado, tipo_periodo, periodo_meses, num_periodos, prc_descuento FROM tmp_Importes order BY Factura)
	loop		
		IFactura:=valor.Factura;
		nimporteReal:=valor.importeReal;
		nimporte_mes:=valor.importe_mes;
		nimporte_semana:=valor.importe_semana;
		nimporte_tomar:=valor.importe_tomar;
		nimporte_concepto:=valor.importe_concepto;
		ntope_mensual:=valor.tope_mensual;
		nimporte_calculado:=valor.importe_calculado;
		itipo_periodo:=valor.tipo_periodo;
		nperiodo_meses:=valor.periodo_meses;
		inum_periodos:=valor.num_periodos;
		iprc_descuento:=valor.prc_descuento;
		return next;
	END loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_realizar_calculos_escenarios(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_realizar_calculos_escenarios(integer, integer) TO sysinternet;
COMMENT ON FUNCTION fun_realizar_calculos_escenarios(integer, integer) IS 'La función realiza los calculos de los importes de colegiaturas';