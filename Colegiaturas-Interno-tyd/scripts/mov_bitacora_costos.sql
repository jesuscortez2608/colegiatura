DROP TABLE IF EXISTS mov_bitacora_costos;

CREATE TABLE mov_bitacora_costos
(
  idu_revision integer NOT NULL, -- ID de la revisión
  idu_motivo_revision integer NOT NULL DEFAULT 0, -- ID del motivo de revisión
  idu_tipo_revision integer NOT NULL DEFAULT 0, -- ID del tipo de revisión o modificación que se llevó a cabo
  idu_estado integer NOT NULL DEFAULT 0, -- ID del Estado donde se encuentra la escuela
  idu_municipio integer NOT NULL DEFAULT 0, -- ID del Municipio donde se encuentra la escuela
  idu_escuela integer NOT NULL DEFAULT 0, -- ID de la Escuela
  nom_escuela character varying(100) NOT NULL DEFAULT ''::character varying, -- Nombre de la Escuela (si se actualizó)
  rfc character varying(20) NOT NULL DEFAULT ''::character varying, -- RFC de la Escuela
  clave_sep character varying(20) NOT NULL DEFAULT ''::character varying,
  razon_social character varying(150) NOT NULL DEFAULT ''::character varying, -- Razón Social de la Escuela
  nom_contacto character varying(50) NOT NULL DEFAULT ''::character varying, -- Nombre del contacto en la escuela
  email_contacto character varying(50) NOT NULL DEFAULT ''::character varying, -- E-mail del contacto
  tel_contacto character varying(50) NOT NULL DEFAULT ''::character varying, -- Teléfono
  ext_contacto character varying(50) NOT NULL DEFAULT ''::character varying, -- Extensión
  area_contacto character varying(50) NOT NULL DEFAULT ''::character varying, -- Área de la escuela donde labora el contacto
  idu_ciclo_escolar integer NOT NULL DEFAULT 0, -- ID del ciclo escolar
  idu_escolaridad integer NOT NULL DEFAULT 0, -- ID de la escolaridad
  idu_carrera integer NOT NULL DEFAULT 0, -- ID de la carrera
  idu_tipo_periodo integer NOT NULL DEFAULT 0, -- ID del tipo de periodo
  prc_descuento integer NOT NULL DEFAULT 0, -- Porcentaje de descuento
  idu_motivo integer NOT NULL DEFAULT 0, -- ID del motivo de descuento
  importe_concepto numeric(12,2) NOT NULL DEFAULT 0, -- Importe del concepto
  porcentaje_tolerancia integer NOT NULL DEFAULT 0, -- Porcentaje de tolerancia
  fec_pendiente timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se recibe el pendiente
  fec_revision timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se guarda o modifican costos
  fec_conclusion timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone, -- Fecha en que se concluye una revisión
  opc_frecuente integer NOT NULL DEFAULT 0, -- Indica si la escuela ha tenido más de tres revisiones en los últimos 15 días
  idu_usuario integer NOT NULL -- Usuario que revisa
);

--Informacion
COMMENT ON TABLE mov_bitacora_costos
  IS 'Bitácora de movimientos para adición y actualización de costos de colegiaturas';
COMMENT ON COLUMN mov_bitacora_costos.idu_revision IS 'ID de la revisión';
COMMENT ON COLUMN mov_bitacora_costos.idu_motivo_revision IS 'ID del motivo de revisión';
COMMENT ON COLUMN mov_bitacora_costos.idu_tipo_revision IS 'ID del tipo de revisión o modificación que se llevó a cabo';
COMMENT ON COLUMN mov_bitacora_costos.idu_estado IS 'ID del Estado donde se encuentra la escuela';
COMMENT ON COLUMN mov_bitacora_costos.idu_municipio IS 'ID del Municipio donde se encuentra la escuela';
COMMENT ON COLUMN mov_bitacora_costos.idu_escuela IS 'ID de la Escuela';
COMMENT ON COLUMN mov_bitacora_costos.nom_escuela IS 'Nombre de la Escuela (si se actualizó)';
COMMENT ON COLUMN mov_bitacora_costos.rfc IS 'RFC de la Escuela';
COMMENT ON COLUMN mov_bitacora_costos.razon_social IS 'Razón Social de la Escuela';
COMMENT ON COLUMN mov_bitacora_costos.nom_contacto IS 'Nombre del contacto en la escuela';
COMMENT ON COLUMN mov_bitacora_costos.email_contacto IS 'E-mail del contacto';
COMMENT ON COLUMN mov_bitacora_costos.tel_contacto IS 'Teléfono';
COMMENT ON COLUMN mov_bitacora_costos.ext_contacto IS 'Extensión';
COMMENT ON COLUMN mov_bitacora_costos.area_contacto IS 'Área de la escuela donde labora el contacto';
COMMENT ON COLUMN mov_bitacora_costos.idu_ciclo_escolar IS 'ID del ciclo escolar';
COMMENT ON COLUMN mov_bitacora_costos.idu_escolaridad IS 'ID de la escolaridad';
COMMENT ON COLUMN mov_bitacora_costos.idu_carrera IS 'ID de la carrera';
COMMENT ON COLUMN mov_bitacora_costos.idu_tipo_periodo IS 'ID del tipo de periodo';
COMMENT ON COLUMN mov_bitacora_costos.prc_descuento IS 'Porcentaje de descuento';
COMMENT ON COLUMN mov_bitacora_costos.idu_motivo IS 'ID del motivo de descuento';
COMMENT ON COLUMN mov_bitacora_costos.importe_concepto IS 'Importe del concepto';
COMMENT ON COLUMN mov_bitacora_costos.porcentaje_tolerancia IS 'Porcentaje de tolerancia';
COMMENT ON COLUMN mov_bitacora_costos.fec_pendiente IS 'Fecha en que se recibe el pendiente';
COMMENT ON COLUMN mov_bitacora_costos.fec_revision IS 'Fecha en que se guarda o modifican costos';
COMMENT ON COLUMN mov_bitacora_costos.fec_conclusion IS 'Fecha en que se concluye una revisión';
COMMENT ON COLUMN mov_bitacora_costos.opc_frecuente IS 'Indica si la escuela ha tenido más de tres revisiones en los últimos 15 días';
COMMENT ON COLUMN mov_bitacora_costos.idu_usuario IS 'Usuario que revisa';


--Indices
CREATE INDEX idx_mov_bitacora_costos_area_contacto ON mov_bitacora_costos (area_contacto);
CREATE INDEX idx_mov_bitacora_costos_email_contacto ON mov_bitacora_costos (email_contacto);
CREATE INDEX idx_mov_bitacora_costos_ext_contacto ON mov_bitacora_costos (ext_contacto);
CREATE INDEX idx_mov_bitacora_costos_fec_conclusion ON mov_bitacora_costos (fec_conclusion);
CREATE INDEX idx_mov_bitacora_costos_fec_pendiente ON mov_bitacora_costos (fec_pendiente);
CREATE INDEX idx_mov_bitacora_costos_fec_revision ON mov_bitacora_costos (fec_revision);
CREATE INDEX idx_mov_bitacora_costos_idu_carrera ON mov_bitacora_costos (idu_carrera);
CREATE INDEX idx_mov_bitacora_costos_idu_ciclo_escolar ON mov_bitacora_costos (idu_ciclo_escolar);
CREATE INDEX idx_mov_bitacora_costos_idu_escolaridad ON mov_bitacora_costos (idu_escolaridad);
CREATE INDEX idx_mov_bitacora_costos_idu_escuela ON mov_bitacora_costos (idu_escuela);
CREATE INDEX idx_mov_bitacora_costos_idu_estado ON mov_bitacora_costos (idu_estado);
CREATE INDEX idx_mov_bitacora_costos_idu_motivo ON mov_bitacora_costos (idu_motivo);
CREATE INDEX idx_mov_bitacora_costos_idu_motivo_revision ON mov_bitacora_costos (idu_motivo_revision);
CREATE INDEX idx_mov_bitacora_costos_idu_municipio ON mov_bitacora_costos (idu_municipio);
CREATE INDEX idx_mov_bitacora_costos_idu_revision ON mov_bitacora_costos (idu_revision);
CREATE INDEX idx_mov_bitacora_costos_idu_tipo_periodo ON mov_bitacora_costos (idu_tipo_periodo);
CREATE INDEX idx_mov_bitacora_costos_idu_tipo_revision ON mov_bitacora_costos (idu_tipo_revision);
CREATE INDEX idx_mov_bitacora_costos_idu_usuario ON mov_bitacora_costos (idu_usuario);
CREATE INDEX idx_mov_bitacora_costos_importe_concepto ON mov_bitacora_costos (importe_concepto);
CREATE INDEX idx_mov_bitacora_costos_nom_contacto ON mov_bitacora_costos (nom_contacto);
CREATE INDEX idx_mov_bitacora_costos_nom_escuela ON mov_bitacora_costos (nom_escuela);
CREATE INDEX idx_mov_bitacora_costos_opc_frecuente ON mov_bitacora_costos (opc_frecuente);
CREATE INDEX idx_mov_bitacora_costos_porcentaje_tolerancia ON mov_bitacora_costos (porcentaje_tolerancia);
CREATE INDEX idx_mov_bitacora_costos_prc_descuento ON mov_bitacora_costos (prc_descuento);
CREATE INDEX idx_mov_bitacora_costos_razon_social ON mov_bitacora_costos (razon_social);
CREATE INDEX idx_mov_bitacora_costos_rfc ON mov_bitacora_costos (rfc);
CREATE INDEX idx_mov_bitacora_costos_tel_contacto ON mov_bitacora_costos (tel_contacto);

