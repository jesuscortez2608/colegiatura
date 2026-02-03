
DROP TABLE IF EXISTS cat_descuentos_colegiaturas;
CREATE TABLE cat_descuentos_colegiaturas
(
  prc_descuento integer NOT NULL DEFAULT 0,
  des_descuento character varying(10) NOT NULL DEFAULT '',
  emp_registro integer NOT NULL DEFAULT 0,
  fec_registro date NOT NULL DEFAULT now()
);

INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (50,'50%',93902761);
INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (60,'60%',93902761);
INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (70,'70%',93902761);
INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (80,'80%',93902761);
INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (90,'90%',93902761);
INSERT INTO cat_descuentos_colegiaturas (prc_descuento, des_descuento, emp_registro) VALUES (100,'100%',93902761);