CREATE OR REPLACE FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer, OUT iestado integer, OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 
	imp_pagado numeric;
	imp_ajuste numeric;
	imp_ajuste_actual numeric;
	Total_importes numeric;
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
	
	IF EXISTS (SELECT fec_traspaso FROM mov_ajustes_facturas_colegiaturas WHERE idu_ajuste=iAjusteID and fec_traspaso>'19000101') THEN
		INSERT INTO tmp (estado, mensaje) VALUES (-1,'El movimiento de ajuste ya fue traspasado y no puede eliminarse');
	ELSE		
		DELETE FROM mov_ajustes_facturas_colegiaturas WHERE idu_ajuste=iAjusteID;
		INSERT INTO tmp (estado, mensaje) VALUES (1,'El movimiento de ajuste fue eliminado exitosamente ');
		
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
GRANT EXECUTE ON FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer)   TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer)   TO sysetl;
GRANT EXECUTE ON FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer)   TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer)   TO postgres;
COMMENT ON FUNCTION fun_borrar_ajuste_por_factura(IN iajusteid integer)  IS 'La función borra ajuste que se le hacen a la factura';
