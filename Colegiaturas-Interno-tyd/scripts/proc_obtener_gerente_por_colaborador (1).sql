
CREATE PROCEDURE [dbo].[proc_obtener_gerente_por_colaborador]
    @numemp INT
 WITH EXECUTE AS OWNER
 AS
 SET NOCOUNT ON
 /*
    No. petición APS               : 39116
    Fecha                          : 20/02/2025
    Número empleado                : 97270661, 90244610
    Nombre del empleado            : Luis Antonio Monge, Luis Eduardo Hernandez Jimenez
    Base de datos                  : 
    Usuario de BD                  : 
    Servidor de pruebas            : 10.201.117.9
    Servidor de produccion         : 
    Descripción del funcionamiento : Permite mostrar el gerente a cargo del colaborador consultado
    Descripción del cambio         : 
    Sistema                        : 
    Módulo                         : 
    Repositorio del proyecto       : 
    Ejemplo                        : 
        exec proc_obtener_gerente_por_colaborador 90244610
    ------------------------------------------------------------------------------------------------------  */
	
 BEGIN

    
 select 
		case 
			when @numemp = sap2.numemp then sap3.numemp else sap2.numemp end as numemp, 
		case 
			when @numemp = sap2.numemp then ltrim(rtrim(sap3.nombre))+' '+ltrim(rtrim(sap3.apellidopaterno))+' '+ltrim(rtrim(sap3.apellidomaterno)) 
		else 
			ltrim(rtrim(sap2.nombre))+' '+ltrim(rtrim(sap2.apellidopaterno))+' '+ltrim(rtrim(sap2.apellidomaterno)) end as nombre
		from sapcatalogoempleados as sap with(nolock)
			join ctl_estructurajerarquicaporarea as est with(nolock) on sap.centron = est.numerocentro
			join sapcatalogoempleados as sap2  with(nolock) on sap2.numempn = est.numerogerente
			join sapCatalogoCentros as cen with(nolock) on cen.centron = est.centroorigen
			join sapcatalogoempleados as sap3 with(nolock) on cen.numerogerenten = sap3.numempn
			where sap.numempn = @numemp   
 END

 SET NOCOUNT OFF

 GRANT EXECUTE ON proc_obtener_gerente_por_colaborador TO syscoppelpersonal
 GO

 GRANT EXECUTE ON proc_obtener_gerente_por_colaborador TO sysaccesos
 GO

 GRANT EXECUTE ON proc_obtener_gerente_por_colaborador TO syspersonal
 GO
