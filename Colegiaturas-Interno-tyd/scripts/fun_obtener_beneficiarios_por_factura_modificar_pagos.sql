CREATE OR REPLACE FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer)
  RETURNS SETOF type_obtener_beneficiarios_por_factura_modificar_pagos AS
$BODY$
   DECLARE

        iEmpleado     	ALIAS FOR $1;
        iFactura 	ALIAS FOR $2;
        registro	type_obtener_beneficiarios_por_factura_modificar_pagos;
        nImporteConcepto numeric;
        nImporteCalculado numeric;

        sumImportes numeric;

	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 07/12/2016
	     Número empleado                : 97695068
	     Nombre del empleado            : Héctor Medina Escareño
	     Base de datos                  : Personal
	     Descripción del funcionamiento : Modificación de la función "fun_obtener_beneficiarios_por_factura()" obtiene el idfactura y el importe pagado.
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Procesos Especiales
	     Ejemplo                        : SELECT * FROM fun_obtener_beneficiarios_por_factura_modificar_pagos(98439677,1859);
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
		imp_importefactura NUMERIC(12,2),
		imp_importe_pagado numeric(12,2),
		descuento integer,
		comentario text not null default '',
		keyx integer,
		idfactura integer
	) on commit drop;

	/*
	create local temp table tmp_Importe_Calculado
	( 	
		iFactura integer, 
		importeReal numeric (12,2),
		importe_mes numeric (12,2),
		importe_semana numeric (12,2),
		importe_tomar numeric (12,2),
		importe_concepto numeric (12,2), --importe modificado
		tope_mensual numeric (12,2),
		importe_calculado numeric (12,2),
		tipo_periodo integer,
		periodo_meses numeric (12,2),
		prc_descuento INTEGER
	)on commit drop;*/

	--
	/*
	INSERT 	INTO tmp_detalles_facturas(idu_beneficiario, idu_parentesco,idu_tipo_pago,  nom_periodo, idu_escolaridad, idu_grado,idu_ciclo, imp_importe,imp_importe_pagado,descuento, keyx, idfactura)
	select 	idu_beneficiario, idu_parentesco,idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar, importe_concepto,importe_pagado, prc_descuento, keyx, idfactura
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS 
	WHERE 	idu_empleado=iEmpleado 
		and idFactura=iFactura;
	*/

	--FUNCION PARA TRAER IMPORTES
	--SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (iEmpleado, iFactura) as fun into nImporteConcepto, nImporteCalculado;
	SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (iEmpleado, 0) as fun into nImporteConcepto, nImporteCalculado;

	--INSERTAR IMPORTES DETALLE
	INSERT 	INTO tmp_detalles_facturas(idu_beneficiario, idu_parentesco,idu_tipo_pago,  nom_periodo, idu_escolaridad, idu_grado,idu_ciclo
		, imp_importe ,imp_importe_pagado
		,descuento, keyx, idfactura)
	select 	idu_beneficiario, idu_parentesco,idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar
		, importe_concepto ,importe_pagado
		,prc_descuento, keyx, idfactura
		--A.idfactura, A.importe_concepto, 0.00, A.idu_tipopago, A.prc_descuento
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS 	
	WHERE 	idu_empleado=iEmpleado
		and idFactura=iFactura;
		--and tmp_detalles_facturas.keyx=A.keyx;

	
	--SELECT nimporte_concepto, nimporte_calculado FROM fun_realizar_calculos_escenarios (idEmpleado, iFolioFactura) as fun into nImporteConcepto, nImporteCalculado;

	--IMPORTE CONCEPTO
	--UPDATE 	tmp_detalles_facturas SET imp_importe_pagado=
	--from	; --A.importe_concepto
	--/*imp_importe = nImporteConcepto,*/
	--FROM	tmp_Importes A
	--where	tmp_detalles_facturas.idfactura=A.iFactura;

	
	update	tmp_detalles_facturas set imp_importefactura=B.importe_factura
	from	MOV_FACTURAS_COLEGIATURAS B
	where	tmp_detalles_facturas.idfactura=B.idfactura;

	--IMPORTE PAGADO
	--UPDATE	tmp_detalles_facturas SET imp_importe_pagado=imp_importe*(descuento/100.00);
	

	IF ((SELECT COUNT(*)FROM tmp_detalles_facturas)	=0) THEN --HISTORICA
		
		INSERT 	INTO tmp_detalles_facturas(idu_beneficiario, idu_parentesco,idu_tipo_pago,  nom_periodo, idu_escolaridad, idu_grado,idu_ciclo, imp_importe,imp_importe_pagado,descuento, keyx, idfactura)
		select 	idu_beneficiario, idu_parentesco,idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar, importe_concepto,importe_pagado, prc_descuento, keyx, idfactura
		from 	his_detalle_facturas_colegiaturas 
		WHERE 	idu_empleado=iEmpleado 
			and idFactura=iFactura;		
	END IF;

	update 	tmp_detalles_facturas set nom_parentesco= a.des_parentesco 
	from 	CAT_PARENTESCOS a 
	where 	a.idu_parentesco=tmp_detalles_facturas.idu_parentesco;

	update 	tmp_detalles_facturas set nom_escolaridad=a.nom_escolaridad 
	from 	CAT_ESCOLARIDADES a 
	where 	a.idu_escolaridad=tmp_detalles_facturas.idu_escolaridad;

	update 	tmp_detalles_facturas set nom_grado=a.nom_grado_escolar
	from 	CAT_GRADOS_ESCOLARES a 
	where 	a.idu_grado_escolar=tmp_detalles_facturas.idu_grado 
		and a.idu_escolaridad=tmp_detalles_facturas.idu_escolaridad;

	update 	tmp_detalles_facturas set nom_ciclo_escolar=a.des_ciclo_escolar 
	from 	CAT_CICLOS_ESCOLARES a 
	where 	a.idu_ciclo_escolar=tmp_detalles_facturas.idu_ciclo;

	update 	tmp_detalles_facturas set des_tipo_pago=a.des_tipo_pago 
	from 	CAT_TIPOS_PAGOS a 
	where 	a.idu_tipo_pago=tmp_detalles_facturas.idu_tipo_pago;

	--NOMBRE DE LOS BENEFICIARIOS ESPECIALES
	UPDATE 	tmp_detalles_facturas SET nom_beneficiario=trim(b.nom_beneficiario)||' '||trim(b.ape_paterno)||' '||trim(b.ape_materno), idu_hoja_azul=0, 
		comentario=case when b.opc_becado_especial=1 then  b.des_observaciones else '' end
	FROM 	CAT_BENEFICIARIOS_COLEGIATURAS b 
	WHERE 	b.idu_empleado=iEmpleado 
		and b.idu_beneficiario=tmp_detalles_facturas.idu_beneficiario;

	--BENEFICIARIOS HOJA AZUL
	UPDATE 	tmp_detalles_facturas SET nom_beneficiario= trim(b.nombre)||' '||trim(b.apellidopaterno)||' '||trim(b.apellidomaterno)
	FROM 	sapfamiliarhojas b 
	where 	numemp=iEmpleado and b.keyx=tmp_detalles_facturas.idu_beneficiario;
	

	FOR registro IN (
		SELECT 	idu_hoja_azul, idu_beneficiario, nom_beneficiario, idu_parentesco, nom_parentesco, idu_tipo_pago, des_tipo_pago,nom_periodo, idu_escolaridad, nom_escolaridad, idu_grado, 
			nom_grado, idu_ciclo, nom_ciclo_escolar, imp_importe,imp_importefactura,imp_importe_pagado, descuento, comentario, keyx, idfactura 
		from 	tmp_detalles_facturas 
		order 	by keyx)
	LOOP
		RETURN NEXT registro;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_beneficiarios_por_factura_modificar_pagos(integer, integer) IS 'La función obtiene datos de la facturas de acuerdo al empleado y factura';