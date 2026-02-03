DROP FUNCTION IF EXISTS fun_grabar_estatus_aclarar_factura(integer, integer);

CREATE OR REPLACE FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer)
  RETURNS integer AS
$BODY$
DECLARE 
	
	nFactura alias for $1;
	nEmpleadoRegistra alias for $2;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 28/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Actualiza el campo IDU_ESTATUS de la tabla MOV_FACTURAS_COLEGIATURAS e inserta un registro en la tabla MOV_BLOG_ACLARACIONES
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Aceptar / Rechazar facturas
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_estatus_aclarar_factura(1,93902761);
	 /*----------------------------------------------------
		No. Peticion:		16559.1
		Fecha:			10/09/2018
		Descripcion del cambio:	Se agrega vacio a los comentarios al mandar a aclaracion una factura
		Colaborador:		Rafael Ramos	98439677
		Sistema:		Colegiaturas.
		
	 ----------------------------------------------------*/
		 
	*/
BEGIN
	UPDATE MOV_FACTURAS_COLEGIATURAS SET IDU_ESTATUS=4, EMP_MARCO_ESTATUS= nEmpleadoRegistra, FEC_MARCO_ESTATUS=now(), des_observaciones = ''
	WHERE IDFACTURA=nFactura;
	
	
	RETURN 1;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_estatus_aclarar_factura(integer, integer) IS 'Actualiza estatus de facturas que se mandan a aclaracion.';
