USE ContabilidadNueva
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('ContabilidadNueva.dbo.proc_validar_poliza_cancelacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.proc_validar_poliza_cancelacion
GO
CREATE PROCEDURE dbo.proc_validar_poliza_cancelacion @iPoliza INT, @iClave INT, @dFecha DATETIME
    WITH EXECUTE AS OWNER
AS
SET NOCOUNT ON
BEGIN
	--=============================================            
	-- AUTOR: 95194185 Paimi
	-- FECHA: 23/01/2017
	-- DESCRIPCION GENERAL: PROCEDIMIENTO UTILIZADO PARA VALIDAR SI UNA PÓLIZA ES VÁLIDA
	-- EJEMPLO: exec dbo.proc_validar_poliza_cancelacion 1169876, 4031, '20160915'
	-- =============================================    
	select NumeroCheque
        , Cuenta1, Cuenta2, Cuenta3, Cuenta4, Cuenta5
        , NombreBanco
        , Beneficiario
        , Importe
        , Fecha
        , Realizo
        , Conciliado1
        , Conciliado2
        , ClavePoliza
        , NumeroRfc
        , ClaveNumeroRfc
        , Cancelado
        , NumeroNuevo
        , ClaveNueva
        , FechaNueva
        , FechaPago
        , Pagado
        , Ciudad
        , FechaAlta
        , Keyx
	from chemovtoscheques(nolock)
	where NumeroCheque = @iPoliza
	    and ClavePoliza = @iClave
	    and Fecha = @dFecha
END
SET NOCOUNT OFF
GO
GRANT EXECUTE ON dbo.proc_validar_poliza_cancelacion TO syspersonal
GO
