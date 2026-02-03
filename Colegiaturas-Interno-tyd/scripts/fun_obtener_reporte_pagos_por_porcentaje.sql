DROP FUNCTION if exists fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_pagos_por_porcentaje(
IN iporcentaje integer, 
IN idempresa integer, 
IN dfechainicial date, 
IN dfechafinal date, 
OUT tipo integer, 
OUT fechacorte date, 
OUT fecha character varying, 
OUT idu_empresa integer, 
OUT nom_empresa character varying, 
OUT num_empleado integer, 
OUT nom_empleado character varying, 
OUT num_centro integer, 
OUT nom_centro character varying, 
OUT total_importe_facturas numeric, 
OUT total_pagado numeric, 
OUT total_facturas integer, 
OUT ruta_pago integer, 
OUT nom_ruta_pago character varying, 
OUT num_tarjeta character varying, 
OUT prc_descuento integer, 
OUT total_empleados integer)
  RETURNS SETOF record AS
$BODY$
declare
	/*===================================================================================================================
		No. petición APS               : 16559.1
		Fecha                          : 22/08/2018
		Número empleado                : 98439677
		Nombre del empleado            : Rafael Ramos Gutiérrez
		Base de datos                  : Personal
		Descripción del funcionamiento : 
		Descripción del cambio         : 
		Sistema                        : Colegiaturas
		Módulo                         : Reporte Pagos por Porcentaje
		Ejemplo                        : 
				SELECT tipo
                    , fechacorte
                    , fecha
                    , idu_empresa
                    , ENCODE(CONVERT_TO(nom_empresa, 'UTF-8'), 'base64') as nom_empresa
                    , num_empleado
                    , ENCODE(CONVERT_TO(nom_empleado, 'UTF-8'), 'base64') as nom_empleado
                    , num_centro
                    , ENCODE(CONVERT_TO(nom_centro, 'UTF-8'), 'base64') as nom_centro
                    , total_importe_facturas
                    , total_pagado
                    , total_facturas
                    , ruta_pago
                    , ENCODE(CONVERT_TO(nom_ruta_pago, 'UTF-8'), 'base64') as nom_ruta_pago
                    , ENCODE(CONVERT_TO(num_tarjeta, 'UTF-8'), 'base64') as num_tarjeta
                    , prc_descuento
                    , total_empleados
				FROM fun_obtener_reporte_pagos_por_porcentaje(80, 0, '20180601', '20180730') 
                
                set client_encoding =''
                set client_encoding ='SQL_ASCII'
                -- Decoding
                SELECT CONVERT_FROM(DECODE(field, 'BASE64'), 'UTF-8') FROM table;

                -- Encoding
                SELECT ENCODE(CONVERT_TO(field, 'UTF-8'), 'base64') FROM table;




			SELECT * 
			FROM fun_obtener_reporte_pagos_por_porcentaje(50
			, 0
			, '20180801'
			, '20180905')
			sapcatalogoempleados where numempn = 97225101
	===================================================================================================================*/

	valor record;
	TotalRegistros integer;
	TotalEmpleados integer;
