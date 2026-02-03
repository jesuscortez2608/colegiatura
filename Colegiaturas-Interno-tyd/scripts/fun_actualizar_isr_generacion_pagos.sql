DROP FUNCTION if exists fun_actualizar_isr_generacion_pagos(xml);

CREATE OR REPLACE FUNCTION fun_actualizar_isr_generacion_pagos(sxml xml)
  RETURNS integer AS
$BODY$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT fun_actualizar_isr_generacion_pagos('<Root><r><e>95194185</e><i>26700</i></r><r><e>91729815</e><i>2900</i></r><r><e>91815381</e><i>23800</i></r><r><e>90874897</e><i>8800</i></r></Root>');
	------------------------------------------------------------------------------------------------------ */
BEGIN
    CREATE LOCAL TEMP TABLE tmp_isr_colegiaturas (
        idu_empleado INTEGER,
        importe_isr NUMERIC(12,2)
	)ON COMMIT DROP;
    
	INSERT INTO tmp_isr_colegiaturas(idu_empleado, importe_isr)
	SELECT (xpath('//e/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS idu_empleado,
		(xpath('//i/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS importe_isr
	FROM unnest(xpath('//Root/r', sXml)) AS myTempTable(myXmlColumn);
	
    update mov_generacion_pagos_colegiaturas set importe_isr = (tmp.importe_isr::float/100::float)::numeric(12,2)
    from tmp_isr_colegiaturas as tmp
    where tmp.idu_empleado = mov_generacion_pagos_colegiaturas.idu_empleado;
    
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_actualizar_isr_generacion_pagos(xml) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_actualizar_isr_generacion_pagos(xml) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_actualizar_isr_generacion_pagos(xml) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_actualizar_isr_generacion_pagos(xml) TO postgres;
COMMENT ON FUNCTION fun_actualizar_isr_generacion_pagos(xml) IS 'LA FUNCION ACTUALIZA EL ISR GENERADO POR EL PROCEDIMIENTO PROC_GENERAR_ISR_COLEGIATURAS, EN LA TABLA MOV_GENERACION_PAGOS_COLEGIATURAS';  