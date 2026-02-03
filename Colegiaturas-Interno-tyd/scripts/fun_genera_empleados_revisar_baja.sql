CREATE OR REPLACE FUNCTION fun_genera_empleados_revisar_baja(
IN iusuario integer, 
OUT inumemp integer, 
OUT inum integer
)
  RETURNS SETOF record AS
$BODY$
DECLARE
	valor record;
BEGIN	
-- ==================================================================================================================
-- Peticion: 16559 
-- APS : 22418
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 21-05-2019
-- Descripción General:Obtiene los empleados traspasados activos para revisar en sql si siguen activos o son baja
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: SELECT fun_genera_empleados_revisar_baja (94827443);
-- ==================================================================================================================
	CREATE TEMPORARY TABLE Datos(
		numemp integer,
		cancelado CHARACTER VARYING(1)		
	) ON COMMIT DROP;

	INSERT 	INTO Datos (numemp)
	SELECT 	DISTINCT idu_empleado
	FROM 	MOV_FACTURAS_COLEGIATURAS 
	WHERE 	opc_movimiento_traspaso = 1; 
			--and usuario = iUsuario;

	UPDATE 	Datos set cancelado=B.cancelado
	FROM	sapcatalogoempleados B
	WHERE	Datos.numemp=B.numemp::int;
	

	FOR valor IN (	SELECT 	numemp, numemp
			FROM 	Datos 
			WHERE 	cancelado!= '1' 				
			)
	LOOP
		inumemp:=valor.numemp;
		inum:=valor.numemp;		
		
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;