begin
	
	create temporary table tmp_PagosPorcentaje(
		idfactura integer not null default 0
		--, tipo integer not null default 0
		, tipo integer not null default 0
		, fechacorte date not null default '19000101'
		, fecha character varying(7) not null default ''
		, idu_empresa integer not null default 0
		, nom_empresa character varying(100) not null default ''
		, num_empleado integer not null default 0
		, nom_empleado character varying(100) not null default ''
		, num_centro integer not null default 0
		, nom_centro character varying(100) not null default ''
		, total_importe_facturas numeric(12,2)
		, total_pagado numeric(12,2)
		, total_facturas integer
		, ruta_pago integer not null default 0
		, nom_ruta_pago character varying(50) not null default ''
		, num_tarjeta character varying(100) not null default ''
		, prc_descuento integer not null default 0		
		, total_empleados integer not null default 0
	)on commit drop;

	create temporary table tmp_Totales(
		total_importe_facturas numeric(12,2)
		, total_pagado numeric(12,2)
		, fechacorte date not null default '19000101'
		, fecha character varying(7) not null default ''
		, totalfacturas integer not null default 0
		, totalEmpleados integer not null default 0
	)on commit drop;
	

	
	INSERT INTO tmp_PagosPorcentaje(idfactura 
					, num_empleado
					, num_centro
					, fechacorte
					, fecha
					, idu_empresa
					, prc_descuento
					, ruta_pago
					, num_tarjeta
					, total_importe_facturas
					, total_pagado
					, total_facturas)
	SELECT	his.idfactura
		, his.idu_empleado
		, his.idu_centro
		, his.fec_cierre::DATE
		, to_char(his.fec_cierre,'yyyy-MM')
		, his.idu_empresa
		, his.prc_descuento
		, his.clv_rutapago
		, his.num_cuenta
		, SUM(his.importe_factura) AS total_importe_facturas
		, SUM(his.importe_pagado)/COUNT(his.idfactura::NUMERIc) AS total_pagado
		, COUNT(his.idfactura) AS total_facturas
	FROM	view_his_rutas_pagos as his
	WHERE	his.idu_estatus = 6
		AND his.fec_cierre::DATE BETWEEN dFechaInicial AND dFechaFinal
		AND his.prc_descuento = iPorcentaje
	GROUP	BY his.idfactura 
		, his.idu_empleado
		, his.idu_centro
		, his.fec_cierre::DATE
		, to_char(his.fec_cierre, 'yyyy-MM')
		, his.prc_descuento
		, his.clv_rutapago
		, his.num_cuenta
		, his.idu_empresa;
	--ORDER	BY his.idu_empleado DESC;
