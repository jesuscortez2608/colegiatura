CREATE OR REPLACE FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE
	iEmpleado 		alias for $1;
	iBeneficiario 	alias for $2;
	iEscuela 		alias for $3;
	iEscolaridad 	alias for $4;

	resultado int;
  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 19/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Elimina una estudio de un beneficiario
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Empleados con Colegiatuta
	     Ejemplo                        :
		 SELECT * FROM fun_eliminar_estudio_beneficiario(93902761,1,1,2,3,93902761);
		 SELECT * FROM fun_grabar_beneficiario_escuela_escolaridad(93902761,1,6,4,1,93902761);
	*/
BEGIN

	DELETE FROM cat_estudios_beneficiarios where idu_empleado=iEmpleado and idu_beneficiario=iBeneficiario
	and idu_escuela=iEscuela and idu_escolaridad=iEscolaridad;

		resultado:=1;

	RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_estudio_beneficiario(integer, integer, integer, integer) IS 'Borra el estudio de un beneficiario de la tabla: cat_estudios_beneficiarios';