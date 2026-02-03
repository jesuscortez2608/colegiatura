USE [Personal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE proc_consultaarbolcentro    
  @IduCentro INTEGER    
WITH EXECUTE AS OWNER
AS
SET NOCOUNT ON    
-- =============================================    
-- Autor: De La Paz Hernandez Victor Manuel    
-- Fecha: 2012-02-11    
-- Descripción General: Procedimiento para consultar la estructura jerarquica de un centro de la tabla     
-- ctl_estructurajerarquicaporarea   
--proc_consultaarbolcentro 230534  
-- =============================================    
DECLARE    
  @Cve_Nivel INTEGER,    
  @IduCentroPadre INTEGER,    
  @IduEstado INTEGER,    
  @Nom_CentroPadre VARCHAR(128)    
   
  CREATE TABLE #TMP_RESPUESTA(    
    IduCentro int not null default 0,    
    nom_centro VARCHAR(128) not null default '',      
    cve_nivel int not null default 0,    
    IduGerente int not null default 0,    
    nom_gerente VARCHAR(128) not null default '',    
    tiponomina int not null default 0  
 );  
    
  CREATE TABLE #TMP_PADRES(    
    IduCentro int not null default 0  
 );    
    
  SELECT @Cve_Nivel = 1;    
  SELECT @IduEstado = 0;    
  -- SE AGREGAN PRIMERO LOS HIJOS DEL CENTRO SELECCIONADO    
      
  INSERT INTO #TMP_RESPUESTA (IduCentro, nom_centro, cve_nivel, IduGerente, nom_gerente)     
  SELECT a.numerocentro, b.nombre, @Cve_Nivel, 0, ''   
  FROM ctl_estructurajerarquicaporarea a WITH(NOLOCK)    
  INNER JOIN cat_centros b WITH(NOLOCK) ON a.numerocentro = b.numerocentro    
  WHERE a.centroorigen = @IduCentro   
  AND a.centroorigen != 0   
  AND a.centroorigen IS NOT NULL   
  ORDER BY a.numerocentro;    
    
  INSERT INTO #TMP_PADRES   
  SELECT @IduCentro;    
      
  -- SE VERIFICA SI HAY HIJOS PARA AUMENTAR EL NIVEL(EFECTO VISUAL EN PAGINA WEB :P)    
  SELECT @IduEstado = COUNT(IduCentro) FROM #TMP_RESPUESTA WITH(NOLOCK);  
    
  IF @IduEstado > 0    
  begin  
 SELECT @Cve_Nivel = @Cve_Nivel + 1;    
   end  
  -- SE AGREGA EL CENTRO SELECCIONADO    
  INSERT INTO #TMP_RESPUESTA (IduCentro, nom_centro, cve_nivel, IduGerente, nom_gerente)     
  SELECT a.numerocentro, b.nombre, @Cve_Nivel, 0, '' FROM ctl_estructurajerarquicaporarea a WITH(NOLOCK)    
  INNER JOIN cat_centros b WITH(NOLOCK) ON a.numerocentro = b.numerocentro    
  WHERE a.numerocentro = @IduCentro;  
    
  --SELECT @Cve_Nivel = @Cve_Nivel + 1    
    
  -- EMPIEZA CICLO PARA BUSCAR NIVELES JERARQUICOS SUPERIORES(NODOS PADRES)    
  SELECT @IduEstado = @Cve_Nivel;    
  
  WHILE @IduEstado > 0    
  BEGIN    
   SELECT @IduEstado = 0    
   SELECT @IduCentroPadre = a.centroorigen, @Nom_CentroPadre = b.nombre, @IduEstado = @Cve_Nivel + 1   
   FROM ctl_estructurajerarquicaporarea a WITH(NOLOCK)    
   INNER JOIN cat_centros b WITH(NOLOCK) ON a.centroorigen = b.numerocentro    
   WHERE a.numerocentro = @IduCentro   
   AND a.centroorigen != 0   
   AND a.centroorigen IS NOT NULL   
   AND a.centroorigen NOT IN(SELECT IduCentro FROM #TMP_PADRES WITH(NOLOCK));  
     
    IF @IduEstado > 0    
  BEGIN    
    INSERT INTO #TMP_PADRES SELECT @IduCentroPadre    
    INSERT INTO #TMP_RESPUESTA (IduCentro, nom_centro, cve_nivel, IduGerente, nom_gerente)    
    SELECT @IduCentroPadre, @Nom_CentroPadre, @IduEstado, 0, ''    
    SELECT @Cve_Nivel = @IduEstado    
    SELECT @IduCentro = @IduCentroPadre;    
  END    
    CONTINUE    
  END    
  
  SELECT @IduEstado = @Cve_Nivel + 1;    
  UPDATE #TMP_RESPUESTA SET CVE_NIVEL = ((CVE_NIVEL * -1) + @IduEstado)    
  UPDATE #TMP_RESPUESTA SET IDUGERENTE = CASE WHEN numerogerente IS NULL then 0 else numerogerente end FROM ctl_estructurajerarquicaporarea WHERE IDUCENTRO = numerocentro    
  UPDATE #TMP_RESPUESTA SET NOM_GERENTE = RTRIM(nombre) + ' ' + RTRIM(apellidopaterno) + ' ' + RTRIM(apellidomaterno)     
  FROM hecatalogoempleados WHERE IDUGERENTE = numemp;    
      
  UPDATE #TMP_RESPUESTA SET tiponomina = b.tiponomina  FROM sapcatalogoempleados as b WHERE IDUGERENTE = numemp;    
      
  UPDATE #TMP_RESPUESTA SET NOM_GERENTE = NOM_GERENTE + ' *'  WHERE tiponomina=3;    
      
  UPDATE #TMP_RESPUESTA SET IDUGERENTE = COALESCE(IDUGERENTE, 0);    
  UPDATE #TMP_RESPUESTA SET NOM_GERENTE = 'NO ASIGNADO' WHERE IDUGERENTE = 0;    
  
  SELECT IDUCENTRO, NOM_CENTRO, CVE_NIVEL, IDUGERENTE, NOM_GERENTE   
  FROM #TMP_RESPUESTA   
  ORDER BY CVE_NIVEL;    
    
SET NOCOUNT OFF
GO     