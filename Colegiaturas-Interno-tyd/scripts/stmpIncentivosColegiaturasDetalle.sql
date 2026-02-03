
CREATE TABLE stmpIncentivosColegiaturasDetalle (
	/*
	No. petición APS               : 22865
	Fecha                          : 02/08/2019
	Número empleado                : 94827443
	Nombre del empleado            : Omar Lizarraga 
	Base de datos                  : Personal
	Servidor de produccion         : 10.44.1.13
	Descripción del funcionamiento : Se crea tabla para guardar detalle del numero de vueltas para recalcular de ISR	
	*/
	numemp int,
	total_sueldo float,
	importe_colegiaturas float,
	isr_sueldo float,
	nuevo_importe_colegiaturas float,
	isr_sueldo_colegiaturas float,
	importe_pagar_colegiatura float,
	diferencia float,	
	importe_neto float,
	tipo_nomina int,
	vuelta int default 0		
);
	
	