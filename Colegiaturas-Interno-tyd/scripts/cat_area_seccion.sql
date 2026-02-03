DROP TABLE IF EXISTS cat_area_seccion;

CREATE TABLE cat_area_seccion
(
  idu_area integer NOT NULL DEFAULT 0,
  nom_area character varying NOT NULL DEFAULT ''::character varying,
  idu_seccion integer NOT NULL DEFAULT 0,
  nom_seccion character varying NOT NULL DEFAULT ''::character varying,
  fec_actualizacion timestamp without time zone NOT NULL DEFAULT now()
);

--Índices
CREATE INDEX ix_cat_area_seccion_idu_area ON cat_area_seccion (idu_area);
CREATE INDEX ix_cat_area_seccion_idu_seccion ON cat_area_seccion (idu_seccion);

