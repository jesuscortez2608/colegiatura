-- ===================================================
-- Peticion					: 16559.1
-- Autor					: Rafael Ramos Gutiérrez 98439677
-- Fecha					: 28/03/2018
-- Descripción General		: CLAVES DE USO PERMITIDAS EN FACTURAS DE COLEGIATURAS
-- Sistema					: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos			: personal
-- ===================================================
-- Definicion
DROP TABLE IF EXISTS cat_claves_uso_permitidas;
CREATE TABLE cat_claves_uso_permitidas
(
  clv_uso character varying(5) NOT NULL,
  des_uso character varying(50) NOT NULL,
  fec_registro timestamp without time zone DEFAULT now(),
  idu_empleado_registro integer NOT NULL,
  keyx serial
);

--Datos
INSERT INTO cat_claves_uso_permitidas (clv_uso, des_uso, idu_empleado_registro) VALUES ('G03', 'Gastos en general', 95194185);
INSERT INTO cat_claves_uso_permitidas (clv_uso, des_uso, idu_empleado_registro) VALUES ('D10', 'Pagos por servicios educativos', 95194185);
INSERT INTO cat_claves_uso_permitidas (clv_uso, des_uso, idu_empleado_registro) VALUES ('P01', 'Por definir', 95194185);