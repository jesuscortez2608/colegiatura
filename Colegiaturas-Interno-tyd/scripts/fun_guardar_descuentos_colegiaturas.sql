
CREATE OR REPLACE FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer)
  RETURNS character varying AS
$BODY$
DECLARE
/*
	     No. petición APS               : 16559.1
	     Fecha                          : 20/02/2018
	     Número empleado                : 98439677
	     Nombre del empleado            : Rafael Ramos
	     Base de datos                  : personal
	     Servidor de desarrollo         : 10.28.114.75
	     Servidor de produccion         : 10.44.2.183
	     Descripción del funcionamiento : inserta registros de nuevos porcentajes en la tabla (cat_descentos_colegiaturas)
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Descuentos
	     Ejemplo                        : 
		 SELECT * FROM fun_guardar_descuentos_colegiaturas(50,'50',98439677);

		 SELECT * FROM cat_descuentos_colegiaturas	
*/
	idu_descuento	ALIAS FOR $1;
	cDescuento	ALIAS FOR $2;
	idu_usuario	ALIAS FOR $3;
	msg varchar(100);
BEGIN
	IF EXISTS (SELECT prc_descuento FROM cat_descuentos_colegiaturas WHERE prc_descuento=idu_descuento) THEN
		msg:='El porcentaje ya existe';
	ELSE
		INSERT INTO cat_descuentos_colegiaturas (prc_descuento,des_descuento,emp_registro,fec_registro)
		VALUES (idu_descuento, cDescuento||'%', idu_usuario, now());
		msg:='Porcentaje guardado';
	END IF;
	RETURN msg as msg;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_guardar_descuentos_colegiaturas(integer, character varying, integer) IS 'La función graba un descuento nuevo para poder seleccionarlo en la configuración de descuentos.';
