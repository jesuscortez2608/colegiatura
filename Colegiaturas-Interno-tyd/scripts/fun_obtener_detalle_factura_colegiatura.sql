CREATE OR REPLACE FUNCTION fun_obtener_detalle_factura_colegiatura(integer, integer, character varying)
  RETURNS SETOF type_facturas_colegiaturas AS
$BODY$
   DECLARE

        iEmpleado     	ALIAS FOR $1;
        iFactura 	ALIAS FOR $2;
        cFactura   	ALIAS FOR $3;
        registro	type_facturas_colegiaturas;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 12/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Regresa los beneficiarios del empleado y folio de la temporal
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_facturas_colegiaturas(95194185,8,'B0BDB98B-9641-4837-A7D4-27F43739D55C'); 

		 
	*/
	
BEGIN
	create local temp table tmp_detalles_facturas  
	(
		idu_hoja_azul integer not null default 1,
		idu_beneficiario integer  not null default 0,
		nom_beneficiario varchar(150) not null default '',
		idu_parentesco integer  not null default 0,
		nom_parentesco varchar(20)  not null default '',
		idu_tipo_pago  integer  not null default 0,
		des_tipo_pago varchar(20) NOT NULL DEFAULT '',
		nom_periodo varchar(150)  not null default '',
		idu_escolaridad integer  not null default 0,
		nom_escolaridad varchar(30)  not null default '',
		idu_grado integer  not null default 0,
		nom_grado varchar(50)  not null default '',
		idu_ciclo integer not null default 0,
		nom_ciclo_escolar varchar(30) not null default '',
		imp_importe numeric(12,2),
		keyx integer

	) on commit drop; 

	INSERT INTO tmp_detalles_facturas(idu_beneficiario, idu_parentesco,idu_tipo_pago,  nom_periodo, idu_escolaridad, idu_grado,idu_ciclo, imp_importe, keyx )
	select idu_beneficiario, idu_parentesco,idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar, importe_concepto, keyx 
	from mov_detalle_facturas_colegiaturas
	WHERE idu_empleado=iEmpleado and trim(fol_fiscal)=trim(cFactura) and idFactura=iFactura;

	update tmp_detalles_facturas set nom_parentesco= a.des_parentesco 
	from cat_parentescos a where a.idu_parentesco=tmp_detalles_facturas.idu_parentesco;

	update tmp_detalles_facturas set nom_escolaridad=a.nom_escolaridad 
	from cat_escolaridades a where a.idu_escolaridad=tmp_detalles_facturas.idu_escolaridad;

	update tmp_detalles_facturas set nom_grado=a.nom_grado_escolar
	from cat_grados_escolares a where a.idu_grado_escolar=tmp_detalles_facturas.idu_grado and a.idu_escolaridad=tmp_detalles_facturas.idu_escolaridad;

	update tmp_detalles_facturas set nom_ciclo_escolar=a.des_ciclo_escolar 
	from cat_ciclos_escolares a where a.idu_ciclo_escolar=tmp_detalles_facturas.idu_ciclo;

	update tmp_detalles_facturas set des_tipo_pago=a.des_tipo_pago 
	from cat_tipos_pagos a where a.idu_tipo_pago=tmp_detalles_facturas.idu_tipo_pago;

	--NOMBRE DE LOS BENEFICIARIOS ESPECIALES
	UPDATE tmp_detalles_facturas SET nom_beneficiario=trim(b.nom_beneficiario)||' '||trim(b.ape_paterno)||' '||trim(b.ape_materno), idu_hoja_azul=0 
	FROM CAT_BENEFICIARIOS_COLEGIATURAS b WHERE b.idu_empleado=iEmpleado and b.idu_beneficiario=tmp_detalles_facturas.idu_beneficiario;

	FOR registro IN ( SELECT idu_hoja_azul, idu_beneficiario, nom_beneficiario, idu_parentesco, nom_parentesco, idu_tipo_pago, des_tipo_pago,
	nom_periodo, idu_escolaridad, nom_escolaridad, idu_grado, nom_grado, idu_ciclo, nom_ciclo_escolar, imp_importe, keyx from tmp_detalles_facturas order by keyx) 
	LOOP
		RETURN NEXT registro;
	END LOOP;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_detalle_factura_colegiatura(integer, integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_detalle_factura_colegiatura(integer, integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_detalle_factura_colegiatura(integer, integer, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_detalle_factura_colegiatura(integer, integer, character varying) TO postgres;