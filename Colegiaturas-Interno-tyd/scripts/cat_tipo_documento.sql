/*
	No. petición APS               : 16559.1
	Fecha                          : 17/04/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal (postgres)
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Sistema                        : Colegiaturas Web
	Módulo                         : Autorizar Facturas Gerente.
	Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas
	Definición                     : Catálogo donde se almacenan los tipos de documentos que se capturarán en el sistema de colegiaturas
	Ejemplo                        : 
		SELECT idu_tipo_documento
			, nom_tipo_documento
			, idu_usuario_registro
			, fec_registro
		FROM cat_tipo_documento
------------------------------------------------------------------------------------------------------ */

DROP TABLE IF EXISTS cat_tipo_documento;

CREATE TABLE cat_tipo_documento (
    idu_tipo_documento INTEGER NOT NULL DEFAULT(0),
    nom_tipo_documento VARCHAR(30) NOT NULL DEFAULT(''),
    idu_usuario_registro INTEGER NOT NULL DEFAULT(0),
    fec_registro DATE NOT NULL DEFAULT NOW());

CREATE INDEX IDX_cat_tipo_documento_idu_tipo_documento ON cat_tipo_documento(idu_tipo_documento);

INSERT INTO cat_tipo_documento(idu_tipo_documento, nom_tipo_documento, idu_usuario_registro, fec_registro)
    VALUES (1, 'INGRESO', 95194185, NOW()),
            (2, 'NOTA DE CREDITO', 95194185, NOW()),
            (3, 'PAGO', 95194185, NOW()),
            (4, 'ESPECIAL', 95194185, NOW());

-- Documentación
    comment on table cat_tipo_documento is 'Catálogo de tipos de documentos para las facturas de Colegiaturas';
    
    comment on column cat_tipo_documento.idu_tipo_documento is 'ID del tipo de documento'; 
    comment on column cat_tipo_documento.nom_tipo_documento is 'Nombre del tipo de documento'; 
    comment on column cat_tipo_documento.idu_usuario_registro is 'ID del colaborador que capturó'; 
    comment on column cat_tipo_documento.fec_registro is 'Fecha de captura'; 
