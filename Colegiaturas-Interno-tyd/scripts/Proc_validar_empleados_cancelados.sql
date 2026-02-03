CREATE PROCEDURE Proc_validar_empleados_cancelados      
@iVuelta INT,                  
@cXml XML,    
@iConexion INT                
WITH EXECUTE AS OWNER                  
AS                  
BEGIN               
	SET NOCOUNT ON      
 -- ==================================================================================================================
-- Peticion: 16559 
-- APS : 22418
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 21-05-2019
-- Descripción General:Obtiene los empleados traspasados activos para revisar en sql si siguen activos o son baja
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.1.13
-- Servidor Desarrollo: 10.44.1.135
-- Ejemplo: Proc_validar_empleados_cancelados 1,'<Root><r a="94827443"></r><r a="95194185"></r></Root>',94827443
-- ==================================================================================================================       
   
	IF (@iVuelta=0)      
		BEGIN      
			DELETE FROM stmp_empleados_cancelados WHERE conexion=@iConexion;        
		END     
				 
	INSERT 	INTO stmp_empleados_cancelados (numemp,conexion)      
	SELECT 	a= T.Item.value('@a', 'int'),@iConexion      
	FROM 	@cXml.nodes('Root/r') AS T(Item);      
	   
	UPDATE 	stmp_empleados_cancelados set cancelado=B.Cancelado      
	FROM 	hecatalogoempleados B      
	WHERE 	stmp_empleados_cancelados.numemp=B.numemp    
			and conexion=@iConexion;         
	   
	SELECT 	numemp, conexion   
	FROM 	stmp_empleados_cancelados   
	WHERE 	conexion=@iConexion and cancelado='1';       
	   
	SET NOCOUNT OFF          
END