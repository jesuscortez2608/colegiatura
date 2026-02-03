USE [personal]
GO

/****** Object:  StoredProcedure [dbo].[proc_generar_isr_colegiaturas]    Script Date: 08/01/2019 17:15:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE proc_generar_isr_colegiaturas    
@iUsuario INT,                              
@cXml XML                             
WITH EXECUTE AS OWNER                              
AS                              
BEGIN                           
 SET NOCOUNT ON                  
 /*                              
 NOMBRE: NALLELY MACHADO                            
 BD: personal SQL                              
 FECHA: 08/12/2017                              
 SERVIDOR: 10.44.1.13                              
 DESCRIPCION: CALCULA EL ISR PARA EL INCENTIVO DE COLEGIATURAS                            
 MODULO: GENERACION DE PAGOS                            
 SISTEMA: COLEGIATURAS
 MODIFICA: OMAR LIZARRAGA 94827443
 DESCRIPCION: SE AGREGA CICLO PARA HACER RECALCULO DE ISR
 EJEMPLO:                            
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="95194185" i="125000"></r><r e="91729815" i="10000"></r></Root>'                     
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="90423127 " i="245000"></r></Root>'                
                 
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="96874554 " i="386930"></r></Root>'                     
                 
 select   (5692.02   - 5343.62)+                
                 
 40.51 + 30.87                
                           
            5,692.02                
                           
                           
                           
 proc_generar_isr_colegiaturas 93902761, '<Root><r e="95194185" i="125000"></r><r e="91729815" i="10000"></r><r e="91815381" i="68100"></r>><r e="90874897" i="25000"></r></Root>'                            
                     
 */                             
 DECLARE @sFechaQuincena DATE                        
 DECLARE @sFechaIni DATE                    
 DECLARE @sFechaFin DATE                      
 DECLARE @Contador int              
 DECLARE @i int    
 DECLARE @TopePermitido int                 
                     
 TRUNCATE TABLE stmpIncentivoColegiaturas              
 TRUNCATE TABLE stmpIncentivosColegiaturasDetalle              
 TRUNCATE TABLE stmpCalculoISRColegiaturas                    
                 
