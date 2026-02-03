
/*
	No. petición APS               : 8613.1
	Fecha                          : 20/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : Administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.24
------------------------------------------------------------------------------------------------------ */
--SET CLIENT_ENCODING TO 'UTF8';
--SHOW client_encoding;
--RESET client_encoding;

DROP TABLE IF EXISTS cat_tipos_pagos;
CREATE TABLE cat_tipos_pagos(
	idu_tipo_pago integer not null default 0,
	des_tipo_pago varchar(20) not null default '',
	mes_tipo_pago double precision not null default 0,
	CONSTRAINT pk_cat_tipos_pagos_idu_tipo_pago PRIMARY KEY (idu_tipo_pago),
	CONSTRAINT uq_cat_tipos_pagos_des_tipo_pago UNIQUE (des_tipo_pago)
);

-- Datos
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (1,'INSCRIPCIÓN',1);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (2,'MES',1);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (3,'BIMESTRE',2);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (4,'TRIMESTRE',3);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (5,'TETRAMESTRE',4);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (6,'SEMESTRE',6);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (7,'SEMANA',0.25);
    INSERT INTO cat_tipos_pagos (idu_tipo_pago, des_tipo_pago,mes_tipo_pago ) VALUES (8,'AÑO',12);

-- Índices
    create index IX_cat_tipos_pagos_idu_tipo_pago on cat_tipos_pagos (idu_tipo_pago);

-- Documentación
    comment on table cat_tipos_pagos is 'Catálogo de Tipos Períodos Pagos (TPP)';
    
    comment on column cat_tipos_pagos.idu_tipo_pago is 'ID del tipo de pago'; 
    comment on column cat_tipos_pagos.des_tipo_pago is 'Nombre del tipo de pago';
    comment on column cat_tipos_pagos.mes_tipo_pago is 'Equivalente en meses del tipo de pago'; 
