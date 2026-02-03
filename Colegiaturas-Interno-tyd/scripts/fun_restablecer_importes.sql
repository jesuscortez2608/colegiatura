CREATE OR REPLACE FUNCTION fun_restablecer_importes(
OUT iEstatus integer, 
OUT sMensaje VARCHAR (150)
)
  RETURNS SETOF record AS
$BODY$
DECLARE  
	valor record;	
	/*===========================================================================================================    
	No. Peticion APS               : 8613.1
	Fecha                          : 11/10/2018
	Número empleado                : 94827443
	Nombre del empleado            : Omar Alejandro Lizárraga Hernández 
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Guarda los datos de la factura en la tabla tenporal 
	Modifica		       : Omar Alejandro Lizárraga Hernández 94827443
	Peticion		       : 16559
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Suplentes
	Ejemplo                        : 

		SELECT * FROM fun_realizar_calculos_escenarios (94827443, 0)		
		

		itipodoc=2 Es Nota de Credito
	===========================================================================================================*/
BEGIN   
	create local temp table tmp_Estado( 		
		iEstado Integer,
		sMsg	VARCHAR (150)
	)on commit drop; 
	
	--CTL_IMPORTES_FACTURAS_MES
	--DROP TABLE tmp_facturas
	--create table tmp_facturas( 
	create local temp table tmp_facturas( 			
		idfactura 		integer		
		, keyx			integer
		, mov			integer
	)on commit drop; 
	
	--drop table tmp_Importes_Facturas_Mes
	--create local temp table tmp_Importes_Facturas_Mes( 	
	create local temp table tmp_Importes_Facturas_Mes( 	
		idfactura 		integer
		, numemp  		integer
		, idu_tipo_pago 	integer
		, idu_periodo 		NUMERIC(12,2)
		, mes_pagado		NUMERIC(12,2)
		, importe_mes 		NUMERIC(12,2)
		, importe_concepto 	NUMERIC(12,2)
		, ciclo_escolar 	integer
		, anio 			integer
		, pagado 		integer
		, numero_meses		integer
		, keyx			integer
	)on commit drop; 

	--drop table tmp_Importes_Facturas
	--create table tmp_Importes_Facturas( 	
	create local temp table tmp_Importes_Facturas( 	
		idfactura 		integer
		, numemp  		integer
		, idu_tipo_pago 	integer
		, idu_periodo 		NUMERIC(12,2)
		, mes_pagado		NUMERIC(12,2)
		, mes			varchar(250)
		, importe_mes 		NUMERIC(12,2)
		, importe_concepto 	NUMERIC(12,2)
		, ciclo_escolar 	integer
		, anio 			integer
		, pagado 		integer
		, numero_meses		integer
		, keyx			integer
	)on commit drop; 

	--drop table tmp_Importes_Facturas_Semana
	create local temp table tmp_Importes_Facturas_Semana(
	--create table tmp_Importes_Facturas_Semana( 	
		idfactura 		integer
		, numemp  		integer
		, idu_tipo_pago 	integer
		, idu_periodo 		NUMERIC(12,2)
		, mes_pagado		NUMERIC(12,2)
		, mes			varchar(250)
		, importe_mes 		NUMERIC(12,2)
		, importe_concepto 	NUMERIC(12,2)
		, ciclo_escolar 	integer
		, anio 			integer
		, pagado 		integer
		, numero_semanas	integer
		, keyx			integer
	)on commit drop; 


	--drop table tmp_Importe_Desglozado
	--create local temp table tmp_Importe_Desglozado
	/*create table tmp_Importe_Desglozado
	( 	
		idfactura 		integer
		, numemp  		integer
		, idu_tipo_pago 	integer
		, idu_periodo 		NUMERIC(12,2)
		, mes_pagado		NUMERIC(12,2)
		, mes			varchar(250)
		, importe_mes 		NUMERIC(12,2)
		, importe_concepto 	NUMERIC(12,2)
		, ciclo_escolar 	integer
		, anio 			integer
		, pagado 		integer
		--, numeromeses		integer
		,keyx 			integer	
	)on commit drop; */

	create local temp table tmp_MesesFactura
	( 	
		idfactura 	integer
		,numero_meses	integer
		,keyx		integer
	)on commit drop; 

	--drop table tmp_SemanasFactura
	--create table tmp_SemanasFactura
	create local temp table tmp_SemanasFactura
	( 	
		idfactura 	integer
		,numero_semanas	integer
		,keyx		integer
	)on commit drop;

	--drop table tmp_VecesFactura
	--create table tmp_VecesFactura
	create local temp table tmp_VecesFactura	
	( 	
		idfactura 	integer
		,numero_meses	integer
		,keyx		integer
	)on commit drop;  

	--drop table tmp_Importe_Desglozado_Meses
	--create table tmp_Importe_Desglozado_Meses
	create local temp table tmp_Importe_Desglozado_Meses
	( 	
		idfactura 		integer
		, numemp  		integer
		, idu_tipo_pago 	integer
		, idu_periodo 		NUMERIC(12,2)
		, mes_pagado		NUMERIC(12,2)
		, mes			varchar(250)
		, importe_mes 		NUMERIC(12,2)
		, importe_concepto 	NUMERIC(12,2)
		, ciclo_escolar 	integer
		, anio 			integer
		, pagado 		integer
		, numero_meses		integer
		,keyx 			integer	
	)on commit drop; 


	--FACTURAS EN MOVIMIENTOS
	insert 	into tmp_facturas (idfactura, keyx, mov)
	select 	idfactura, keyx, 1
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS 
	where 	idfactura not in (select idfactura from CTL_IMPORTES_FACTURAS_MES)
	order	by idfactura; 	

	--FACTURAS EN HISTORICO
	insert 	into tmp_facturas (idfactura, keyx, mov)
	select 	idfactura, keyx, 0
	from 	HIS_DETALLE_FACTURAS_COLEGIATURAS 
	where 	idfactura not in (select idfactura from CTL_IMPORTES_FACTURAS_MES)
	order	by idfactura;
	
	-------------------------------------------------------------------------------------------------------------------------------------------
	-- I	M	P	O	R	T	E	S 		M	E	N	S	U	A	L	E	S
	-------------------------------------------------------------------------------------------------------------------------------------------
	--IMPORTES PENDIENTES (MOVIMIENTO)
	insert	into  tmp_Importes_Facturas_Mes (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado, keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo, 0 as mespagado,B.importe_concepto, B.importe_concepto, 
		B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 0 as pagado, keyx
	from 	MOV_FACTURAS_COLEGIATURAS A
	inner	join MOV_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=1)
		and B.idu_tipopago in (1,2)
	order 	by idfactura;

	--IMPORTES PAGADOS (HISTORICO)
	insert	into  tmp_Importes_Facturas_Mes (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado, keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo, 0 as mespagado,B.importe_concepto, B.importe_concepto, 
			B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 1 as pagado, keyx
	from 	HIS_FACTURAS_COLEGIATURAS A
	inner	join HIS_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=0)
		and B.idu_tipopago in (1,2)
	order 	by idfactura;

	--CONTAR MESES
	insert 	into tmp_MesesFactura (idfactura, numero_meses, keyx)
	select 	idfactura, count(*), keyx
	from	tmp_Importes_Facturas_Mes
	group	by idfactura , keyx;

	--NUMERO DE MESES
	update 	tmp_Importes_Facturas_Mes set numero_meses=B.numero_meses
	from	tmp_MesesFactura B 
	where	tmp_Importes_Facturas_Mes.idfactura=B.idfactura 
		and tmp_Importes_Facturas_Mes.keyx=B.keyx;

	--
	update 	tmp_Importes_Facturas_Mes set importe_mes=importe_mes/numero_meses;

	--ACTUALIZAR AL MES QUE LE CORRESPONDE
	update	tmp_Importes_Facturas_Mes set mes_pagado=B.idu_periodo
	from	CAT_PERIODOS_PAGOS B 
	where	tmp_Importes_Facturas_Mes.idu_tipo_pago=B.idu_tipo_periodo 
		and tmp_Importes_Facturas_Mes.idu_periodo=B.idu_periodo;

	--ACTUALIZAR CUANDO ES INSCRIPCION
	update 	tmp_Importes_Facturas_Mes set mes_pagado=0 
	where 	idu_tipo_pago=1 
		and idu_periodo=1;

	--INSERTAR EN CTL_IMPORTES
	INSERT 	INTO CTL_IMPORTES_FACTURAS_MES (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx)
	SELECT 	idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx
	FROM	tmp_Importes_Facturas_Mes;
	--------------------------------------------------------------------------------------------------------------------------------------------------
	--	I	M	P	O	R	T	E	S		S	E	M	A	N	A	L	E	S
	--------------------------------------------------------------------------------------------------------------------------------------------------
	
	--
	insert	into  tmp_Importes_Facturas_Semana (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo,
		--to_number(B.periodo,'9999999') as periodo, 
		0 as mespagado,B.importe_concepto, B.importe_concepto, B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 0 as pagado, keyx
	from 	MOV_FACTURAS_COLEGIATURAS A
	inner	join MOV_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=1)
		and B.idu_tipopago=7;

	--IMPORTES PAGADOS (HISTORICO)
	insert	into  tmp_Importes_Facturas_Semana (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo,
		--to_number(B.periodo,'9999999') as periodo, 
		0 as mespagado,B.importe_concepto, B.importe_concepto, B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 1 as pagado, keyx
	from 	HIS_FACTURAS_COLEGIATURAS A
	inner	join HIS_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=0)
		and B.idu_tipopago=7;

	--CONTAR SEMANAS
	insert 	into tmp_SemanasFactura (idfactura, numero_semanas, keyx)
	select 	idfactura, count(*), keyx
	from	tmp_Importes_Facturas_Semana
	group	by idfactura , keyx;

	--NUMERO DE SEMANAS
	update 	tmp_Importes_Facturas_Semana set numero_semanas=B.numero_semanas
	from	tmp_SemanasFactura B 
	where	tmp_Importes_Facturas_Semana.idfactura=B.idfactura and tmp_Importes_Facturas_Semana.keyx=B.keyx;

	--
	update 	tmp_Importes_Facturas_Semana set importe_mes=importe_mes/numero_semanas;

	--MES PAGADO
	update 	tmp_Importes_Facturas_Semana set mes_pagado=to_number(B.mes_pago,'9999999')
	from	CAT_MESES_PAGOS B
	where	tmp_Importes_Facturas_Semana.idu_tipo_pago=B.idu_tipo_pago
		and tmp_Importes_Facturas_Semana.idu_periodo=B.idu_periodo;

	--INSERTAR EN CTL_IMPORTES
	INSERT 	INTO CTL_IMPORTES_FACTURAS_MES (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx)
	select 	idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado, keyx
	from	tmp_Importes_Facturas_Semana 
	order 	by idfactura;
	-------------------------------------------------------------------------------------------------------------------------------------------
	--	I	M	P	O	R	T	E	S
	-------------------------------------------------------------------------------------------------------------------------------------------
	insert	into  tmp_Importes_Facturas (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado, keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo, 0 as mespagado,B.importe_concepto, B.importe_concepto, 
		B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 0 as pagado, B.keyx
	from 	MOV_FACTURAS_COLEGIATURAS A
	inner	join MOV_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=1)
		--A.idfactura in (800)
		and B.idu_tipopago not in (1,2,7);
		

	--IMPORTES PAGADOS (HISTORICO)
	insert	into  tmp_Importes_Facturas (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado, keyx)
	select 	A.idfactura, A.idu_empleado, B.idu_tipopago, to_number(regexp_split_to_table(B.periodo, ','),'9999999') as periodo, 0 as mespagado,B.importe_concepto, B.importe_concepto, 
		B.idu_ciclo_escolar, DATE_PART ('year',A.fec_registro) as anio, 1 as pagado, B.keyx
	from 	HIS_FACTURAS_COLEGIATURAS A
	inner	join HIS_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	where 	A.idfactura in (select idfactura from tmp_facturas where mov=0)		
		and B.idu_tipopago not in (1,2,7);

	--tmp_Importes_Facturas order by idu_tipo_pago

--BIMESTRES
	update 	tmp_Importes_Facturas SET mes='1,2'	
	WHERE	idu_tipo_pago=3 and idu_periodo=1;

	update 	tmp_Importes_Facturas SET mes='3,4' 	
	WHERE	idu_tipo_pago=3 and idu_periodo=2;

	update 	tmp_Importes_Facturas SET mes='5,6' 	
	WHERE	idu_tipo_pago=3 and idu_periodo=3;

	update 	tmp_Importes_Facturas SET mes='7,8' 	
	WHERE	idu_tipo_pago=3 and idu_periodo=4;

	update 	tmp_Importes_Facturas SET mes='9,10' 	
	WHERE	idu_tipo_pago=3 and idu_periodo=5;

	update 	tmp_Importes_Facturas SET mes='11,12' 	
	WHERE	idu_tipo_pago=3 and idu_periodo=6;

--TRIMESTRES
	update 	tmp_Importes_Facturas SET mes='1,2,3'	
	WHERE	idu_tipo_pago=4 and idu_periodo=1;

	update 	tmp_Importes_Facturas SET mes='4,5,6'	 	
	WHERE	idu_tipo_pago=4 and idu_periodo=2;

	update 	tmp_Importes_Facturas SET mes='7,8,9'	 	
	WHERE	idu_tipo_pago=4 and idu_periodo=3;

	update 	tmp_Importes_Facturas SET mes='10,11,12'		
	WHERE	idu_tipo_pago=4 and idu_periodo=4;

--CUATRIMESTRES
	update 	tmp_Importes_Facturas SET mes='1,2,3,4'	 	
	WHERE	idu_tipo_pago=5 and idu_periodo=1;

	update 	tmp_Importes_Facturas SET mes='5,6,7,8'	 	
	WHERE	idu_tipo_pago=5 and idu_periodo=2;

	update 	tmp_Importes_Facturas SET mes='9,10,11,12'	 	
	WHERE	idu_tipo_pago=5 and idu_periodo=3;

--SEMESTRES
	update 	tmp_Importes_Facturas SET mes='1,2,3,4,5,6'
	WHERE	idu_tipo_pago=6 
		and idu_periodo=1;

	update 	tmp_Importes_Facturas SET mes='7,8,9,10,11,12'
	WHERE	idu_tipo_pago=6 
		and idu_periodo=2;
--ANUAL
	update 	tmp_Importes_Facturas SET mes='1,2,3,4,5,6,7,8,9,10,11,12'
	WHERE	idu_tipo_pago=8; 

	--IMPORTE DESGLOZADOS
	insert	into tmp_Importe_Desglozado_Meses (idfactura,numemp,idu_tipo_pago,idu_periodo,mes_pagado,importe_concepto,ciclo_escolar,anio,pagado,keyx)
	select 	idfactura,numemp,idu_tipo_pago,idu_periodo,to_number(regexp_split_to_table(mes, ','),'9999999') as mes,importe_concepto, ciclo_escolar,anio,pagado,keyx
	from	tmp_Importes_Facturas	
	order	by idfactura;

	--CONTAR VECES
	insert 	into tmp_VecesFactura (idfactura, numero_meses, keyx)
	select 	idfactura, count(idfactura), keyx
	from	tmp_Importe_Desglozado_Meses
	group	by idfactura , keyx;

	--NUMERO DE VECES
	update 	tmp_Importe_Desglozado_Meses set numero_meses=B.numero_meses, importe_mes=importe_concepto/B.numero_meses
	from	tmp_VecesFactura B
	where	tmp_Importe_Desglozado_Meses.idfactura=B.idfactura 
		and tmp_Importe_Desglozado_Meses.keyx=B.keyx;

	INSERT 	INTO CTL_IMPORTES_FACTURAS_MES (idfactura, numemp, idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx)
	SELECT 	idfactura, numemp,  idu_tipo_pago, idu_periodo, mes_pagado, importe_mes, importe_concepto, ciclo_escolar, anio, pagado,keyx
	FROM	tmp_Importe_Desglozado_Meses;	

	INSERT INTO tmp_Estado (iEstado, sMsg) VALUES (1,'Importes Restablecidos Correctamente');
		
	FOR valor IN (SELECT iEstado, sMsg FROM tmp_Estado)
	LOOP
		iEstatus:=valor.iEstado;
		sMensaje:=valor.sMsg;	
		
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;