CREATE OR REPLACE FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(IN irutapago integer, 
    IN iestatus integer, 
    IN iregion integer, 
    IN iciudad integer, 
    IN itipodeduccion integer, 
    IN iempresa integer, 
    IN dfechainicio character, 
    IN dfechafin character, 
    OUT iidu_empresa integer, 
    OUT snom_empresa character varying, 
    OUT iidu_escolaridad integer, 
    OUT snom_escolaridad character varying, 
    OUT icolaboradores_por_nivel integer, 
    OUT ifacturas_ingresadas integer, 
    OUT nimporte numeric, 
    OUT nreembolso numeric, 
    OUT nporcentaje_colaboradores numeric, 
    OUT nporcentaje_facturas numeric, 
    OUT itotal_colaboradores integer, 
    OUT itotal_facturas_ingresadas integer)
  RETURNS SETOF record AS
$BODY$
DECLARE	
	sQuery TEXT;
	valor record;	
	iOpcionTabla integer=0;
	
	/* --------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 14/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez 
	BD: personal    
	Servidor Desarrollo: 10.44.114.75
	Servidor Productivo: 10.44.2.183
	Modulo: Colegiaturas
	Repositorio: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
    
	SELECT * FROM fun_obtener_reporte_colegiaturas_por_escolaridad(-1, 3, 0, 0, 0, 0, '20180901', '20181026')
	
	--------------------------------------------------------------------------------*/	
	BEGIN
		--CENTROS INVOLUCRADOS
		CREATE LOCAL TEMP TABLE TEMP_CENTROS_INVOLUCRADOS(
			idu_centro integer not null default(0) 
		)ON COMMIT DROP;

		/*--EMPRESAS
		CREATE LOCAL TEMP TABLE TMP_EMPRESAS(
			idu_empresa integer not null default(0)
			, nom_empresa character varying(30) not null default ('')
			, nom_legal character varying(70) not null default ('')
			, rfc character varying(13) not null default ('')
		)ON COMMIT DROP;*/
		
		--ESCOLARIDADES
		CREATE LOCAL TEMP TABLE TMP_ESCOLARIDADES(
			idu_escolaridad integer not null default(0) 
			, nom_escolaridad character varying(30) not null default ('')
		)ON COMMIT DROP;

		--EMPLEADOS/FACTURAS POR EMPRESA
		CREATE LOCAL TEMP TABLE TMP_TOTALES(
			idu_empresa integer not null default(0) 
			, total_empleados integer not null default(0)
			, total_facturas integer not null default(0)			
		)ON COMMIT DROP;

		--TOTAL DE COLABORADORES Y FACTURAS POR EMPRESA -ESCOLARIDAD
		CREATE LOCAL TEMP TABLE TMP_EMPRESA_ESCOLARIDAD(
			idu_empresa integer not null default(0)
			,idu_escolaridad integer not null default(0) 
			,cantidad_empleados integer not null default(0) 
			,cantidad_facturas integer not null default(0) 			
		)ON COMMIT DROP;

		--IMPORTES GENERALES POR EMPRESA-ESCOLARIDAD
		CREATE LOCAL TEMP TABLE TMP_IMPORTES(
			idu_empresa integer not null default(0)
			,idu_escolaridad integer not null default(0) 
			,importe numeric not null default(0)
			,reembolso numeric not null default(0)
		)ON COMMIT DROP;

		--SUMA DE LOS IMPORTES POR EMPRES
		CREATE LOCAL TEMP TABLE TMP_IMPORTES_GENERALES(
			idu_empresa integer not null default(0)			
			,importe numeric not null default(0)
			,reembolso numeric not null default(0)
		)ON COMMIT DROP;

		--TABLA QUE REGRESA LA INFORMACION DEL REPORTE
		CREATE LOCAL TEMP TABLE TMP_REPORTE (
			idu_empresa integer not null default(0)
			, nom_empresa character varying(30) not null default ('')
			, idu_escolaridad integer not null default(0)
			, nom_escolaridad character varying(30) not null default ('')
			, colaboradores_por_nivel integer not null default (0)
			, facturas_ingresadas  integer not null default (0)
			, importe numeric(12,2) not null default(0.0)
			, reembolso numeric(12,2) not null default(0.0)
			, porcentaje_colaboradores numeric(12,4) not null default(0.0)
			, porcentaje_facturas numeric(12,4) not null default(0.0)
			, total_colaboradores numeric(12, 4) not null default(0.0)
			, total_facturas_ingresadas numeric(12, 4) not null default(0.0)
			, total_importe numeric(12, 4) not null default(0.0)
			, total_reembolso numeric(12, 4) not null default(0.0)
		) ON COMMIT DROP;
		
		--RUTAS PAGOS
		create local temp table TEMP_RUTAS_PAGOS (
			idu_empresa integer
			, idu_escolaridad integer
			, idu_empleado integer
			, idu_centro integer
			, idfactura integer
			, idu_estatus integer
			, idu_escuela integer
			, opc_tipo_escuela integer
			, idu_tipo_deduccion integer
			, fec_registro timestamp without time zone
			, fec_cierre timestamp without time zone
			, clv_rutapago integer
			, prc_descuento integer
			, num_cuenta character varying
			, importe_factura numeric(12,2)
			, importe_pagado numeric(12,2)
		) ON COMMIT DROP;

		--INSERTAR CENTROS
		if iRegion = 0 and iCiudad = 0 then -- todos los centros de todas las regiones
			insert 	into temp_centros_involucrados(idu_centro)
			SELECT 	numerocentro::integer
			FROM 	sapcatalogocentros
			WHERE 	cancelado = '';
		elsif iRegion > 0 and iCiudad = 0 then -- todos los centros de la región
			insert 	into temp_centros_involucrados(idu_centro)
			SELECT 	cen.numerocentro::integer
			FROM 	sapcatalogocentros cen
			INNER 	JOIN sapcatalogociudades ciu on (cen.ciudadn = ciu.ciudadn)
			INNER 	JOIN sapregiones reg on ((case when ciu.regionzona = '' or ciu.regionzona is null then '0' else ciu.regionzona end)::integer = reg.numero)
			WHERE 	cen.cancelado = ''
				and reg.numero = iRegion
			order by cen.numerocentro::integer;
		elsif iRegion > 0 and iCiudad > 0 then -- todos los centros de una ciudad
			insert 	into temp_centros_involucrados(idu_centro)
			SELECT 	cen.numerocentro::integer
			FROM 	sapcatalogocentros cen
			INNER 	JOIN sapcatalogociudades ciu on (cen.ciudadn = ciu.ciudadn)
			WHERE 	cen.cancelado = ''
				and ciu.ciudadn = iCiudad
			order 	by cen.numerocentro::integer;
		end if;
		
		--HIS FACTURAS
		sQuery := 'INSERT INTO TEMP_RUTAS_PAGOS(idu_empresa, idu_escolaridad, idu_empleado, idu_centro, idfactura, idu_estatus, idu_escuela, idu_tipo_deduccion, fec_registro, fec_cierre, clv_rutapago, prc_descuento, num_cuenta, importe_factura, importe_pagado)' || 
		'SELECT MOV.idu_empresa, DET.idu_escolaridad, DET.idu_empleado, MOV.idu_centro, DET.idfactura, MOV.idu_estatus, DET.idu_escuela, MOV.idu_tipo_deduccion, MOV.fec_registro, MOV.fec_cierre, MOV.clv_rutapago, DET.prc_descuento, MOV.num_cuenta ' ||
            ', SUM(DET.importe_concepto) ' ||
            ', SUM(DET.importe_pagado) ' ||
		'FROM 	HIS_FACTURAS_COLEGIATURAS MOV ' ||
		'INNER	JOIN HIS_DETALLE_FACTURAS_COLEGIATURAS DET ON DET.idfactura=MOV.idfactura ' ||
		'WHERE  MOV.idu_empresa>0 AND DET.idu_escolaridad>0 AND MOV.fec_cierre::DATE between ''' || dFechaInicio::varchar || ''' and ''' || dFechaFin::varchar || ''' ' ||
		'AND MOV.idu_tipo_documento!=2 AND MOV.idu_beneficiario_externo=0 ' || 
		'and MOV.idu_centro in (SELECT idu_centro FROM TEMP_CENTROS_INVOLUCRADOS) ' ||
		'and MOV.idu_estatus = ' || iEstatus::varchar || ' ';
        
		--EMPRESA
		if iEmpresa>0 then
			sQuery := sQuery || 'and MOV.idu_empresa = ' || iEmpresa::varchar || ' ';
		end if;

		--RUTA PAGO
		if iRutaPago > 0 then
			sQuery := sQuery || 'and MOV.clv_rutapago = ' || iRutaPago::varchar || ' ';
		end if;

		--TIPO DEDUCCION
		if iTipoDeduccion > 0 then
			sQuery := sQuery || 'and MOV.idu_tipo_deduccion = ' || iTipoDeduccion::varchar || ' ';
		end if;
        
        sQuery := sQuery || 'GROUP BY MOV.idu_empresa, DET.idu_escolaridad, DET.idu_empleado, MOV.idu_centro, DET.idfactura, MOV.idu_estatus, DET.idu_escuela, MOV.idu_tipo_deduccion, MOV.fec_registro, MOV.fec_cierre, MOV.clv_rutapago, DET.prc_descuento, MOV.num_cuenta ';
        
		--
		raise notice '%', sQuery; 
		EXECUTE sQuery;	

		--MOV_FACTURAS
		sQuery := 'INSERT INTO TEMP_RUTAS_PAGOS(idu_empresa, idu_escolaridad, idu_empleado, idu_centro, idfactura, idu_estatus, idu_escuela, idu_tipo_deduccion, fec_registro, fec_cierre
                    , clv_rutapago, prc_descuento, num_cuenta
                    , importe_factura, importe_pagado)' || 
		'SELECT MOV.idu_empresa, DET.idu_escolaridad, DET.idu_empleado, MOV.idu_centro, DET.idfactura, MOV.idu_estatus, DET.idu_escuela, MOV.idu_tipo_deduccion, MOV.fec_registro, ''1900-01-01''::DATE as fec_cierre 
            , (CASE WHEN TRIM(EMP.controlpago) = '''' THEN ''0'' ELSE EMP.controlpago END)::INTEGER, DET.prc_descuento, EMP.numerotarjeta ' ||
            ', SUM(DET.importe_concepto), SUM(DET.importe_pagado) ' ||
		'FROM 	MOV_FACTURAS_COLEGIATURAS MOV ' ||
		'INNER	JOIN MOV_DETALLE_FACTURAS_COLEGIATURAS DET ON DET.idfactura=MOV.idfactura ' ||
		'INNER	JOIN SAPCATALOGOEMPLEADOS EMP ON MOV.idu_empleado = EMP.numempn ' ||
		'WHERE  MOV.idu_empresa>0 AND DET.idu_escolaridad>0 AND MOV.fec_registro::DATE between ''' || dFechaInicio::varchar || ''' and ''' || dFechaFin::varchar || ''' ' ||
		'AND MOV.idu_tipo_documento!=2 AND MOV.idu_beneficiario_externo=0 ' || 
		'and MOV.idu_centro in (SELECT idu_centro FROM TEMP_CENTROS_INVOLUCRADOS) ' ||
		'and MOV.idu_estatus = ' || iEstatus::varchar || ' ';
        
		--EMPRESA
		if iEmpresa>0 then
			sQuery := sQuery || 'and MOV.idu_empresa = ' || iEmpresa::varchar || ' ';
		end if;

		--RUTA PAGO
		if iRutaPago > 0 then
			sQuery := sQuery || 'and EMP.clv_rutapago = ' || iRutaPago::varchar || ' ';
		end if;

		--TIPO DEDUCCION	
		if iTipoDeduccion > 0 then
			sQuery := sQuery || 'and MOV.idu_tipo_deduccion = ' || iTipoDeduccion::varchar || ' ';
		end if;
		
		sQuery := sQuery || 'GROUP BY MOV.idu_empresa, DET.idu_escolaridad, DET.idu_empleado, MOV.idu_centro, DET.idfactura, MOV.idu_estatus, DET.idu_escuela, MOV.idu_tipo_deduccion, MOV.fec_registro, EMP.controlpago, DET.prc_descuento, EMP.numerotarjeta ';
        
		raise notice '%', sQuery; 
		EXECUTE sQuery;	

		/*--INSERTAR EMPRESAS TMP
		INSERT 	INTO TMP_EMPRESAS (idu_empresa) 
		SELECT 	DISTINCt idu_empresa 
		from 	TEMP_RUTAS_PAGOS;*/
		
		--OBTENER ESCOLARIDADES
		insert 	into TMP_ESCOLARIDADES (idu_escolaridad, nom_escolaridad)
		select 	idu_escolaridad, nom_escolaridad
		from 	CAT_ESCOLARIDADES
		order 	by idu_escolaridad;

		--INSERTAR EMPRESA-ESCOLARIDAD
		insert into TMP_REPORTE (idu_empresa, idu_escolaridad)
		SELECT 	idu_empresa, idu_escolaridad 
		FROM 	temp_rutas_pagos
		GROUP 	BY idu_empresa, idu_escolaridad
		order	by idu_empresa;

		--INSERTAR REGISTRO 'TOTAL' DE EMPRESA		
		insert into TMP_REPORTE (idu_empresa, idu_escolaridad)
		SELECT 	DISTINCT idu_empresa, 99 
		FROM 	temp_rutas_pagos
		GROUP 	BY idu_empresa, idu_escolaridad
		order	by idu_empresa;

		--MODIFICAR EL NOMBRE DE LA EMPRESA
		update 	TMP_REPORTE set nom_empresa= B.nom_empresa
		FROM	view_empresas_colegiaturas B
		where	TMP_REPORTE.idu_empresa=B.idu_empresa;

		--MODIFICAR EL REGISTRO 'TOTAL'
		update 	TMP_REPORTE set nom_empresa= 'T O T A L   E M P R E S A' WHERE idu_escolaridad=99;
			

		--MODIFICAR NOMBRE DE LA ESCOLARIDAD
		update 	TMP_REPORTE set nom_escolaridad=B.nom_escolaridad
		from  	TMP_ESCOLARIDADES B
		where	TMP_REPORTE.idu_escolaridad=B.idu_escolaridad;	
		
		--ELIMINAR EMPRESA 0
		delete from TMP_REPORTE where idu_empresa=0;

		
		--CANTIDAD DE COLABORADORES Y FACTURAS POR EMPRESA-ESCOLARIDAD
		insert 	into TMP_EMPRESA_ESCOLARIDAD (idu_empresa,idu_escolaridad,cantidad_empleados, cantidad_facturas)
		SELECT 	idu_empresa, idu_escolaridad, count(distinct idu_empleado) as empleados, count(idfactura)as facturas
		FROM 	TEMP_RUTAS_PAGOS
		group	by idu_empresa, idu_escolaridad
		order	by idu_empresa, idu_escolaridad;

		--MODIFICAR NUMERO COLABORADORES
		update 	TMP_REPORTE set colaboradores_por_nivel= B.cantidad_empleados, facturas_ingresadas=B.cantidad_facturas
		FROM	tmp_empresa_escolaridad B
		where	TMP_REPORTE.idu_empresa=B.idu_empresa
			and TMP_REPORTE.idu_escolaridad=B.idu_escolaridad;

		--OBTENER IMPORTES
		INSERT INTO TMP_IMPORTES (idu_empresa, idu_escolaridad, importe, reembolso)
		SELECT 	idu_empresa, idu_escolaridad, sum(importe_factura), sum(importe_pagado) 
		FROM 	TEMP_RUTAS_PAGOS
		group	by idu_empresa, idu_escolaridad
		order	by idu_empresa, idu_escolaridad;			
		
		--MODIFICAR IMPORTES
		update 	TMP_REPORTE set importe=B.importe , reembolso = B.reembolso
		FROM	TMP_IMPORTES B
		where	TMP_REPORTE.idu_empresa=B.idu_empresa
			and TMP_REPORTE.idu_escolaridad=B.idu_escolaridad;

		--TOTALES EMPLEADOS POR EMPRESA
		insert 	into TMP_TOTALES (idu_empresa, total_empleados, total_facturas) 
		SELECT 	idu_empresa, count(distinct idu_empleado), count(idfactura)			
		FROM 	TEMP_RUTAS_PAGOS
		group	by idu_empresa			
		order	by idu_empresa;
					
		--MODIFICAR TOTALES
		UPDATE 	TMP_REPORTE SET total_colaboradores=B.total_empleados,total_facturas_ingresadas = B.total_facturas
		FROM	TMP_TOTALES B
		where	TMP_REPORTE.idu_empresa=B.idu_empresa;

		--TOTAL EMPLEADOS Y FACTURAS EN LA COLUMNA 'TOTAL'}
		UPDATE 	TMP_REPORTE SET colaboradores_por_nivel=total_colaboradores, facturas_ingresadas=total_facturas_ingresadas WHERE idu_escolaridad=99;

		--TOTAL DE IMPORTES POR EMPRESA
		INSERT INTO TMP_IMPORTES_GENERALES(idu_empresa,importe,reembolso)
		SELECT 	idu_empresa, sum(importe_factura), sum(importe_pagado) 
		FROM 	TEMP_RUTAS_PAGOS
		group	by idu_empresa
		order	by idu_empresa;

		--MODIFICAR IMPORTES GENERALES
		update 	TMP_REPORTE set importe=B.importe , reembolso = B.reembolso
		FROM	TMP_IMPORTES_GENERALES B
		where	TMP_REPORTE.idu_empresa=B.idu_empresa			
			AND TMP_REPORTE.idu_escolaridad=99;

		--PORCENTAJES
		UPDATE	TMP_REPORTE SET porcentaje_colaboradores=(colaboradores_por_nivel*100)/total_colaboradores, porcentaje_facturas=(facturas_ingresadas*100)/total_facturas_ingresadas;
		
		--TOTAL GENERAL
		INSERT INTO TMP_REPORTE (idu_empresa, nom_empresa, idu_escolaridad, nom_escolaridad, colaboradores_por_nivel
            , facturas_ingresadas, importe, reembolso, porcentaje_colaboradores, porcentaje_facturas, total_colaboradores,total_facturas_ingresadas)
            SELECT 999 as idu_empresa
                , 'T O T A L   G E N E R A L' as nom_empresa
                , 999 as idu_escolaridad
                , '' as nom_escolaridad
                , SUM(colaboradores_por_nivel) as colaboradores_por_nivel
                , SUM(facturas_ingresadas) AS facturas_ingresadas
                , SUM(importe) AS importe
                , SUM(reembolso) AS reembolso
                , 100.0 as porcentaje_colaboradores
                , 100.0 as porcentaje_facturas
                , SUM(total_colaboradores) as total_colaboradores
                , SUM(total_facturas_ingresadas) as total_facturas_ingresadas
            FROM TMP_REPORTE
            WHERE idu_escolaridad = 99
            GROUP BY idu_escolaridad;
		
		--
		FOR valor IN (
			SELECT 	idu_empresa, nom_empresa, idu_escolaridad, nom_escolaridad, colaboradores_por_nivel, facturas_ingresadas, importe, reembolso, porcentaje_colaboradores, porcentaje_facturas, total_colaboradores,total_facturas_ingresadas 
			FROM 	TMP_REPORTE 
			order	by idu_empresa, idu_escolaridad
			)
		LOOP			
			iidu_empresa:=valor.idu_empresa; 
			snom_empresa:=valor.nom_empresa;
			iidu_escolaridad:=valor.idu_escolaridad; 
			snom_escolaridad:=valor.nom_escolaridad;
			icolaboradores_por_nivel:=valor.colaboradores_por_nivel;
			ifacturas_ingresadas:=valor.facturas_ingresadas;
			nimporte:=valor.importe;
			nreembolso:=valor.reembolso;
			nporcentaje_colaboradores:=valor.porcentaje_colaboradores;
			nporcentaje_facturas:=valor.porcentaje_facturas;
			itotal_colaboradores:=valor.total_colaboradores;
			itotal_facturas_ingresadas:=valor.total_facturas_ingresadas;
			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(integer, integer, integer, integer, integer, integer, character, character) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(integer, integer, integer, integer, integer, integer, character, character) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(integer, integer, integer, integer, integer, integer, character, character) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(integer, integer, integer, integer, integer, integer, character, character) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_colegiaturas_por_escolaridad(integer, integer, integer, integer, integer, integer, character, character)  IS 'La función obtiene los totales por empresa y escolaridad de las facturas que se suben';

