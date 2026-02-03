DROP FUNCTION IF EXISTS fun_obtener_incentivos_admin();

CREATE OR REPLACE FUNCTION fun_obtener_incentivos_admin(
OUT numemp integer, 
OUT importe numeric(12,2), 
OUT isr numeric(12,2), 
OUT total numeric(12,2))
  RETURNS SETOF record AS
$BODY$
DECLARE
-- ===================================================
-- Peticion: 18292
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 19/12/2017
-- Descripción General: Función para exportar excel incentivos de Colegiaturas_33
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/personal/elp/colegiaturas_33/scripts
-- Sistema: Colegiaturas_33
-- Servidor Productivo: 10.44.2.29
-- Servidor Desarrollo: 10.44.15.182
-- Ejemplo: 
--	SELECT * FROM fun_obtener_incentivos_admin()

-- ===================================================
	--DECLARACION DE VARIABLES		
	sQuery TEXT;	
	valor record;

BEGIN

	CREATE TEMPORARY TABLE tmp_incentivos(		
		num_empleado INTEGER,		
		imp_factura NUMERIC(12,2), 
		imp_isr NUMERIC(12,2), 
		total NUMERIC(12,2)
	)ON COMMIT DROP;

	INSERT 	INTO tmp_incentivos(num_empleado, imp_factura, imp_isr, total)	
	SELECT 	num_empleado, imp_factura/100.00, imp_isr/100.00, (imp_factura+imp_isr )/100.00
	FROM 	MOV_GENERACIONPAGOCOLEGIATURAS 
	ORDER 	BY num_empleado ASC;	
	
	FOR valor IN SELECT a.num_empleado, a.imp_factura, a.imp_isr, a.total FROM tmp_incentivos a ORDER BY a.num_empleado ASC
	LOOP		
		numemp:=valor.num_empleado;		
		importe:=valor.imp_factura;
		isr:=valor.imp_isr;
		total:=	valor.total;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_incentivos_admin() TO sysgenexus;
GRANT EXECUTE ON FUNCTION fun_obtener_incentivos_admin() TO sysmesaayuda;
GRANT EXECUTE ON FUNCTION fun_obtener_incentivos_admin() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_incentivos_admin() TO postgres;
COMMENT ON FUNCTION fun_obtener_incentivos_admin() IS 'La función obtiene los incentivos del sistema anterior';