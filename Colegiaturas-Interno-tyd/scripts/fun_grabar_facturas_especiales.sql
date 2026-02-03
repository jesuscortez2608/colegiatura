DROP FUNCTION if exists fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_facturas_especiales(
IN iidu_empresa integer, 
IN sfoliofiscal character varying, 
IN iidu_empleado integer, 
IN dfec_factura date, 
IN iidu_centro integer, 
IN iidu_escuela integer, 
IN srfc_clave character varying, 
IN iimporte_factura numeric, 
IN iidu_tipo_documento integer, 
IN iidu_empleado_registro integer, 
IN snom_pdf_carta character varying, 
IN iidu_beneficiario integer, 
IN ibeneficiario_hoja_azul integer, 
IN iidu_parentesco integer, 
IN iidu_tipopago integer, 
IN speriodo character varying, 
IN iidu_escolaridad integer, 
IN iidu_grado_escolar integer, 
IN iidu_ciclo_escolar integer, 
OUT iestado integer, 
OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES
	valor record;	
	factura integer;
	iHojaAzul smallint;
BEGIN
	--TABLA TEMPORAL
	CREATE TEMP TABLE Datos(
		estado integer,
		mensaje varchar(100)		
	) ON COMMIT DROP;

	/*
	SELECT * FROM STMP_FACTURAS_COLEGIATURAS LIMIT 1
	SELECT * FROM MOV_FACTURAS_COLEGIATURAS
	SELECT * FROM MOV_DETALLE_FACTURAS_COLEGIATURAS
	*/

	iHojaAzul = 0;
	--INSERTAR DATOS DE FACTURA0
	if exists (select fol_fiscal from mov_facturas_colegiaturas where fol_fiscal = sfoliofiscal) then
		insert into Datos(estado, mensaje)
		values (-1, 'Factura registrada anteriormente');
	else
		if not exists (select idu_beneficiario from cat_beneficiarios_colegiaturas where idu_beneficiario = iidu_beneficiario and idu_empleado = iidu_empleado and idu_parentesco = iidu_parentesco) then
			iHojaAzul := 1;
		end if;
		INSERT 	INTO MOV_FACTURAS_COLEGIATURAS (idu_empresa, fol_fiscal, idu_empleado, fec_factura, idu_centro, opc_pdf, idu_escuela, rfc_clave, importe_factura, idu_tipo_documento, idu_estatus, emp_marco_estatus, idu_empleado_registro
							, nom_pdf_carta)
						VALUES 	(iidu_empresa, sfoliofiscal, iidu_empleado, dfec_factura, iidu_centro, 1, iidu_escuela, srfc_clave, iimporte_factura, iidu_tipo_documento, 1, 0, iidu_empleado_registro
							, snom_pdf_carta);

		factura:=(SELECT MAX(idfactura) FROM MOV_FACTURAS_COLEGIATURAS WHERE fol_fiscal=sfoliofiscal);

		--INSERTAR DETALLE	
		INSERT 	INTO MOV_DETALLE_FACTURAS_COLEGIATURAS (idu_empleado, fol_fiscal, idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, idu_tipopago, prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_grado_escolar
							, idu_ciclo_escolar, importe_concepto, fec_registro, idu_empleado_registro, idfactura) 
							VALUES	(iidu_empleado, sfoliofiscal, iidu_beneficiario, iHojaAzul, iidu_parentesco, iidu_tipopago, 0, speriodo, iidu_escuela, iidu_escolaridad, iidu_grado_escolar
							, iidu_ciclo_escolar, iimporte_factura, now(), iidu_empleado_registro, factura);

		--VALOR REGRESADO
		INSERT 	INTO Datos(estado, mensaje) 
		VALUES 	(0, 'Factura guardada correctamente ');
	end if;	

	-- SELECT idu_empleado, fol_fiscal, idu_beneficiario, beneficiario_hoja_azul, idu_parentesco, periodo, idu_escuela, idu_escolaridad, idu_grado_escolar, idu_ciclo_escolar, importe_concepto, fec_registro, idu_empleado_registro, id_factura) 
	--FROM 	MOV_DETALLE_FACTURAS_COLEGIATURAS 
	
	
	--VALORES REGRESADOS
	FOR valor IN (SELECT estado, mensaje FROM  Datos)
	LOOP
		 iestado:=valor.estado;
		 smensaje:=valor.mensaje;		 
		
	RETURN NEXT; 
	END LOOP;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_facturas_especiales(integer, character varying, integer, date, integer, integer, character varying, numeric, integer, integer, character varying, integer, integer, integer, integer, character varying, integer, integer, integer) IS 'La función graba factura de un colaborador especial o con estudio en el extranjero.';