CREATE OR REPLACE FUNCTION fun_obtener_facturas_nota_credito(
IN inotacredito integer, 
OUT ifactura integer, 
OUT sfoliofactura character varying, 
OUT nimportefactura numeric, 
OUT iprc_descuento integer, 
OUT nimporte_calculado numeric, 
OUT iimporte_aplicado numeric, 
OUT iimporte_pagado numeric)
  RETURNS SETOF record AS
$BODY$
DECLARE     
	--cFactura Varchar(100);
	--iFolioFactura integer DEFAULT 1;
	valor record;	
	
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 17-08-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: 
-- ====================================================================================================
BEGIN 
	--temporal
	CREATE TEMP TABLE tmp_Facturas
	(
		NotaCredito integer,
		Factura integer, 
		FolioFactura varchar(100), 
		ImporteFactura numeric,
		Prc_descuento integer,
		importe_calculado numeric, 
		importe_aplicado numeric, 
		importe_pagado numeric
	)on commit drop;

	INSERT 	INTO tmp_Facturas (NotaCredito,factura,ImporteFactura,Prc_descuento,importe_calculado, importe_aplicado, importe_pagado)
	SELECT 	idnotacredito,idfactura,importe_factura, prc_descuento, importe_calculado, importe_aplicado, importe_pagado 
	FROM 	MOV_APLICACION_NOTAS_CREDITO
	WHERE	idnotacredito=iNotaCredito;

	UPDATE  tmp_Facturas SET FolioFactura=	B.fol_fiscal
	FROM 	MOV_FACTURAS_COLEGIATURAS B
	where	tmp_Facturas.factura=B.idfactura;
	
	--
	FOR valor IN (SELECT NotaCredito,Factura,FolioFactura,ImporteFactura,Prc_descuento,importe_calculado,importe_aplicado,importe_pagado FROM tmp_Facturas) 
	loop
		iFactura:=valor.Factura; 
		sFolioFactura:=valor.FolioFactura;
		nImporteFactura:=valor.ImporteFactura;
		iPrc_descuento:=valor.Prc_descuento;
		nImporte_calculado:=valor.importe_calculado;
		iImporte_aplicado:=valor.importe_aplicado;
		iImporte_pagado:=valor.importe_pagado;
		return next;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER; 
  
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_nota_credito(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_nota_credito(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_nota_credito(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_nota_credito(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_facturas_nota_credito(integer)  IS 'La función obtiene las facturas a las que se les aplicó esa nota de crédito';
