CREATE OR REPLACE FUNCTION fun_grabar_estatus_revision_factura(integer, integer, integer, text)
  RETURNS integer AS
$BODY$
declare

	id_factura		ALIAS FOR $1;
	nFolioDeduccion		ALIAS FOR $2;
	nEmpleadoRegistro	ALIAS for $3;
	cObservaciones		ALIAS FOR $4;

	/*
		No. peticion APS		: 16559.1
		Fecha				: 12/03/2018
		Numero empleado			: 98439677
		Nombre del empleado            	: Rafael Ramos
		Base de datos                  	: personal
		Servidor de desarrollo         	: 10.44.15.182
		Descripción del funcionamiento 	: actualiza el estatus de la factura (IDU_ESTATUS) de la tabla MOV_FACTURAS_COLEGIATURAS
		Descripción del cambio         	: NA
		Sistema                        	: Colegiaturas
		Módulo                         	: Aceptar / Rechazar Facturas
		Ejemplo                        	: 
	*/
begin

	update	MOV_FACTURAS_COLEGIATURAS
	SET	IDU_ESTATUS = 5,
		EMP_MARCO_ESTATUS = nEmpleadoRegistro,
		idu_tipo_deduccion = nFolioDeduccion,
		FEC_MARCO_ESTATUS = now(),
		des_observaciones = trim(cObservaciones)
	where	IDFACTURA = id_factura;

	return 1;
end
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revision_factura(integer, integer, integer, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revision_factura(integer, integer, integer, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revision_factura(integer, integer, integer, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revision_factura(integer, integer, integer, text) TO postgres;