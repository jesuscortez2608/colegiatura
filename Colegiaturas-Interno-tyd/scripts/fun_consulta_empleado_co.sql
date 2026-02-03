CREATE OR REPLACE FUNCTION fun_consulta_empleado_co(integer)
  RETURNS SETOF type_consulta_empleado AS
$BODY$
  DECLARE
	iEmpleado	ALIAS FOR $1;
	registros type_consulta_empleado;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 07/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Consulta el nombre, numero de centro, nombre centro, numero y nombre de puesto de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Ejemplo                        : 
		 SELECT * FROM fun_consulta_empleado_co(93902761);	
		
		 
	*/
	begin
		CREATE TEMPORARY TABLE tmp_ConsultaxEmpleado(
			idu_empleado INTEGER, 
			nom_empleado VARCHAR(150), 
			idu_centro INTEGER, 
			nom_centro VARCHAR(50),
			idu_puesto INTEGER, 
			nom_puesto VARCHAR(50),
			fec_ingreso VARCHAR(10),
			cancelado char(1)
		)on commit drop;
		
		INSERT INTO tmp_ConsultaxEmpleado (idu_empleado, nom_empleado,idu_centro ,idu_puesto, fec_ingreso, cancelado)
		SELECT numempn, TRIM(nombre)||' '||TRIM(apellidopaterno)||' '||TRIM(apellidomaterno), centron, pueston, to_char(fechaalta,'dd/MM/yyyy'), cancelado
		FROM sapcatalogoempleados WHERE numempn= iEmpleado;

		UPDATE tmp_ConsultaxEmpleado SET nom_centro=TRIM(a.nombrecentro) FROM sapcatalogocentros a WHERE tmp_ConsultaxEmpleado.idu_centro=a.centron;

		UPDATE tmp_ConsultaxEmpleado SET nom_puesto=TRIM(a.nombre) FROM sapcatalogopuestos a WHERE tmp_ConsultaxEmpleado.idu_puesto=a.numero::INTEGER;

		FOR registros IN 
			SELECT idu_empleado, nom_empleado, idu_centro, nom_centro, idu_puesto, nom_puesto,fec_ingreso, cancelado FROM tmp_ConsultaxEmpleado
		LOOP
			RETURN NEXT registros;
		END LOOP;
		
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consulta_empleado_co(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consulta_empleado_co(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consulta_empleado_co(integer) TO sysetl;