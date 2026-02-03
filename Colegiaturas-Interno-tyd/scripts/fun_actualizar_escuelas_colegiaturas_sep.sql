CREATE OR REPLACE FUNCTION fun_actualizar_escuelas_colegiaturas_sep(INTEGER, VARCHAR(20))
  RETURNS integer AS
$BODY$
DECLARE
	nEscuela alias for $1;
	cRfc alias for $2;
	/*
	No. petición APS               : 8613.1
	Fecha                          : 21/03/2017
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : Actualiza el rfc de escuelas privadas sin rfc
	Descripción del cambio         : 
	Sistema                        : Colegiaturas
	Módulo                         : Subir factura escuela privadas
	Ejemplo                        : select * from fun_actualizar_escuelas_colegiaturas_sep ('1223');
		
	------------------------------------------------------------------------------------------------------ */
BEGIN
	UPDATE CAT_ESCUELAS_COLEGIATURAS SET RFC_CLAVE_SEP=cRfc where  idu_escuela=nEscuela;
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;