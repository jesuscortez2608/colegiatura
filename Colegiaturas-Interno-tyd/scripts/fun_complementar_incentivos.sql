CREATE OR REPLACE FUNCTION fun_complementar_incentivos(
IN iopcion integer, 
OUT snomempresa character varying, 
OUT inumemp numeric, 
OUT snombre character varying, 
OUT nimporte numeric, 
OUT nisr numeric, 
OUT ntotal numeric)
  RETURNS SETOF record AS
$BODY$
declare
	valor record;
	dFechaQuincena DATE = '1900-01-01';
begin
	/*
	No. petición APS               : 17875.1
	Fecha                          : 14/11/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : administracion
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Actualiza los registros seleccionados en el traspaso de facturas
	Ejemplo                        :
        select * from fun_complementar_incentivos(0)
        select * from fun_complementar_incentivos(1)
	*/
	if date_part('day', now()::DATE) <= 15 then
        -- Día 15 del mes
        dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
    else
        -- Último día del mes
        dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
    end if;
    
	--drop TABLE tmp
	--drop table if exists tmp_incentivos;
	--CREATE TABLE tmp_incentivos(		
	CREATE TEMPORARY TABLE tmp_incentivos(
		nom_empresa character varying(200), 
		num_empleado integer, 
		nombre character varying(200),  
		imp_factura numeric(12,2), 
		imp_isr numeric(12,2), 
		total numeric(12,2)
	)ON COMMIT DROP;
	--);
    
	--drop table if exists mov_incentivos;
	--CREATE TABLE mov_incentivos(
	CREATE TEMPORARY TABLE mov_incentivos(
		idu_empleado integer,
		importe_factura numeric(12,2),
		importe_pagado numeric(12,2),
		importe_isr numeric(12,2)
	)ON COMMIT DROP;
	--);
	
	insert into mov_incentivos(idu_empleado, importe_factura, importe_pagado, importe_isr)
	select idu_empleado
        , importe_factura
        , importe_pagado
        , importe_isr
    from HIS_GENERACION_PAGOS_COLEGIATURAS
    where fec_quincena = dFechaQuincena;
	
	insert into mov_incentivos(idu_empleado, importe_factura, importe_pagado, importe_isr)
	select idu_empleado
        , importe_factura
        , importe_pagado
        , importe_isr
    from MOV_GENERACION_PAGOS_COLEGIATURAS
    where fec_quincena = dFechaQuincena;
    
	--drop table if exists grp_incentivos;
	--CREATE TABLE grp_incentivos(
	CREATE TEMPORARY TABLE grp_incentivos(
		idu_empleado integer,
		importe_factura numeric(12,2),
		importe_pagado numeric(12,2),
		importe_isr numeric(12,2)
	)ON COMMIT DROP;
	--);

	insert into grp_incentivos(idu_empleado, importe_factura, importe_pagado, importe_isr)
	select idu_empleado
        , sum(importe_factura) as importe_factura
        , sum(importe_pagado) as importe_pagado
        , sum(importe_isr) as importe_isr
    from mov_incentivos
    group by idu_empleado;
	
	if (iOpcion=0) then --UNIFICAR ARCHIVO
        update	stmp_incentivos set imp_factura=imp_factura+B.importe_pagado, imp_isr=imp_isr+B.importe_isr, total=total+(B.importe_pagado+B.importe_isr)
		from	grp_incentivos B
		where	stmp_incentivos.num_empleado=B.idu_empleado;
        
		INSERT 	INTO stmp_incentivos(num_empleado, imp_factura, imp_isr, total)	
		SELECT 	idu_empleado, importe_pagado, importe_isr, importe_pagado+importe_isr 
		FROM 	grp_incentivos
		where	idu_empleado not in (select num_empleado from stmp_incentivos) 
		ORDER 	BY idu_empleado ASC;
        
		--EMPLEADO
		UPDATE 	STMP_INCENTIVOS SET num_empresa=B.empresa, nombre=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
		FROM	SAPCATALOGOEMPLEADOS B
		where	stmp_incentivos.num_empleado=B.numempn;

		--EMPRESA
		UPDATE	STMP_INCENTIVOS set nom_empresa=B.nombre
		from 	SAPEMPRESAS B
		where	STMP_INCENTIVOS.num_empresa=B.clave;
		
	end if;

	insert  into tmp_incentivos (nom_empresa, num_empleado, nombre, imp_factura, imp_isr, total)
	SELECT 	nom_empresa, num_empleado, nombre, imp_factura, imp_isr, total 
	FROM 	stmp_incentivos;	

	--ENVIAR INCENTIVOS
	if (iOpcion=2) then
		delete 	from stmp_incentivos;
	end if;

	--
	FOR valor IN (SELECT nom_empresa, num_empleado, nombre, imp_factura, imp_isr, total FROM tmp_incentivos)
	LOOP
		sNomempresa:=valor.nom_empresa;
		iNumemp:=valor.num_empleado;
		sNombre:= valor.nombre;
		nImporte:= valor.imp_factura;
		nIsr:= valor.imp_isr;
		nTotal:=valor.total;
		
	RETURN NEXT;
	END LOOP;	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_complementar_incentivos(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_complementar_incentivos(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_complementar_incentivos(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_complementar_incentivos(integer) TO postgres;
COMMENT ON FUNCTION fun_complementar_incentivos(integer) IS 'La función complementa los incentivos del sistema anterior con el nuevo';
