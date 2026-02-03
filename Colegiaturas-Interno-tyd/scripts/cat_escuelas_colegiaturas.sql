DROP TABLE IF EXISTS cat_escuelas_colegiaturas;

CREATE TABLE cat_escuelas_colegiaturas
(
    idu_escuela INTEGER NOT NULL DEFAULT 0,
    opc_tipo_escuela INTEGER NOT NULL DEFAULT 0,
    rfc_clave_sep character varying(20) NOT NULL DEFAULT ' '::character varying,
    nom_escuela character varying(100) NOT NULL DEFAULT ' '::character varying,
    razon_social CHARACTER VARYING(150) NOT NULL DEFAULT ' '::CHARACTER VARYING,
    idu_escolaridad INTEGER NOT NULL DEFAULT 0,
    idu_carrera INTEGER NOT NULL DEFAULT 0,
    opc_educacion_especial INTEGER NOT NULL DEFAULT 0,
    opc_obligatorio_pdf INTEGER NOT NULL DEFAULT 0,
    opc_nota_credito SMALLINT NOT NULL DEFAULT 0,
    idu_tipo_deduccion INTEGER NOT NULL DEFAULT 0,
    opc_escuela_bloqueada INTEGER ,
    clave_sep varchar(20) not null default (''),
    idu_estado INTEGER NOT NULL DEFAULT(0),
    idu_municipio INTEGER NOT NULL DEFAULT(0),
    idu_localidad INTEGER NOT NULL DEFAULT(0),
    nom_contacto VARCHAR(50) NOT NULL DEFAULT(''),
    email_contacto VARCHAR(50) NOT NULL DEFAULT(''),
    tel_contacto VARCHAR(50) NOT NULL DEFAULT(''),
    ext_contacto VARCHAR(50) NOT NULL DEFAULT(''),
    area_contacto VARCHAR(50) NOT NULL DEFAULT(''),
    fec_captura TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    id_empleado_registro INTEGER NOT NULL DEFAULT 0,
    observaciones character varying(300) NOT NULL DEFAULT ' '::character varying
);

CREATE INDEX idx_cat_escuelas_colegiaturas_fec_captura ON cat_escuelas_colegiaturas (fec_captura);
CREATE INDEX idx_cat_escuelas_colegiaturas_id_empleado_registro ON cat_escuelas_colegiaturas (id_empleado_registro);
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_escolaridad ON cat_escuelas_colegiaturas (idu_escolaridad);
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_carrera ON cat_escuelas_colegiaturas (idu_carrera);
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_escuela ON cat_escuelas_colegiaturas (idu_escuela);
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_tipo_deduccion ON cat_escuelas_colegiaturas (idu_tipo_deduccion);
CREATE INDEX idx_cat_escuelas_colegiaturas_nom_escuela ON cat_escuelas_colegiaturas (nom_escuela);
CREATE INDEX idx_cat_escuelas_colegiaturas_opc_educacion_especial ON cat_escuelas_colegiaturas (opc_educacion_especial);
CREATE INDEX idx_cat_escuelas_colegiaturas_opc_escuela_bloqueada ON cat_escuelas_colegiaturas (opc_escuela_bloqueada);
CREATE INDEX idx_cat_escuelas_colegiaturas_opc_obligatorio_pdf ON cat_escuelas_colegiaturas (opc_obligatorio_pdf);
CREATE INDEX idx_cat_escuelas_colegiaturas_opc_tipo_escuela ON cat_escuelas_colegiaturas (opc_tipo_escuela);
CREATE INDEX idx_cat_escuelas_colegiaturas_rfc_clave_sep ON cat_escuelas_colegiaturas (rfc_clave_sep);
CREATE INDEX idx_cat_escuelas_colegiaturas_clave_sep ON cat_escuelas_colegiaturas (clave_sep);

DROP INDEX if exists idx_cat_escuelas_colegiaturas_idu_estado;  
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_estado
  ON cat_escuelas_colegiaturas(idu_estado);

DROP INDEX if exists idx_cat_escuelas_colegiaturas_idu_municipio; 
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_municipio
  ON cat_escuelas_colegiaturas(idu_municipio);

DROP INDEX if exists idx_cat_escuelas_colegiaturas_idu_localidad;
CREATE INDEX idx_cat_escuelas_colegiaturas_idu_localidad
  ON cat_escuelas_colegiaturas (idu_localidad);

