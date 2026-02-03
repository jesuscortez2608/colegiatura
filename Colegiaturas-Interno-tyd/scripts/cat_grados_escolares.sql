/*
	No. petición APS               : 8613.1
	Fecha                          : 13/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_grados_escolares;
CREATE TABLE cat_grados_escolares
(
	idu_escolaridad INTEGER NOT NULL DEFAULT 0,
	idu_grado_escolar INTEGER NOT NULL DEFAULT 0,
	nom_grado_escolar VARCHAR(50) NOT NULL DEFAULT ''
);

-- Índices
CREATE INDEX idx_cat_grados_escolares_idu_escolaridad ON cat_grados_escolares (idu_escolaridad);
CREATE INDEX idx_cat_grados_escolares_idu_grado_escolar ON cat_grados_escolares (idu_grado_escolar);

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (1, 0, 'MATERNO');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (2, 1, 'PRIMERO DE KINDER');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (2, 2, 'SEGUNDO DE KINDER');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 1, 'PRIMERO DE PRIMARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 2, 'SEGUNDO DE PRIMARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 3, 'TERCERO DE PRIMARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 4, 'CUARTO DE PRIMARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 5, 'QUINTO DE PRIMARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (3, 6, 'SEXTO DE PRIMARIA');


INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (4, 1, 'PRIMERO DE SECUNDARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (4, 2, 'SEGUNDO DE SECUNDARIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (4, 3, 'TERCERO DE SECUNDARIA');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (5, 1, 'PRIMERO DE PREPARATORIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (5, 2, 'SEGUNDO DE PREPARATORIA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (5, 3, 'TERCERO DE PREPARATORIA');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (6, 1, 'PRIMERO DE PROFESIONAL');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (6, 2, 'SEGUNDO DE PROFESIONAL');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (6, 3, 'TERCERO DE PROFESIONAL');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (6, 4, 'CUARTO DE PROFESIONAL');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (6, 5, 'QUINTO DE PROFESIONAL');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (7, 1, 'PRIMERO DE MAESTRÍA');
INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (7, 2, 'SEGUNDO DE MAESTRÍA');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (8, 0, 'INGLÉS');

INSERT INTO cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar) VALUES (9, 0, 'OTRO IDIOMA');