DROP TABLE IF EXISTS bit_proceso_colegiaturas;
CREATE TABLE bit_proceso_colegiaturas(
	id_movimiento INTEGER NOT NULL DEFAULT 0
	, fec_movimiento TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
	, num_facturas BIGINT NOT NULL DEFAULT 0
	, num_colaboradores BIGINT NOT NULL DEFAULT 0
	, fec_quincena DATE NOT NULL DEFAULT '1900-01-01'
	, id_usuario BIGINT NOT NULL DEFAULT 0
	, keyx BIGSERIAL
);

DROP TABLE IF EXISTS cat_movimientos_proceso_colegiaturas;
CREATE TABLE cat_movimientos_proceso_colegiaturas(
	id_movimiento INTEGER NOT NULL DEFAULT 0
	, nom_movimiento CHARACTER VARYING(150) NOT NULL DEFAULT ''
	, fec_registro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
	, id_usuario BIGINT NOT NULL DEFAULT 91432391
);

INSERT INTO cat_movimientos_proceso_colegiaturas(id_movimiento, nom_movimiento)
VALUES(1, 'TRASPASO DE MOVIMIENTOS')
	,(2, 'GENERACIÓN DE PAGOS DE COLEGIATURAS')
	,(3, 'GENERACIÓN DE INCENTIVOS')
	,(4, 'UNIFICACIÓN DE INCENTIVOS')
	,(5, 'ENVIO DE INCENTIVOS')
	,(6, 'GENERACIÓN DE CIERRE DE COLEGIATURAS');