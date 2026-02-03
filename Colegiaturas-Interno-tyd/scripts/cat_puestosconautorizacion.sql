-- ===================================================
-- Peticion					: 16559.1
-- Autor					: Rafael Ramos Gutiérrez 98439677
-- Fecha					: 28/03/2018
-- Descripción General		: PUESTOS QUE NO NECESITARAN VALIDACION DE COSTOS
-- Sistema					: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos			: personal
-- ===================================================

DROP TABLE IF EXISTS cat_puestosconautorizacion;

CREATE TABLE cat_puestosconautorizacion(
	idu_puesto int not null default 0,
	idu_capturo int not null default 0,
	fec_captuta date not null default now()
);

INSERT INTO cat_puestosconautorizacion(idu_puesto, idu_capturo)
VALUES	(32, 93902761)
		, (33, 93902761)
		, (159, 93902761)
		, (228, 93902761)
		, (229, 93902761)
		, (232, 95194185)
		, (354, 93902761)
		, (357, 95194185)
		, (358, 95194185)
		, (359, 95194185)
		, (360, 95194185)
		, (370, 95194185)
		, (371, 95194185)
		, (374, 95194185)
		, (378, 95194185)
		, (454, 93902761)
		, (490, 95194185);