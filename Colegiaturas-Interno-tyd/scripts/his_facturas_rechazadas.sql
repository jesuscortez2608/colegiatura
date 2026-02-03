/*
	No. petición APS               : 16559.1
	Fecha                          : 28/05/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : his_facturas_rechazadas
------------------------------------------------------------------------------------------------------ */
CREATE TABLE his_facturas_rechazadas
(
  idu_generacion integer,
  idfactura integer,
  idu_empleado integer,
  prc_descuento integer,
  opc_cheque integer,
  clv_rutapago integer,
  importe_factura numeric(12,2),
  importe_pagado numeric(12,2)
);

--Indices
CREATE INDEX idx_his_facturas_rechazadas_clv_rutapago ON his_facturas_rechazadas (clv_rutapago);
CREATE INDEX idx_his_facturas_rechazadas_idfactura ON his_facturas_rechazadas (idfactura);
CREATE INDEX idx_his_facturas_rechazadas_idu_empleado ON his_facturas_rechazadas (idu_empleado);
CREATE INDEX idx_his_facturas_rechazadas_idu_generacion ON his_facturas_rechazadas (idu_generacion); 
CREATE INDEX idx_his_facturas_rechazadas_opc_cheque ON his_facturas_rechazadas (opc_cheque);
CREATE INDEX idx_his_facturas_rechazadas_prc_descuento ON his_facturas_rechazadas (prc_descuento);

