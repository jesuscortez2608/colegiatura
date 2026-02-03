CREATE TABLE cat_motivos_colegiaturas
(
  idu_motivo integer NOT NULL,
  idu_tipo_motivo integer NOT NULL,
  des_motivo character varying(100) NOT NULL,
  fec_captura timestamp without time zone DEFAULT now(),
  idu_empleado_registro integer NOT NULL,
  estatus integer NOT NULL DEFAULT 1
);

CREATE INDEX idx_cat_motivos_colegiaturas_des_motivo ON cat_motivos_colegiaturas (des_motivo);
CREATE INDEX idx_cat_motivos_colegiaturas_estatus ON cat_motivos_colegiaturas (estatus);
CREATE INDEX idx_cat_motivos_colegiaturas_fec_captura ON cat_motivos_colegiaturas (fec_captura);
CREATE INDEX idx_cat_motivos_colegiaturas_idu_empleado_registro ON cat_motivos_colegiaturas (idu_empleado_registro);
CREATE INDEX idx_cat_motivos_colegiaturas_idu_motivo ON cat_motivos_colegiaturas (idu_motivo);
CREATE INDEX idx_cat_motivos_colegiaturas_idu_tipo_motivo ON cat_motivos_colegiaturas (idu_tipo_motivo);

INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(1,1,	'RFC DE LA ESCUELA ESTA MAL CAPTURADO',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(2,1,	'EL ESTUDIO EN LA FACTURA NO ESTA CUBIERTO',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(3,2,	'LOS IMPORTES NO COINCIDEN',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(4,2,	'NO EXISTE LA ESCUELA',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(5,2,	'NO EXISTEN COSTOS',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(6,3,	'LOS BENEFICIARIOS NO COINCIDEN',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(7,3,	'LA FACTURA NO ES DE COLEGIATURAS',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(8,3,	'EL COLABORADOR SERÁ DADO DE BAJA',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(9,4,	'ESCUELA NO EXISTE',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(10,4,'NO EXISTE COSTO',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(11,4,'LOS COSTOS NO COINCIDEN',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(12,5,'POR PRONTO PAGO',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(13,5,'POR HERMANO EN LA MISMA ESCUELA',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(14,5,'POR RECOMENDACION',NOW(),94827443,1);
INSERT INTO CAT_MOTIVOS_COLEGIATURAS (idu_motivo, idu_tipo_motivo, des_motivo, fec_captura, idu_empleado_registro, estatus)
VALUES(15,5,'POR CALIFICACIONES',NOW(),94827443,1);




