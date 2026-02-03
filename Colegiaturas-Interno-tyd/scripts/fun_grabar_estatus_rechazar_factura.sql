CREATE OR REPLACE FUNCTION fun_grabar_estatus_rechazar_factura(integer, integer, integer, integer, text)
  RETURNS integer AS
$BODY$
DECLARE 
	
	nFactura alias for $1;
	nRechazo alias for $2;
	nDeduccion alias for $3;
	nEmpleadoRegistro alias for $4;
	cComentario alias for $5;
	
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 28/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : actualiza el estatus de la factura (IDU_ESTATUS) de la tabla MOV_FACTURAS_COLEGIATURAS
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Aceptar / Rechazar Facturas
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_estatus_rechazar_factura(1,1,93902761); 
		 select * from MOV_FACTURAS_COLEGIATURAS
	*/
BEGIN
	UPDATE MOV_FACTURAS_COLEGIATURAS SET IDU_ESTATUS=3, EMP_MARCO_ESTATUS= nEmpleadoRegistro, FEC_MARCO_ESTATUS=now(),IDU_MOTIVO_RECHAZO=nRechazo,idu_tipo_deduccion=nDeduccion, des_observaciones=trim(cComentario)
	WHERE IDFACTURA=nFactura;

	RETURN 1;
END; 
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_estatus_rechazar_factura(integer, integer, integer, integer, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_rechazar_factura(integer, integer, integer, integer, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_rechazar_factura(integer, integer, integer, integer, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_rechazar_factura(integer, integer, integer, integer, text) TO postgres;