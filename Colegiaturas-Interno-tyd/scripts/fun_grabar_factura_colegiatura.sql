CREATE OR REPLACE FUNCTION fun_grabar_factura_colegiatura(IN idempleado integer, IN ibeneficiarioext integer, IN ifactura integer, IN ieditar integer, IN ccomentario text, IN cxmlrecibo character varying, IN xpdfcarta character varying, IN iempresa integer, IN icentro integer, IN itipodoc integer, OUT ifoliofactura integer, OUT cfactura character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE     
	--cFactura Varchar(100);
	--iFolioFactura integer DEFAULT 1;
	valor record;	
	iAutorizar integer default 0;
	iPrcDescuento INTEGER DEFAULT 0;
	iPuesto integer=0;
    
	iEscuela integer=0;
	iCicloEscolar integer=0;
	iEstatus integer=0;
	iIduMotivoRevision INTEGER = 0;
	sDesMotivoRevision VARCHAR = '';
	iTopeMensual numeric;
	iImporteMes numeric ;

	nImporteConcepto numeric = 0.00;
	nImporteCalculado numeric = 0.00;

	rfc_escuela varchar(20);
	/*===========================================================================================================    
	No. Peticion APS               : 8613.1
	Fecha                          : 11/10/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
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

		SELECT * FROM mov_facturas_colegiaturas

		SELECT * FROM stmp_detalle_facturas_colegiaturas
		
		SELECT * FROM fun_grabar_factura_colegiatura(93902761,8,0,'');
		select * from fun_grabar_factura_colegiatura(95194185,0,244,0,'','20180116-ITE430714KI0-1896.xml','', 1, 230468, 1)
		select * from fun_grabar_factura_colegiatura(95194185,0,244,0,'','20180116-ITE430714KI0-1899.xml','', 1, 230468, 1)
		select * from fun_grabar_factura_colegiatura(95194185,0,258,0,'','20180116-ITE430714KI0-1914.xml','', 1, 230468, 1)

		itipodoc=2 Es Nota de Credito
	===========================================================================================================*/
BEGIN 
	--temporal
	create local temp table tmp_Conceptos_Detalle 
	(  
		nFactura integer, 
		importe numeric (12,2),
		idu_tipopago integer,
		prc_descuento integer,
		imeses numeric, 
		importe_mes numeric (12,2)
	)on commit drop;


	create local temp table tmp_Conceptos 
	(  
		nFactura integer, 
		importe numeric (12,2),		
		prc_descuento integer,
		imeses numeric, 
		importe_mes numeric (12,2)
	)on commit drop;

	--temporal
	create local temp table tmp_factura
	(  
		nFactura integer, 
		cMsg varchar(50)
	)on commit drop;
	
	cFactura:= (SELECT TRIM(fol_fiscal) FROM STMP_FACTURAS_COLEGIATURAS WHERE idu_empleado=idEmpleado  and idfactura=iFactura);
	iFolioFactura:=1;
	raise notice 'iFactura % ff :%', ifactura, iFolioFactura;
	IF(iEditar>0) THEN--EDITAR FACTURA
		IF TRIM(xPdfCarta)!='' THEN --ES FACTURA PRIVADA ACTUALIZAR PDF
			UPDATE mov_facturas_colegiaturas SET nom_pdf_carta=trim(xpdfcarta) where idfactura=iFactura;	
		
		--ELSE 	--ESCUELA PUBLICA ACTUALIZA EL RECIBO Y LA CARTA
			--UPDATE mov_facturas_colegiaturas SET nom_pdf_carta=trim(xPdfCarta), nom_xml_recibo=trim(cXmlRecibo)  where idfactura=iFactura;
		END IF;	
		
		DELETE 	FROM MOV_DETALLE_FACTURAS_COLEGIATURAS WHERE idfactura=iFactura;

		--ELIMINAR IMPORTES MENSUALES DE LAS FACTURAS
		delete from CTL_IMPORTES_FACTURAS_MES where idfactura=iFactura;
		
		INSERT 	INTO MOV_DETALLE_FACTURAS_COLEGIATURAS (idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_parentesco, idu_tipopago, prc_descuento, 
				periodo, idu_escuela, idu_escolaridad,  idu_carrera, idu_grado_escolar, idu_ciclo_escolar, importe_concepto, importe_pagado, fec_registro, idu_empleado_registro, idfactura  )
		SELECT 	idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_parentesco, idu_tipopago,prc_descuento, periodo, idu_escuela, idu_escolaridad,  idu_carrera,
				idu_grado_escolar, idu_ciclo_escolar, importe_concepto, ((importe_concepto * prc_descuento)/100), now(), idu_empleado,iFactura
		FROM 	STMP_DETALLE_FACTURAS_COLEGIATURAS 
		WHERE 	idu_empleado=idEmpleado 
				AND idfactura=iFactura;

		update 	MOV_FACTURAS_COLEGIATURAS
		set	idu_escuela = det.idu_escuela
		from	MOV_DETALLE_FACTURAS_COLEGIATURAS as det
		where	MOV_FACTURAS_COLEGIATURAS.idu_empleado = det.idu_empleado--idEmpleado 
			and MOV_FACTURAS_COLEGIATURAS.idfactura = det.idfactura
			AND MOV_FACTURAS_COLEGIATURAS.idu_empleado = idEmpleado
			and MOV_FACTURAS_COLEGIATURAS.idfactura = iFactura;--iFactura;

		--if ((SELECT idu_escuela FROM mov_facturas_colegiaturas where idu_empleado = idEmpleado AND idfactura = iFactura) != 
		--	(SELECT idu_escuela FROM mov_detalle_facturas_colegiaturas WHERE idu_empleado = idEmpleado AND idfactura = iFactura LIMIT 1) )then
			rfc_escuela := (select rfc_clave_sep from cat_escuelas_colegiaturas where idu_escuela = 
					(SELECT idu_escuela from mov_detalle_facturas_colegiaturas where idu_empleado = idEmpleado and idfactura = iFactura LIMIT 1 ));

			update	mov_facturas_colegiaturas
			set	rfc_clave = rfc_escuela
			where	mov_facturas_colegiaturas.idu_empleado = idEmpleado
				and mov_facturas_colegiaturas.idfactura = iFactura;
		--end if;
			
		--SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (idEmpleado, iFolioFactura) as fun into nImporteConcepto, nImporteCalculado;
		SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (idEmpleado, iFactura) as fun into nImporteConcepto, nImporteCalculado;

		IF TRIM(cComentario)!='' THEN
			UPDATE mov_facturas_colegiaturas SET des_aclaracion_costos = TRIM(cComentario) WHERE idfactura = iFactura;
		END IF;
	ELSE
		--SELECT fol_fiscal FROM stmp_facturas_colegiaturas WHERE  idu_empleado=95194185  and idfactura=258 AND fol_fiscal!=''
		raise notice 'ff :% %', idEmpleado, iFactura;
		IF EXISTS (SELECT fol_fiscal FROM STMP_FACTURAS_COLEGIATURAS WHERE  idu_empleado=idEmpleado  and idfactura=iFactura AND fol_fiscal!='') THEN
			cFactura:= TRIM(fol_fiscal) FROM STMP_FACTURAS_COLEGIATURAS WHERE idu_empleado=idEmpleado  and idfactura=iFactura;
			--cFactura='F5CB8855-5166-49A1-AA04-06C69747DD40'
			IF EXISTS(SELECT fol_fiscal FROM MOV_FACTURAS_COLEGIATURAS WHERE upper(trim(fol_fiscal)) =upper(cFactura)) THEN
				--SELECT fol_fiscal FROM mov_facturas_colegiaturas WHERE upper(trim(fol_fiscal)) =upper('F5CB8855-5166-49A1-AA04-06C69747DD40')
				iFolioFactura:=0;
			END IF;
		ELSE
			IF EXISTS(SELECT fol_fiscal FROM HIS_FACTURAS_COLEGIATURAS WHERE upper(trim(fol_fiscal)) =upper(cFactura)) THEN
				iFolioFactura:=0;
			END IF;
		END IF;
		
raise notice 'ff :% % iFolioFactura %', idEmpleado, iFactura, iFolioFactura;
		if EXISTS(SELECT idu_empleado FROM CAT_EMPLEADOS_COLEGIATURAS WHERE OPC_VALIDAR_COSTOS=0 AND idu_empleado=idEmpleado) then 
			iAutorizar:=1; --no ocupa autorizacion por gerente
		end if;

		--SI TIENE PUESTO GERENCIAL
		iPuesto:= (select numeropuesto::int from SAPCATALOGOEMPLEADOS where numemp::int=idEmpleado);
		if (EXISTS(SELECT idu_puesto FROM CAT_PUESTOSCONAUTORIZACION where idu_puesto=iPuesto)) then
			iAutorizar:=1; --no ocupa autorizacion por gerente
		END IF;		
		
		IF iFolioFactura=1 THEN	
            
			if ((itipodoc=2) or (itipodoc=4 AND ibeneficiarioext = 0)) then --si es nota de credito 
											--o factura capturada por personal admon(especial)RRG
											--SE AGREGA EL IBENEFICIARIOEXT, YA QUE LAS FACTURAS DE EXTERNOS SE MANEJAN COMO TIPODOC = 4, Y ESTAS NO SE APLICAN A LA MISMA REGLA RRG
											--QUE LAS DEMASRRG
				iAutorizar:=1;
			end if;
			
			iTopeMensual:=(select (sueldo/2)/100 from SAPCATALOGOEMPLEADOS where numempn=idempleado);

			/*--BORRAMOS SI EXISTIA EN SISTEMA ANTERIOR Y CON ESTATUS 0
			delete 	from ctl_facturas_empleados 
			where 	nom_rfc_empresa= (select rfc_clave from STMP_FACTURAS_COLEGIATURAS where idu_empleado=idEmpleado and idfactura=iFactura)  
					and idu_foliofiscal= (select fol_fiscal from STMP_FACTURAS_COLEGIATURAS where idu_empleado=idEmpleado and idfactura=iFactura)
					and idu_estatus_factura=0;*/
			
			--INSERTAR EN MOV_FACTURA
			INSERT 	INTO MOV_FACTURAS_COLEGIATURAS(idu_empresa, fol_fiscal, fol_factura, serie, fec_factura, idu_empleado, idu_beneficiario_externo, idu_centro, opc_pdf, idu_escuela, rfc_clave, importe_factura, idu_tipo_documento, idu_estatus,fec_registro, idu_empleado_registro, xml_factura, emp_marco_estatus
					, fec_marco_estatus, des_aclaracion_costos,nom_xml_recibo,nom_pdf_carta,des_metodo_pago,fol_relacionado
					, idu_motivo_revision, des_observaciones)
			SELECT 	iEmpresa, fol_fiscal, fol_factura, serie, fec_factura, idu_empleado, iBeneficiarioExt, iCentro, opc_pdf, idu_escuela, rfc_clave, importe_factura, iTipoDoc,iAutorizar, now(),idu_empleado, xml_factura,0
					,CASE WHEN iAutorizar=0 THEN '19000101' ELSE now() END, TRIM(cComentario),cXmlRecibo, xPdfCarta,des_metodo_pago, fol_relacionado
					,iIduMotivoRevision, sDesMotivoRevision
			FROM 	STMP_FACTURAS_COLEGIATURAS 
			WHERE 	idu_empleado=idEmpleado  
					and idfactura=iFactura 
			RETURNING idfactura INTO iFolioFactura;

--raise notice 'ff-- :% % iFolioFactura %', idEmpleado, iFolioFactura, idfactura;
			--INSERTAR EN DETALLE
			INSERT 	INTO MOV_DETALLE_FACTURAS_COLEGIATURAS (idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_carrera, idu_parentesco, idu_tipopago, prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_grado_escolar, idu_ciclo_escolar
					,importe_concepto
					--, importe_pagado
					, fec_registro, idu_empleado_registro, idfactura)
			SELECT 	idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_carrera, idu_parentesco, idu_tipopago,prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_grado_escolar, idu_ciclo_escolar
					,importe_concepto
					--, ((importe_concepto * prc_descuento)/100)
					, now(), idu_empleado,iFolioFactura
			FROM 	STMP_DETALLE_FACTURAS_COLEGIATURAS 
			WHERE 	idu_empleado=idEmpleado 
					and idfactura=iFactura;				 

			--raise notice 'ff :% % iTopeMensual %', iTopeMensual, iFactura, iFolioFactura;
			raise notice 'ff :iTopeMensual %', iTopeMensual;

			--SELECT fun.estado,fun.mensaje FROM fun_funcionallamar() as fun into estado,mensaje;
			--SELECT * FROM fun_realizar_calculos_escenarios (94827443, 706) ;
    
			-- Calcular el descuento cuando se trata de un beneficiario externo
			if (ibeneficiarioext > 0) then
				iPrcDescuento := (SELECT prc_descuento FROM CAT_BENEFICIARIOS_EXTERNOS WHERE idu_beneficiario = ibeneficiarioext limit 1);
				UPDATE 	MOV_FACTURAS_COLEGIATURAS SET importe_calculado= ((importe_factura * iPrcDescuento) / 100)  
					, importe_pagado=((importe_factura * iPrcDescuento) / 100)
				WHERE 	MOV_FACTURAS_COLEGIATURAS.idfactura = iFolioFactura;
			else
				--FUNCION PARA TRAER IMPORTES
				SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (idEmpleado, iFolioFactura) as fun into nImporteConcepto, nImporteCalculado;
			
				raise notice 'ff :nImporteConcepto %', nImporteConcepto;
				raise notice 'ff :nImporteCalculado %', nImporteCalculado;

				--UPDATE MOV_DETALLE_FACTURAS_COLEGIATURAS SET importe_concepto=nImporteConcepto, importe_pagado=nImporteCalculado WHERE idfactura=iFolioFactura;			

				--UPDATE MOV_FACTURAS_COLEGIATURAS SET  importe_calculado=nImporteCalculado, importe_pagado=nImporteCalculado WHERE idfactura=iFolioFactura;
			end if;
			
    
			-- Agregar el centro al que pertenece el empleado.
			UPDATE 	MOV_FACTURAS_COLEGIATURAS SET idu_centro = (CASE WHEN e.centro = '' THEN '0' ELSE e.centro END)::INTEGER
			FROM 	SAPCATALOGOEMPLEADOS e
			WHERE 	e.numempn = MOV_FACTURAS_COLEGIATURAS.idu_empleado;

			--
			if (itipodoc != 2 and iFolioFactura > 0) then
				iEscuela = (select idu_escuela from MOV_FACTURAS_COLEGIATURAS where idfactura=iFolioFactura limit 1);
				iCicloEscolar = (select idu_ciclo_escolar from MOV_DETALLE_FACTURAS_COLEGIATURAS where idfactura=iFolioFactura limit 1);

				CREATE TEMP TABLE tmp_validacion_costos (idu_factura INTEGER
				, idu_estatus INTEGER
				, nom_estatus CHARACTER VARYING) ON COMMIT DROP;

				INSERT INTO tmp_validacion_costos (idu_factura, idu_estatus, nom_estatus)
				SELECT idu_factura, idu_estatus, nom_estatus FROM fun_validar_costos_colegiaturas(iFolioFactura);
				--SELECT idu_factura, idu_estatus, nom_estatus FROM fun_validar_costos_colegiaturas(iFactura);

				iIduMotivoRevision := (select idu_estatus from tmp_validacion_costos limit 1);
				sDesMotivoRevision := (select nom_estatus from tmp_validacion_costos limit 1);

				update 	MOV_FACTURAS_COLEGIATURAS set idu_motivo_revision = iIduMotivoRevision
				where 	idfactura = iFolioFactura;
			end if;
			--END IF;
		END IF;
	END IF;	
	
	--INSERTA tmp_factura
	INSERT INTO tmp_factura (nFactura, cMsg) VALUES (iFolioFactura, CASE WHEN iFolioFactura >0 THEN 'Factura registrada correctamente'  ELSE 'La factura ya se capturo anteriormente ' || coalesce(iFolioFactura, -1)::varchar END);
	
	--
	FOR valor IN SELECT nFactura, cMsg FROM tmp_factura 
	loop
		iFolioFactura:=valor.nFactura;
		cFactura:=valor.cMsg;
		return next;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_factura_colegiatura(integer, integer, integer, integer, text, character varying, character varying, integer, integer, integer) TO syspruebasadmon;
GRANT EXECUTE ON FUNCTION fun_grabar_factura_colegiatura(integer, integer, integer, integer, text, character varying, character varying, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_factura_colegiatura(integer, integer, integer, integer, text, character varying, character varying, integer, integer, integer) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_factura_colegiatura(integer, integer, integer, integer, text, character varying, character varying, integer, integer, integer) IS 'La función graba facturas de colegiaturas';
