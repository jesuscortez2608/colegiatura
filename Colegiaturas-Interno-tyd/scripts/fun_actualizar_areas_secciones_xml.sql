DROP FUNCTION IF EXISTS fun_actualizar_areas_secciones_xml(xml);

CREATE OR REPLACE FUNCTION fun_actualizar_areas_secciones_xml(xml)
  RETURNS integer AS
$BODY$
DECLARE
    /*
        No. petición APS               : 16995 Colegiaturas
        Fecha                          : 04/09/2018
        Número empleado                : 95194185
        Nombre del empleado            : Paimi Arizmendi Lopez
        Base de datos                  : Personal
        Usuario de BD                  : syspersonal
        Servidor de pruebas            : 10.28.114.75
        Servidor de produccion         : 10.44.2.183
        Descripción                    : La función actualiza las áreas secciones desde la BD de Colegiaturas
        Sistema                        : Colegiaturas
        Módulo                         : Reportes
        Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
        Ejemplo                        :
                    SELECT fun_actualizar_areas_secciones_xml ('<Root><r><idu_area>1</idu_area><nom_area>TIENDAS</nom_area><idu_seccion>36</idu_seccion><nom_seccion>DISE\321O REGIONAL</nom_seccion></r></Root>'::XML) AS resultado
    ------------------------------------------------------------------------------------------------------ */
	sXml alias for $1;
BEGIN
    truncate cat_area_seccion;
    
    INSERT INTO cat_area_seccion(idu_area, nom_area, idu_seccion, nom_seccion, fec_actualizacion)
	SELECT (xpath('//idu_area/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS idu_area,
		(xpath('//nom_area/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS nom_area,
		(xpath('//idu_seccion/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS idu_seccion,
		(xpath('//nom_seccion/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS nom_seccion,
		now() as fec_actualizacion
	FROM unnest(xpath('//Root/r', sXml)) AS myTempTable(myXmlColumn);
	
	update cat_area_seccion set nom_area = convert_from(nom_area::BYTEA, 'SQL_ASCII')
        , nom_seccion = convert_from(nom_seccion::BYTEA, 'SQL_ASCII');
	
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_actualizar_areas_secciones_xml(xml) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_actualizar_areas_secciones_xml(xml) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_actualizar_areas_secciones_xml(xml) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_actualizar_areas_secciones_xml(xml) TO postgres;
COMMENT ON FUNCTION fun_actualizar_areas_secciones_xml(xml) IS 'La función actualiza el catalogo de areas secciones desde el procedimiento Personal.dbo.proc_consultaareassecciones en Personal SQLServer (10.44.1.13).';