SET @sFechaQuincena =  (SELECT fecha_corte FROM sn_datos_generales(NOLOCK))               

	IF (EXISTS (SELECT fec_ini_1q FROM  SN_FECHAS_CORTES(NOLOCK) WHERE CONVERT(smalldatetime,fec_ini_1q)<=GETDATE() AND CONVERT(smalldatetime,fec_fin_1q) >=GETDATE()) )                    
		BEGIN                    
			SET @sFechaIni=(SELECT fec_ini_1q FROM SN_FECHAS_CORTES(NOLOCK) WHERE CONVERT(smalldatetime,fec_ini_1q)<=GETDATE() AND CONVERT(smalldatetime,fec_fin_1q) >=GETDATE())                    
			SET @sFechaFin=(SELECT fec_fin_1q FROM SN_FECHAS_CORTES(NOLOCK) WHERE CONVERT(smalldatetime,fec_ini_1q)<=GETDATE() AND CONVERT(smalldatetime,fec_fin_1q) >=GETDATE())                    
		END                    
	ELSE                    
		BEGIN                    
			SET @sFechaIni=(SELECT fec_ini_2q FROM  SN_FECHAS_CORTES WHERE CONVERT(smalldatetime,fec_ini_2q)<=GETDATE() AND CONVERT(smalldatetime,fec_fin_2q) >=GETDATE())                    
			SET @sFechaFin=(SELECT fec_fin_2q FROM  SN_FECHAS_CORTES WHERE CONVERT(smalldatetime,fec_ini_2q)<=GETDATE() AND CONVERT(smalldatetime,fec_fin_2q) >=GETDATE())                    
		END                    

	INSERT 	INTO stmpIncentivoColegiaturas(idu_empleado, imp_incentivo)                            
	SELECT 	e= T.Item.value('@e', 'int'), i = T.Item.value('@i', 'int')                            
	FROM 	@cXml.nodes('Root/r') AS T(Item)                

	--SUELDO, TIPO DE NOMINA y CENTRO                          
	UPDATE 	stmpIncentivoColegiaturas SET imp_sueldo=a.Sueldo,ctipo_nomina= a.tipoNomina, num_centro=a.centron, idu_empresa=a.empresa          
	FROM 	SAPCATALOGOEMPLEADOS a (NOLOCK)               
	WHERE 	a.numempn=stmpIncentivoColegiaturas.idu_empleado                            

	--select * from stmpIncentivoColegiaturas                    
	--DESPENSA                          
	UPDATE 	stmpIncentivoColegiaturas SET imp_despensa=a.despensa      
	FROM 	sapempleadoscatalogo a(NOLOCK)               
	WHERE 	a.numemp=stmpIncentivoColegiaturas.idu_empleado       

	--EMPLEADOS CON CAMBIO DE SUELDO                            
	UPDATE 	stmpIncentivoColegiaturas SET imp_sueldo=a.sueldo                          
	FROM 	sn_bajasyotros_quincena a (NOLOCK)               
	WHERE 	a.fechacap>=@sFechaIni               
			and a.fechacap<=@sFechaFin               
			AND a.movimiento=9 AND a.status <> '1'               
			AND a.numemp=stmpIncentivoColegiaturas.idu_empleado                     

	--EMPLEADOS CAMBIO DE CENTRO                          
	UPDATE 	stmpIncentivoColegiaturas SET num_centro=a.centro                          
	FROM 	sn_bajasyotros_quincena a (NOLOCK)           
	WHERE 	a.fechacap>=@sFechaIni           
			AND a.fechacap<=@sFechaFin           
			AND a.movimiento=3           
			AND a.status <> '1'           
			AND a.numemp=stmpIncentivoColegiaturas.idu_empleado                      

	-- EMPLEADOS CAMBIO DE EMPRESA                    
	UPDATE 	stmpIncentivoColegiaturas SET num_centro=a.centro, imp_sueldo=a.sueldo, idu_empresa=a.empresa                            
	FROM 	sn_bajasyotros_quincena a (NOLOCK)           
	WHERE 	a.fechacap>=@sFechaIni           
			AND a.fechacap<=@sFechaFin           
			AND a.movimiento=20           
			AND a.status <> '1'           
			AND a.dias_vacac = 14           
			AND a.numemp=stmpIncentivoColegiaturas.idu_empleado                    

	--ACTUALIZA LA DESPENSA                           
	UPDATE  stmpIncentivoColegiaturas SET imp_despensa=a.Sueldo                          
	FROM 	Sn_bajasyotros_quincena A(NOLOCK)           
	WHERE 	a.fechacap>=@sFechaIni           
			AND a.fechacap<=@sFechaFin           
			AND movimiento=5           
			AND a.status <> '1'           
			AND a.numemp=stmpIncentivoColegiaturas.idu_empleado                      

	--VALIDA SI SE LE PAGARA A LOS DIRECTIVOS                            
	IF((SELECT DATEPART (DAY, fecha_corte) FROM sn_datos_generales(NOLOCK))=15)                            
		BEGIN                            
		--EMPLEADOS CON CAMBIO DE TIPO DE NOMINA                            
			UPDATE 	stmpIncentivoColegiaturas SET ctipo_nomina=a.tipo_nomina                          
			FROM 	sn_altasycorrec_quincena a (NOLOCK)           
			WHERE 	a.fechacap>=@sFechaIni           
					AND a.fechacap<=@sFechaFin           
					AND a.movimiento=10           
					AND tipo_nomina!=''           
					AND a.numemp=stmpIncentivoColegiaturas.idu_empleado                  
		END                            
	ELSE                            
		BEGIN                           
			--BORRA LOS DIRECTIVOS                            
			DELETE FROM stmpIncentivoColegiaturas WHERE ctipo_nomina='3'                                  
		END               

	--ACTUALIZA EL REPARTO                         
	UPDATE 	stmpIncentivoColegiaturas SET imp_ant_reparto= CASE WHEN stmpIncentivoColegiaturas.ctipo_nomina='1' THEN  anticiporepempleado ELSE anticiporepdirect02 END                        
	FROM 	nomcontrol(NOLOCK)                         

	--ACTUALIZAR LA SECCION                          
	UPDATE 	stmpIncentivoColegiaturas SET num_seccion=CONVERT(INT, a.seccion )                           
	FROM 	SAPCATALOGOCENTROS a(NOLOCK) WHERE a.centron=stmpIncentivoColegiaturas.num_centro                          

	--CALCULA LA PRIMA DOMINICAL EMPLEADOS                          
	UPDATE 	stmpIncentivoColegiaturas SET imp_dominical=(((( ((imp_sueldo)/(30)) * (52))/(3))* (2))/(4))/(24)                          
	WHERE 	ctipo_nomina='1' AND num_seccion IN (SELECT num_seccion FROM cat_seccionesprimadominical(NOLOCK))                          

	--CALCULA LA PRIMA DOMINICAL DIRECTIVOS                          
	UPDATE 	stmpIncentivoColegiaturas SET imp_dominical=(((( ((imp_sueldo)/(30)) *(52))/(3))* (2))/(4))/(12)                          
	WHERE 	ctipo_nomina='3'           
			AND num_seccion IN (SELECT num_seccion FROM cat_seccionesprimadominical(NOLOCK))                          

	--SUELDO, DESPENSA Y REPARTO QUINCENAL PARA EMPLEADOS                             
	UPDATE 	stmpIncentivoColegiaturas SET imp_sueldo=imp_sueldo/2, imp_despensa=imp_despensa/2, imp_ant_reparto=imp_ant_reparto/2           
	WHERE 	ctipo_nomina='1'                          
	--ACTUALIZAR REPARTO CUANDO SON EMPLEADOS DE MEDIO TURNO                     

	--ACTUALIZA EL SUELDO + DINERO ELECTRONICO + ANTICIPO DE REPARTO DE UTILIDADES + PRIMA DOMINICAL                        
	UPDATE stmpIncentivoColegiaturas SET total_sueldo=imp_sueldo+imp_despensa+imp_ant_reparto+imp_dominical                          

	--CALCULA EL IRS SIN INCENTIVO  EMPLEADOS                   
	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo= dbo.nomcalcularisrdiario(15, stmpIncentivoColegiaturas.total_sueldo/100, stmpIncentivoColegiaturas.idu_empresa)                  
	WHERE 	stmpIncentivoColegiaturas.ctipo_nomina = '1'                  

	--CALCULA EL IRS SIN INCENTIVO  DIRECTIVOS                    
	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo=cast( ((((stmpIncentivoColegiaturas.total_sueldo-b.limiteinferior)*CONVERT(FLOAT,b.excedente)/100.00)/10000.00)) +CONVERT(FLOAT,b.cuotafija)/100.00 as float)                      
	FROM 	nomlimitesisrmensual b(NOLOCK)           
	WHERE 	stmpIncentivoColegiaturas.total_sueldo >=CONVERT(FLOAT, b.limiteinferior)           
			AND stmpIncentivoColegiaturas.total_sueldo <= CONVERT(FLOAT, b.limitesuperior)           
			AND b.tipo = 1                      
			AND stmpIncentivoColegiaturas.ctipo_nomina = '3'                    

	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo=0             
	WHERE 	isr_sueldo<0                     

	--ACTUALIZA EL SUELDO CON PRESTACION COLEGIATURAS + DINERO ELECTRONICO + ANTICIPO DE REPARTO DE UTILIDADES + PRIMA DOMINICAL + PRESTACION+ ISR CALCULADO                          
	UPDATE 	stmpIncentivoColegiaturas SET total_sueldo_incentivo=total_sueldo+imp_incentivo                       

	----CALCULA EL IRS CON INCENTIVO EMPLEADOS                   
	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo_incentivo = dbo.nomcalcularisrdiario(15, stmpIncentivoColegiaturas.total_sueldo_incentivo/100, stmpIncentivoColegiaturas.idu_empresa)                  
	WHERE 	stmpIncentivoColegiaturas.ctipo_nomina = '1'                  

	--CALCULA EL IRS CON INCENTIVO DIRECTIVOS                     
	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo_incentivo=  
			cast(((((stmpIncentivoColegiaturas.total_sueldo_incentivo-b.limiteinferior)*CONVERT(FLOAT,b.excedente)/100.00)/10000.00)) +CONVERT(FLOAT,b.cuotafija)/100.00 as float)                      
	FROM 	nomlimitesisrmensual b(NOLOCK)               
	WHERE 	stmpIncentivoColegiaturas.total_sueldo_incentivo >=CONVERT(FLOAT, b.limiteinferior)             
			AND stmpIncentivoColegiaturas.total_sueldo_incentivo <= CONVERT(FLOAT, b.limitesuperior)             
			AND b.tipo = 1                  
			AND stmpIncentivoColegiaturas.ctipo_nomina = '3'               

	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------            
	--INCENTIVOS DETALLE ISR            
	INSERT 	INTO stmpIncentivosColegiaturasDetalle (numemp,total_sueldo,importe_colegiaturas,isr_sueldo,nuevo_importe_colegiaturas,isr_sueldo_colegiaturas,importe_pagar_colegiatura,importe_neto,tipo_nomina)              
	SELECT 	idu_empleado, total_sueldo, imp_incentivo, isr_sueldo,imp_incentivo,isr_sueldo_incentivo*100,          
			(total_sueldo_incentivo-(isr_sueldo_incentivo*100)) - (total_sueldo-(isr_sueldo*100)) as importe_pagar,          
			total_sueldo-(isr_sueldo*100) as importe_neto, ctipo_nomina            
	FROM 	stmpIncentivoColegiaturas              

	--DIFERENCIA              
	UPDATE stmpIncentivosColegiaturasDetalle SET diferencia=importe_colegiaturas-importe_pagar_colegiatura              

	--CALCULO ISR             
	INSERT 	INTO stmpCalculoISRColegiaturas (numemp,percepcion,isr_sueldo,importe_colegiaturas,isr_sueldo_colegiaturas,importe_pagar_colegiatura,tipo_nomina)            
	SELECT 	idu_empleado, total_sueldo, isr_sueldo, imp_incentivo,isr_sueldo_incentivo*100,            
			(total_sueldo_incentivo-(isr_sueldo_incentivo*100)) - (total_sueldo-(isr_sueldo*100)) as importe_neto,ctipo_nomina               
	FROM 	stmpIncentivoColegiaturas            

	--DIFERENCIA TABLA CALCULO ISR            
	UPDATE stmpCalculoISRColegiaturas SET diferencia=importe_colegiaturas-importe_pagar_colegiatura     

	SET @TopePermitido = (SELECT clv_porcentaje FROM ctl_porcentajeCuotaAhorro(NOLOCK) WHERE idu_porcentaje=2)

	--CICLO               
	SET @Contador = (SELECT COUNT(*) FROM stmpCalculoISRColegiaturas WHERE diferencia>@TopePermitido)              
	SET @i=0               
	WHILE @Contador > 0                                        
		BEGIN              
			SET @i = @i + 1                
			--UPDATE stmpIncentivosColegiaturasDetalle set vuelta=@i WHERE vuelta=0              
			--DELETE FROM stmpIncentivosColegiaturasDetalle WHERE vuelta=1              

			--INSERTAR DETALLE          
			INSERT 	INTO stmpIncentivosColegiaturasDetalle (numemp, total_sueldo, isr_sueldo,importe_colegiaturas, nuevo_importe_colegiaturas, importe_neto, tipo_nomina,vuelta)            
			SELECT 	numemp,total_sueldo,isr_sueldo,importe_colegiaturas,nuevo_importe_colegiaturas + diferencia,importe_neto, tipo_nomina,@i             
			FROM 	stmpIncentivosColegiaturasDetalle          
			WHERE 	diferencia>@TopePermitido                  
					AND vuelta=@i-1              

			--ISR CON COLEGIATURAS EMPLEADO                
			UPDATE 	stmpIncentivosColegiaturasDetalle SET isr_sueldo_colegiaturas = 100*dbo.nomcalcularisrdiario(15, (stmpIncentivosColegiaturasDetalle.total_sueldo+stmpIncentivosColegiaturasDetalle.nuevo_importe_colegiaturas)/100, 1)           
			WHERE 	stmpIncentivosColegiaturasDetalle.vuelta = @i          
					AND stmpIncentivosColegiaturasDetalle.tipo_nomina=1           

			--ISR CON COLEGIATURAS DIRECTIVO             
			UPDATE 	stmpIncentivosColegiaturasDetalle SET isr_sueldo_colegiaturas=100*cast( ((((          
					stmpIncentivosColegiaturasDetalle.total_sueldo          
					+ stmpIncentivosColegiaturasDetalle.nuevo_importe_colegiaturas          
					-b.limiteinferior)*CONVERT(FLOAT,b.excedente)/100.00)/10000.00)) +CONVERT(FLOAT,b.cuotafija)/100.00 as float)                  
			FROM 	nomlimitesisrmensual b(NOLOCK)           
			WHERE 	(stmpIncentivosColegiaturasDetalle.total_sueldo+ stmpIncentivosColegiaturasDetalle.nuevo_importe_colegiaturas)>=CONVERT(FLOAT, b.limiteinferior)           
					AND (stmpIncentivosColegiaturasDetalle.total_sueldo+ stmpIncentivosColegiaturasDetalle.nuevo_importe_colegiaturas)<= CONVERT(FLOAT, b.limitesuperior)           
					AND b.tipo = 1              
					AND stmpIncentivosColegiaturasDetalle.tipo_nomina = '3'          
					AND stmpIncentivosColegiaturasDetalle.vuelta = @i             
			 
			--IMPORTE PAGAR COLEGIATURAS            
			UPDATE  stmpIncentivosColegiaturasDetalle SET importe_pagar_colegiatura=((total_sueldo)+nuevo_importe_colegiaturas-isr_sueldo_colegiaturas-importe_neto)            
			WHERE 	vuelta = @i              

			--DIFERENCIA              
			UPDATE 	stmpIncentivosColegiaturasDetalle SET diferencia= importe_colegiaturas-importe_pagar_colegiatura              
			WHERE 	vuelta = @i             

			--              
			UPDATE 	stmpCalculoISRColegiaturas SET importe_colegiaturas=(B.nuevo_importe_colegiaturas),               
					isr_sueldo_colegiaturas=B.isr_sueldo_colegiaturas, importe_pagar_colegiatura=B.importe_pagar_colegiatura,              
					diferencia=B.diferencia              
			FROM 	stmpIncentivosColegiaturasDetalle B               
			WHERE 	stmpCalculoISRColegiaturas.numemp=B.numemp    
					AND B.diferencia>@TopePermitido              
					AND B.vuelta=@i                    

			SET @Contador =   
			--(SELECT COUNT(*) FROM stmpCalculoISRColegiaturas WHERE diferencia>@TopePermitido)    
			(SELECT COUNT(*) FROM stmpIncentivosColegiaturasDetalle WHERE diferencia>@TopePermitido AND vuelta=@i)              
			/*SELECT COUNT(*) FROM stmpCalculoISRColegiaturas WHERE diferencia>@TopePermitido*/                 
		END                    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                  
	UPDATE 	stmpIncentivoColegiaturas SET isr_sueldo_incentivo=0 WHERE   isr_sueldo_incentivo<0   

	UPDATE 	stmpIncentivoColegiaturas SET isr_colegiatura=Round((isr_sueldo_incentivo-isr_sueldo),0,0)*100       

	UPDATE 	stmpIncentivoColegiaturas SET isr_colegiatura=Round(((B.isr_sueldo_colegiaturas/100)-B.isr_sueldo),0,0)*100          
	FROM 	stmpCalculoISRColegiaturas B          
	WHERE 	stmpIncentivoColegiaturas.idu_empleado=B.numemp    

	/*    
	stmpCalculoISRColegiaturas    
	stmpIncentivosColegiaturasDetalle    

	update ctl_porcentajeCuotaAhorro set clv_porcentaje=100000 where idu_porcentaje=2    
	update ctl_porcentajeCuotaAhorro set clv_porcentaje=10000 where idu_porcentaje=2    
	update ctl_porcentajeCuotaAhorro set clv_porcentaje=100 where idu_porcentaje=2    

	select (337487/100)-2575.19    
	SELECT isr_sueldo_colegiaturas, isr_sueldo,(isr_sueldo_colegiaturas/100)-isr_sueldo FROM stmpCalculoISRColegiaturas    

	select * from stmpCalculoISRColegiaturas    
	select * from stmpIncentivosColegiaturasDetalle    
	*/            

	SELECT 	*,@sFechaQuincena AS fechaQuincena        
	FROM 	stmpIncentivoColegiaturas (NOLOCK)        
                   
 SET NOCOUNT OFF                      
END