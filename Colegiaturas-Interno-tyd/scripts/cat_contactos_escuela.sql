CREATE TABLE cat_contactos_escuela
(
  idu_contacto serial, -- Identificador único para contacto
  idu_escuela integer NOT NULL, -- ID de la Escuela que se está revisando
  nom_contacto character varying(100) NOT NULL, -- Nombre del contacto en la Escuela
  telefono character varying(100) NOT NULL DEFAULT ''::character varying, -- Teléfono del contacto en la escuela
  email character varying(100) NOT NULL DEFAULT ''::character varying, -- Correo electrónico
  area character varying(100) NOT NULL DEFAULT ''::character varying, -- Área a la que pertenece el Contacto
  ext character varying(100) NOT NULL DEFAULT ''::character varying, -- Número de extensión
  observaciones text NOT NULL DEFAULT ''::text, -- Observaciones
  idu_usuario_registro integer NOT NULL DEFAULT 0, -- Colaborador o usuario de captura
  fec_registro date NOT NULL DEFAULT now() -- Fecha de captura
);
COMMENT ON TABLE cat_contactos_escuela IS 'Tabla donde se guardan los contactos por Escuela ';
COMMENT ON COLUMN cat_contactos_escuela.idu_contacto IS 'Identificador único para contacto';
COMMENT ON COLUMN cat_contactos_escuela.idu_escuela IS 'ID de la Escuela que se está revisando';
COMMENT ON COLUMN cat_contactos_escuela.nom_contacto IS 'Nombre del contacto en la Escuela';
COMMENT ON COLUMN cat_contactos_escuela.telefono IS 'Teléfono del contacto en la escuela';
COMMENT ON COLUMN cat_contactos_escuela.email IS 'Correo electrónico';
COMMENT ON COLUMN cat_contactos_escuela.area IS 'Área a la que pertenece el Contacto';
COMMENT ON COLUMN cat_contactos_escuela.ext IS 'Número de extensión';
COMMENT ON COLUMN cat_contactos_escuela.observaciones IS 'Observaciones';
COMMENT ON COLUMN cat_contactos_escuela.idu_usuario_registro IS 'Colaborador o usuario de captura';
COMMENT ON COLUMN cat_contactos_escuela.fec_registro IS 'Fecha de captura';

CREATE INDEX idx_cat_contactos_escuela_fec_registro ON cat_contactos_escuela (fec_registro);
CREATE INDEX idx_cat_contactos_escuela_idu_contacto ON cat_contactos_escuela (idu_contacto);
CREATE INDEX idx_cat_contactos_escuela_idu_escuela ON cat_contactos_escuela (idu_escuela);
CREATE INDEX idx_cat_contactos_escuela_idu_usuario_registro ON cat_contactos_escuela (idu_usuario_registro);