/*
	insert into tmp_Empleados
	SELECt	count(distinct his.idu_empleado)
	from	view_his_rutas_pagos his
	WHERE	his.idu_estatus = 6
		AND his.fec_cierre::DATE BETWEEN '20180601' AND '20180824'
		AND his.prc_descuento = 100
*/
	UPDATE	tmp_PagosPorcentaje set	tipo = 0;
	if(idEmpresa != 0)then
		delete from tmp_PagosPorcentaje as tmp where tmp.idu_empresa not in (idEmpresa);
	end if;
	
	--ACTUALIZAR CAMPOS DE TEMPORAL
	update	tmp_PagosPorcentaje
	set	nom_empleado = trim(UPPER(a.nombre)) || ' ' || trim(UPPER(a.apellidopaterno)) || ' ' || trim(UPPER(a.apellidomaterno))
	from	sapcatalogoempleados as a
	where	tmp_PagosPorcentaje.num_empleado = a.numempn;

	--ACTUALIZAR NOMBRE DE CENTRO
	update	tmp_PagosPorcentaje
	set	nom_centro = trim(UPPER(a.nombrecentro))
	from	sapcatalogocentros as a
	where	tmp_PagosPorcentaje.num_centro = a.centron;
	
	--ACTUALIZAR RUTA DE PAGO
	Update	tmp_PagosPorcentaje
	set	nom_ruta_pago = trim(UPPER(a.nom_rutapago))
	from	cat_rutaspagos as a
	where	tmp_PagosPorcentaje.ruta_pago = a.idu_rutapago;

	--PORCENTAJES DE HIS_DETALLE_FACTURAS_COLEGIATURAS
	update	tmp_PagosPorcentaje
	set	prc_descuento = a.prc_descuento
	from	his_detalle_facturas_colegiaturas AS a
	where	tmp_PagosPorcentaje.num_empleado = a.idu_empleado
		AND a.prc_descuento = tmp_PagosPorcentaje.prc_descuento;

	--ACTUALIZAR EL NOMBRE DE LA EMPRESA
	update	tmp_PagosPorcentaje
	set	nom_empresa = TRIM(UPPER(a.nom_empresa))
	from	view_empresas_colegiaturas AS a
	where	tmp_PagosPorcentaje.idu_empresa = a.idu_empresa;

	--CALCULAR TOTALES DEL MES Y LO REGISTRA EN LA TEMPORAL TMP_TOTALES
	INSERT INTO tmp_Totales(fecha, total_importe_facturas
				, total_pagado
				, totalfacturas
				, totalEmpleados)
	SELECT	tmp.fecha
        , SUM(tmp.total_importe_facturas)
		, SUM(tmp.total_pagado)
		, sum(tmp.total_facturas)
		, COUNT(DISTINCT tmp.num_empleado)
	from	tmp_PagosPorcentaje AS tmp
	GROUP	BY tmp.fecha;
	
	--INSERTAR IMPORTES MENSUALES EN TABLA tmp_PagosPorcentaje
	insert into tmp_PagosPorcentaje(tipo
					, fecha
					, total_importe_facturas
					, total_pagado
					, total_facturas
					, total_Empleados)
	SELECT	1
		, a.fecha
		, a.total_importe_facturas
		, a.total_pagado
		, a.totalfacturas
		, a.totalEmpleados
	FROM	tmp_Totales AS a
	group	by a.fecha
			, a.fechacorte
			, a.total_importe_facturas
			, a.total_pagado
			, a.totalfacturas
			, a.totalEmpleados
	order	by a.fecha;

	TotalRegistros := (SELECT COUNT(*) FROM tmp_PagosPorcentaje);
	TotalEmpleados := (SELECT COUNT(DISTINCT tmp.num_empleado) FROM tmp_PagosPorcentaje as tmp where tmp.num_empleado != 0);

	if(TotalRegistros != 0)then
		--INSERTAR IMPORTE GENERAL EN TABLA tmp_PagosPorcentaje
		INSERT INTO tmp_PagosPorcentaje(tipo
						, fecha
						, total_importe_facturas
						, total_pagado
						, total_facturas
						, total_Empleados)
		SELECT	2
			, to_char(now() ,'yyyy-MM') as fecha
			, SUM(a.total_importe_facturas)
			, SUM(a.total_pagado)
			, SUM(a.total_facturas)
			--, COUNT(a.total_Empleados) as total_Empleados
			, TotalEmpleados
		from	tmp_PagosPorcentaje AS a
		where	a.tipo = 1;
	end if;
    
	for valor in (SELECT tmp.tipo
				, tmp.fechacorte
				, tmp.fecha
				, tmp.idu_empresa
				, tmp.nom_empresa
				, tmp.num_empleado
				, tmp.nom_empleado
				, tmp.num_centro
				, tmp.nom_centro
				, tmp.total_importe_facturas
				, tmp.total_pagado
				, tmp.total_facturas
				, tmp.ruta_pago
				, tmp.nom_ruta_pago
				, tmp.num_tarjeta
				, tmp.prc_descuento
				, tmp.total_empleados
			FROM	tmp_PagosPorcentaje as tmp
			order	BY  tmp.fecha,tmp.tipo, tmp.fechacorte)
	loop
		tipo			:=	valor.tipo;
		fechacorte		:=	valor.fechacorte;
		fecha			:=	valor.fecha;
		idu_empresa		:=	valor.idu_empresa;
		nom_empresa		:=	valor.nom_empresa;
		num_empleado		:=	valor.num_empleado;
		nom_empleado		:=	valor.nom_empleado;
		num_centro		:=	valor.num_centro;
		nom_centro		:=	valor.nom_centro;
		total_importe_facturas	:=	valor.total_importe_facturas;
		total_pagado		:=	valor.total_pagado;
		total_facturas		:=	valor.total_facturas;
		ruta_pago		:=	valor.ruta_pago;
		nom_ruta_pago		:=	valor.nom_ruta_pago;
		num_tarjeta		:=	valor.num_tarjeta;
		prc_descuento		:=	valor.prc_descuento;	
		total_empleados		:=	valor.total_empleados;
		return next;
	end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_pagos_por_porcentaje(integer, integer, date, date) IS 'La funcion obtiene el reporte de pagos por porcentaje de descuento';  