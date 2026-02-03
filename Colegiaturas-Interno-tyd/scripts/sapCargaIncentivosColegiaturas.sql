CREATE PROCEDURE [dbo].[sapCargaIncentivosColegiaturas]  
@iConexion INT,     
@nTipoIncentivo INT                                                                              
AS                                                                                                                                                   
SET NOCOUNT ON                                                                                                                                       
	UPDATE	stmpCargaIncentivos     
			SET nombre = RIGHT(LTRIM(RTRIM(b.ApellidoPaterno)) + ' ' + LTRIM(RTRIM(b.ApellidoMaterno)) + ' ' + LTRIM(RTRIM(b.Nombre)), 50),    
			centro = b.centron,tipo = (CASE WHEN b.cancelado <> 1 THEN 0 ELSE 1 END),empresa = b.empresa    
	FROM	stmpCargaIncentivos a ( NOLOCK )     
	JOIN	sapcatalogoempleados b ( NOLOCK )     
			ON a.numemp = CONVERT( INT,b.numemp )    
	WHERE	 a.conexion = @iConexion     
                                                                                                                                          
	UPDATE	stmpCargaIncentivos SET nombre = RIGHT(LTRIM(RTRIM(b.appat)) + ' ' + LTRIM(RTRIM(b.apmat)) + ' ' + LTRIM(RTRIM(b.nombre)),50),    
			centro = b.centro     
	FROM	stmpCargaIncentivos a ( NOLOCK )     
	JOIN	sn_altasycorrec_quincena b ( NOLOCK ) ON a.numemp = CONVERT(INT,b.numemp )     
	WHERE	b.movimiento = 20 
			AND fecha_alta != '19000101'     
			AND a.conexion = @iConexion   
                                                                                                                                          
	UPDATE	stmpCargaIncentivos     
			SET tipo = (CASE WHEN numemp IN (
				SELECT	x.numemp 
				FROM	sn_incentivos_quincena x ( NOLOCK ) 
				WHERE	x.TIpo = @nTipoIncentivo AND CONVERT (INT, STATUS) = 0) THEN 2  ELSE b.tipo END)     
	FROM	stmpCargaIncentivos b                                                                                                                          
	WHERE	tipo = 0                                                                                                                                      
			AND b.conexion = @iConexion    
                                                                                                                                                      
	INSERT INTO stmpCargaIncentivos(clasificacion,tipo,descripcion,conexion)                                                                            
	SELECT	1,b.tipo,(CASE                                                                                                                               
			WHEN b.tipo = 0 THEN ' EMPLEADOS ACTIVOS'                                                                                                          
			WHEN b.tipo = 1 THEN ' EMPLEADOS CANCELADOS'                                                                                                       
			WHEN b.tipo = 2 THEN ' EMPLEADOS C/INCENTIVO'                                                                                                      
			WHEN b.tipo = 4 THEN ' EMPLEADOS NO ENCONTRADOS'                                                                                                   
			END) , @iConexion                                                                                                                                   
	FROM	stmpCargaIncentivos b                                                                                                                          
	WHERE	b.conexion = @iConexion                                                                                                         
	GROUP	by b.tipo                                                                                                                                     
                                               
	INSERT 	INTO stmpCargaIncentivos (clasificacion,numemp,tipo, descripcion, nombre, importeincentivo, conexion )                                       
	SELECT 	3,0, tipo, ' ' AS descripcion, 'TOTAL' AS Nombre, ISNULL(SUM(importeincentivo),0) AS importeincentivo, @iConexion     
	FROM 	stmpCargaIncentivos (NOLOCK)                                                                                                                            
	WHERE  	conexion = @iConexion                                                                                                                         
	GROUP  	BY tipo                                                                                                                                       
																																					  
	INSERT	INTO stmpCargaIncentivos(tipo, clasificacion, nombre, importeincentivo,conexion)    
	SELECT	5,4,'TOTAL GENERAL' , ISNULL(SUM(importeincentivo),0), @iConexion    
	FROM	stmpCargaIncentivos (NOLOCK)    
	WHERE	clasificacion = 3 AND conexion = @iConexion       
																																					  
	SELECT 	descripcion, nombre, importeincentivo, clasificacion, tipo, numemp                                                                                   
	FROM  	stmpCargaIncentivos  (NOLOCK)                                                                                                                          
	WHERE  	conexion =  @iConexion                                                                                                                        
	ORDER  	BY tipo,clasificacion,numemp                                                                                                                  
SET NOCOUNT OFF;   