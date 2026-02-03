
CREATE OR REPLACE FUNCTION fun_obtener_listado_importe_pagado_por_mes(integer)
  RETURNS SETOF type_listado_importe_pagado_por_mes AS
$BODY$
DECLARE
	iEmpleado ALIAS FOR $1;
	anno integer;
	mes integer;
	numMeses INTEGER;
	registro type_listado_importe_pagado_por_mes;
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 27/10/2016
	     Número empleado                : 96753269
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Obtiene el acumulado de las facturas pagadas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Autorizar o rechazar facturas
	     Ejemplo                        :
		SELECT * FROM fun_obtener_listado_importe_pagado_por_mes(93902761)
  ------------------------------------------------------------------------------------------------------ */
	
BEGIN
	CREATE local temp TABLE tmpPagosMensuales
	--DROP TABLE tmpPagosMensuales
	--CREATE TABLE tmpPagosMensuales
	(  
		imes integer default 0, 
		mes varchar(20) default 0.0,
		pagado_mes numeric (12,2) default 0.0,
		tope_mes numeric (12,2) default 0.0,
		restante_mes numeric(12,2) default 0.0,
		pagado numeric (12,2) default 0.0,
		tope numeric (12,2) default 0.0,
		restante numeric(12,2) default 0.0,
		ajuste numeric(12,2) default 0.0
		--idfactura integer,		
	)
	on commit drop; 

	--IMPORTES POR MES 
	CREATE local temp TABLE tmpImportes
	--DROP TABLE tmpImportes
	--CREATE TABLE tmpImportes
	(  
		imes integer default 0, 
		importe numeric (12,2) default 0.0,
		numemp integer default 0, 
		anio integer default 0			
	)
	on commit drop; 

	--IMPORTES POR MES 
	CREATE local temp TABLE tmpImporte_Anual
	--DROP TABLE tmpImporte_Anual
	--CREATE TABLE tmpImporte_Anual
	(  	
		--idfactura integer default 0,
		anio integer default 0,
		numemp integer default 0,
		importe numeric (12,2) default 0.0
	)
	on commit drop;

	--AJUSTES
	--DROP TABLE tmpAjustes
	CREATE local temp TABLE tmpAjustes
	--CREATE TABLE tmpAjustes
	(  	
		idfactura integer default 0,
		importe numeric (12,2) default 0.0				
	)
	on commit drop;

	--PAGADO SIN CENTAVOS	
	CREATE local temp TABLE tmpPagadoFacturas
	--DROP TABLE tmpPagadoFacturas
	--CREATE TABLE tmpPagadoFacturas
	(  	
		idfactura integer default 0,
		numemp integer,
		anio integer,
		importe_factura numeric (12,2) default 0.0,
		importe_concepto numeric (12,2) default 0.0,
		importe_pagado numeric (12,2) default 0.0,
		prc_descuento numeric (12,2) default 0.0,
		mes_pagado numeric (12,2) default 0.0,
		idu_tipo_pago numeric (12,2) default 0.0
	)
	on commit drop;
	
	anno:= cast((DATE_PART('year', now())) as integer);	

	--PAGOS MENSUALES 
	INSERT INTO tmpPagosMensuales (imes)
	SELECT 	DISTINCT mes_pagado::int
	FROM 	CTL_IMPORTES_FACTURAS_MES 
	WHERE 	anio=anno 
			AND numemp=iEmpleado
			AND pagado=1
	ORDER	BY mes_pagado;

	--IMPORTE POR MES
	INSERT 	INTO tmpImportes (imes, importe)
	SELECT 	mes_pagado, sum(importe_mes)  
	FROM 	CTL_IMPORTES_FACTURAS_MES 
	WHERE 	anio=anno 
			AND numemp=iEmpleado
			AND pagado=1
	GROUP	BY mes_pagado
	ORDER	BY mes_pagado;

	--IMPORTE PAGADO POR MES
	UPDATE 	tmpPagosMensuales SET pagado_mes=B.importe
	FROM	tmpImportes B
	WHERE	tmpPagosMensuales.imes=B.imes;
  
	--TOPE MENSUAL Y TOPE ANUAL
	UPDATE 	tmpPagosMensuales SET tope_mes=((B.sueldo/100)/2) --, tope=((B.sueldo/100)/2)*numMeses
	FROM	sapcatalogoempleados B
	WHERE	B.numempn=iEmpleado; --AND imes!=0;


	--numMeses:= (SELECT date_part('MONTH',now()) -  date_part('MONTH',fechaalta) FROM sapcatalogoempleados WHERE numempn=iEmpleado);
	--MESES TRABAJADOS DONDE EL AÑO DE LA FECHA ALTA NO SEA EL ACTUAL

	IF (EXISTS(SELECT numemp FROM sapcatalogoempleados WHERE numempn=iEmpleado AND DATE_PART('YEAR',fechaalta)=anno)) THEN 	
		--numMeses:= (SELECT 11+(DATE_PART('month', now()) - DATE_PART('month', fechaalta)) FROM sapcatalogoempleados WHERE numempn=iEmpleado AND DATE_PART('YEAR',fechaalta)=anno);
		numMeses:=13 - (select DATE_PART('month', fechaalta) FROM sapcatalogoempleados WHERE numempn=iEmpleado); 
	ELSif ((select DATE_PART('year', fechaalta + INTERVAL '1 YEAR') FROM sapcatalogoempleados WHERE numempn=iEmpleado) = anno) THEN
		/*
		IF ((SELECT DATE_PART('year', fechaalta + INTERVAL '1 YEAR')  FROM sapcatalogoempleados WHERE numempn=iEmpleado ) = anno) THEN
			numMeses:= (SELECT 11 + (DATE_PART('month', now()) - DATE_PART('month', fechaalta)) FROM sapcatalogoempleados WHERE numempn=iEmpleado AND DATE_PART('YEAR',fechaalta)!=anno);
		ELSE
			numMeses:=12;
		end IF;		
		*/
		if (select (fechaalta+ INTERVAL '1 YEAR')::date FROM sapcatalogoempleados WHERE numempn=iEmpleado)<= now()::date then
		    numMeses:=13 - (select DATE_PART('month', fechaalta) FROM sapcatalogoempleados WHERE numempn=iEmpleado); 		    
		else
		    numMeses:=12;		    
		end if;
	
	else
		numMeses:=12;
	end IF;	

	--
	IF  (numMeses>=12) THEN
		numMeses=12;	
	END IF;
	
	--TOPE ANUAL
	UPDATE 	tmpPagosMensuales SET tope=((B.sueldo/100.00)/2)*numMeses
	FROM	sapcatalogoempleados B
	WHERE	B.numempn=iEmpleado; 
	
	--RESTANTE MES
	UPDATE tmpPagosMensuales SET restante_mes= tope_mes - pagado_mes;

	--INSERTAR FACTURAS PAGADAS
	INSERT 	INTO tmpPagadoFacturas (idfactura, numemp, anio, importe_concepto,mes_pagado, idu_tipo_pago)
	SELECT 	DISTINCT idfactura, numemp, anio, importe_mes/*importe_concepto*/,mes_pagado, idu_tipo_pago 
	FROM 	CTL_IMPORTES_FACTURAS_MES
	WHERE	anio=anno 
	AND numemp=iEmpleado
	AND pagado=1;
			
	/*INSERT 	INTO tmpPagadoFacturas (idfactura, numemp, anio, importe_concepto)
	SELECT 	idfactura, numemp, anio, importe_concepto 
	FROM 	CTL_IMPORTES_FACTURAS_MES
	WHERE	anio=anno 
	AND numemp=iEmpleado
	AND pagado=1;*/

	--IMPORTE ANUAL
	INSERT 	INTO tmpImporte_Anual (anio, numemp, importe)
	SELECT	anio,numemp,sum(importe_concepto)
	FROM 	tmpPagadoFacturas
	GROUP	BY anio,numemp ;

	--MODIFICAR IMPORTES FACTURAS PAGADAS MOV
	UPDATE 	tmpPagadoFacturas set importe_factura=B.importe_factura, importe_pagado=B.importe_pagado
	FROM	MOV_FACTURAS_COLEGIATURAS B
	WHERE	tmpPagadoFacturas.idfactura=B.idfactura;

	--MODIFICAR IMPORTES FACTURAS PAGADAS HIS
	UPDATE 	tmpPagadoFacturas set importe_factura=B.importe_factura, importe_pagado=B.importe_pagado
	FROM	HIS_FACTURAS_COLEGIATURAS B
	WHERE	tmpPagadoFacturas.idfactura=B.idfactura;

	--PORCENTAJE DESCUENTO
	UPDATE	tmpPagadoFacturas SET prc_descuento=B.prc_descuento
	FROM	MOV_DETALLE_FACTURAS_COLEGIATURAS B
	WHERE	tmpPagadoFacturas.idfactura=B.idfactura;

	--PORCENTAJE DESCUENTO HIS
	UPDATE	tmpPagadoFacturas SET prc_descuento=B.prc_descuento
	FROM	HIS_DETALLE_FACTURAS_COLEGIATURAS B
	WHERE	tmpPagadoFacturas.idfactura=B.idfactura;

	--IMPORTE PAGADO
	--UPDATE 	tmpPagosMensuales set pagado=B.importe_factura --B.importe_pagado + (B.importe_factura*(prc_descuento/100.00))
	--FROM	tmpPagadoFacturas B;

	UPDATE 	tmpPagosMensuales set pagado= B.importe
	FROM	tmpImporte_Anual B;

	--AJUSTES ACTUALES DEL EMPLEADO
	INSERT 	INTO tmpAjustes
	SELECT 	B.idfactura, sum(B.importe_ajuste) 
	FROM 	HIS_FACTURAS_COLEGIATURAS A 
	inner	join MOV_AJUSTES_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	WHERE	A.idu_empleado=iEmpleado
		AND cast((DATE_PART('year', B.fec_registro)) as integer)=anno
	GROUP 	BY B.idfactura;

	--AJUSTES HISTORICO DEL EMPLEADO
	INSERT 	INTO tmpAjustes
	SELECT 	B.idfactura, sum(B.importe_ajuste) 
	FROM 	HIS_FACTURAS_COLEGIATURAS A 
	inner	join HIS_AJUSTES_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
	WHERE	A.idu_empleado=iEmpleado
		AND cast((DATE_PART('year', B.fec_registro)) as integer)=anno
	GROUP 	BY B.idfactura;	

	--SUMA AJUSTES
	UPDATE 	tmpPagosMensuales set ajuste= COALESCE((SELECT sum(importe) FROM tmpAjustes),0.00);

	--RESTANTE AÑO
	UPDATE tmpPagosMensuales SET restante= (tope + ajuste) - pagado;	
	
	FOR registro IN (
		SELECT case 
			when imes=1 THEN 'ENERO' 
			when imes=2 THEN 'FEBRERO' 
			when imes=3 THEN 'MARZO' 
			when imes=4 THEN 'ABRIL' 
			when imes=5 THEN 'MAYO'
			when imes=6 THEN 'JUNIO' 
			when imes=7 THEN 'JULIO' 
			when imes=8 THEN 'AGOSTO' 
			when imes=9 THEN 'SEPTIEMBRE' 
			when imes=10 THEN 'OCTUBRE'
			when imes=11 THEN 'NOVIEMBRE' 
			when imes=12 THEN 'DICIEMBRE'
		ELSE 'INSCRIPCION' END, 
			pagado_mes,  tope_mes, restante_mes,
			pagado,  tope, restante, ajuste 
		FROM 	tmpPagosMensuales ORDER BY imes ) LOOP
		RETURN NEXT registro;
	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
