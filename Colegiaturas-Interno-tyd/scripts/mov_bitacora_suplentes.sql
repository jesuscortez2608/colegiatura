/*
	No. petición APS               : 8613.1
	Fecha                          : 02/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallelly Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
		
------------------------------------------------------------------------------------------------------ */

-- Definición
DROP TABLE IF EXISTS mov_bitacora_suplentes;
CREATE TABLE mov_bitacora_suplentes
(
  idu_empleado integer NOT NULL,
  idu_suplente integer NOT NULL,
  idu_empleado_registro integer NOT NULL,
  fec_registro timestamp without time zone,
  fec_inicial timestamp without time zone,
  fec_final timestamp without time zone,
  opc_indefinido integer NOT NULL,
  opc_expirado integer NOT NULL,
  opc_cancelado integer NOT NULL,
  idu_empleado_cancelo integer
);

-- Index: idx_mov_bitacora_suplentes_fec_final

-- DROP INDEX idx_mov_bitacora_suplentes_fec_final;

CREATE INDEX idx_mov_bitacora_suplentes_fec_final ON mov_bitacora_suplentes (fec_final );

-- Index: idx_mov_bitacora_suplentes_fec_inicial

-- DROP INDEX idx_mov_bitacora_suplentes_fec_inicial;

CREATE INDEX idx_mov_bitacora_suplentes_fec_inicial ON mov_bitacora_suplentes (fec_inicial );

-- Index: idx_mov_bitacora_suplentes_fec_registro

-- DROP INDEX idx_mov_bitacora_suplentes_fec_registro;

CREATE INDEX idx_mov_bitacora_suplentes_fec_registro ON mov_bitacora_suplentes (fec_registro );

-- Index: idx_mov_bitacora_suplentes_idu_empleado

-- DROP INDEX idx_mov_bitacora_suplentes_idu_empleado;

CREATE INDEX idx_mov_bitacora_suplentes_idu_empleado ON mov_bitacora_suplentes (idu_empleado );

-- Index: idx_mov_bitacora_suplentes_idu_empleado_cancelo

-- DROP INDEX idx_mov_bitacora_suplentes_idu_empleado_cancelo;

CREATE INDEX idx_mov_bitacora_suplentes_idu_empleado_cancelo ON mov_bitacora_suplentes (idu_empleado_cancelo );

-- Index: idx_mov_bitacora_suplentes_idu_empleado_registro

-- DROP INDEX idx_mov_bitacora_suplentes_idu_empleado_registro;

CREATE INDEX idx_mov_bitacora_suplentes_idu_empleado_registro ON mov_bitacora_suplentes (idu_empleado_registro );

-- Index: idx_mov_bitacora_suplentes_idu_suplente

-- DROP INDEX idx_mov_bitacora_suplentes_idu_suplente;

CREATE INDEX idx_mov_bitacora_suplentes_idu_suplente ON mov_bitacora_suplentes (idu_suplente );

-- Index: idx_mov_bitacora_suplentes_opc_cancelado

-- DROP INDEX idx_mov_bitacora_suplentes_opc_cancelado;

CREATE INDEX idx_mov_bitacora_suplentes_opc_cancelado ON mov_bitacora_suplentes (opc_cancelado );

-- Index: idx_mov_bitacora_suplentes_opc_expirado

-- DROP INDEX idx_mov_bitacora_suplentes_opc_expirado;

CREATE INDEX idx_mov_bitacora_suplentes_opc_expirado ON mov_bitacora_suplentes (opc_expirado );

-- Index: idx_mov_bitacora_suplentes_opc_indefinido

-- DROP INDEX idx_mov_bitacora_suplentes_opc_indefinido;

CREATE INDEX idx_mov_bitacora_suplentes_opc_indefinido ON mov_bitacora_suplentes (opc_indefinido );

