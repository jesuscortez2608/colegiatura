CREATE OR REPLACE FUNCTION fun_obtener_motivos_descuento(OUT idu_motivo_descto integer, OUT des_motivo_descto character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	valor record;
BEGIN	
	FOR valor IN( 
		SELECT 	idu_motivo, des_motivo
		FROM 	CAT_MOTIVOS_COLEGIATURAS
		WHERE	idu_tipo_motivo=5
		) LOOP
		idu_motivo_descto := valor.idu_motivo;
		des_motivo_descto := valor.des_motivo;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_descuento() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_descuento() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_descuento() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_motivos_descuento() TO postgres;
COMMENT ON FUNCTION fun_obtener_motivos_descuento() IS 'La funcion obtiene los motivos de descuentos.';