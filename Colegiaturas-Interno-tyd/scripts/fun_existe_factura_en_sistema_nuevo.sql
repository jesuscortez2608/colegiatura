CREATE OR REPLACE FUNCTION fun_existe_factura_en_sistema_nuevo(
IN srfc_empresa character varying, 
IN sidu_foliofiscal character varying, 
OUT iestatus integer, 
OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
-- ===================================================
-- Peticion: 18292
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 19/12/2017
-- Descripción General: Función para exportar excel incentivos de Colegiaturas_33
-- Ruta Tortoise: 
-- Sistema: Colegiaturas_33
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.27.114.75
-- Ejemplo: 
--	SELECT * FROM fun_exportar_excel_incentivos_colegiaturas(1)
--  	SELECT * FROM fun_exportar_excel_incentivos_colegiaturas(0)
-- DROP TABLE tmp_incentivos
-- ===================================================
	--DECLARACION DE VARIABLES		
	existe integer;	
	valor record;
BEGIN	

	CREATE TEMPORARY TABLE tmp_Regresa(		
		estado integer,
		msg character varying	
	)ON COMMIT DROP;

	if (exists (select idu_foliofiscal from CTL_FACTURAS_EMPLEADOS where nom_rfc_empresa=srfc_empresa and idu_foliofiscal=sidu_foliofiscal )) then
		existe:=1;
	else
		existe:=0;
	end if;	
	

	insert 	into tmp_Regresa (estado, msg)
	select 	existe, (case when existe=1 then 'se subió la factura con el sistema anterior y ya se inició el proceso' else 'no se ha subido' end);	
	
	FOR valor IN (SELECT estado, msg FROM tmp_Regresa)
	LOOP		
		iEstatus:=valor.estado;		
		sMensaje:=valor.msg;		
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_nuevo(character varying, character varying)  TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_nuevo(character varying, character varying)  TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_nuevo(character varying, character varying)  TO sysetl;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_nuevo(character varying, character varying)  TO postgres;
COMMENT ON FUNCTION fun_existe_factura_en_sistema_nuevo(character varying, character varying)  IS 'La función valida si existe la factura en el sistema nuevo';