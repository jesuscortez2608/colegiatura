DROP FUNCTION IF EXISTS fun_obtenerfacturaele(integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtenerfacturaele(IN iidfactura integer, IN inicio integer, IN final integer, OUT sxml text, OUT tamanio integer)
  RETURNS record AS
$BODY$
	DECLARE
	/** --------------------------------------------------------------------------------     
	No.Petición: 16559.1
	Fecha: 06/09/2018
	Numero Empleado: 98439677
	Nombre Empleado: RAFAEL RAMOS GUTIERREZ
	BD: Personal    
	Servidor: 
	Modulo: Colegiaturas
	Repositorio:
	Ejemplo:
			SELECT * FROM fun_obtenerFacturaEle('FD45R-R15G5-R15T5E-R165E58R',0,4000)

			mov_facturas_colegiaturas where fol_fiscal = 'FD45R-R15G5-R15T5E-R165E58R'
	--------------------------------------------------------------------------------*/
	BEGIN
		if exists (SELECT mov.fol_fiscal from mov_facturas_colegiaturas as mov where mov.idfactura = iidfactura) then
			if inicio = 0 then inicio := 1; end if;
			SELECT xml_factura FROM mov_facturas_colegiaturas WHERE idfactura = iidfactura INTO sXml;
			IF sXml IS NULL THEN
				sXml := '-1';
				tamanio := char_length(sXml);
			else
				tamanio := char_length(sXml);
				sXml := substring(sXml from inicio for final);
			END IF;
		elsif exists (select his.fol_fiscal from his_facturas_colegiaturas as his where his.idfactura = iidfactura) then
			if inicio = 0 then inicio := 1; end if;
			select xml_factura from his_facturas_colegiaturas where idfactura = iidfactura into sXml;
			if sXml is null then
				sXml := '-1';
				tamanio := char_length(sXml);
			else
				tamanio := char_length(sXml);
				sXml := substring(sXml from inicio for final);
			end if;
		end if;
		
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtenerfacturaele(integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtenerfacturaele(integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtenerfacturaele(integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtenerfacturaele(integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtenerfacturaele(integer, integer, integer) IS 'La funcion obtiene el xml de la factura.';  