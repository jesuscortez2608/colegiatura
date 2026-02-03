
DROP TABLE IF EXISTS cat_ciclos_escolares;
CREATE TABLE cat_ciclos_escolares(
	idu_ciclo_escolar integer not null default 2000,
	des_ciclo_escolar varchar(30) not null default '',
	fec_alta  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

INSERT INTO cat_ciclos_escolares(idu_ciclo_escolar, des_ciclo_escolar)
VALUES (2015,'2015 - 2016');
INSERT INTO cat_ciclos_escolares(idu_ciclo_escolar, des_ciclo_escolar)
VALUES (2016,'2016 - 2017');
INSERT INTO cat_ciclos_escolares(idu_ciclo_escolar, des_ciclo_escolar)
VALUES (2017,'2017 - 2018');
INSERT INTO cat_ciclos_escolares(idu_ciclo_escolar, des_ciclo_escolar)
VALUES (2018,'2018 - 2019');

-- Índices
create index IX_cat_ciclos_escolares_idu_ciclo_escolar on cat_ciclos_escolares(idu_ciclo_escolar);

-- Documentación
comment on table cat_ciclos_escolares is 'Catálogo de ciclos escolares';

comment on column cat_ciclos_escolares.idu_ciclo_escolar is 'Identificador para el ciclo, normalmente es el año de comienzo del ciclo'; 
comment on column cat_ciclos_escolares.des_ciclo_escolar is 'Nombre del ciclo escolar, ej. 2017-2018'; 
comment on column cat_ciclos_escolares.fec_alta is 'Fecha de captura del ciclo'; 
