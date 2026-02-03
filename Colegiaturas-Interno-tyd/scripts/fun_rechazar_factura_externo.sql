CREATE OR REPLACE FUNCTION fun_rechazar_factura_externo(ifactura integer, imotivorechazo integer, cobservaciones character, iusuario integer)
  RETURNS void AS
$BODY$
DECLARE
	--valor record;
/** ====================================================================================================
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

		UPDATE 	mov_facturas_colegiaturas SET idu_estatus=3, emp_marco_estatus=iUsuario,  fec_marco_estatus=now(), idu_motivo_rechazo=iMotivoRechazo, des_observaciones=cObservaciones
		WHERE	idfactura=iFactura;
        END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_rechazar_factura_externo(ifactura integer, imotivorechazo integer, cobservaciones character, iusuario integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_rechazar_factura_externo(ifactura integer, imotivorechazo integer, cobservaciones character, iusuario integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_rechazar_factura_externo(ifactura integer, imotivorechazo integer, cobservaciones character, iusuario integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_rechazar_factura_externo(ifactura integer, imotivorechazo integer, cobservaciones character, iusuario integer) TO postgres;