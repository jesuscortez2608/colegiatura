/*
	No. petición APS               : 16559.1
	Fecha                          : 15/11/2016
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : cat_estados_colegiaturas
------------------------------------------------------------------------------------------------------ */
drop table if exists cat_estados_colegiaturas;

CREATE TABLE cat_estados_colegiaturas
(
  idu_estado integer NOT NULL DEFAULT 0,
	nom_estado VARCHAR(60) NOT NULL DEFAULT '',
	fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT(NOW()),
  idu_empleado_registro integer NOT NULL,
  keyx serial
);

-- Índices
CREATE INDEX idx_cat_estados_colegiaturas_idu_estado ON cat_estados_colegiaturas (idu_estado);
CREATE INDEX idx_cat_estados_colegiaturas_nom_estado ON cat_estados_colegiaturas (nom_estado);
CREATE INDEX idx_cat_estados_colegiaturas_keyx ON cat_estados_colegiaturas (keyx);

-- Datos
insert into cat_estados_colegiaturas(idu_estado, nom_estado, idu_empleado_registro)
values (0,'EXTRANJERO/EN LINEA',95194185),
    (1,'AGUASCALIENTES',95194185),
    (2,'BAJA CALIFORNIA',95194185),
    (3,'BAJA CALIFORNIA SUR',95194185),
    (4,'CAMPECHE',95194185),
    (5,'COAHUILA DE ZARAGOZA',95194185),
    (6,'COLIMA',95194185),
    (7,'CHIAPAS',95194185),
    (8,'CHIHUAHUA',95194185),
    (9,'DISTRITO FEDERAL',95194185),
    (10,'DURANGO',95194185),
    (11,'GUANAJUATO',95194185),
    (12,'GUERRERO',95194185),
    (13,'HIDALGO',95194185),
    (14,'JALISCO',95194185),
    (15,'MÉXICO',95194185),
    (16,'MICHOACÁN DE OCAMPO',95194185),
    (17,'MORELOS',95194185),
    (18,'NAYARIT',95194185),
    (19,'NUEVO LEÓN',95194185),
    (20,'OAXACA',95194185),
    (21,'PUEBLA',95194185),
    (22,'QUERÉTARO',95194185),
    (23,'QUINTANA ROO',95194185),
    (24,'SAN LUIS POTOSÍ',95194185),
    (25,'SINALOA',95194185),
    (26,'SONORA',95194185),
    (27,'TABASCO',95194185),
    (28,'TAMAULIPAS',95194185),
    (29,'TLAXCALA',95194185),
    (30,'VERACRUZ DE IGNACIO DE LA LLAVE',95194185),
    (31,'YUCATÁN',95194185),
    (32,'ZACATECAS',95194185);
