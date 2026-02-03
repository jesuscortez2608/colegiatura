/*
	No. petición APS               : 16559.1
	Fecha                          : 28/05/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : Personal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción                    : cat_rutaspagos
------------------------------------------------------------------------------------------------------ */
CREATE TABLE cat_rutaspagos
(
  idu_rutapago integer NOT NULL, -- ID de la ruta de pago
  nom_rutapago character varying(20) NOT NULL, -- Nombre de la ruta de pago
  fec_altarutapago date NOT NULL, -- Fecha en que se registró la ruta de pago
  CONSTRAINT cat_rutaspagos_pkey PRIMARY KEY (idu_rutapago)
);

GRANT ALL ON TABLE cat_rutaspagos TO syspersonal;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cat_rutaspagos TO sysproyectos;

--indices
CREATE INDEX ix_cat_rutaspagos_idu_rutapago ON cat_rutaspagos (idu_rutapago);
CREATE INDEX ix_cat_rutaspagos_idu_rutapago ON cat_rutaspagos (idu_rutapago);

--Comentarios
COMMENT ON TABLE cat_rutaspagos IS 'Catálogo de rutas de pago';
COMMENT ON COLUMN cat_rutaspagos.idu_rutapago IS 'ID de la ruta de pago';
COMMENT ON COLUMN cat_rutaspagos.nom_rutapago IS 'Nombre de la ruta de pago';
COMMENT ON COLUMN cat_rutaspagos.fec_altarutapago IS 'Fecha en que se registró la ruta de pago';


