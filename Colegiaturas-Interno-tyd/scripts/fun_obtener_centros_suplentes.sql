CREATE OR REPLACE FUNCTION fun_obtener_centros_suplentes(integer)
  RETURNS SETOF type_obtener_centros_suplentes AS
$BODY$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT idu_centro
		FROM fun_obtener_centros_suplentes(93902761::INTEGER)

		SELECT idu_centro from fun_obtener_centros_suplentes(98439677::INTEGER)

		select * from fun_obtener_centros_suplentes(96777915)

SELECT idu_empleado
			, idu_suplente, *
		FROM mov_suplentes_colegiaturas
		WHERE idu_suplente = 96799251--96777915
			AND (opc_indefinido = 1 OR cast(now() as date) between cast(fec_registro as date)  and cast(fec_inicial as date) );

			96799251
	
		
	------------------------------------------------------------------------------------------------------ */
	iUsuario alias for $1;
	dFecha timestamp without time zone;
	returnrec type_obtener_centros_suplentes;
BEGIN
	dFecha := now();
	
	CREATE TEMPORARY TABLE tmp_centros_suplentes(
	idu_empleado INTEGER,
	idu_suplente INTEGER,
	idu_centro INTEGER) on commit drop;

	INSERT 	INTO tmp_centros_suplentes(idu_empleado, idu_suplente)
	SELECT 	idu_empleado
			, idu_suplente
	FROM 	mov_suplentes_colegiaturas
	WHERE 	idu_suplente = iUsuario
			AND (opc_indefinido = 1 OR cast(now() as date) between cast(fec_inicial as date)  and cast(fec_final as date) );

	/*INSERT 	INTO tmp_centros_suplentes(idu_empleado, idu_suplente)
	VALUES 	(iUsuario, iUsuario);*/

	UPDATE 	tmp_centros_suplentes SET idu_centro = sapcatalogoempleados.centron
	FROM 	sapcatalogoempleados
	WHERE 	sapcatalogoempleados.numempn = tmp_centros_suplentes.idu_empleado;
	
	insert 	into tmp_centros_suplentes(idu_empleado, idu_suplente, idu_centro)
	select	iUsuario, iUsuario, centron
	from	sapcatalogocentros
	where	numerogerenten = iUsuario; 

	FOR returnrec IN (SELECT DISTINCT idu_centro FROM tmp_centros_suplentes) LOOP
	RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;