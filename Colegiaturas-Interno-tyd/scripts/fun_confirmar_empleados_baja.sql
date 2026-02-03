CREATE OR REPLACE FUNCTION fun_confirmar_empleados_baja(integer, xml, integer)
  RETURNS void AS
$BODY$
DECLARE
	iBloque alias for $1;
	cXml alias for $2;
	iUsuario alias for $3;
BEGIN
/* 
=======================================================================================================================================================
-- Peticion: 16559 
-- APS : 22418
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 21-05-2019
-- Descripción General:Inserta en la tabla temporal stmp_empleados_baja los empleados que son baja en la he de sql
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: SELECT fun_confirmar_empleados_baja (0,'<Root><r><e>$numemp</e><u>$Usuario</u></r><r><e>$numemp</e><u>$Usuario</u></r></Root>',94827443)
=======================================================================================================================================================
*/ 
   
	
	IF (iBloque=0)THEN
		DELETE FROM stmp_empleados_baja WHERE usuario=iUsuario;
	END IF;	
	
	INSERT 	INTO stmp_empleados_baja(numemp,usuario)
	SELECT 	(xpath('//e/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS numemp,
			(xpath('//u/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS usuario			
	FROM 	unnest(xpath('//Root/r', cXml)) AS myTempTable(myXmlColumn);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;