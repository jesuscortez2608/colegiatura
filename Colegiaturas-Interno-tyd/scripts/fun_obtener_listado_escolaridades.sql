CREATE OR REPLACE FUNCTION fun_obtener_listado_escolaridades(
IN id_escolaridad integer, 
OUT idu_escolaridad integer, 
OUT nom_escolaridad character varying, 
OUT opc_carrera integer, 
OUT fec_captura character varying, 
OUT idu_empleado_registro integer, 
OUT nom_empleado_registro character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	sQuery TEXT;
	valor record;	
	-- =================================================================================================
	-- Peticion:
	-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
	-- Fecha:
	-- Descripción General: Consulta el nombre de la carrera de acuerdo al id 
	-- Ruta Tortoise:
	-- Sistema: Colegiaturas
	-- Servidor Productivo: 10.44.2.183
	-- Servidor Desarrollo: 10.28.114.75
	-- Ejemplo:
	--	SELECT * FROM fun_obtener_listado_escolaridades (0)
	--	SELECT * FROM fun_obtener_listado_escolaridades (1): 
	-- =================================================================================================
	BEGIN			
		CREATE TEMP TABLE Datos (
			idu_escolaridad INTEGER DEFAULT 0,
			nom_escolaridad CHARACTER VARYING(30) DEFAULT '',
			opc_carrera INTEGER DEFAULT 0,
			fec_captura CHARACTER VARYING(10) DEFAULT '' ,
			idu_empleado_registro INTEGER DEFAULT 0, 
			nom_empleado_registro CHARACTER VARYING(150) DEFAULT ''
		)on commit drop;

		sQuery := 'INSERT INTO Datos (idu_escolaridad, nom_escolaridad, opc_carrera, fec_captura, idu_empleado_registro) 
		SELECT idu_escolaridad, nom_escolaridad, opc_carrera, to_char(fec_captura,''dd/MM/yyyy'') as fec_captura, idu_empleado_registro 
		FROM cat_escolaridades ';
						
		IF (id_escolaridad>0) THEN
			sQuery := sQuery || ' WHERE idu_escolaridad= ' || id_escolaridad;
		END IF;
		
		--raise notice '%', sQuery;
		execute sQuery;

		
		UPDATE 	Datos SET nom_empleado_registro=trim(B.nombre)||' '|| trim(B.apellidopaterno)||' ' ||trim(B.apellidomaterno)
		FROM	sapcatalogoempleados B
		WHERE	Datos.idu_empleado_registro=B.numempn;

		sQuery := ' SELECT A.idu_escolaridad, A.nom_escolaridad, A.opc_carrera, A.fec_captura, A.idu_empleado_registro, A.nom_empleado_registro FROM Datos A ORDER BY A.idu_escolaridad ';
		
		FOR valor IN EXECUTE (sQuery)
		LOOP
			idu_escolaridad:=valor.idu_escolaridad;
			nom_escolaridad:=valor.nom_escolaridad;
			opc_carrera:=valor.opc_carrera;
			fec_captura:=valor.fec_captura;
			idu_empleado_registro:=valor.idu_empleado_registro;
			nom_empleado_registro:=valor.nom_empleado_registro;
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_escolaridades(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_escolaridades(integer) IS 'La función obtiene listado de escolaridades de colegiaturas.';