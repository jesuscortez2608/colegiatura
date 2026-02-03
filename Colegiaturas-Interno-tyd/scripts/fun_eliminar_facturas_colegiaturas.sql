CREATE OR REPLACE FUNCTION fun_eliminar_facturas_colegiaturas(integer, integer)
  RETURNS SETOF type_eliminar_facturas_colegiaturas AS
$BODY$
DECLARE    

	iOpcion ALIAS FOR $1;
	iFactura ALIAS FOR $2;
	registro type_eliminar_facturas_colegiaturas;
	crfc varchar(20) default '';
	cserie varchar(20) default '';
	cfol_fiscal varchar(100) default '';
/*    
		No. peticiÃ³n APS               : 8613.1
		Fecha                          : 18/10/2016
		NÃºmero empleado                : 93902761
		Nombre del empleado            : Nallely Machado
		Base de datos                  : administracion
		Servidor de pruebas            : 10.44.15.182
		Servidor de produccion         : 10.44.2.29
		DescripciÃ³n del funcionamiento : Borra las tabla de colegiaturas una factura cargada con error
		DescripciÃ³n del cambio         : NA
		Sistema                        : Colegiaturas
		MÃ³dulo                         : Subir Factura
		Ejemplo                        : 
		 SELECT * FROM fun_eliminar_facturas_colegiaturas(1,8);	
		 select * from mov_facturas_colegiaturas
		*/

	

BEGIN
	IF (iOpcion=1) then ---BORRAR TEMPORALES
		DELETE FROM stmp_facturas_colegiaturas where idfactura=iFactura;
		DELETE FROM stmp_detalle_facturas_colegiaturas where idfactura=iFactura;
	ELSE -- BORRAR FACTURA
		
		cserie:= serie from mov_facturas_colegiaturas where idfactura=iFactura;
		crfc:= rfc_clave from mov_facturas_colegiaturas where idfactura=iFactura;
		cfol_fiscal:=fol_fiscal from mov_facturas_colegiaturas where idfactura=iFactura;

		DELETE FROM mov_facturas_colegiaturas where idfactura=iFactura;
		DELETE FROM mov_detalle_facturas_colegiaturas where idfactura=iFactura;
		DELETE FROM CTL_IMPORTES_FACTURAS_MES where idfactura=iFactura;
		
	END IF;

	FOR registro IN SELECT crfc, cserie, cfol_fiscal 
	LOOP
		RETURN NEXT registro;
	END LOOP;
	RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER ;
GRANT EXECUTE ON FUNCTION fun_eliminar_facturas_colegiaturas(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION fun_eliminar_facturas_colegiaturas(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_facturas_colegiaturas(integer, integer) TO syspersonal;
COMMENT ON FUNCTION fun_eliminar_facturas_colegiaturas(integer, integer) IS 'La función elimina la factura .';