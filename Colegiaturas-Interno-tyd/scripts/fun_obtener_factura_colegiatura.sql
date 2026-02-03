DROP FUNCTION IF EXISTS fun_obtener_factura_colegiatura(integer);
DROP TYPE IF EXISTS type_obtener_factura_colegiatura;

CREATE TYPE type_obtener_factura_colegiatura AS
   (idu_empresa integer,
    rfc character varying(20),
    escuela integer,
    foliofiscal character varying(100),
    importe numeric(12,2),
    fecha character varying(10),
    des_metodo_pago character varying(20),
    fol_relacionado character varying(100),
    idu_empleado integer,
    idu_beneficiario_externo integer,
    importe_calculado numeric(12,2),
    importe_pagado numeric(12,2),
    nom_xml_recibo character varying(60),
    nom_pdf_carta character varying(60),
    xml_factura text,
    idu_estatus integer,
    fec_registro timestamp without time zone,
    idfactura integer);

CREATE OR REPLACE FUNCTION fun_obtener_factura_colegiatura(integer)
  RETURNS SETOF type_obtener_factura_colegiatura AS
$BODY$
DECLARE  
	iFactura alias for $1;	
	registros type_obtener_factura_colegiatura;
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 09/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los datos general de una factura
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir Factura
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_factura_colegiatura(262);	
		 SELECT * FROM fun_obtener_factura_colegiatura(9);	
	*/
BEGIN

	--select * from mov_facturas_colegiaturas

	delete from stmp_detalle_facturas_colegiaturas where idfactura=iFactura;

	INSERT INTO stmp_detalle_facturas_colegiaturas (idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_parentesco, 
	idu_tipopago,prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_carrera, idu_grado_escolar, idu_ciclo_escolar, importe_concepto, idfactura)
	select idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_parentesco, idu_tipopago,prc_descuento, periodo, 
	idu_escuela, idu_escolaridad, idu_carrera, idu_grado_escolar, idu_ciclo_escolar, importe_concepto, idfactura
	from mov_detalle_facturas_colegiaturas where idfactura=iFactura;	 

	FOR registros IN (SELECT idu_empresa, rfc_clave, idu_escuela, fol_fiscal, importe_factura,  to_char(fec_factura,'dd/MM/yyyy')
            , des_metodo_pago
            , fol_relacionado
            , idu_empleado
            , idu_beneficiario_externo
            , importe_calculado
            , importe_pagado
            , nom_xml_recibo
            , nom_pdf_carta
            , xml_factura
            , idu_estatus
            , fec_registro
            , idfactura
		from mov_facturas_colegiaturas where idfactura=iFactura) 
	LOOP
		RETURN NEXT registros;
	END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_factura_colegiatura(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_factura_colegiatura(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_factura_colegiatura(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_factura_colegiatura(integer) TO postgres;