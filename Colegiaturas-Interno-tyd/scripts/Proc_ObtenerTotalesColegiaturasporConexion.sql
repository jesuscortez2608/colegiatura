CREATE PROCEDURE Proc_ObtenerTotalesColegiaturasporConexion
@iConexion INT                                                                            
AS                                                                                                                                                   
SET NOCOUNT ON   
  BEGIN
	-- ====================================================================================================
	-- Peticion: 16559
	-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
	-- Fecha: 09-08-2018
	-- Descripción General: Obtiene la suma de los importes de incentivos de colegiaturas
	-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
	-- Sistema: Colegiaturas
	-- Servidor Productivo: 10.44.1.13
	-- Servidor Desarrollo: 10.44.1.135
	-- Ejemplo: PROC_OBTENER_INCENTIVO_DESARROLLO()
	-- ====================================================================================================
		SELECT 	SUM(importeincentivo) as totalimporte  
		FROM 	stmpCargaIncentivos   
		WHERE 	conexion=@iConexion and numemp>0;                                                                                                                                      
    END                                                                                                            
SET NOCOUNT OFF    