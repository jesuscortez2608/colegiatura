CREATE OR REPLACE FUNCTION fun_existe_factura_en_sistema_anterior(
IN iempleado integer, 
IN sfoliofiscal character varying, 
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
-- Servidor Productivo: 10.44.2.29
-- Servidor Desarrollo: 10.44.15.182
-- Ejemplo: 
-- SELECT * FROM fun_existe_factura_en_sistema_anterior (94827443, 'FOLIOFACTURA')

-- ===================================================
	--DECLARACION DE VARIABLES		
	existe integer;	
	valor record;
BEGIN	

	CREATE TEMPORARY TABLE tmp_Regresa(		
		estado integer,
		msg character varying	
	)ON COMMIT DROP;

	if (exists (select idu_empleadofactura from MOV_FACTURASCOLEGIATURAS_ELP where idu_empleadofactura=iEmpleado and fol_factura=sFolioFiscal)) then
		existe:=1;
	elsif (exists (select idu_empleadofactura from MOV_FACTURASCOLEGIATURAS where idu_empleadofactura=iEmpleado and fol_factura=sFolioFiscal)) then
		existe:=1;
	elsif (exists (select idu_hisempleadofactura from HIS_FACTURASCOLEGIATURAS where idu_hisempleadofactura=iEmpleado and num_hisfoliofactura=sFolioFiscal)) then
		existe:=1;
	else 
		existe:=0;
	end if;	
	

	insert 	into tmp_Regresa (estado, msg)
	select 	existe, (case when existe=1 then 'La factura ya ha sido subida en el sistema anterior' else 'no se ha subido' end);	
	
	FOR valor IN (SELECT estado, msg FROM tmp_Regresa)
	LOOP		
		iEstatus:=valor.estado;		
		sMensaje:=valor.msg;		
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;  

GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_anterior(integer, character varying) TO sysgenexus;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_anterior(integer, character varying) TO sysmesaayuda;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_anterior(integer, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_existe_factura_en_sistema_anterior(integer, character varying) TO postgres;
COMMENT ON FUNCTION fun_existe_factura_en_sistema_anterior(integer, character varying  ) IS 'La función valida si existe la factura en el sistema anterior';