/*
Colaborador: 98439677 - Rafael Ramos
Sistema: 	Colegiaturas
APS: 		23187
Opcion: 	Subir facturas
*/
DROP TABLE IF EXISTS CTL_TIPORELACIONCFDI_COLEGIATURAS ;
CREATE TABLE CTL_TIPORELACIONCFDI_COLEGIATURAS (
	id SERIAL
	, id_tiporelacion INTEGER NOT NULL DEFAULT 0
	, nom_tiporelacion CHARACTER VARYING(150) NOT NULL DEFAULT ''
	, id_colaboradorregistro INTEGER NOT NULL DEFAULT 0
	, fec_registro DATE DEFAULT NOW()::DATE
);

CREATE INDEX idx_ctl_tiporelacioncfdi_colegiaturas_id_tiporelacion ON ctl_tiporelacioncfdi_colegiaturas(id_tiporelacion);

INSERT INTO CTL_TIPORELACIONCFDI_COLEGIATURAS(id_tiporelacion, nom_tiporelacion, id_colaboradorregistro)
VALUES (1,'NOTA DE CREDITO', 98439677),
(2,'NOTA DE DEBITO DE LOS DOCTOS. RELACIONADOS', 98439677),
(4,'SUSTITUCI&OACUTE;N DE CFDI', 98439677),
(7,'CFDI POR APLICACI&OACUTE;N DE ANTICIPO', 98439677);


GRANT ALL ON TABLE CTL_TIPORELACIONCFDI_COLEGIATURAS TO syspersonal;