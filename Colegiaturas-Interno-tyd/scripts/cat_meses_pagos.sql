/*
	No. petición APS               : 16995.1 Mejoras al sistema de colegiaturas
	Fecha                          : 12/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Descripción                    : Tabla de meses a los que corresponde cada periodo_pago (cat_periodos_pagos)
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
        SELECT * 
        FROM cat_meses_pagos 
        ORDER BY idu_tipo_pago, idu_periodo, mes_pago
------------------------------------------------------------------------------------------------------ */

-- Definición
    --    cat_tipos_pagos
    --        cat_periodos_pagos
    --            cat_meses_pagos
    DROP TABLE IF EXISTS cat_meses_pagos; -- cat_periodos_pagos
    CREATE TABLE cat_meses_pagos (idu_tipo_pago integer not null default(0)
        , idu_periodo integer not null default(0)
        , mes_pago VARCHAR(50) NOT NULL DEFAULT('')
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
    );
    
    INSERT INTO cat_meses_pagos (idu_tipo_pago, idu_periodo, idu_usuario, fec_registro)
    SELECT C.idu_tipo_pago
        , D.idu_periodo
        , 95194185 as idu_usuario
        , now() as fec_registro
    FROM cat_tipos_pagos C
        inner join cat_periodos_pagos D on C.idu_tipo_pago = D.idu_tipo_periodo
    order by C.idu_tipo_pago, D.idu_periodo;
    
    -- Inscripción
    update cat_meses_pagos set mes_pago = '0' where idu_tipo_pago = 1 and idu_periodo = 1; -- La inscripción no corresponde a ningún mes
    
    -- Meses
    update cat_meses_pagos set mes_pago = '1' where idu_tipo_pago = 2 and idu_periodo = 1; -- Enero
    update cat_meses_pagos set mes_pago = '2' where idu_tipo_pago = 2 and idu_periodo = 2; -- Febrero
    update cat_meses_pagos set mes_pago = '3' where idu_tipo_pago = 2 and idu_periodo = 3; -- Marzo
    update cat_meses_pagos set mes_pago = '4' where idu_tipo_pago = 2 and idu_periodo = 4; -- Abril
    update cat_meses_pagos set mes_pago = '5' where idu_tipo_pago = 2 and idu_periodo = 5; -- Mayo
    update cat_meses_pagos set mes_pago = '6' where idu_tipo_pago = 2 and idu_periodo = 6; -- Junio
    update cat_meses_pagos set mes_pago = '7' where idu_tipo_pago = 2 and idu_periodo = 7; -- Julio
    update cat_meses_pagos set mes_pago = '8' where idu_tipo_pago = 2 and idu_periodo = 8; -- Agosto
    update cat_meses_pagos set mes_pago = '9' where idu_tipo_pago = 2 and idu_periodo = 9; -- Septiembre
    update cat_meses_pagos set mes_pago = '10' where idu_tipo_pago = 2 and idu_periodo = 10; -- Octubre
    update cat_meses_pagos set mes_pago = '11' where idu_tipo_pago = 2 and idu_periodo = 11; -- Noviembre
    update cat_meses_pagos set mes_pago = '12' where idu_tipo_pago = 2 and idu_periodo = 12; -- Diciembre
    
    -- Bimestres
    update cat_meses_pagos set mes_pago = '1,2' where idu_tipo_pago = 3 and idu_periodo = 1; -- Enero-Febrero
    update cat_meses_pagos set mes_pago = '3,4' where idu_tipo_pago = 3 and idu_periodo = 2; -- Marzo-Abril
    update cat_meses_pagos set mes_pago = '5,6' where idu_tipo_pago = 3 and idu_periodo = 3; -- Mayo-Junio
    update cat_meses_pagos set mes_pago = '7,8' where idu_tipo_pago = 3 and idu_periodo = 4; -- Julio-Agosto
    update cat_meses_pagos set mes_pago = '9,10' where idu_tipo_pago = 3 and idu_periodo = 5; -- Septiembre-Octubre
    update cat_meses_pagos set mes_pago = '11,12' where idu_tipo_pago = 3 and idu_periodo = 6; -- Noviembre-Diciembre
    
    -- Trimestres
    update cat_meses_pagos set mes_pago = '1,2,3' where idu_tipo_pago = 4 and idu_periodo = 1; -- Enero,Febrero,Marzo
    update cat_meses_pagos set mes_pago = '4,5,6' where idu_tipo_pago = 4 and idu_periodo = 2; -- Abril,Mayo,Junio
    update cat_meses_pagos set mes_pago = '7,8,9' where idu_tipo_pago = 4 and idu_periodo = 3; -- ,Septiembre
    update cat_meses_pagos set mes_pago = '10,11,12' where idu_tipo_pago = 4 and idu_periodo = 4; -- Octubre,Noviembre,Diciembre
    
    -- Tetramestre
    update cat_meses_pagos set mes_pago = '1,2,3,4' where idu_tipo_pago = 5 and idu_periodo = 1; -- Enero,Febrero,Marzo,Abril
    update cat_meses_pagos set mes_pago = '5,6,7,8' where idu_tipo_pago = 5 and idu_periodo = 2; -- Mayo,Junio,Julio,Agosto
    update cat_meses_pagos set mes_pago = '9,10,11,12' where idu_tipo_pago = 5 and idu_periodo = 3; -- Septiembre,Octubre,Noviembre,Diciembre
    
    -- Semestre
    update cat_meses_pagos set mes_pago = '1,2,3,4,5,6' where idu_tipo_pago = 6 and idu_periodo = 1; -- Enero,Febrero,Marzo,Abril,Mayo,Junio
    update cat_meses_pagos set mes_pago = '7,8,9,10,11,12' where idu_tipo_pago = 6 and idu_periodo = 2; -- Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre
    
    -- Semanas
    update cat_meses_pagos set mes_pago = '1' where idu_tipo_pago = 7 and idu_periodo IN (1,2,3,4); -- Enero
    update cat_meses_pagos set mes_pago = '2' where idu_tipo_pago = 7 and idu_periodo IN (5,6,7,8,9); -- Febrero
    update cat_meses_pagos set mes_pago = '3' where idu_tipo_pago = 7 and idu_periodo IN (10,11,12,13); -- Marzo
    update cat_meses_pagos set mes_pago = '4' where idu_tipo_pago = 7 and idu_periodo IN (14,15,16,17,18); -- Abril
    update cat_meses_pagos set mes_pago = '5' where idu_tipo_pago = 7 and idu_periodo IN (19,20,21,22); -- Mayo
    update cat_meses_pagos set mes_pago = '6' where idu_tipo_pago = 7 and idu_periodo IN (23,24,25,26,27); -- Junio
    update cat_meses_pagos set mes_pago = '7' where idu_tipo_pago = 7 and idu_periodo IN (28,29,30,31); -- Julio
    update cat_meses_pagos set mes_pago = '8' where idu_tipo_pago = 7 and idu_periodo IN (32,33,34,35,36); -- Agosto
    update cat_meses_pagos set mes_pago = '9' where idu_tipo_pago = 7 and idu_periodo IN (37,38,39,40); -- Septiembre
    update cat_meses_pagos set mes_pago = '10' where idu_tipo_pago = 7 and idu_periodo IN (41,42,43,44); -- Octubre
    update cat_meses_pagos set mes_pago = '11' where idu_tipo_pago = 7 and idu_periodo IN (45,46,47,48); -- Noviembre
    update cat_meses_pagos set mes_pago = '12' where idu_tipo_pago = 7 and idu_periodo IN (49,50,51,52); -- Diciembre
    
    -- Año
    update cat_meses_pagos set mes_pago = '1,2,3,4,5,6,7,8,9,10,11,12' where idu_tipo_pago = 8 and idu_periodo = 1; -- Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre