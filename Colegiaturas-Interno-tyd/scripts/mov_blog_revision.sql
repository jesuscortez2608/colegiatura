CREATE TABLE mov_blog_revision
(
  id_factura integer, -- ID de la factura mov_facturas_colegiaturas.id_factura
  idu_empleado_origen integer NOT NULL, -- ID del usuario que envía el mensaje
  idu_empleado_destino integer NOT NULL, -- ID del usuario que recibe el mensaje
  comentario text NOT NULL DEFAULT ''::text, -- Comentario o contenido del mensaje
  opc_leido smallint NOT NULL DEFAULT 0, -- Indica si el comentario fue leído por el destinatario
  fec_registro timestamp without time zone DEFAULT now() -- Fecha de registro del mensaje
);

COMMENT ON TABLE mov_blog_revision IS 'Tabla para controlar el blog de facturas en revisión (Colegiaturas)';
COMMENT ON COLUMN mov_blog_revision.id_factura IS 'ID de la factura mov_facturas_colegiaturas.id_factura';
COMMENT ON COLUMN mov_blog_revision.idu_empleado_origen IS 'ID del usuario que envía el mensaje';
COMMENT ON COLUMN mov_blog_revision.idu_empleado_destino IS 'ID del usuario que recibe el mensaje';
COMMENT ON COLUMN mov_blog_revision.comentario IS 'Comentario o contenido del mensaje';
COMMENT ON COLUMN mov_blog_revision.opc_leido IS 'Indica si el comentario fue leído por el destinatario';
COMMENT ON COLUMN mov_blog_revision.fec_registro IS 'Fecha de registro del mensaje';

CREATE INDEX idx_mov_blog_revision_fec_registro ON mov_blog_revision (fec_registro);
CREATE INDEX idx_mov_blog_revision_id_factura ON mov_blog_revision (id_factura);
CREATE INDEX idx_mov_blog_revision_idu_empleado_destino ON mov_blog_revision (idu_empleado_destino);
CREATE INDEX idx_mov_blog_revision_idu_empleado_origen ON mov_blog_revision (idu_empleado_origen);
CREATE INDEX idx_mov_blog_revision_opc_leido ON mov_blog_revision (opc_leido);
