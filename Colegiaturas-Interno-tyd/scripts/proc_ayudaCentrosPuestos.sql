CREATE PROCEDURE proc_ayudaCentrosPuestos  @iOpcion INT, @Nombre VARCHAR(30)  
AS  
SET NOCOUNT ON    
BEGIN   
 /*    
  NOMBRE: Nallely Machado  
  BD: Personal SQL    
  FECHA: 23/09/2016    
  SERVIDOR PRUEBAS: 10.44.1.135    
  DESCRIPCION: Consulta el numero y nombre de centro o puesto donde el nombre coincida con el nombre que se envia y consulta los puetsos de un centro  
  PROYECTO: COLEGIATURAS  
  EJEMPLOS  
 proc_ayudaCentrosPuestos 1,'sis'  
 proc_ayudaCentrosPuestos 2,'sis'  
 proc_ayudaCentrosPuestos 3,'230140'  
 */   
   
 if @iOpcion=1 --Puestos  
 begin  
  SELECT CONVERT(int,NUMERO) AS numero, NOMBRE AS nombre FROM SAPCATALOGOPUESTOS WHERE Nombre like '%'+@Nombre+'%'  
    
 end  
 else if @iOpcion=2 --Centros  
 begin  
  SELECT centron AS numero, NombreCentro AS nombre FROM sapCatalogoCentros WHERE NombreCentro like '%'+@Nombre+'%'  
 end  
 else --Regresa los puestos de un centro  
 begin  
   SELECT  distinct CONVERT(int,P.NUMERO) AS numero,P.NOMBRE AS nombre FROM sapCatalogoEmpleados E   
   INNER JOIN SAPCATALOGOPUESTOS P ON E.PUESTON=CONVERT(int,P.NUMERO)  
   WHERE E.CENTRON=CONVERT(int,@Nombre) ORDER BY CONVERT(int,P.NUMERO) ASC  
 end  
END    
SET NOCOUNT OFF    
  