-- Function: public.fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer)

-- DROP FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE 
	
	nFactura alias for $1;
	nRechazo alias for $2;
	nDeduccion alias for $3;
	nEmpleadoRegistro alias for $4;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 28/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Actualiza el campo IDU_ESTATUS de la tabla MOV_FACTURAS_COLEGIATURAS 
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Aceptar / Rechazar Facturas
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_estatus_aceptar_factura(1,93902761,1,1); 
		 
	*/
BEGIN
	if (exists (select idfactura from MOV_FACTURAS_COLEGIATURAS where idfactura=nFactura and des_metodo_pago='PPD' AND idu_tipo_documento=1)) then		
		INSERT INTO HIS_FACTURAS_COLEGIATURAS (
			fol_fiscal, fol_factura, serie, fec_factura, des_metodo_pago, fol_relacionado, idu_empleado, clv_rutapago, num_cuenta, idu_beneficiario_externo, idu_centro, idu_puesto, idu_empresa, opc_pdf
			, idu_escuela, rfc_clave, importe_factura, importe_calculado, importe_pagado, tope_mensual, idu_tipo_documento, idu_tipo_deduccion, idu_estatus, opc_modifico_pago, idu_motivo_rechazo, emp_marco_estatus
			, fec_marco_estatus, fec_cierre, des_comentario_especial, des_aclaracion_costos, des_observaciones, fec_registro, opc_movimiento_traspaso, idu_empleado_traspaso, fec_movimiento_traspaso
			, idu_empleado_registro, xml_factura, nom_xml_recibo, nom_pdf_carta, idfactura)
		SELECT  fol_fiscal, fol_factura, serie, fec_factura, des_metodo_pago, fol_relacionado, idu_empleado, 0, 0, idu_beneficiario_externo, idu_centro, 0, idu_empresa, opc_pdf, idu_escuela, rfc_clave, importe_factura
			, importe_calculado, importe_pagado, 0.00, idu_tipo_documento, idu_tipo_deduccion, 2, opc_modifico_pago, idu_motivo_rechazo, nEmpleadoRegistro, now(), '19000101', des_comentario_especial
			, des_aclaracion_costos, des_observaciones, fec_registro, opc_movimiento_traspaso, idu_empleado_traspaso, fec_movimiento_traspaso, idu_empleado_registro, xml_factura, nom_xml_recibo, nom_pdf_carta, idfactura
		FROM	MOV_FACTURAS_COLEGIATURAS WHERE IDFACTURA=nFactura;

		insert into HIS_DETALLE_FACTURAS_COLEGIATURAS (idu_empleado, fol_fiscal, idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, idu_tipopago, prc_descuento, periodo, idu_escuela, idu_escolaridad
			, idu_grado_escolar, idu_ciclo_escolar, importe_concepto, importe_pagado, fec_registro, idu_empleado_registro, idfactura, keyx, idu_carrera)
		select 	idu_empleado, fol_fiscal, idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, idu_tipopago, prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_grado_escolar, idu_ciclo_escolar
			, importe_concepto, importe_pagado, fec_registro, idu_empleado_registro, idfactura, keyx, idu_carrera 
		from 	MOV_DETALLE_FACTURAS_COLEGIATURAS WHERE IDFACTURA=nFactura;

		
		delete from MOV_FACTURAS_COLEGIATURAS WHERE IDFACTURA=nFactura;		
		delete from MOV_DETALLE_FACTURAS_COLEGIATURAS WHERE IDFACTURA=nFactura;	
	else	
		UPDATE 	MOV_FACTURAS_COLEGIATURAS SET IDU_ESTATUS=2, EMP_MARCO_ESTATUS= nEmpleadoRegistro, FEC_MARCO_ESTATUS=now(),IDU_MOTIVO_RECHAZO=nRechazo,idu_tipo_deduccion=nDeduccion, des_observaciones = ''
		WHERE 	IDFACTURA=nFactura;
	end if;

	UPDATE	CTL_IMPORTES_FACTURAS_MES set pagado=1
	from	MOV_DETALLE_FACTURAS_COLEGIATURAS B
	WHERE	CTL_IMPORTES_FACTURAS_MES.idfactura=B.idfactura	
			and CTL_IMPORTES_FACTURAS_MES.idfactura=nFactura;
	return 1;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer) TO sysetl;
COMMENT ON FUNCTION fun_grabar_estatus_aceptar_factura(integer, integer, integer, integer) IS 'La funcion actualiza el estatus de la factura a aceptada.';
