CREATE OR REPLACE FUNCTION fun_obtener_reporte_facturas_ajuste(
    IN irutapago integer,
    IN iescolaridad integer,
    IN iregion integer,
    IN iciudad integer,
    IN itipodeduccion integer,
    IN icicloescolar integer,
    IN dfechainicio character varying,
    IN dfechafin character varying,
    IN inumemp integer,
    OUT iidfactura integer,
    OUT iimportefactura numeric,
    OUT iimportepagado numeric,
    OUT dfechafactura character varying,
    OUT sfoliofiscal character varying,
    OUT sbecado character varying,
    OUT sparentesco character varying,
    OUT nporc_pagado numeric,
    OUT iidu_empleado integer,
    OUT snom_empleado character varying,
    OUT iidu_estatus integer,
    OUT snom_estatus character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE	
	--cNom_tipo_factura character(25);
	--dFecha timestamp;	
	sQuery TEXT;	
	valor record;	
	
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
	EJEMPLO:
		SELECT * FROM fun_obtener_reporte_facturas_ajuste(-1,0,0,0,0,-1,'20180801'::VARCHAR,'20180904'::VARCHAR,0)
		SELECT * FROM fun_obtener_reporte_facturas_ajuste(-1,0,0,0,0,0,'19000101','19000101',0)
		SELECT * FROM fun_obtener_reporte_facturas_ajuste(-1,0,0,0,0,2018,'19000101','19000101',0)
	--------------------------------------------------------------------------------*/	
	BEGIN
		--CENTROS INVOLUCRADOS
		CREATE LOCAL TEMP TABLE tmp_Datos(
			idfactura integer not null default(0),
			importefactura numeric not null default(0),
			importepagado numeric not null default(0),
			fechafactura timestamp without time zone,
			foliofiscal character varying,
			beneficiario_hoja_azul integer,
			idu_beneficiario integer, 
			nom_beneficiario varchar(150), 
			idu_parentesco integer not null default(0),
			nom_parentesco varchar(20),
			porc_pagado numeric not null default(0),
			idu_empleado integer not null default(0),
			nom_empleado varchar(60),			
			idu_estatus integer not null default(0),
			nom_estatus varchar(30),
			clv_ruta_pago integer not null default(0),
			idu_escolaridad integer not null default(0),
			idu_ciclo_escolar integer not null default(0),
			pct_ajuste INTEGER NOT NULL DEFAULT(0),
			importe_ajuste NUMERIC(12,2) NOT NULL DEFAULT(0.0),
			fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT('1900-01-01'),
			idu_usuario_traspaso INTEGER NOT NULL DEFAULT(0),
			tipo SMALLINT NOT NULL DEFAULT (0) -- Para identificar si está en movimiento o en histórico
		)ON COMMIT DROP;

		
		CREATE LOCAL TEMP TABLE temp_centros_involucrados(
			idu_centro integer not null default(0) 
		)ON COMMIT DROP;

		if iRegion = 0 and iCiudad = 0 then -- todos los centros de todas las regiones
			insert 	into temp_centros_involucrados(idu_centro)
			select 	numerocentro::integer
			from 	sapcatalogocentros
			where 	cancelado = '';
		elsif iRegion > 0 and iCiudad = 0 then -- todos los centros de la región
			insert 	into temp_centros_involucrados(idu_centro)
			select 	cen.numerocentro::integer
			from 	sapcatalogocentros cen
			inner 	join sapcatalogociudades ciu on (cen.ciudadn = ciu.ciudadn)
			inner 	join sapregiones reg on ((case when ciu.regionzona = '' or ciu.regionzona is null then '0' else ciu.regionzona end)::integer = reg.numero)
			where 	cen.cancelado = ''
				and reg.numero = iRegion
			order by cen.numerocentro::integer;
		elsif iRegion > 0 and iCiudad > 0 then -- todos los centros de una ciudad
			insert 	into temp_centros_involucrados(idu_centro)
			select 	cen.numerocentro::integer
			from 	sapcatalogocentros cen
			inner 	join sapcatalogociudades ciu on (cen.ciudadn = ciu.ciudadn)
			where 	cen.cancelado = ''
				and ciu.ciudadn = iCiudad
			order 	by cen.numerocentro::integer;
		end if;
		
		sQuery := 'INSERT INTO tmp_Datos(idfactura,importefactura,importepagado,fechafactura,foliofiscal,idu_empleado, idu_estatus, clv_ruta_pago, pct_ajuste, importe_ajuste, fec_registro, idu_usuario_traspaso, tipo
            , idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, idu_escolaridad, porc_pagado, idu_ciclo_escolar) ' ||
		' SELECT A.idfactura, A.importe_factura, A.importe_pagado, B.fec_factura, B.fol_fiscal, B.idu_empleado,B.idu_estatus, B.clv_rutapago, A.pct_ajuste, A.importe_ajuste, A.fec_registro, A.idu_usuario_traspaso, 0 ' || 
		'   , C.idu_beneficiario, C.beneficiario_hoja_azul, C.idu_parentesco, C.idu_escolaridad, C.prc_descuento, C.idu_ciclo_escolar' ||
		' FROM	MOV_AJUSTES_FACTURAS_COLEGIATURAS A ' ||		
		'   INNER JOIN HIS_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura 
            INNER JOIN HIS_DETALLE_FACTURAS_COLEGIATURAS C on B.idfactura = C.idfactura
            INNER JOIN temp_centros_involucrados D on B.idu_centro=D.idu_centro
		  WHERE b.idu_beneficiario_externo = 0';
		
		if (icicloescolar > 0)then
            sQuery := sQuery || ' AND C.idu_ciclo_escolar = ' || icicloescolar::VARCHAR || ' ';
		ELSE
			sQuery := sQuery || ' AND A.fec_registro::DATE BETWEEN ''' || dFechaInicio::VARCHAR || ''' AND ''' || dFechaFin::VARCHAR || ''' ';
		end if;
        
        if inumemp > 0 then
            sQuery := sQuery || 'AND B.idu_empleado = ' || inumemp::varchar || ' ';
        end if;
        
		--RUTA PAGO
		if iRutaPago>0 then
			sQuery := sQuery || 'AND B.clv_ruta_pago = ' || iRutaPago::varchar || ' ';
		end if;		

		--TIPO DEDUCCION
		if iTipoDeduccion>0 then
			sQuery := sQuery || 'AND B.idu_tipo_deduccion = ' || iTipoDeduccion::varchar || ' ';
		end if;
		
		--ESCOLARIDAD
		if iEscolaridad>0 then
            sQuery := sQuery || 'AND C.idu_escolaridad = ' || iEscolaridad::varchar || ' ';
		end if;

		raise notice '%', sQuery;
		EXECUTE sQuery;

		sQuery := 'INSERT INTO tmp_Datos(idfactura,importefactura,importepagado,fechafactura,foliofiscal,idu_empleado, idu_estatus, clv_ruta_pago, pct_ajuste, importe_ajuste, fec_registro, idu_usuario_traspaso, tipo
            , idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, idu_escolaridad, porc_pagado, idu_ciclo_escolar) ' ||
		' SELECT A.idfactura, A.importe_factura, A.importe_pagado, B.fec_factura, B.fol_fiscal, B.idu_empleado,B.idu_estatus, B.clv_rutapago, A.pct_ajuste, A.importe_ajuste, A.fec_registro, A.idu_usuario_traspaso, 1 ' || 
		'   , C.idu_beneficiario, C.beneficiario_hoja_azul, C.idu_parentesco, C.idu_escolaridad, C.prc_descuento, C.idu_ciclo_escolar' ||
		' FROM	HIS_AJUSTES_FACTURAS_COLEGIATURAS A ' ||		
		'   INNER JOIN HIS_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura 
            INNER JOIN HIS_DETALLE_FACTURAS_COLEGIATURAS C on B.idfactura = C.idfactura
            INNER JOIN temp_centros_involucrados D on B.idu_centro=D.idu_centro
		  WHERE b.idu_beneficiario_externo = 0';
		  
		if (icicloescolar > 0)then
            sQuery := sQuery || ' AND C.idu_ciclo_escolar = ' || icicloescolar::VARCHAR || ' ';
		ELSE
			sQuery := sQuery || ' AND A.fec_registro::DATE BETWEEN ''' || dFechaInicio::VARCHAR || ''' AND ''' || dFechaFin::VARCHAR || ''' ';
		end if;
        
        if inumemp > 0 then
            sQuery := sQuery || 'AND B.idu_empleado = ' || inumemp::varchar || ' ';
        end if;
        
		--RUTA PAGO
		if iRutaPago>0 then
			sQuery := sQuery || 'AND B.clv_ruta_pago = ' || iRutaPago::varchar || ' ';
		end if;
        
		--TIPO DEDUCCION
		if iTipoDeduccion>0 then
			sQuery := sQuery || 'AND B.idu_tipo_deduccion = ' || iTipoDeduccion::varchar || ' ';
		end if;
		
		--ESCOLARIDAD
		if iEscolaridad>0 then
            sQuery := sQuery || 'AND C.idu_escolaridad = ' || iEscolaridad::varchar || ' ';
		end if;
        
		raise notice '%', sQuery;
		EXECUTE sQuery;
		
		--EMPLEADO
		update  tmp_Datos set nom_empleado=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno  
		from	SAPCATALOGOEMPLEADOS  B 
		where	tmp_Datos.idu_empleado=B.numemp::int;
		
		--BENEFICIARIOS COLEGIATURAS
		UPDATE 	tmp_Datos set nom_beneficiario=B.nom_beneficiario || ' ' || B.ape_paterno || ' ' || B.ape_materno
		FROM	CAT_BENEFICIARIOS_COLEGIATURAS B
		WHERE	tmp_Datos.idu_empleado=B.idu_empleado 		
			and tmp_Datos.beneficiario_hoja_azul=0
			and tmp_Datos.idu_beneficiario=B.idu_beneficiario;
        
		--BENEFICARIOS HOJA AZUL
		UPDATE 	tmp_Datos set nom_beneficiario=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
		FROM	SAPFAMILIARHOJAS B
		WHERE	tmp_Datos.idu_empleado=B.numemp 		
			and tmp_Datos.beneficiario_hoja_azul=1
			and tmp_Datos.idu_beneficiario=B.clave;
        
		--PARENTESCO
		UPDATE  tmp_Datos SET nom_parentesco=B.des_parentesco
		from	CAT_PARENTESCOS B
		where	tmp_Datos.idu_parentesco=B.idu_parentesco;
        
		--ESTATUS AJUSTES
		update 	tmp_Datos SET nom_estatus=
            CASE WHEN tipo = 0 and idu_usuario_traspaso > 0 then 'TRASPASADO POR PAGAR'
                WHEN tipo = 0 and idu_usuario_traspaso = 0 then 'EN PROCESO'
                WHEN tipo = 1 then 'PAGADO'
            END;
        
		FOR valor IN (
			SELECT 	idfactura,
			importefactura,
			importe_ajuste,
			to_char(fec_registro,'yyyy-mm-dd') as fec_registro,
			foliofiscal,
			--beneficiario_hoja_azul,
			--idu_beneficiario,
			nom_beneficiario,
			--idu_parentesco,
			nom_parentesco,
			pct_ajuste,
			idu_empleado,
			nom_empleado,
			idu_estatus,
			nom_estatus
			--clv_ruta_pago,
			--idu_escolaridad,
			--idu_centro,
			FROM 	tmp_Datos 
			order by fec_registro
			)
		LOOP
			iidfactura:=valor.idfactura;
			iimportefactura:=valor.importefactura;
			iimportepagado:=valor.importe_ajuste;
			dfechafactura:=valor.fec_registro;
			sfoliofiscal:=valor.foliofiscal;
			sbecado:=valor.nom_beneficiario;
			sparentesco:=valor.nom_parentesco;
			nporc_pagado:=valor.pct_ajuste;
			iidu_empleado:=valor.idu_empleado;
			snom_empleado:=valor.nom_empleado;
			iidu_estatus:=valor.idu_estatus;
			snom_estatus:=valor.nom_estatus;
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_facturas_ajuste(integer, integer, integer, integer, integer, integer, character varying, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_facturas_ajuste(integer, integer, integer, integer, integer, integer, character varying, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_facturas_ajuste(integer, integer, integer, integer, integer, integer, character varying, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_facturas_ajuste(integer, integer, integer, integer, integer, integer, character varying, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_facturas_ajuste(integer, integer, integer, integer, integer, integer, character varying, character varying, integer)  IS 'La función obtiene datos para el reporte de facturas con ajuste';
