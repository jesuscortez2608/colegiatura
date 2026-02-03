/*
No. petición APS               : 22865
Fecha                          : 02/08/2019
Número empleado                : 94827443
Nombre del empleado            : Omar Lizarraga 
Base de datos                  : Personal
Servidor de produccion         : 10.44.1.13
Descripción					   : Se inserta registro para saber el margen que debe de quedar de diferencia en el monto del calculo del ISR
*/
INSERT INTO ctl_porcentajeCuotaAhorro (idu_porcentaje, clv_porcentaje, des_porcentaje, fec_capturo)
VALUES(2,100,'Monto permitido de diferencia de ISR de colegiaturas',GETDATE());