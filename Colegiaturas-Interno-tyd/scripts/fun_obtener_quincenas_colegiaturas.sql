drop function if exists fun_obtener_quincenas_colegiaturas(OUT idu_generacion INTEGER, OUT fec_generacion character varying);
drop function if exists fun_obtener_quincenas_colegiaturas(OUT fecha date, OUT fecha_mostrar character varying);

CREATE OR REPLACE FUNCTION fun_obtener_quincenas_colegiaturas(OUT fecha date, OUT fecha_mostrar character varying)
 RETURNS SETOF record
AS $function$
DECLARE
	/* -----------------------------------------------------     
	No.Petición: 16995.1 Mejoras al sistema de colegiaturas
	Fecha: 18/09/2018
	Numero Empleado: 95194185
	Nombre Empleado: Paimi Arizmendi Lopez
	BD: personal
	Servidor: 10.44.2.183
	Sistema: Colegiaturas
	Modulo: REPORTE DE  INCENTIVOS
	Ejemplo: 
		SELECT fecha, fecha_mostrar FROM fun_obtener_quincenas_colegiaturas()
	--------------------------------------------------------------------------------*/
	valor record;
BEGIN
    CREATE TEMP TABLE tmp_generaciones_quincena (idu_generacion integer
        , fec_quincena date) on commit drop;
    
    insert into tmp_generaciones_quincena (idu_generacion, fec_quincena)
        select DISTINCT idu_generacion
            , fec_quincena
        from mov_generacion_pagos_colegiaturas;
    
    -- Solo muestra fechas de dos años atras
    insert into tmp_generaciones_quincena (idu_generacion, fec_quincena)
        select DISTINCT idu_generacion
            , fec_quincena
        from his_generacion_pagos_colegiaturas
        where date_part('year', fec_quincena) >= (date_part('year', now()) - 3);
    
    FOR valor IN(
        select distinct fec_quincena
            , TO_CHAR(fec_quincena,'DD/mm/YYYY') as fecha_mostrar
        from tmp_generaciones_quincena 
        order by fec_quincena
         )  
    LOOP
        fecha := valor.fec_quincena;
        fecha_mostrar := valor.fecha_mostrar;
        RETURN NEXT;
    END LOOP;
END;
$function$
LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_quincenas_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_quincenas_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_quincenas_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_quincenas_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_quincenas_colegiaturas() IS 'La función obtiene las quincenas de pago.';