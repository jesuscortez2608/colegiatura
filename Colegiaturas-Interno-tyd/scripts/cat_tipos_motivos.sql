/*
	No. petición APS               : 8613.1
	Fecha                          : 02/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
------------------------------------------------------------------------------------------------------ */

-- Definición
	DROP TABLE IF EXISTS cat_tipos_motivos;
	
	CREATE TABLE cat_tipos_motivos (idu_tipo_motivo INT NOT NULL
		, des_tipo_motivo VARCHAR(30) NOT NULL
		);
	
-- Datos
	INSERT INTO cat_tipos_motivos (idu_tipo_motivo, des_tipo_motivo) VALUES (1, 'RECHAZO');
	INSERT INTO cat_tipos_motivos (idu_tipo_motivo, des_tipo_motivo) VALUES (2, 'ACLARACION');
	INSERT INTO cat_tipos_motivos (idu_tipo_motivo, des_tipo_motivo) VALUES (3, 'RECHAZO GERENTE');
	INSERT INTO cat_tipos_motivos (idu_tipo_motivo, des_tipo_motivo) VALUES (4, 'REVISION');
	INSERT INTO cat_tipos_motivos (idu_tipo_motivo, des_tipo_motivo) VALUES (5, 'DESCUENTO');
	
-- Índices
	CREATE INDEX idx_cat_tipos_motivos_idu_tipo_motivo ON cat_tipos_motivos (idu_tipo_motivo);
	CREATE INDEX idx_cat_tipos_motivos_des_tipo_motivo ON cat_tipos_motivos (des_tipo_motivo);

-- Documentación
    comment on table cat_tipos_motivos is 'Catálogo de tipos de motivos para agrupar el catálogo de motivos (cat_motivos_colegiaturas)';
    
    comment on column cat_tipos_motivos.idu_tipo_motivo is 'ID del tipo de motivo'; 
    comment on column cat_tipos_motivos.des_tipo_motivo is 'Descripción del tipo de motivo'; 
