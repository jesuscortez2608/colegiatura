CREATE OR REPLACE FUNCTION fun_autorizar_factura_externo(IN iusuario integer, IN ifactura integer)
  RETURNS void AS
$BODY$
DECLARE
	--valor record;
/* ====================================================================================================
-- Peticion: 
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 15-05-2018
-- Descripción General: Autoriza facturas para Externos
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas 
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75 
-- Ejemplo: 
-- ====================================================================================================
 */      
        BEGIN 			

		UPDATE 	mov_facturas_colegiaturas SET idu_estatus=6, emp_marco_estatus=iUsuario,  fec_marco_estatus=now()
		WHERE	idfactura=iFactura;

		INSERT 	INTO his_facturas_colegiaturas (fol_fiscal,fol_factura,serie,fec_factura,idu_empleado,idu_beneficiario_externo,idu_centro,idu_empresa,opc_pdf,idu_escuela,rfc_clave,importe_factura,
			importe_calculado,importe_pagado,idu_tipo_documento,idu_tipo_deduccion,idu_estatus,opc_modifico_pago,idu_motivo_rechazo,emp_marco_estatus,fec_marco_estatus,des_comentario_especial,
			des_aclaracion_costos,des_observaciones,fec_registro,opc_movimiento_traspaso,idu_empleado_traspaso,fec_movimiento_traspaso,idu_empleado_registro,xml_factura,nom_xml_recibo,nom_pdf_carta,idfactura)
		SELECT 	fol_fiscal,fol_factura,serie,fec_factura,idu_empleado,idu_beneficiario_externo,idu_centro,idu_empresa,opc_pdf,idu_escuela,rfc_clave,importe_factura,	importe_calculado,importe_pagado,idu_tipo_documento,
			idu_tipo_deduccion,idu_estatus,opc_modifico_pago,idu_motivo_rechazo,emp_marco_estatus,fec_marco_estatus,des_comentario_especial,des_aclaracion_costos,des_observaciones,fec_registro,opc_movimiento_traspaso,
			idu_empleado_traspaso,fec_movimiento_traspaso,idu_empleado_registro,xml_factura,nom_xml_recibo,nom_pdf_carta,idfactura	
		FROM 	mov_facturas_colegiaturas 
		WHERE 	idfactura=iFactura;

		DELETE FROM mov_facturas_colegiaturas WHERE idfactura=iFactura;		

        END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_autorizar_factura_externo(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_autorizar_factura_externo(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_autorizar_factura_externo(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_autorizar_factura_externo(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_autorizar_factura_externo(integer, integer) IS 'La función inserta en la tabla historica los movimientos de las facturas que son autorizadas.';