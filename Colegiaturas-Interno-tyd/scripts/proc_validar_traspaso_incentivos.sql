
CREATE PROCEDURE proc_validar_traspaso_incentivos
AS
/*-------------------------------------------------------------------------------
Fecha :			29/10/2018
Colaborador:	Rafael Ramos 98439677
Sistema:		Colegiaturas
Modulo:			Archivo de Incentivos
--------------------------------------------------------------------------------*/
SET NOCOUNT ON
BEGIN
IF EXISTS (SELECT tipo FROM sn_incentivos_quincena where tipo = 351)
BEGIN 
	SELECT 1 AS resultado
END 
ELSE
BEGIN
	SELECT 0 AS resultado
END 
END    
    
SET NOCOUNT OFF 

GO

GRANT EXECUTE ON dbo.proc_validar_traspaso_incentivos TO syspersonal
GO