CREATE TABLE cat_ciudades_colegiaturas
(
  idu_estado integer NOT NULL DEFAULT 0,
  idu_ciudad integer NOT NULL DEFAULT 0,
  nom_ciudad character varying(100) NOT NULL DEFAULT ''::character varying,
  fec_registro timestamp without time zone NOT NULL DEFAULT now(),
  idu_empleado_registro integer NOT NULL,
  keyx serial
);
-- Index: idx_cat_ciudades_colegiaturas_idu_ciudad

-- DROP INDEX idx_cat_ciudades_colegiaturas_idu_ciudad;

CREATE INDEX idx_cat_ciudades_colegiaturas_idu_ciudad ON cat_ciudades_colegiaturas (idu_ciudad );

-- Index: idx_cat_ciudades_colegiaturas_idu_estado

-- DROP INDEX idx_cat_ciudades_colegiaturas_idu_estado;

CREATE INDEX idx_cat_ciudades_colegiaturas_idu_estado ON cat_ciudades_colegiaturas (idu_estado );

-- Index: idx_cat_ciudades_colegiaturas_keyx

-- DROP INDEX idx_cat_ciudades_colegiaturas_keyx;

CREATE INDEX idx_cat_ciudades_colegiaturas_keyx ON cat_ciudades_colegiaturas (keyx );

-- Index: idx_cat_ciudades_colegiaturas_nom_ciudad

-- DROP INDEX idx_cat_ciudades_colegiaturas_nom_ciudad;

CREATE INDEX idx_cat_ciudades_colegiaturas_nom_ciudad ON cat_ciudades_colegiaturas (nom_ciudad);

