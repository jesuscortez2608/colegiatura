CREATE OR REPLACE FUNCTION fun_grabar_ajuste_por_factura(
IN iidfactura integer, 
IN ipctajuste integer, 
IN iusuarioregistro integer, 
IN sobservaciones text, 
OUT iestado integer, 
OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 
	imp_pagado numeric;
	imp_ajuste numeric;
	imp_ajuste_actual numeric;
	Total_importes integer;
	imp_factura integer;
	valor record;
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 22-05-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo:  10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- BD: Personal
-- Ejemplo: SELECT * FROM FUN_GRABAR_AJUSTE_POR_FACTURA (1,60,94827443,'')
-- ====================================================================================================
	
BEGIN
	CREATE TEMP TABLE tmp(
		estado integer not null default 0,
		mensaje varchar(100) default ''
	) ON COMMIT DROP;
	
	IF EXISTS (SELECT idfactura FROM mov_ajustes_facturas_colegiaturas WHERE idfactura=  iIDFactura ) THEN
		INSERT INTO tmp (estado, mensaje) VALUES (-1,'Solo se permite un movimiento de ajuste por cierre de Colegiaturas');
	ELSE	
		imp_factura:=(SELECT (importe_factura*100) FROM his_facturas_colegiaturas WHERE idfactura=iIDFactura);
		imp_pagado:=(SELECT importe_pagado FROM his_facturas_colegiaturas WHERE idfactura=iIDFactura);
		imp_ajuste:= (SELECT COALESCE(SUM(importe_ajuste),0) FROM his_ajustes_facturas_colegiaturas WHERE idfactura=iIDFactura);				
		imp_ajuste_actual:=(SELECT COALESCE((importe_factura/100)*iPctAjuste,0) FROM his_facturas_colegiaturas WHERE idfactura=iIDFactura);
		--imp_ajuste_actual:=(SELECT COALESCE((importe_factura/100)*iPctAjuste,0) FROM mov_ajustes_facturas_colegiaturas WHERE idfactura=iIDFactura);		
		--Total_importes:=(SELECT imp_pagado::int+imp_ajuste::int+imp_ajuste_actual::int);
		Total_importes:=(SELECT (imp_pagado::int+imp_ajuste::int+imp_ajuste_actual::int)*100);
		--INSERT INTO tmp (estado, mensaje) VALUES (Total_importes,'Total ');
		
		IF (COALESCE(Total_importes::int,0)<=imp_factura) THEN
			--SELECT * FROM mov_ajustes_facturas_colegiaturas
			INSERT 	INTO mov_ajustes_facturas_colegiaturas (idfactura, importe_factura, importe_pagado, pct_ajuste, importe_ajuste, des_observaciones, idu_usuario_traspaso, fec_traspaso, idu_usuario_registro, fec_registro)
			SELECT 	iIDFactura, importe_factura, importe_pagado,iPctAjuste, COALESCE(imp_ajuste_actual,0), sObservaciones, 0, '19000101', iUsuarioRegistro, now()
			FROM 	his_facturas_colegiaturas
			WHERE	idfactura=iIDFactura;

			UPDATE mov_ajustes_facturas_colegiaturas SET importe_ajuste=COALESCE((importe_factura/100)*iPctAjuste,0) WHERE idfactura=iIDFactura;

			INSERT 	INTO tmp (estado, mensaje) 
			SELECT 	idu_ajuste, 
				--imp_pagado::int,
				--imp_ajuste::int,
				--imp_ajuste_actual::int,
				--imp_factura,
				--Total_importes,
				'Ajuste generado correctamente'
			FROM 	mov_ajustes_facturas_colegiaturas 
			WHERE 	idfactura= iIDFactura 
			ORDER 	BY idu_ajuste DESC;
		ELSE
			INSERT INTO tmp (estado, mensaje) VALUES (-2,'El importe pagado más el ajuste, no deben exceder el importe de la factura ');
			--INSERT INTO tmp (estado, mensaje) VALUES (Total_importes,'El importe pagado más el ajuste, no deben exceder el importe de la factura ');
			
		END IF;
		
	END IF;	

	FOR valor IN( SELECT estado, mensaje FROM tmp )
	LOOP
		iEstado:=valor.estado;
		sMensaje:=valor.mensaje;
	RETURN NEXT;
	END LOOP;
	
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_grabar_ajuste_por_factura(integer, integer, integer, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_ajuste_por_factura(integer, integer, integer, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_ajuste_por_factura(integer, integer, integer, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_ajuste_por_factura(integer, integer, integer, text) TO postgres;
COMMENT ON FUNCTION fun_grabar_ajuste_por_factura(integer, integer, integer, text) IS 'La función graba los importes de ajustes a las facturas.';