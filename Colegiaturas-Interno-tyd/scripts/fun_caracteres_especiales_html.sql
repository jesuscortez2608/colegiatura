DROP FUNCTION IF EXISTS fun_caracteres_especiales_html(text);

CREATE OR REPLACE FUNCTION fun_caracteres_especiales_html(IN sText text, OUT sReturn TEXT)
RETURNS TEXT AS
$function$
DECLARE
	/*
	No. petición APS               : 16559.1 Colegiaturas
	Fecha                          : 04/03/2019
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		select fun_caracteres_especiales_html('AÑO BICIESTO'); -- A&Ntilde;O BICIESTO
		select fun_caracteres_especiales_html('CENTRO DE ENSE#ANZA TÉCNICA Y SUPERIOR');
	------------------------------------------------------------------------------------------------------ */
BEGIN
    sReturn := replace(sText,'¡', '&iexcl;');
    sReturn := replace(sReturn,'¢', '&cent;');
    sReturn := replace(sReturn,'£', '&pound;');
    sReturn := replace(sReturn,'¤', '&curren;');
    sReturn := replace(sReturn,'¥', '&yen;');
    sReturn := replace(sReturn,'¦', '&brvbar;');
    sReturn := replace(sReturn,'§', '&sect;');
    sReturn := replace(sReturn,'¨', '&uml;');
    sReturn := replace(sReturn,'©', '&copy;');
    sReturn := replace(sReturn,'ª', '&ordf;');
    sReturn := replace(sReturn,'«', '&laquo;');
    sReturn := replace(sReturn,'¬', '&not;');
    sReturn := replace(sReturn,'®', '&reg;');
    sReturn := replace(sReturn,'¯ ', '&macr;');
    sReturn := replace(sReturn,'°', '&deg;');
    sReturn := replace(sReturn,'±', '&plusmn;');
    sReturn := replace(sReturn,'²', '&sup2;');
    sReturn := replace(sReturn,'³', '&sup3;');
    sReturn := replace(sReturn,'´', '&acute;');
    sReturn := replace(sReturn,'µ', '&micro;');
    sReturn := replace(sReturn,'¶', '&para;');
    sReturn := replace(sReturn,'·', '&middot;');
    sReturn := replace(sReturn,'¸', '&cedil;');
    sReturn := replace(sReturn,'¹', '&sup1;');
    sReturn := replace(sReturn,'º', '&ordm;');
    sReturn := replace(sReturn,'»', '&raquo;');
    sReturn := replace(sReturn,'¼', '&frac14;');
    sReturn := replace(sReturn,'½', '&frac12;');
    sReturn := replace(sReturn,'¾', '&frac34;');
    sReturn := replace(sReturn,'¿', '&iquest;');
    sReturn := replace(sReturn,'À', '&Agrave;');
    sReturn := replace(sReturn,'Á', '&Aacute;');
    sReturn := replace(sReturn,'Â', '&Acirc;');
    sReturn := replace(sReturn,'Ã', '&Atilde;');
    sReturn := replace(sReturn,'Ä', '&Auml;');
    sReturn := replace(sReturn,'Å', '&Aring;');
    sReturn := replace(sReturn,'Æ', '&AElig;');
    sReturn := replace(sReturn,'Ç', '&Ccedil;');
    sReturn := replace(sReturn,'È', '&Egrave;');
    sReturn := replace(sReturn,'É', '&Eacute;');
    sReturn := replace(sReturn,'Ê', '&Ecirc;');
    sReturn := replace(sReturn,'Ë', '&Euml;');
    sReturn := replace(sReturn,'Ì', '&Igrave;');
    sReturn := replace(sReturn,'Í', '&Iacute;');
    sReturn := replace(sReturn,'Î', '&Icirc;');
    sReturn := replace(sReturn,'Ï', '&Iuml;');
    sReturn := replace(sReturn,'Ð', '&ETH;');
    sReturn := replace(sReturn,'Ñ', '&Ntilde;');
    sReturn := replace(sReturn,'Ò', '&Ograve;');
    sReturn := replace(sReturn,'Ó', '&Oacute;');
    sReturn := replace(sReturn,'Ô', '&Ocirc;');
    sReturn := replace(sReturn,'Õ', '&Otilde;');
    sReturn := replace(sReturn,'Ö', '&Ouml;');
    sReturn := replace(sReturn,'×', '&times;');
    sReturn := replace(sReturn,'Ø', '&Oslash;');
    sReturn := replace(sReturn,'Ù', '&Ugrave;');
    sReturn := replace(sReturn,'Ú', '&Uacute;');
    sReturn := replace(sReturn,'Û', '&Ucirc;');
    sReturn := replace(sReturn,'Ü', '&Uuml;');
    sReturn := replace(sReturn,'Ý', '&Yacute;');
    sReturn := replace(sReturn,'Þ', '&THORN;');
    sReturn := replace(sReturn,'ß', '&szlig;');
    sReturn := replace(sReturn,'à', '&agrave;');
    sReturn := replace(sReturn,'á', '&aacute;');
    sReturn := replace(sReturn,'â', '&acirc;');
    sReturn := replace(sReturn,'ã', '&atilde;');
    sReturn := replace(sReturn,'ä', '&auml;');
    sReturn := replace(sReturn,'å', '&aring;');
    sReturn := replace(sReturn,'æ', '&aelig;');
    sReturn := replace(sReturn,'ç', '&ccedil;');
    sReturn := replace(sReturn,'è', '&egrave;');
    sReturn := replace(sReturn,'é', '&eacute;');
    sReturn := replace(sReturn,'ê', '&ecirc;');
    sReturn := replace(sReturn,'ë', '&euml;');
    sReturn := replace(sReturn,'ì', '&igrave;');
    sReturn := replace(sReturn,'í', '&iacute;');
    sReturn := replace(sReturn,'î', '&icirc;');
    sReturn := replace(sReturn,'ï', '&iuml;');
    sReturn := replace(sReturn,'ð', '&eth;');
    sReturn := replace(sReturn,'ñ', '&ntilde;');
    sReturn := replace(sReturn,'ò', '&ograve;');
    sReturn := replace(sReturn,'ó', '&oacute;');
    sReturn := replace(sReturn,'ô', '&ocirc;');
    sReturn := replace(sReturn,'õ', '&otilde;');
    sReturn := replace(sReturn,'ö', '&ouml;');
    sReturn := replace(sReturn,'÷', '&divide;');
    sReturn := replace(sReturn,'ø', '&oslash;');
    sReturn := replace(sReturn,'ù', '&ugrave;');
    sReturn := replace(sReturn,'ú', '&uacute;');
    sReturn := replace(sReturn,'û', '&ucirc;');
    sReturn := replace(sReturn,'ü', '&uuml;');
    sReturn := replace(sReturn,'ý', '&yacute;');
    sReturn := replace(sReturn,'þ', '&thorn;');
    sReturn := replace(sReturn,'ÿ', '&yuml;');
    sReturn := replace(sReturn,'€ ', '&euro;');
END;
$function$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_caracteres_especiales_html(TEXT) TO public;
GRANT EXECUTE ON FUNCTION fun_caracteres_especiales_html(TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION fun_caracteres_especiales_html(TEXT) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_caracteres_especiales_html(TEXT) TO syspersonal;
COMMENT ON FUNCTION fun_caracteres_especiales_html(TEXT) IS 'La función convierte caracteres especiales en su correspondiente a secuencias HTML';