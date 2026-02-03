CREATE TABLE mov_detalle_revision_colegiaturas
(
  idu_revision integer NOT NULL,
  idu_escuela integer NOT NULL,
  idu_ciclo_escolar integer NOT NULL,
  idu_escolaridad integer NOT NULL,
  idu_carrera integer NOT NULL DEFAULT 0,
  idu_tipo_pago integer NOT NULL,
  prc_descuento integer NOT NULL DEFAULT 0,
  idu_motivo integer NOT NULL,
  importe_concepto numeric(12,2),
  idu_usuario_registro integer NOT NULL DEFAULT 0,
  fec_registro date NOT NULL DEFAULT now(),
  keyx serial);
  
CREATE INDEX idx_mov_detalle_revision_colegiaturas_fec_registro
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (fec_registro);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_carrera

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_carrera;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_carrera
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_carrera);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_ciclo_escolar

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_ciclo_escolar;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_ciclo_escolar
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_ciclo_escolar);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_escolaridad

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_escolaridad;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_escolaridad
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_escolaridad);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_escuela

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_escuela;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_escuela
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_escuela);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_revision

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_revision;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_revision
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_revision);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_tipo_pago

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_tipo_pago;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_tipo_pago
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_tipo_pago);

-- Index: public.idx_mov_detalle_revision_colegiaturas_idu_usuario_registro

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_idu_usuario_registro;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_idu_usuario_registro
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (idu_usuario_registro);

-- Index: public.idx_mov_detalle_revision_colegiaturas_keyx

-- DROP INDEX public.idx_mov_detalle_revision_colegiaturas_keyx;

CREATE INDEX idx_mov_detalle_revision_colegiaturas_keyx
  ON public.mov_detalle_revision_colegiaturas
  USING btree
  (keyx);

