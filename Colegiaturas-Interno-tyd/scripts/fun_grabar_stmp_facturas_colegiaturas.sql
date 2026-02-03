DROP FUNCTION IF EXISTS fun_grabar_stmp_facturas_colegiaturas(integer, character varying, character varying, character varying, integer, integer, integer, character varying, numeric, text, date, smallint, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_grabar_stmp_facturas_colegiaturas(integer, character varying, character varying, character varying, integer, integer, integer, character varying, numeric, text, date, smallint, character varying, character varying, character varying)
  RETURNS SETOF type_grabar_stmp_facturas_colegiaturas AS
$BODY$
DECLARE
	iOpcion      	ALIAS FOR $1;
	cFolioFiscal	ALIAS FOR $2;
	cFolioFac 	ALIAS FOR $3;
	cSerie		ALIAS FOR $4; 
	iEmpleado	ALIAS FOR $5; 
	iPdf	 	ALIAS FOR $6;
	iEscuela	ALIAS FOR $7;
	cRfc		ALIAS FOR $8;
	importe		ALIAS FOR $9;
	cXml			 ALIAS FOR $10;
	fecha		  	 ALIAS FOR $11;
	iRevision  		ALIAS FOR $12;
	cDocumento  		ALIAS FOR $13;
	cMtodo_pago  		ALIAS FOR $14;
	cfol_relacionado  	ALIAS FOR $15;
	iRegresa 		 SMALLINT DEFAULT 0;
	iEstatus 		 INTEGER DEFAULT 0;
	iFolioFactura 		 INTEGER DEFAULT 0;
	cMensaje		 VARCHAR;
	registro 	type_grabar_stmp_facturas_colegiaturas;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 11/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Guarda los datos de la factura en la tabla temporal  stmp_facturas_colegiaturas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Facturas
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_stmp_facturas_colegiaturas('123456','12','ABC',93902761,0,1,'RFCDEESC',100.00,'ESTE ES EL XML','20160920')
		select * from MOV_FACTURAS_COLEGIATURAS where fol_fiscal='2CC2T04F-1TT7-4T14-T471-T12T445T2T35'
		 
	*/
BEGIN
	IF TRIM(cFolioFiscal)!='' THEN --FACTURAS CON XML
		IF EXISTS (select * from HIS_FACTURAS_COLEGIATURAS where trim(fol_fiscal)=upper(trim(cFolioFiscal))) then
			iRegresa:=2;
			iEstatus:=  idu_estatus from his_facturas_colegiaturas where upper(trim(fol_fiscal))=upper(trim(cFolioFiscal));
			
		END IF;	
		IF EXISTS (select * from MOV_FACTURAS_COLEGIATURAS where trim(fol_fiscal)=upper(trim(cFolioFiscal))) then
			iRegresa:=2;
			iEstatus:=  idu_estatus from mov_facturas_colegiaturas where upper(trim(fol_fiscal))=upper(trim(cFolioFiscal));
		END IF;

		--si es nota de credito
		if cDocumento='E' then 
			if not exists (select * from MOV_FACTURAS_COLEGIATURAS where trim(fol_fiscal)=upper(trim(cfol_relacionado)) ) then
				iRegresa:=3;
			end if;
		end if;

		IF iRegresa=0 THEN 
			IF EXISTS (select * from STMP_FACTURAS_COLEGIATURAS where trim(fol_fiscal)=upper(trim(cFolioFiscal))) then
				IF iOpcion=0 THEN
					DELETE FROM stmp_facturas_colegiaturas where idu_empleado=iEmpleado; --trim(fol_fiscal)=upper(trim(cFolioFiscal));
					DELETE FROM stmp_detalle_facturas_colegiaturas where trim(fol_fiscal)=upper(trim(cFolioFiscal));
				ELSE  --ACTUALIZA LA ESCUELA

					IF EXISTS (select opc_escuela_bloqueada from CAT_ESCUELAS_COLEGIATURAS WHERE opc_escuela_bloqueada=1 AND IDU_ESCUELA=iEscuela) THEN
						--iRegresa:=1;
						INSERT INTO stmp_facturas_colegiaturas(fol_fiscal, fol_factura, serie, idu_empleado, opc_pdf, idu_escuela
											, rfc_clave, importe_factura, idu_estatus, xml_factura,fec_factura
											, fec_registro, idu_motivo_revision, des_tipo_documento, des_metodo_pago, fol_relacionado )
						SELECT 	TRIM(cFolioFiscal), TRIM(cFolioFac), TRIM(cSerie), iEmpleado, iPdf,iEscuela, TRIM(cRfc), importe, 0, trim(cXml), fecha, now(),iRevision, cDocumento, cMtodo_pago, cfol_relacionado
						RETURNING idFactura INTO iFolioFactura;
						iRegresa:=0;
					ELSE
						UPDATE stmp_facturas_colegiaturas SET idu_escuela=iEscuela where trim(fol_fiscal)=upper(trim(cFolioFiscal));
						iFolioFactura:= idfactura from stmp_facturas_colegiaturas where trim(fol_fiscal)=upper(trim(cFolioFiscal));
					END IF;	
				END IF;
			END IF;
				
			IF iOpcion=0 THEN
				DELETE FROM stmp_facturas_colegiaturas where idu_empleado=iEmpleado;				
				INSERT INTO stmp_facturas_colegiaturas(fol_fiscal, fol_factura, serie, idu_empleado, opc_pdf, idu_escuela, rfc_clave, importe_factura, idu_estatus, xml_factura,fec_factura, fec_registro, idu_motivo_revision, des_tipo_documento, des_metodo_pago, fol_relacionado )
				SELECT 	TRIM(cFolioFiscal), TRIM(cFolioFac), TRIM(cSerie), iEmpleado, iPdf,iEscuela, TRIM(cRfc), importe, 0, trim(cXml), fecha, now(),iRevision, cDocumento, cMtodo_pago, cfol_relacionado
				RETURNING idFactura INTO iFolioFactura;
				iRegresa:=0;
			END IF;				
			
		ELSE
			cMensaje:= nom_estatus from CAT_ESTATUS_FACTURAS where idu_estatus=iEstatus;	
		END IF;	
	ELSE 
		DELETE FROM  stmp_facturas_colegiaturas WHERE /*trim(fol_fiscal)='' AND*/ idu_empleado=iEmpleado;
		DELETE FROM stmp_detalle_facturas_colegiaturas WHERE trim(fol_fiscal)='' AND idu_empleado=iEmpleado;
				
		INSERT INTO stmp_facturas_colegiaturas(fol_fiscal, fol_factura, serie, idu_empleado, opc_pdf, idu_escuela, rfc_clave, importe_factura, idu_estatus, xml_factura,fec_factura, fec_registro, idu_motivo_revision, des_tipo_documento, des_metodo_pago, fol_relacionado )
		SELECT 	TRIM(cFolioFiscal), TRIM(cFolioFac), TRIM(cSerie), iEmpleado, iPdf,iEscuela, TRIM(cRfc), importe, 0, trim(cXml), fecha, now(),iRevision, cDocumento, cMtodo_pago, cfol_relacionado
		RETURNING idFactura INTO iFolioFactura;
	END IF;	

	if iRegresa=0 then
		cMensaje:='Se guardo la factura';
	elsif iRegresa=1 then
		cMensaje:='No se puede subir la factura, porque la escuela está bloqueada';
	elsif iRegresa=2 then
		cMensaje:='Factura cargada anteriormente, estatus '||cMensaje;
	else
		cMensaje:='Es necesario subir la factura para poder subir la nota de credito';
	end if;
	
	FOR registro IN select iRegresa,iFolioFactura, cMensaje

	 
	LOOP
		RETURN NEXT registro;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_stmp_facturas_colegiaturas(integer, character varying, character varying, character varying, integer, integer, integer, character varying, numeric, text, date, smallint, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_stmp_facturas_colegiaturas(integer, character varying, character varying, character varying, integer, integer, integer, character varying, numeric, text, date, smallint, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_stmp_facturas_colegiaturas(integer, character varying, character varying, character varying, integer, integer, integer, character varying, numeric, text, date, smallint, character varying, character varying, character varying) TO syspersonal;