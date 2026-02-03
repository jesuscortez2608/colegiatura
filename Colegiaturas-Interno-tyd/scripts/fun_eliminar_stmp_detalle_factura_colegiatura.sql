CREATE OR REPLACE FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer)
  RETURNS smallint AS
$BODY$
   DECLARE
        iEmpleado	ALIAS FOR $1;
        iKeyx    	ALIAS FOR $2;
        iResultado smallint;
         /*
	     No. petición APS               : 8613.1
	     Fecha                          : 12/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Elimina un beneficiario de la tabla temporal stmp_detalle_facturas_colegiaturas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 
		 SELECT * FROM fun_eliminar_stmp_detalle_factura_colegiatura(93902761,1); 
		 
	*/
BEGIN
	IF iKeyx>0 then 		
		DELETE FROM stmp_detalle_facturas_colegiaturas WHERE idu_empleado=iEmpleado and keyx=iKeyx;
	else 
		--DELETE FROM stmp_facturas_colegiaturas WHERE idu_empleado=iEmpleado;
		DELETE FROM stmp_detalle_facturas_colegiaturas WHERE idu_empleado=iEmpleado;
	end if;
	iResultado:=1;
	return iResultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_stmp_detalle_factura_colegiatura(integer, integer) IS 'La función elimina factura de tabla temporal fija de detalle.';