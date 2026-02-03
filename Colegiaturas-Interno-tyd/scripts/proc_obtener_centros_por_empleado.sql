USE PERSONAL  
GO

ALTER PROCEDURE [dbo].[proc_obtener_centros_por_empleado] @idu_empleado INTEGER, @centros_suplente VARCHAR(500)  
    WITH EXECUTE AS OWNER  
AS  
BEGIN  
    /*  
 No. petición APS               : 8613  
 Fecha                          : 04/11/2016  
 Número empleado                : 95194185  
 Nombre del empleado            : Paimi Arizmendi Lopez  
 Base de datos                  : Personal  
 Usuario de BD                  : syspersonal  
 Servidor de pruebas            : 10.44.1.135  
 Servidor de produccion         : 10.44.1.13  
 Ejemplo                        :   
  dbo.proc_obtener_centros_por_empleado 92194711, ''  
  proc_obtener_centros_por_empleado 96226421, '514302' 
  proc_obtener_centros_por_empleado 90029585 , '514302'  
    ------------------------------------------------------------------------------------------------------ */  
    SET NOCOUNT ON  
      
    DECLARE @iCentro INTEGER  
    DECLARE @iNivel INTEGER  
    DECLARE @iAux INTEGER  
      
    CREATE TABLE #TMP_CENTROS (idu_centro INTEGER  
        , nom_centro  VARCHAR(30)  
        , cve_nivel INTEGER  
        , idugerente INTEGER  
        , nom_gerente VARCHAR(150))  
      
    CREATE TABLE #TMP_CENTROS_SUPLENTES (idu_centro INTEGER)  
    IF LTRIM(RTRIM(@centros_suplente)) != ''  
    BEGIN 
	
        INSERT INTO #TMP_CENTROS_SUPLENTES(idu_centro)  
		(select a.numeroCentro from ctl_estructurajerarquicaporarea a with(NOLOCK) left join   
		ctl_estructurajerarquicaporarea b with(NOLOCK) on a.numerogerente=b.numerogerente where b.numerocentro in   
		(SELECT DISTINCT CAST(Items AS INTEGER) FROM Split(@centros_suplente, ',')))   
		
    END  
      
    SET @iNivel = 10  
    SET @iAux = 0  
    IF EXISTS(SELECT idu_centro FROM #TMP_CENTROS_SUPLENTES)  
    BEGIN  
        DECLARE CENTROS_SUPLENTES_CURSOR CURSOR FOR  
            SELECT idu_centro  
            FROM #TMP_CENTROS_SUPLENTES;  
              
        OPEN CENTROS_SUPLENTES_CURSOR;  
        FETCH NEXT FROM CENTROS_SUPLENTES_CURSOR INTO @iCentro;  
        WHILE @@FETCH_STATUS = 0    
        BEGIN  
            INSERT INTO #TMP_CENTROS (idu_centro, nom_centro, cve_nivel, idugerente, nom_gerente)  
            EXEC proc_consultaarbolcentro @iCentro  
              
            SET @iAux = (SELECT TOP 1 cve_nivel FROM #TMP_CENTROS WHERE idu_centro = @iCentro)  
            IF @iAux < @iNivel  
                SET @iNivel = @iAux  
              
            FETCH NEXT FROM CENTROS_SUPLENTES_CURSOR INTO @iCentro;  
        END;  
        CLOSE CENTROS_SUPLENTES_CURSOR;  
        DEALLOCATE CENTROS_SUPLENTES_CURSOR;  
    END  
      
    -- Obtener el centro del usuario. Debe agregarse en el listado en caso de no existir  
    SET @iCentro = (SELECT TOP 1 centro FROM hecatalogoempleados with(NOLOCK) WHERE numemp = @idu_empleado)  
      
    IF NOT EXISTS (SELECT * FROM #TMP_CENTROS WHERE idu_centro = @iCentro)  
    BEGIN  
        INSERT INTO #TMP_CENTROS (idu_centro, nom_centro, cve_nivel, idugerente, nom_gerente)  
            SELECT NumeroCentro  
                , NombreCentro  
                , 10 AS cve_nivel  
                , NumeroGerente  
                , '' AS nom_gerente  
            FROM sapCatalogoCentros with(NOLOCK)   
            WHERE NumeroCentro = @iCentro  
              
        UPDATE #TMP_CENTROS SET nom_gerente = LTRIM(RTRIM(Nombre)) + ' ' + LTRIM(RTRIM(ApellidoPaterno)) + ' ' + LTRIM(RTRIM(ApellidoMaterno))  
        FROM sapcatalogoempleados(NOLOCK)  
        WHERE numempn = #TMP_CENTROS.idugerente  
            AND cve_nivel = 10  
    END  
      
    -- Agregar los centros donde el usuario está registrado como gerente  
    INSERT INTO #TMP_CENTROS (idu_centro, nom_centro, cve_nivel, idugerente, nom_gerente)  
        SELECT cen.NumeroCentro  
            , cen.NombreCentro  
            , 10 AS cve_nivel  
            , cen.NumeroGerente  
            , '' AS nom_gerente  
        FROM sapCatalogoCentros(NOLOCK) cen  
            LEFT JOIN #TMP_CENTROS as tmp ON (tmp.idu_centro = cen.centron)  
        WHERE NumeroGerente = @idu_empleado and Cancelado!='1'
            AND tmp.idu_centro IS NULL  
          
    UPDATE #TMP_CENTROS SET nom_gerente = LTRIM(RTRIM(Nombre)) + ' ' + LTRIM(RTRIM(ApellidoPaterno)) + ' ' + LTRIM(RTRIM(ApellidoMaterno))  
        FROM sapcatalogoempleados(NOLOCK)  
        WHERE numempn = #TMP_CENTROS.idugerente  
            AND cve_nivel = 10  
    
    SELECT DISTINCT idu_centro  
        , nom_centro  
        , cve_nivel  
        , idugerente  
        , nom_gerente  
    FROM #TMP_CENTROS  
    WHERE cve_nivel >= @iNivel  
    ORDER BY nom_centro  
      
    SET NOCOUNT OFF  
END  
  