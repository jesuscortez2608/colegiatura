CREATE OR REPLACE FUNCTION fun_grabar_incentivos_administracion(integer, xml)
  RETURNS void AS
$BODY$
declare
	iBloque alias for $1;
	cXml alias for $2;
begin
	/*
	No. peticiÃ³n APS               : 17875.1
	Fecha                          : 14/11/2017
	NÃºmero empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : administracion
	Servidor de produccion         : 10.44.2.29
	DescripciÃ³n del funcionamiento : Actualiza los registros seleccionados en el traspaso de facturas
	Ejemplo                        :
	SELECT fun_grabar_incentivos_administracion(1::INTEGER
	'<Root><r><e>9519418</e><i>2000</i><s>10</s><t>2010</t></r><r><e>94827443</e><i>1000</i><s>10</s><t>1010</t></r>
	</Root>'
	*/
    

	IF (iBloque=1)THEN
		DELETE FROM stmp_incentivos;
	END IF;
    
	INSERT 	INTO stmp_incentivos(num_empleado, imp_factura, imp_isr, total)
	SELECT 	(xpath('//e/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS empleado,
			(xpath('//i/text()', myTempTable.myXmlColumn))[1]::TEXT::NUMERIC(12,2) AS importe,
			(xpath('//s/text()', myTempTable.myXmlColumn))[1]::TEXT::NUMERIC(12,2) AS isr,
			(xpath('//t/text()', myTempTable.myXmlColumn))[1]::TEXT::NUMERIC(12,2) AS total
	FROM 	unnest(xpath('//Root/r', cXml)) AS myTempTable(myXmlColumn);	
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
 GRANT EXECUTE ON FUNCTION fun_grabar_incentivos_administracion(integer, xml) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_incentivos_administracion(integer, xml) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_incentivos_administracion(integer, xml) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_incentivos_administracion(integer, xml) TO postgres;
COMMENT ON FUNCTION fun_grabar_incentivos_administracion(integer, xml) IS 'La función graba los incentivos del sistema anterior en personal';