/*
	No. petición APS               : 8613.1
	Fecha                          : 02/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS cat_parentescos;
CREATE TABLE cat_parentescos (
	idu_parentesco integer not null,
	des_parentesco varchar (10) not null default ''
);

CREATE INDEX idx_cat_parentescos_idu_parentesco ON cat_parentescos (idu_parentesco);
CREATE INDEX idx_cat_parentescos_des_parentesco ON cat_parentescos (des_parentesco);

INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (1, 'PADRES');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (2, 'HERMANO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (3, 'ESPOSO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (4, 'HIJO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (5, 'TIO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (6, 'PRIMO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (7, 'ABUELO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (8, 'SUEGRO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (9, 'AMIGO(A)');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (10, 'OTRO');
INSERT INTO cat_parentescos (idu_parentesco, des_parentesco) VALUES (11, 'EL MISMO');





