/*
	No. petición APS               : 16559.1
	Fecha                          : 
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */
drop table if exists stmp_facturas_rechazadas;

CREATE TABLE stmp_facturas_rechazadas
(
  idu_generacion integer,
  idfactura integer,
  idu_ajuste integer,
  idu_empleado integer,
  prc_descuento integer,
  clv_rutapago integer,
  importe_factura numeric(12,2),
  importe_pagado numeric(12,2)
);

--Índices
CREATE INDEX idx_stmp_facturas_rechazadas_clv_rutapago ON stmp_facturas_rechazadas(clv_rutapago);
CREATE INDEX idx_stmp_facturas_rechazadas_idfactura ON stmp_facturas_rechazadas(idfactura);
CREATE INDEX idx_stmp_facturas_rechazadas_idu_ajuste ON stmp_facturas_rechazadas(idu_ajuste);
CREATE INDEX idx_stmp_facturas_rechazadas_idu_empleado ON stmp_facturas_rechazadas(idu_empleado);
CREATE INDEX idx_stmp_facturas_rechazadas_idu_generacion ON stmp_facturas_rechazadas(idu_generacion);
CREATE INDEX idx_stmp_facturas_rechazadas_prc_descuento ON stmp_facturas_rechazadas(prc_descuento);