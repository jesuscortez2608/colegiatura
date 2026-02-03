CREATE TABLE cat_motivos_revision
(
  idu_motivo_revision smallint, 
  des_motivo_revision character varying(30) 
);

CREATE INDEX ix_cat_motivos_revision_idu_motivo_revision ON cat_motivos_revision (idu_motivo_revision);