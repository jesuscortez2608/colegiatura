/*
	No. petición APS               : 
	Fecha                          :25/06/2018
	Número empleado                : 94827443
	Nombre del empleado            : Omar Alejandro Lizarraga Hernandez
	Base de datos                  : Personal
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : 
	Ejemplo                        : 
		cat_tipos_deduccion
------------------------------------------------------------------------------------------------------ */
-- Definición
DROP TABLE IF EXISTS mov_revision_colegiaturas;
CREATE TABLE mov_revision_colegiaturas
(
  idu_revision serial,  
  idu_escuela integer NOT NULL,
  idu_motivo_revision smallint NOT NULL,
  idu_estatus_revision smallint NOT NULL,
  idu_usuario_captura integer NOT NULL,
  fec_captura timestamp without time zone NOT NULL DEFAULT now(),
  fec_revision timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  fec_conclusion timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  usuario_revision integer NOT NULL DEFAULT 0
);

--indices
CREATE INDEX idx_mov_revision_colegiaturas_idu_revision ON mov_revision_colegiaturas (idu_revision);
CREATE INDEX idx_mov_revision_colegiaturas_idu_escuela ON mov_revision_colegiaturas (idu_escuela);
CREATE INDEX idx_mov_revision_colegiaturas_idu_idu_motivo_revision ON mov_revision_colegiaturas (idu_motivo_revision);
CREATE INDEX idx_mov_revision_colegiaturas_idu_idu_estatus_revision ON mov_revision_colegiaturas (idu_estatus_revision);
CREATE INDEX idx_mov_revision_colegiaturas_idu_usuario_captura ON mov_revision_colegiaturas (idu_usuario_captura);
CREATE INDEX idx_mov_revision_colegiaturas_fec_captura ON mov_revision_colegiaturas (fec_captura);
CREATE INDEX idx_mov_revision_colegiaturas_fec_revision ON mov_revision_colegiaturas (fec_revision);
CREATE INDEX idx_mov_revision_colegiaturas_fec_conclusion ON mov_revision_colegiaturas (fec_conclusion);
CREATE INDEX idx_mov_revision_colegiaturas_usuario_revision ON mov_revision_colegiaturas (usuario_revision);