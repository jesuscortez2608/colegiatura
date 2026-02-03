ALTER PROCEDURE proc_enviar_incentivos_colegiaturas   
@iUsuario INT,                  
@cXml XML,  
@iConexion INT ,
@iVuelta INT                
WITH EXECUTE AS OWNER                  
AS                  
BEGIN               
 SET NOCOUNT ON   
 /*                  
 NOMBRE: OMAR LIZARRAGA  
 BD: personal SQL  
 FECHA: 25/07/2018  
 SERVIDOR: 10.44.1.135                  
 DESCRIPCION: INSERTA INCENTIVO DE COLEGIATURAS                
 MODULO: GENERAR INCENTIVOS  
 SISTEMA: COLEGIATURAS                
 EJEMPLO:                
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="95194185" i="125000"></r><r e="91729815" i="10000"></r></Root>'         
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="96874554 " i="386930"></r></Root>'         
  
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="96874554 " i="386930"></r></Root>'         
  
 select   (5692.02   - 5343.62)+    
  
 40.51 + 30.87    
  
 5,692.02    
  
  
  
 proc_enviar_incentivos_colegiaturas 93902761, '<Root><r e="95194185" i="125000"></r><r e="91729815" i="10000"></r><r e="91815381" i="68100"></r>><r e="90874897" i="25000"></r></Root>'                
  
 */    
  IF (@iVuelta=0)
		BEGIN
			DELETE FROM  stmpCargaIncentivos WHERE conexion=@iConexion;  
		END 
   
  INSERT INTO stmpCargaIncentivos(clasificacion,numemp, importeincentivo,conexion)                
  SELECT 2,e= T.Item.value('@e', 'int'), i = T.Item.value('@i', 'int'), @iConexion                
  FROM @cXml.nodes('Root/r') AS T(Item)    
   
 SET NOCOUNT OFF          
END     
------------------------------------------------------------------------------  
  