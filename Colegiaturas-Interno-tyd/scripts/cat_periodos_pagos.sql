/*
	No. petición APS               : 8613.1
	Fecha                          : 20/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_periodos_pagos;

CREATE TABLE cat_periodos_pagos(
	idu_tipo_periodo integer NOT NULL DEFAULT 0,
	des_periodo character varying(20) NOT NULL DEFAULT ''::character varying,
	idu_periodo integer NOT NULL DEFAULT 0
);

-- Datos iniciales
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(1, 'INSCRIPCIÓN', 1);

    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'ENERO', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'FEBRERO', 2);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'MARZO', 3);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'ABRIL', 4);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'MAYO', 5);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'JUNIO', 6);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'JULIO', 7);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'AGOSTO', 8);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'SEPTIEMBRE', 9);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'OCTUBRE', 10);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'NOVIEMBRE', 11);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(2, 'DICIEMBRE', 12);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'ENERO-FEBRERO', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'MARZO-ABRIL', 2);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'MAYO-JUNIO', 3);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'JULIO-AGOSTO', 4);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'SEPTIEMBRE-OCTUBRE', 5);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(3, 'NOVIEMBRE-DICIEMBRE', 6);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(4, 'ENERO-MARZO', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(4, 'ABRIL-JUNIO', 2);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(4, 'JULIO-SEPTIEMBRE', 3);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(4, 'OCTUBRE-DICIEMBRE', 4);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(5, 'ENERO-ABRIL', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(5, 'MAYO-AGOSTO', 2);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(5, 'SEPTIEMBRE-DICIEMBRE', 3);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(6, 'ENERO-JUNIO', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(6, 'JULIO-DICIEMBRE', 2);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 1', 1);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 2', 2);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 3', 3);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 4', 4);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 5', 5);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 6', 6);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 7', 7);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 8', 8);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 9', 9);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 10', 10);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 11', 11);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 12', 12);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 13', 13);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 14', 14);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 15', 15);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 16', 16);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 17', 17);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 18', 18);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 19', 19);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 20', 20);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 21', 21);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 22', 22);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 23', 23);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 24', 24);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 25', 25);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 26', 26);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 27', 27);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 28', 28);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 29', 29);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 30', 30);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 31', 31);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 32', 32);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 33', 33);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 34', 34);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 35', 35);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 36', 36);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 37', 37);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 38', 38);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 39', 39);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 40', 40);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 41', 41);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 42', 42);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 43', 43);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 44', 44);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 45', 45);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 46', 46);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 47', 47);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 48', 48);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 49', 49);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 50', 50);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 51', 51);
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(7, 'SEMANA 52', 52);
    
    INSERT INTO cat_periodos_pagos(idu_tipo_periodo,des_periodo, idu_periodo )
    VALUES(8, 'AÑO', 1);

-- Índices
    create index IX_cat_periodos_pagos_idu_tipo_periodo on cat_periodos_pagos(idu_tipo_periodo);
    create index IX_cat_periodos_pagos_idu_periodo on cat_periodos_pagos(idu_periodo);

-- Documentación
    comment on table cat_periodos_pagos is 'Catálogo de períodos de pago de Colegiaturas';

    comment on column cat_periodos_pagos.idu_tipo_periodo is 'ID del tipo de período'; 
    comment on column cat_periodos_pagos.des_periodo is 'Nombre del período';
    comment on column cat_periodos_pagos.idu_periodo is 'ID del período';
