CREATE TABLE cat_tipo_revision
(
  idu_tipo_revision integer NOT NULL, -- ID del tipo de revisión
  des_tipo_revision character varying(50) -- Descripción del tipo de revisión
);

CREATE INDEX idx_cat_tipo_revision_idu_tipo_revision ON cat_tipo_revision (idu_tipo_revision);

insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (1,'Modificación de datos generales');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (2,'Modificación de descuentos');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (3,'Modificación de costos de colegiaturas');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (4,'Modificación del porcentaje de tolerancia');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (5,'Modificación de datos de contacto');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (6,'Escuela revisada sin actualizar datos');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (7,'Descuentos Agregados');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (8,'Costos Agregados');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (9,'Descuentos Eliminados');
insert into cat_tipo_revision (idu_tipo_revision, des_tipo_revision)
values (10,'Costos Eliminados');
