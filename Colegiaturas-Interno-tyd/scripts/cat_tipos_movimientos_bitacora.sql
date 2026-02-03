DROP TABLE IF EXISTS cat_tipos_movimientos_bitacora;

CREATE TABLE cat_tipos_movimientos_bitacora
(
  idu_tipo_movimiento SERIAL, -- Identificador único del catálogo (SERIAL)
  nom_tipo_movimiento character varying(40) NOT NULL DEFAULT ''::character varying, -- Nombre del tipo de movimiento
  fec_registro timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de registro o captura
  idu_empleado_registro integer NOT NULL -- Usuario que registró
);

COMMENT ON TABLE cat_tipos_movimientos_bitacora
  IS 'Catálogo de tipos de movimientos en bitácora';
COMMENT ON COLUMN cat_tipos_movimientos_bitacora.idu_tipo_movimiento IS 'Identificador único del catálogo (SERIAL)';
COMMENT ON COLUMN cat_tipos_movimientos_bitacora.nom_tipo_movimiento IS 'Nombre del tipo de movimiento';
COMMENT ON COLUMN cat_tipos_movimientos_bitacora.fec_registro IS 'Fecha de registro o captura';
COMMENT ON COLUMN cat_tipos_movimientos_bitacora.idu_empleado_registro IS 'Usuario que registró';

--Indices
CREATE INDEX idx_cat_tipos_movimientos_bitacora_fec_registro ON cat_tipos_movimientos_bitacora (fec_registro);
CREATE INDEX idx_cat_tipos_movimientos_bitacora_idu_empleado_registro ON cat_tipos_movimientos_bitacora (idu_empleado_registro);
CREATE INDEX idx_cat_tipos_movimientos_bitacora_idu_tipo_movimiento ON cat_tipos_movimientos_bitacora (idu_tipo_movimiento);
CREATE INDEX idx_cat_tipos_movimientos_bitacora_nom_tipo_movimiento ON cat_tipos_movimientos_bitacora (nom_tipo_movimiento);

--Datos iniciales
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (1,'MODIFICAR IMPORTE CONCEPTO', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (2,'COLABORADOR BLOQUEADO', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (3,'CANCELAR PAGO', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (4,'MARCADO ESPECIAL', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (5,'DESMARCADO ESPECIAL', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (6,'CONCEPTOS PAGABLES', now(), 95194185);
INSERT INTO cat_tipos_movimientos_bitacora(idu_tipo_movimiento, nom_tipo_movimiento, fec_registro, idu_empleado_registro) VALUES (7,'PRESTACION ANTES DE TIEMPO', now(), 95194185);