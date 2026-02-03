CREATE OR REPLACE FUNCTION fun_grabar_aplicar_nota_credito(
IN inotacredito integer, 
IN ifactura integer, 
IN iimportenota numeric, 
IN iimportefactura numeric, 
IN iprcdescuento integer, 
IN iimportecalculado numeric, 
IN iimporteaplicado numeric, 
IN iimportepagado numeric, 
OUT iestado integer, 
OUT cmsg character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE    
	
	valor record;	
	
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 22-08-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema:  Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: 
-- ====================================================================================================
BEGIN 
	--TABLA TEMPORAL
	CREATE TEMP TABLE tmp(
		estado integer not null default 0,
		mensaje varchar(50) not null default ''
	) ON COMMIT DROP;	
	
	--INSERTA tmp_factura
	INSERT INTO MOV_APLICACION_NOTAS_CREDITO (idnotacredito, idfactura, importe_nota, importe_factura, prc_descuento, importe_calculado, importe_aplicado, importe_pagado)
	VALUES (iNotaCredito, iFactura, iImporteNota, iImporteFactura, iPrcDescuento, iImporteCalculado, iImporteAplicado, iImportePagado);

	update 	MOV_APLICACION_NOTAS_CREDITO set prc_descuento=B.prc_descuento
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS B
	where   MOV_APLICACION_NOTAS_CREDITO.idfactura=B.idfactura;

	INSERT INTO tmp (estado, mensaje)
	VALUES(0,'La nota de crédito ha sido aplicada correctamente');
	
	--
	FOR valor IN SELECT estado, mensaje FROM tmp 
	loop
		iEstado:=valor.estado;
		cMsg:=valor.mensaje;
		return next;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

  
GRANT EXECUTE ON FUNCTION fun_grabar_aplicar_nota_credito(integer,integer, numeric, numeric, integer, numeric, numeric, numeric) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_aplicar_nota_credito(integer,integer, numeric, numeric, integer, numeric, numeric, numeric) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_aplicar_nota_credito(integer,integer, numeric, numeric, integer, numeric, numeric, numeric) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_aplicar_nota_credito(integer,integer, numeric, numeric, integer, numeric, numeric, numeric) TO postgres;
COMMENT ON FUNCTION fun_grabar_aplicar_nota_credito(integer,integer, numeric, numeric, integer, numeric, numeric, numeric)IS 'La función graba la nota de crédito';
  
    
