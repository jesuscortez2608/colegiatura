DROP FUNCTION IF EXISTS fun_generar_incentivos_colegiaturas(integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_generar_incentivos_colegiaturas(IN ipage integer, IN ilimit integer, IN tipoc integer, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT numempresa character varying, OUT nomempresa character varying, OUT numemp integer, OUT nombre character varying, OUT importe numeric, OUT isr numeric, OUT total numeric, OUT tipo integer, OUT estatus integer, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
-- ===================================================
-- Peticion: 18292
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 19/12/2017
-- Descripción General: Función para exportar excel incentivos de Colegiaturas_33
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/personal/elp/colegiaturas_33/scripts
-- Sistema: Colegiaturas_33
-- Servidor Productivo: 10.44.2.29
-- Servidor Desarrollo: 10.44.15.182
-- Ejemplo: 
--	SELECT * FROM fun_generar_incentivos_colegiaturas(1)
--  SELECT numemp, (cast(importe+isr as float))/100 as total FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS(1)
--  	SELECT * FROM fun_generar_incentivos_colegiaturas(0) -- Grid
--  	SELECT * FROM fun_generar_incentivos_colegiaturas(1) -- Listado
--      SELECT  trim(nombre) as Colaborador, trunc((importe::float/100::float)::numeric,2) as importe, trunc((isr::float/100::float)::numeric,2) as isr, trunc((total::float/100::float)::numeric,2) as total  FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS(0)
--      SELECT  trim(nombre) as Colaborador, trunc((importe::float/100::float)::numeric,2) as importe, trunc((isr::float/100::float)::numeric,2) as isr, trunc((total::float/100::float)::numeric,2) as total, estatus, mensaje FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS(0)
-- DROP TABLE tmp_incentivos
-- delete from ctl_proceso_colegiaturas
-- ===================================================
	--DECLARACION DE VARIABLES		
	sQuery TEXT;	
	valor record;		
    
	iCicloColegiaturas INTEGER;
	iPagosUltimoCiclo SMALLINT;
	iCierreUltimoCiclo SMALLINT;
	iUsuario integer;
	dFechaQuincena DATE = '1900-01-01';
		
	sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER;
	iColaboradores BIGINT;
	iFacturas BIGINT;

BEGIN
	if date_part('day', now()::DATE) <= 15 then
	    -- Día 15 del mes
	    dFechaQuincena = (select date_trunc('month', now()::date) + interval '14 day');
	    dFechaQuincena = dFechaQuincena::DATE;
	else
	    -- Último día del mes
	    dFechaQuincena := (select date_trunc('month', now()::date) + interval '1 month' - interval '1 day');
	    dFechaQuincena = dFechaQuincena::DATE;
	end if;
    
    iCicloColegiaturas:= (SELECT COALESCE(MAX(idu_ciclo), 0) FROM ctl_proceso_colegiaturas);
    iPagosUltimoCiclo:=  (select (case when fec_pagos::date > '1900-01-01' then 1 else 0 end)::smallint from ctl_proceso_colegiaturas where idu_ciclo = iCicloColegiaturas limit 1);
    iCierreUltimoCiclo:= (select (case when fec_cierre::date > '1900-01-01' then 1 else 0 end)::smallint from ctl_proceso_colegiaturas where idu_ciclo = iCicloColegiaturas limit 1);
    iPagosUltimoCiclo:=  COALESCE(iPagosUltimoCiclo, 0::SMALLINT);
    iCierreUltimoCiclo:= COALESCE(iCierreUltimoCiclo, 0::SMALLINT);

    iColaboradores := 0;
    iFacturas := 0;
    
    if iCicloColegiaturas = 0 or iCierreUltimoCiclo = 1 or iPagosUltimoCiclo = 0 then
        FOR valor IN SELECT 0::INTEGER AS num_empresa
                        , ''::VARCHAR AS nom_empresa
                        , 0::INTEGER AS tipo
                        , 0::INTEGER AS num_empleado
                        , ''::VARCHAR AS nombre
                        , 0.0::NUMERIC(12,2) AS imp_factura
                        , 0.0::NUMERIC(12,2) AS imp_isr
                        , 0.0::NUMERIC(12,2) AS total
                        , -1 as estatus
                        , 'Es necesario generar pagos de colegiaturas para generar los incentivos' as mensaje
        LOOP
            numempresa=valor.num_empresa;
            nomempresa=valor.nom_empresa;
            tipo:= valor.tipo;
            numemp:=valor.num_empleado;
            nombre:=valor.nombre;
            importe:=valor.imp_factura;
            isr:=valor.imp_isr;
            total:=valor.total;
            estatus:=valor.estatus;
            mensaje:=valor.mensaje;
            RETURN NEXT;
        END LOOP;
        
        return;
    end if;

	--
	CREATE TEMPORARY TABLE tmp_incentivos(
		tipo INTEGER,
		num_empresa INTEGER,
		nom_empresa VARCHAR(200),
		num_empleado INTEGER,
		nombre VARCHAR(200),
		imp_factura NUMERIC(12,2), 
		imp_isr NUMERIC(12,2),
		total NUMERIC(12,2)
	)ON COMMIT DROP;

	INSERT 	INTO tmp_incentivos(tipo, num_empleado, imp_factura, imp_isr, total)	
	SELECT 	inc.tipo
		, inc.num_empleado
		, sum(inc.imp_factura)
		, sum(inc.imp_isr)
		, sum(inc.total)
	from 	(	
		SELECT 	0 as tipo
			, idu_empleado as num_empleado
			, importe_pagado as imp_factura
			, importe_isr as imp_isr
			, importe_pagado+importe_isr as total
		FROM 	mov_generacion_pagos_colegiaturas 
		WHERE   fec_quincena = dFechaQuincena
		UNION ALL
		SELECT 	0 as tipo
			, idu_empleado as num_empleado
			, importe_pagado as imp_factura
			, importe_isr as imp_isr
			, importe_pagado+importe_isr as total
		FROM 	his_generacion_pagos_colegiaturas 
		WHERE   fec_quincena = dFechaQuincena
		) as inc
	group 	by inc.tipo, inc.num_empleado
	ORDER 	BY inc.num_empleado ASC;
	--SELECT 0, num_hisempleado, imp_hisfactura, imp_isr, imp_hisfactura+imp_isr FROM his_generacionpagocolegiaturas where imp_isr>0 ORDER BY num_hisempleado ASC;

	--select * from sapcatalogoempleados limit 1
	UPDATE 	tmp_incentivos SET num_empresa=empresa,nombre=CAST(a.numemp AS VARCHAR)||' '||TRIM(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno) 
	from 	sapcatalogoempleados a 
	WHERE 	a.numempn=tmp_incentivos.num_empleado;

	UPDATE 	tmp_incentivos SET nom_empresa=b.nombre
	FROM 	sapempresas b
	WHERE	tmp_incentivos.num_empresa=b.clave;

	IF (tipoC=0 and (select count(num_empleado) from tmp_incentivos)>0)THEN --INSERTAR TOTALES
		INSERT 	INTO tmp_incentivos(tipo,nombre, num_empleado, imp_factura, imp_isr, total)
		SELECT 	1,'TOTAL COLABORADORES: '||CAST(COUNT(a.num_empleado) AS VARCHAR),COUNT(a.num_empleado), SUM(a.imp_factura), SUM(a.imp_isr), SUM(a.total) 
		FROM 	tmp_incentivos a;
	END IF;
	
	-- Actualizar el proceso
	-------------------------------------------------------
	iUsuario := (select idu_empleado_generacion from mov_generacion_pagos_colegiaturas limit 1);
	iUsuario := COALESCE(iUsuario, 0);

	if (tipoC = 1) THEN -- Al hacer click en el boton de "Generar Incentivos"
        /** =======================================
            REALIZAR REGISTRO DE MOVIMIENTO
                TABLA DE BITACORA
        ======================================= **/
        iColaboradores := (SELECT COUNT(DISTINCT(num_empleado)) FROM tmp_incentivos);
        iFacturas := (SELECT COUNT(DISTINCT(idfactura)) FROM mov_detalle_generacion_pagos_colegiaturas  );

        INSERT INTO bit_proceso_colegiaturas(id_movimiento, num_facturas, num_colaboradores, fec_quincena, id_usuario)
        VALUES(3, iFacturas, iColaboradores , dFechaQuincena, iUsuario);
        /** =======================================
        ======================================= **/

        update 	CTL_PROCESO_COLEGIATURAS set fec_incentivos = now()
            , usr_incentivos = iUsuario
        where 	idu_ciclo = iCicloColegiaturas;
    END IF;

	--
	CREATE TEMPORARY TABLE tmp_incentivos_paginado(
		records integer,
		page integer,
		pages integer,
		tipo INTEGER,
		num_empresa INTEGER,
		nom_empresa VARCHAR(200),
		num_empleado INTEGER,
		nombre VARCHAR(200),
		imp_factura NUMERIC(12,2), 
		imp_isr NUMERIC(12,2),
		total NUMERIC(12,2),
		estatus integer,
		mensaje varchar(50)
	)ON COMMIT DROP;	

	insert	into tmp_incentivos_paginado (
		num_empresa, 
		nom_empresa,
		tipo,
		num_empleado,
		nombre,
		imp_factura, 
		imp_isr,
		total, 
		estatus, 
		mensaje)
	SELECT 	a.num_empresa
		, a.nom_empresa
		, a.tipo
		, a.num_empleado
		, a.nombre
		, a.imp_factura
		, a.imp_isr
		, a.total 
		, 1 --::INTEGER as estatus
		, 'Incentivos generados correctamente'::VARCHAR AS mensaje
	FROM 	tmp_incentivos a 
	ORDER 	BY a.tipo, a.num_empleado ASC;


	--VARIABLES PARA PAGINADO
	if iPage = -1 then
		iPage := NULL;
	end if;
	if iLimit = -1 then
		iLimit := null;
	end if;

	iRecords := (SELECT COUNT(*) FROM tmp_incentivos_paginado);
	raise notice '%',iRecords;

	sColumns := 'records, page, pages, num_empresa, nom_empresa, tipo, num_empleado, nombre, imp_factura, imp_isr, total, estatus, mensaje';

	if (iPage is not null and iLimit is not null) then	
		iStart := (iLimit * iPage) - iLimit + 1;
		iTotalPages := ceiling(iRecords / (iLimit * 1.0));


		sQuery := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		, ' || CAST(iPage AS VARCHAR) || ' AS page
		, ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		, id
		, ' || sColumns || '
		from (
		SELECT ROW_NUMBER() OVER (ORDER BY Nombre ASC) AS id, ' || sColumns || '
		FROM tmp_incentivos_paginado
		) AS t
		WHERE  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
	else 
		sQuery := 'SELECT ' || iRecords::VARCHAR || ' AS records, 0 as page, 0 as pages, 0 as id, ' || sColumns || ' FROM tmp_incentivos_paginado ';

	end if;
	--WHERE  t.conexion= ' || iConexion || ' and t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
	
	/*FOR valor IN 
		SELECT 	a.num_empresa
			, a.nom_empresa
			, a.tipo
			, a.num_empleado
			, a.nombre
			, a.imp_factura
			, a.imp_isr
			, a.total 
			, 1::INTEGER as estatus
			, 'Incentivos generados correctamente'::VARCHAR AS mensaje
		FROM 	tmp_incentivos_paginado a 
		ORDER 	BY a.tipo, a.num_empleado ASC*/
		
	FOR valor IN EXECUTE (sQuery)
	LOOP
		records:=valor.records;
		page:=valor.page;
		pages:=valor.pages;
		id:=valor.id;
		numempresa=valor.num_empresa;
		nomempresa=valor.nom_empresa;
		tipo:= valor.tipo;
		numemp:=valor.num_empleado;
		nombre:=valor.nombre;
		importe:=valor.imp_factura;
		isr:=valor.imp_isr;
		total:=	valor.total;
		estatus:=valor.estatus;
		mensaje:=valor.mensaje;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_generar_incentivos_colegiaturas(integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_generar_incentivos_colegiaturas(integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_generar_incentivos_colegiaturas(integer, integer, integer) TO sysetl;
COMMENT ON FUNCTION fun_generar_incentivos_colegiaturas(integer, integer, integer) IS 'La función genera incentivos de colegiaturas';