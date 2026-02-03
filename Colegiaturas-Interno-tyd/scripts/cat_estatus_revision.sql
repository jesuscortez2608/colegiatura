CREATE TABLE cat_estatus_revision
(
  idu_estatus_revision integer NOT NULL,
  des_estatus_revision character varying(30) NOT NULL
);

CREATE INDEX idx_cat_estatus_revision_des_estatus_revision ON cat_estatus_revision (des_estatus_revision );
CREATE INDEX idx_cat_estatus_revision_idu_estatus_revision ON cat_estatus_revision (idu_estatus_revision);

INSERT INTO cat_estatus_revision (idu_estatus_revision,  des_estatus_revision) VALUES (1,'PENDIENTES');
INSERT INTO cat_estatus_revision (idu_estatus_revision,  des_estatus_revision) VALUES (2,'REVISADOS');
