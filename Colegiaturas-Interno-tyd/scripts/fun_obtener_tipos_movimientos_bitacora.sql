DROP FUNCTION IF EXISTS fun_obtener_tipos_movimientos_bitacora();
DROP TYPE IF EXISTS type_obtener_tipos_movimientos_bitacora;


CREATE TYPE type_obtener_tipos_movimientos_bitacora AS
   (idu_tipo_movimiento integer,
    nom_tipo_movimiento character varying(40),
    fec_registro timestamp without time zone,
    idu_empleado_registro integer);

CREATE OR REPLACE FUNCTION fun_obtener_tipos_movimientos_bitacora()
  RETURNS SETOF type_obtener_tipos_movimientos_bitacora AS
$BODY$
/*
	No. petición APS               : 8613.1
	Fecha                          : 26/12/2016
	Número empleado                : 97695068
	Nombre del empleado            : Hector Medina Escareño
	Base de datos                  : Personal
	Descripción del funcionamiento : Trae todos los tipos de movimientos de la bitacora.
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Bitácora de Movimientos de Colegiaturas.
	Ejemplo                        : 
					 SELECT * FROM fun_obtener_tipos_movimientos_bitacora();

		//=== TABLAS INVOLUCRADAS ===//
		SELECT * FROM cat_tipos_movimientos_bitacora;
	====================================================================================================================================
	No.Peticion:			16559.1
	Fecha:				15/08/2018
	Colaborador:			98439677 Rafael Ramos
	Descripcion del cambio:		Se muestan solo los disponibles en el sistema de Colegiaturas
*/
DECLARE
	resultado type_obtener_tipos_movimientos_bitacora;
BEGIN
	CREATE TEMPORARY TABLE tmp_tipos_movimientos_bitacora(
		idu_tipo_movimiento integer,
		nom_tipo_movimiento character varying(40),
		fec_registro timestamp without time zone,
		idu_empleado_registro integer
	)ON COMMIT DROP;

	INSERT INTO tmp_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro)
	SELECT 	t.idu_tipo_movimiento, t.nom_tipo_movimiento, t.fec_registro, t.idu_empleado_registro
	FROM 	cat_tipos_movimientos_bitacora t
	where	t.idu_tipo_movimiento in(1,2,4,5,7);

	FOR resultado IN
		SELECT idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro
		FROM tmp_tipos_movimientos_bitacora
		ORDER BY idu_tipo_movimiento
	LOOP
		RETURN NEXT resultado;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_tipos_movimientos_bitacora() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_movimientos_bitacora() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_movimientos_bitacora() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_tipos_movimientos_bitacora() TO postgres;
COMMENT ON FUNCTION fun_obtener_tipos_movimientos_bitacora() IS 'La función obtiene un listado con los diferentes tipos de movimiento de la bitácora.';  