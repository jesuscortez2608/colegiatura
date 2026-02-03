
ALTER PROCEDURE [dbo].[proc_obtener_datos_colaborador_colegiaturas] @iNumEmp INT  
AS            
SET NOCOUNT ON              
BEGIN             
 /*              
  NOMBRE: Nallely Machado            
  BD: Personal SQL              
  FECHA: 14/09/2016              
  SERVIDOR PRUEBAS: 10.44.1.135              
  DESCRIPCION: Consulta los datos de un empleado para colegiaturas            
  proc_obtener_datos_colaborador_colegiaturas 98449451      
  proc_obtener_datos_colaborador_colegiaturas (93902761)      
  ----------------------------------------------------------
  NOMBRE: Rafael Ramos    
  BD: Personal SQL    
  FECHA: 30/07/2018    
  DESCRIPCION DE CAMBIO: Se agrega el campo de empresa a la que pertenece el colaborador.
  ----------------------------------------------------------
  NOMBRE: 
 */             
   
  CREATE TABLE #tmpEmpleado(              
    numemp INT NOT NULL DEFAULT 0,              
    nombre VARCHAR(20) NOT NULL DEFAULT '',              
    appat VARCHAR(15) NOT NULL DEFAULT '',              
    apmat VARCHAR(15) NOT NULL DEFAULT '',              
    centro INT NOT NULL DEFAULT 0,              
    nombrecentro VARCHAR(30) NOT NULL DEFAULT '',              
    puesto varchar(3) NOT NULL DEFAULT '',             
    nombrepuesto VARCHAR(30) NOT NULL DEFAULT '',             
    seccion varchar(3) NOT NULL DEFAULT '',             
    nombreseccion VARCHAR(30) NOT NULL DEFAULT '',             
    rutapago INT NOT NULL DEFAULT 0,            
    nombrerutapago  VARCHAR(20) NOT NULL DEFAULT '0',            
    fec_alta VARCHAR(10) NOT NULL DEFAULT '',   
    fechaalta smalldatetime NOT NULL DEFAULT GETDATE() ,            
    sueldo INT NOT NULL DEFAULT 0,             
    cancelado VARCHAR(1) NOT NULL DEFAULT '0',             
    antiguedad INT NOT NULL DEFAULT 0,            
    topeproporcion INT NOT NULL DEFAULT 0,            
    numerotarjeta VARCHAR(16) NOT NULL DEFAULT '',          
    rfc VARCHAR(13) NOT NULL DEFAULT '',    
    empresa CHAR(1) NOT NULL DEFAULT '1',    
    fec_limite SMALLDATETIME DEFAULT GETDATE(),
    fec_alta_anio_actual smalldatetime  DEFAULT GETDATE()
 )   
   
 CREATE TABLE #tmpfechalimite(  
	fec_limite VARCHAR(10) NOT NULL DEFAULT '',  
	meses INT NOT NULL DEFAULT 0  
 )  
 --insert into #tmpfechalimite (fec_limite) values (YEAR(getdate() & '1231')   
              
 INSERT	INTO #tmpEmpleado (numemp,nombre, appat, apmat, centro, puesto,fec_alta,fechaalta,cancelado,sueldo, rutapago, antiguedad, numerotarjeta, rfc, empresa)            
 SELECT	numemp, nombre, apellidopaterno, apellidomaterno, centron, numeropuesto, CONVERT(char(10),fechaalta,103),fechaalta,cancelado, sueldo, ControlPago,   
		--case when datediff(month,fechaalta,getdate())>=12 then 12 else datediff(month,fechaalta,getdate()) end    
		datediff(month,fechaalta,getdate())  
		--datediff(month,fechaalta,'20181216')  
		, numerotarjeta, rfc, tipoempresa    
 From	SAPCATALOGOEMPLEADOS(nolock)   
 --where	numemp=cast (91982022 as varchar);
 where	numemp=cast (@iNumEmp as varchar);  
   
 --SELECT fechaalta,* FROM SAPCATALOGOEMPLEADOS  
   
	UPDATE #tmpEmpleado SET fec_limite= CONVERT(VARCHAR,YEAR (getdate()))+  '1201';  
	--UPDATE #tmpEmpleado SET fec_limite= '20181201'; 
	 --UPDATE #tmpEmpleado SET fec_alta_anio_actual= CONVERT(VARCHAR,YEAR (getdate())) +  CONVERT(VARCHAR,MONTH(fechaalta)) + CONVERT(VARCHAR,DAY (fechaalta));   
  
	--ant = SELECT antiguedad FROM #tmpEmpleado;  
   
	IF EXISTS (SELECT antiguedad FROM #tmpEmpleado WHERE antiguedad>=12 AND antiguedad<24)  
		BEGIN  
			IF ((select cast (year(fechaalta)+1 as integer) FROM SAPCATALOGOEMPLEADOS WHERE numemp=cast(@iNumEmp as varchar)) < YEAR(GETDATE()))
			--IF ((select cast (year(fechaalta)+1 as integer) FROM SAPCATALOGOEMPLEADOS WHERE numemp=cast(@iNumEmp as varchar)) < 2018)
				BEGIN
					UPDATE #tmpEmpleado set antiguedad= 12;
				END			
			ELSE
				BEGIN
					UPDATE #tmpEmpleado SET fec_alta_anio_actual= DATEADD (year , 1 , fechaalta);    
					UPDATE #tmpEmpleado set antiguedad= datediff(month,fec_alta_anio_actual, fec_limite)+1;
				END      
			--UPDATE #tmpEmpleado set antiguedad= datediff(month,'20181215', fec_limite)+1;      
		END  

	ELSE IF EXISTS (SELECT antiguedad FROM #tmpEmpleado WHERE antiguedad<12)  
		BEGIN  
			IF (EXISTS(SELECT * FROM #tmpEmpleado WHERE YEAR(fechaalta)< YEAR(GETDATE())))  
				BEGIN  
					UPDATE #tmpEmpleado set antiguedad= 12;  
				--UPDATE #tmpEmpleado set antiguedad= 12-12;  
				END  
			ELSE  
				BEGIN  
					UPDATE #tmpEmpleado set antiguedad= 12-MONTH(fechaalta)+1;  
				END  
		END    

	ELSE IF EXISTS (SELECT antiguedad FROM #tmpEmpleado WHERE antiguedad>=24)  
		BEGIN  
			UPDATE #tmpEmpleado set antiguedad= 12;  
		END  
	         
	UPDATE #tmpEmpleado set nombrecentro=a.NombreCentro, seccion= a.Seccion from sapcatalogocentros(nolock) a where a.centron=#tmpEmpleado.centro;            
	         
	UPDATE #tmpEmpleado set nombrepuesto=a.nombre from  sapcatalogopuestos(nolock) a where a.numero=#tmpEmpleado.puesto;    --select * from sapcatalogopuestos(nolock)        
	         
	UPDATE #tmpEmpleado set nombreseccion=a.nombre  from cat_secciones(nolock) a where a.numeroseccion=convert(int, #tmpEmpleado.seccion);            
	         
	UPDATE #tmpEmpleado set nombrerutapago=a.nombre from  cat_rutaspagos(nolock) a where a.rutadepago=#tmpEmpleado.rutapago;            
	         
	-- update #tmpEmpleado set antiguedad=case when datediff(month,fec_alta,getdate())>=12 then 12 else datediff(month,fec_alta,getdate()) end;            
	--update #tmpEmpleado set antiguedad=datediff(month,fec_alta,getdate())            
	update #tmpEmpleado set topeproporcion= (sueldo * antiguedad)/2;            
	         
	SELECT numemp, rtrim(nombre) AS nombre ,rtrim(appat)as appat,rtrim(apmat) as apmat,centro,rtrim(nombrecentro) as nombrecentro,  
	puesto,rtrim(nombrepuesto) as nombrepuesto,   
	seccion, rtrim(nombreseccion) as nombreseccion,fec_alta,cancelado, sueldo,rutapago,        
	rtrim(nombrerutapago) as nombrerutapago, antiguedad, topeproporcion, numerotarjeta, rfc, empresa  
	--, fec_limite, fec_alta_anio_actual  
	--sueldo, antiguedad, topeproporcion  
	FROM #tmpEmpleado (nolock)           
             
END              
SET NOCOUNT OFF 

