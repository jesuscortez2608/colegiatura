CREATE OR REPLACE FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text)
  RETURNS integer AS
$BODY$
	   /*
	     No. petición APS               : 8613.1
	     Fecha                          : 26/10/2016
	     Número empleado                : 96753269
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Actualiza el importe a pagar en una factura
	     ==============================================================================
	     Modificó                       : Hector Medina Escareño
	     Número empleado                : 97695068
	     Descripción del cambio         : 	(1) .- Actualizar Detalles de la Factura (mov_detalle_facturas_colegiaturas).
						(2) .- Registrar movimientos en la bitacora (mov_bitacora_movimientos_colegiaturas).
	     ==============================================================================
	     Sistema                        : Colegiaturas
	     Módulo                         : Autorizar o rechazar facturas
	     Ejemplo                        :
			--/OBSOLETO/-->   SELECT * FROM fun_grabar_importe_pagado(1, 500.00, 380.00, 93902761);

			--/NUEVO/----->   SELECT * FROM fun_grabar_importe_pagado(10, 540.00, 270.80, 95194185,
											'<Root>
												<detalleFactura>
													<iFactura>10</iFactura>
													<iKeyX>11</iKeyX>
													<nImportePagadoNuevo>199.50</nImportePagadoNuevo>
												</detalleFactura>
												<detalleFactura>
													<iFactura>10</iFactura>
													<iKeyX>12</iKeyX>
													<nImportePagadoNuevo>299.90</nImportePagadoNuevo>
												</detalleFactura>
											</Root>');
			//TABLAS PARTICIPANTES o Relacionadas//
			SELECT * FROM mov_facturas_colegiaturas;
			SELECT * FROM mov_detalle_facturas_colegiaturas;

			SELECT * FROM cat_tipos_movimientos_bitacora; //-- Tabla de Movimientos.
			SELECT * FROM mov_bitacora_movimientos_colegiaturas; // BITACORA -- Registrar movimientos.
------------------------------------------------------------------------------------------------------ */
DECLARE
	iFactura ALIAS FOR $1;
	nImporteOriginal ALIAS FOR $2;
	nImporteNuevo ALIAS FOR $3;
	iEmpleadoRegistro ALIAS FOR $4;
	cDetallesXml ALIAS FOR $5;
	cJustidficacion ALIAS FOR $6;
	DECLARE nActual integer;
	nImporteConcepto numeric;
	nImporteCalculado numeric;
BEGIN
	-- //=====// ACTUALIZAR EL DETALLE DE LA FACTURA (mov_detalle_facturas_colegiaturas) //=====//
	-- Crear la tabla que almacenara los detalles de la factura con los importes nuevos.
	CREATE LOCAL TEMP TABLE tempDetallesFactura(
		iFactura INTEGER not null default 0,
		iKeyX INTEGER not null default 0,
		nImportePagadoNuevo NUMERIC(12, 2)
	)ON COMMIT DROP;

	CREATE LOCAL TEMP TABLE tmpImportes(
		iImporte numeric(12,2),
		iFactura INTEGER not null default 0		
	)ON COMMIT DROP;

	nActual:=0;
	-- Extraer los importes nuevos del xml de transporte.
	INSERT INTO tempDetallesFactura(iFactura, iKeyX, nImportePagadoNuevo)
	SELECT (xpath('//iFactura/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS iFactura,
		(xpath('//iKeyX/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS iKeyX,
		(xpath('//nImportePagadoNuevo/text()', myTempTable.myXmlColumn))[1]::TEXT::NUMERIC(12, 2) AS nImportePagadoNuevo
	FROM unnest(xpath('//Root/detalleFactura', cDetallesXml)) AS myTempTable(myXmlColumn);
	
	-- Actualizar Detalle.
	IF EXISTS ( SELECT M.idfactura FROM MOV_DETALLE_FACTURAS_COLEGIATURAS M INNER JOIN  TEMPDETALLESFACTURA f ON  M.idfactura = f.iFactura AND M.keyx = f.iKeyX) THEN 
		nActual:=1;
	
		UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET importe_concepto = f.nImportePagadoNuevo
		FROM 	tempDetallesFactura f
		WHERE 	idfactura = f.iFactura 
			AND keyx = f.iKeyX;

		
	ELSE
		UPDATE 	HIS_DETALLE_FACTURAS_COLEGIATURAS SET importe_concepto = f.nImportePagadoNuevo
		FROM 	tempDetallesFactura f
		WHERE 	idfactura = f.iFactura AND keyx = f.iKeyX;
	END IF;
	-- //=====// REGISTRAR EL MOVIMIENTO EN LA BITACORA (mov_bitacora_movimientos_colegiaturas) //=====//
	INSERT INTO MOV_BITACORA_MOVIMIENTOS_COLEGIATURAS(idu_tipo_movimiento, idu_factura, importe_original, importe_pagado, idu_empleado_registro, des_justificacion)
	VALUES(1, iFactura, nImporteOriginal, nImporteNuevo, iEmpleadoRegistro, cJustidficacion);

	-- //=====// ACTUALIZAR EL IMPORTE DE LA FACTURA (mov_facturas_colegiaturas) //=====//
	IF nActual=1 THEN
		--
		
		insert	into tmpImportes(iImporte,iFactura)
		select 	sum (importe_concepto), idfactura
		from 	MOV_DETALLE_FACTURAS_COLEGIATURAS 
		where 	idfactura=iFactura
		group 	by idfactura;		

		UPDATE 	MOV_FACTURAS_COLEGIATURAS SET /*importe_pagado = B.iImporte,*/ opc_modifico_pago = 1 
		from 	tmpImportes B
		WHERE 	MOV_FACTURAS_COLEGIATURAS.idfactura= B.iFactura;
			--MOV_FACTURAS_COLEGIATURAS.idFactura = iFactura;	
		
	ELSE
		--
		insert	into tmpImportes(iImporte,iFactura)
		select 	sum (importe_concepto), idfactura
		from 	HIS_FACTURAS_COLEGIATURAS 
		where 	idfactura=iFactura
		group 	by idfactura;	
	
		--UPDATE HIS_FACTURAS_COLEGIATURAS SET importe_pagado = nImporteNuevo,opc_modifico_pago = 1 WHERE idFactura = iFactura;
		UPDATE 	HIS_FACTURAS_COLEGIATURAS SET importe_pagado = B.iImporte, opc_modifico_pago = 1 
		from 	tmpImportes B
		WHERE 	HIS_FACTURAS_COLEGIATURAS.idfactura=B.iFactura;
			--HIS_FACTURAS_COLEGIATURAS.idFactura = iFactura;
	END IF;
	
	RETURN 1;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text) TO postgres;
COMMENT ON FUNCTION fun_grabar_importe_pagado(integer, numeric, numeric, integer, xml, text) IS 'La función graba facturas de colegiaturas';

