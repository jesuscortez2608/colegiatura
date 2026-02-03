 DROP FUNCTION if exists fun_total_facturas_pendientes_aturizar(integer, character varying);
 drop type if exists type_costospendientes;

CREATE TYPE type_costospendientes AS
   (total integer,
    numemp integer,
    empleado character varying(200));

CREATE OR REPLACE FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying)
  RETURNS SETOF type_costospendientes AS
$BODY$
   DECLARE

	iOpcion alias for $1;
        sListadoCentros alias for $2;
	sQuery VARCHAR(3000);
	registros type_costospendientes;
        iTotal integer;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 24/04/2017
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : Regresa los beneficiarios de la hoja azul de un empleado que contengan el apellido del empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 
		 SELECT * FROM fun_total_facturas_pendientes_aturizar(1,'230140,230297,230468'::VARCHAR);  
		 select * from fun_total_facturas_pendientes_aturizar(2,'230399,230468'::VARCHAR)

		  select idu_empleado, * FROM mov_facturas_colegiaturas WHERE idu_estatus=0 and idu_empleado in (select idu_empleado from tmp_empleados_colegiaturas
	*/
	
BEGIN
	CREATE TEMPORARY TABLE tmp_empleados_colegiaturas (
		idu_centro INTEGER,
		idu_empleado INTEGER
	)on commit drop;

	CREATE TEMPORARY TABLE tmp_empleados_pendientes (
		idu_total INTEGER,
		idu_empleado INTEGER,
		nom_empleado varchar(200)
	)on commit drop;

	
	sQuery := 'INSERT INTO tmp_empleados_colegiaturas(idu_centro, idu_empleado)
		SELECT centron, numempn FROM sapcatalogoempleados
		WHERE centron IN (' || sListadoCentros || ' ) AND cancelado != ''1'' ';
	raise notice '%',sQuery;
	
	EXECUTE sQuery;
	
	if iOpcion=1 then 
		INSERT INTO tmp_empleados_pendientes(idu_total, idu_empleado)
		select count(idu_empleado),idu_empleado FROM mov_facturas_colegiaturas WHERE idu_estatus=0 and idu_beneficiario_externo = 0 and idu_tipo_documento in (1,3) and idu_empleado in (select idu_empleado from tmp_empleados_colegiaturas)
		GROUP BY idu_empleado;
	else
		INSERT INTO tmp_empleados_pendientes(idu_total, idu_empleado)
		select count(idu_empleado),idu_empleado FROM mov_configuracion_costos WHERE  idu_empleado in (select idu_empleado from tmp_empleados_colegiaturas)
		GROUP BY idu_empleado;
	end if;	
	update  tmp_empleados_pendientes set nom_empleado=rtrim(a.nombre)||' '||rtrim(a.apellidopaterno)||' '||rtrim(a.apellidomaterno) from sapcatalogoempleados a where tmp_empleados_pendientes.idu_empleado=a.numempn;

	FOR registros IN 
		SELECT 	idu_total, idu_empleado, nom_empleado
		FROM 	tmp_empleados_pendientes 
		ORDER 	by nom_empleado
	LOOP
		RETURN NEXT registros;
	END LOOP;
	RETURN;	
END

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying) TO postgres;
COMMENT ON FUNCTION fun_total_facturas_pendientes_aturizar(integer, character varying) IS 'La función muestra la cantidad de facturas o mvtos pendientes en el sistema de colegiaturas.';  