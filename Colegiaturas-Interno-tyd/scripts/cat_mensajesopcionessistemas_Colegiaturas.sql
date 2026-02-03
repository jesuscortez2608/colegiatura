INSERT INTO cat_sistemas (id_sistema,desc_sistema, num_capturo, fec_captura)
SELECT 3,'COLEGIATURAS', 93902761, NOW();

INSERT INTO cat_opcionessistemas (id_opcion, id_sistema, desc_opcion, num_capturo, fec_captura)
VALUES 
(20,3,'COLEGIATURAS GENERAL', 93902761, NOW()), 
(21,3,'BITÁCORA DE MOVIMIENTOS', 93902761, NOW()),
(22,3,'CONFIGURAR COSTOS DE COLEGIATURAS', 93902761, NOW()),
(23,3,'AUTORIZARCIÓN DE COSTOS DE COLEGIATURAS', 93902761, NOW()), 
(24,3,'CONSULTA DE COSTOS AUTORIZADOS', 93902761, NOW()),
(25,3,'COFIGURACIÓN DE ESCOLARIDAD', 93902761, NOW()),
(26,3,'CONFIGURACIÓN DE SUPLENTES', 93902761, NOW()),
(27,3,'CONFIGURACIÓN DE ESCUELAS-ESCOLARIDAD', 93902761, NOW()),
(28,3,'CONFIGURACIÓN DE MOTIVOS', 93902761, NOW()),
(29,3,'CONFIGURACIÓN DE DESCUENTOS', 93902761, NOW()),
(30,3,'CAPTURA DE EMPLEADOS CON PRESTACIÓN DE COLEGIATURAS', 93902761, NOW()),
(31,3,'CONFIGURACIÓN DE AVISOS PARA COLABORADORES', 93902761, NOW()),
(32,3,'CONSULTA DE MOVIMIENTOS DE PERSONAL ADMINISTRACIÓN', 93902761, NOW()),
(33,3,'CONSULTA DE MOVIMIENTOS DE PERSONAL ELP', 93902761, NOW()),
(34,3,'CONSULTA DE FACTURAS', 93902761, NOW()),
(35,3,'SUBIR FACTURA ELECTRONICA PARA ESCUELA PUBLICA', 93902761, NOW()),
(36,3,'SUBIR FACTURA ELECTRONICA PARA ESCUELA PRIVADA', 93902761, NOW()),
(37,3,'GENERAR ARCHIVOS BANAMEX', 93902761, NOW()),
(38,3,'GENERAR ARCHIVOS BANCOMER', 93902761, NOW()),
(39,3,'GENERAR ARCHIVOS BANCOPPEL', 93902761, NOW()),
(40,3,'GENERAR ARCHIVOS INVERNOMINA', 93902761, NOW()),
(41,3,'ACEPTAR O RECHAZAR FACTURAS', 93902761, NOW()),
(42,3,'TRASPASO DE MOVIMEINTOS DE COLEGIATURAS', 93902761, NOW()),
(43,3,'GENERAR PAGOS DE COLEGIATURAS', 93902761, NOW()),
(44,3,'CIERRE DE COLEGIATURAS', 93902761, NOW()),
(45,3,'REPORTE DE PAGOS DE COLEGIATURAS', 93902761, NOW()),
(46,3,'REPORTE ACUMULADO COLEGIATURAS', 93902761, NOW()),
(47,3,'REPORTE DE PAGOS POR PORCENTAJE', 93902761, NOW()),
(48,3,'REPORTE DE BECAS POR ESCOLARIDAD', 93902761, NOW()),
(49,3,'REPORTE DE BECAS POR REGIÓN  - ESCOLARIDAD', 93902761, NOW()),
(50,3,'REPORTE DE BECAS POR PARENTESCO', 93902761, NOW()),
(51,3,'REPORTE DE BECAS POR ESCUELA', 93902761, NOW()),
(52,3,'REPORTE DE BECAS POR PUESTO', 93902761, NOW()),
(53,3,'REPORTE DE BECAS POR CENTRO', 93902761, NOW()),
(54,3,'SEGUIMIENTO DE FACTURAS ELECTRONICAS DE COLABORADORES', 93902761, NOW()),
(55,3,'AUTORIZAR FACTURAS GERENTE', 93902761, NOW()),
(56,3,'SEGUITO DE FACTURAS POR PERSONAL ADMINISTRACIN', 93902761, NOW());


--BITÁCORA DE MOVIMIENTOS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES (86,3,20, 'No se encontró información', 93902761, NOW()), 
(87,3,20,'No existe información para imprimir', 93902761, NOW()),
(88,3,20,'Ocurrio un problema al cargar', 93902761, NOW()),
(89,3,21,'El Colaborador no existe', 93902761, NOW()),
(90,3,21,'Colaborador dado de baja', 93902761, NOW()),
(91,3,21,'Proporcione al menos dos campo para la búsqueda', 93902761, NOW()),
(92,3,21,'Proporcione número o nombre del centro a buscar', 93902761, NOW());

--CONFIGURAR COSTOS DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(93,3,22, 'Sólo se permite editar configuraciones no autorizadas', 93902761, NOW()), 
(94,3,22, 'Seleccione el registro a editar', 93902761, NOW()),
(95,3,22, 'Seleccione el registro que desea descargar el anexo', 93902761, NOW()),
(96,3,22, 'Favor de proporcionar el nombre o la clave SEP de la escuela', 93902761, NOW()),
(97,3,22, 'El archivo seleccionado no es válido , favor de verificar', 93902761, NOW()),
(98,3,22, 'Seleccione la Escuela', 93902761, NOW()),
(99,3,22, 'Seleccione la Escolaridad', 93902761, NOW()),
(100,3,22,'Seleccione  el Grado Escolar', 93902761, NOW()),
(101,3,22, 'Ingrese el importe de la inscripción', 93902761, NOW()),
(102,3,22, 'Ingrese el importe de la colegiatura', 93902761, NOW()),
(103,3,22, 'Seleccione el archivo', 93902761, NOW()),
(104,3,22,'¿Está seguro que la información capturada es  la correcta?', 93902761, NOW()),
(105,3,22, 'Datos Actualizados Correctamente', 93902761, NOW()),
(106,3,22, 'Datos Guardados Correctamente', 93902761, NOW());
--AUTORIZARCIÓN DE COSTOS DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(107,3,23, 'No existen registros para autorizar', 93902761, NOW()),
(108,3,23, 'Registro seleccionado ya se encuentra autorizado', 93902761, NOW()),
(109,3,23, 'Seleccione el registro para autorizar', 93902761, NOW()),
(110,3,23, 'No existen registros', 93902761, NOW()),
(111,3,23, 'Seleccione el registro que desea descargar el anexo', 93902761, NOW()),
(112,3,23, 'Seleccione un Centro…', 93902761, NOW()),
(113,3,23, 'Seleccione un Colaborador…', 93902761, NOW()),
(114,3,23, 'Seleccione un Estatus…', 93902761, NOW()),
(436,3,23,'Costo autorizado correctamente', 93902761, NOW());
--CONSULTA DE COSTOS AUTORIZADOS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(115,3,24, 'No se encontraron costos autorizados para el colaborador', 93902761, NOW()),
(116,3,24, 'No existen registros', 93902761, NOW()),
(117,3,24, 'Seleccione el registro que desea descargar el anexo', 93902761, NOW()),
(118,3,24, 'Ingrese un número de colaborador para realizar la búsqueda', 93902761, NOW()),
(119,3,24, 'El colaborador no existe', 93902761, NOW()),
(120,3,24, 'Colaborador dado de baja', 93902761, NOW()),
(121,3,24, 'Favor de ingresar un filtro de búsqueda', 93902761, NOW()),
(122,3,24, 'Proporcione número de colaborador', 93902761, NOW());
-- COFIGURACIÓN DE ESCOLARIDAD
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(123,3,25, 'Seleccione la escolaridad a modificar', 93902761, NOW()),
(124,3,25, 'Proporcione escolaridad', 93902761, NOW()),
(125,3,25, 'Escolaridad actualizada correctamente', 93902761, NOW()),
(126,3,25, 'La Escolaridad ya existe', 93902761, NOW()),
(232,3,25, 'Escolaridad registrada correctamente', 93902761, NOW());
-- CONFIGURACIÓN DE SUPLENTES
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(127,3,26, '¿Desea cancelar los suplentes seleccionados?', 93902761, NOW()),
(128,3,26, 'Suplentes cancelados correctamente', 93902761, NOW()),
(129,3,26, 'Deberá de marcar los registros a eliminar', 93902761, NOW()),
(130,3,26, 'No existen registros para modificar', 93902761, NOW()),
(131,3,26, 'Deberá de marcar el registro a modificar', 93902761, NOW()),
(132,3,26, 'Se debe marcar un sólo registro para editar', 93902761, NOW()),
(133,3,26, 'Colaborador no válido, favor de verificar', 93902761, NOW()),
(134,3,26, 'El suplente no puede ser igual al colaborador a suplir', 93902761, NOW()),
(135,3,26, 'Colaborador dado de baja', 93902761, NOW()),
(136,3,26, 'No existe el número de colaborador', 93902761, NOW()),
(137,3,26, 'Proporcione el colaborador a suplir', 93902761, NOW()),
(138,3,26, 'Proporcione el suplente', 93902761, NOW()),
(139,3,26, 'Ya se encuentra capturado el suplente, favor de verificar…', 93902761, NOW()),
(140,3,26, 'Suplente guardado correctamente…', 93902761, NOW()),
(433,3,26, 'El colaborador no cuenta con el puesto', 93902761, NOW());
--CONFIGURACIÓN DE ESCUELAS-ESCOLARIDAD
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(141,3,27, 'Seleccione la escuela a modificar', 93902761, NOW()),
(142,3,27, 'Se rechazarán todas las facturas correspondientes a esta escuela.  ¿Desea continuar?', 93902761, NOW()),
(143,3,27, 'Seleccione al menos una escuela', 93902761, NOW()),
(144,3,27, 'Especifique el texto de búsqueda', 93902761, NOW()),
(145,3,27, 'Especifique un texto de búsqueda significativo (más de 3 caracteres)', 93902761, NOW()),
(146,3,27, 'Seleccione el Estado al que corresponde la Escuela', 93902761, NOW()),
(147,3,27, 'Seleccione el Municipio al que corresponde la Escuela', 93902761, NOW()),
(148,3,27, 'Proporcione RFC/Clave SEP', 93902761, NOW()),
(149,3,27, 'Proporcione nombre', 93902761, NOW()),
(150,3,27, 'Proporcione escolaridad', 93902761, NOW()),
(151,3,27, 'Proporcione deducción', 93902761, NOW()),
(152,3,27, 'Escuela agregada correctamente', 93902761, NOW()),
(153,3,27, 'Escuela actualizada correctamente', 93902761, NOW()),
(154,3,27, 'La escuela con esa escolaridad ya existe, favor de verificar', 93902761, NOW()),
(155,3,27, 'La escuela se desbloqueo', 93902761, NOW()),
(156,3,27, 'La escuela se bloqueo', 93902761, NOW()),
(233,3,27, 'Proporcione una observación', 93902761, NOW()),
(234,3,27, 'Ya se encuentra registrado el rfc en la lista de escuelas', 93902761, NOW());
--CONFIGURACIÓN DE MOTIVOS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(157,3,28, 'Seleccione el motivo que desea editar', 93902761, NOW()),
(158,3,28, 'Motivo actualizado correctamente…', 93902761, NOW()),
(159,3,28, 'Seleccione el motivo que desea bloquear/desbloquear', 93902761, NOW()),
(160,3,28, 'Proporcione el motivo …', 93902761, NOW()),
(161,3,28, 'Motivo guardado correctamente…', 93902761, NOW()),
(162,3,28, 'El motivo ya existe, favor de verificar…', 93902761, NOW());
--CONFIGURACIÓN DE DESCUENTOS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(163,3,29, 'Seleccione registro de colaborador', 93902761, NOW()),
(164,3,29, 'Seleccione un registro de descuento', 93902761, NOW()),
(165,3,29, '¿Desea eliminar el descuento a colaborador?', 93902761, NOW()),
(166,3,29, 'Seleccione Registro de puesto', 93902761, NOW()),
(167,3,29, '¿Desea eliminar el descuento a puesto?', 93902761, NOW()),
(168,3,29, 'Seleccione Registro de centro', 93902761, NOW()),
(169,3,29, '¿Desea eliminar el descuento a centro?', 93902761, NOW()),
(170,3,29, 'El colaborador no existe', 93902761, NOW()),
(171,3,29, 'Colaborador dado de baja', 93902761, NOW()),
(172,3,29, 'El puesto no existe', 93902761, NOW()),
(173,3,29, 'El centro no existe', 93902761, NOW()),
(174,3,29, 'Debe de indicar al menos una parte del apellido y del nombre del colaborador', 93902761, NOW()),
(175,3,29, 'Registro eliminado correctamente', 93902761, NOW()),
(176,3,29, 'Proporcione el colaborador', 93902761, NOW()),
(177,3,29, 'Seleccione el parentesco', 93902761, NOW()),
(178,3,29, 'Seleccione el estudio', 93902761, NOW()),
(179,3,29, 'Seleccione el descuento', 93902761, NOW()),
(180,3,29, 'Seleccione el puesto', 93902761, NOW()),
(181,3,29, 'Seleccione la sección', 93902761, NOW()),
(182,3,29, 'Proporcione el centro', 93902761, NOW()),
(183,3,29, 'Ingrese número de puesto', 93902761, NOW()),
(184,3,29, 'Descuento de colaborador agregado correctamente', 93902761, NOW()),
(185,3,29, 'Descuento de colaborador ya existe', 93902761, NOW()),
(186,3,29, 'Descuento de centro agregado correctamente', 93902761, NOW()),
(187,3,29, 'Descuento de centro ya existe', 93902761, NOW()),
(188,3,29, 'Descuento de puesto agregado correctamente', 93902761, NOW()),
(189,3,29, 'Descuento de puesto ya existe', 93902761, NOW()),
(190,3,29, 'El estudio de maestría sólo se permite para el colaborador', 93902761, NOW()),
(191,3,29, 'Ingrese número de colaborador', 93902761, NOW()),
(192,3,29, 'Ingrese el número de centro', 93902761, NOW()),
(193,3,29, 'Favor de proporcionar un comentario', 93902761, NOW()),
(235,3,29,'Proporcione el puesto', 93902761, NOW());
--30 CAPTURA DE EMPLEADOS CON PRESTACIÓN DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(194,3,30, 'Se rechazarán todas las facturas correspondientes a este colaborador.  ¿Desea continuar?', 93902761, NOW()),
(195,3,30, 'Colaborador no válido, favor de verificar', 93902761, NOW()),
(196,3,30, 'Seleccione el beneficiario a modificar', 93902761, NOW()),
(197,3,30, 'Proporcione el colaborador que desea agregar un estudio a un beneficiario', 93902761, NOW()),
(198,3,30, 'Seleccione un beneficiario', 93902761, NOW()),
(199,3,30, '¿Desea eliminar el estudio seleccionado?', 93902761, NOW()),
(200,3,30, 'Seleccione el estudio a eliminar', 93902761, NOW()),
(201,3,30, 'Proporcione el colaborador que desea agregar un beneficiario', 93902761, NOW()),
(202,3,30, 'Seleccione la escolaridad', 93902761, NOW()),
(203,3,30, 'Seleccione el grado', 93902761, NOW()),
(204,3,30, 'Proporcione el nombre del beneficiario', 93902761, NOW()),
(205,3,30, 'Proporcione el apellido paterno del beneficiario', 93902761, NOW()),
(206,3,30, 'Proporcione el parentesco', 93902761, NOW()),
(207,3,30, 'Proporcione la observación', 93902761, NOW()),
(208,3,30, 'Proporcione una justificación', 93902761, NOW()),
(209,3,30, 'Beneficiario guardado correctamente', 93902761, NOW()),
(210,3,30, 'El beneficiario ya existe, favor de verificar', 93902761, NOW()),
(211,3,30, 'Proporcione nombre o clave SEP de la escuela a buscar', 93902761, NOW()),
(212,3,30, 'Colaborador dado de baja', 93902761, NOW()),
(213,3,30, 'No existe el número de colaborador', 93902761, NOW()),
(214,3,30, 'Colaborador no válido', 93902761, NOW()),
(215,3,30, 'Estudio guardado correctamente', 93902761, NOW()),
(216,3,30, 'El estudio para este beneficiario ya existe, favor de verificar', 93902761, NOW()),
(217,3,30, 'Sólo es posible agregar maestría a los colaboradores', 93902761, NOW()),
(218,3,30, 'Estudio eliminado correctamente', 93902761, NOW()),
(219,3,30, 'El estudio no se puede eliminar, favor de verificar', 93902761, NOW()),
(220,3,30, 'Favor de dar una justificación para el  sAccionBloqueo  de este usuario', 93902761, NOW()),
(221,3,30, 'Favor de ingresar un filtro de búsqueda', 93902761, NOW());
--31 CONFIGURACIÓN DE AVISOS PARA COLABORADORES
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(222,3,31, 'Seleccione un registro para editar', 93902761, NOW()),
(223,3,31, 'Ingrese mensaje', 93902761, NOW()),
(224,3,31, 'Ingrese fecha de inicio', 93902761, NOW()),
(225,3,31, 'Seleccione fecha final', 93902761, NOW()),
(226,3,31, 'Seleccione una o todas las opciones', 93902761, NOW()),
(227,3,31, 'Datos actualizados correctamente', 93902761, NOW()),
(228,3,31, 'Datos guardados correctamente', 93902761, NOW()),
(229,3,31, 'Registro eliminado correctamente', 93902761, NOW());
--GENERALES
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(230,3,20, 'Ocurrio un problema al intentar guardar', 93902761, NOW()),
(231,3,20, 'Ocurrio un problema al intentar eliminar', 93902761, NOW());
--32	CONSULTA DE MOVIMIENTOS DE PERSONAL ADMINISTRACION
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(236,3,32, 'Proporcione al menos dos campo para la búsqueda', 93902761, NOW()),
(237,3,32, 'Colaborador no válido, favor de verificar', 93902761, NOW()),
(238,3,32, 'No existen registros ', 93902761, NOW()),
(239,3,32, 'Seleccione la factura que desea ver los beneficiarios', 93902761, NOW()),
(240,3,32, 'Seleccione la factura que desea ver las aclaraciones', 93902761, NOW()),
(241,3,32, 'Favor de proporcionar un comentario', 93902761, NOW()),
(242,3,32, 'Colaborador dado de baja', 93902761, NOW()),
(243,3,32, 'No existe el número de colaborador', 93902761, NOW());
--33	CONSULTA DE MOVIMIENTOS DE PERSONAL ELP
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(244,3,33, 'Proporcione al menos dos campo para la búsqueda', 93902761, NOW()),
(245,3,33, 'Colaborador no válido, favor de verificar', 93902761, NOW()),
(246,3,33, 'Colaborador dado de baja', 93902761, NOW()),
(247,3,33, 'No existe el número de colaborador', 93902761, NOW()),
(248,3,33, 'No existen registros', 93902761, NOW()),
(249,3,33, 'Seleccione la factura que desea ver los beneficiarios', 93902761, NOW()),
(250,3,33, 'Seleccione la factura que desea ver las aclaraciones', 93902761, NOW()),
(251,3,33, 'Favor de proporcionar un comentario', 93902761, NOW()),
(252,3,33, 'Ocurrio un problema al enviar el comentario', 93902761, NOW()),
(253,3,33, 'Comentario enviado', 93902761, NOW()),
(254,3,33, 'Favor de proporcionar el comentario', 93902761, NOW());
--34	CONSULTA DE FACTURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(255,3,34, 'No existen registros', 93902761, NOW()),
(256,3,34, 'Seleccione la factura que desea ver los detalles', 93902761, NOW());
--37	GENERAR ARCHIVOS BANAMEX
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(257,3,37, 'No se generaron pagos para Banamex en esta fecha', 93902761, NOW()),
(258,3,37, 'Debe consultar los movimientos antes de generar el archivo', 93902761, NOW()),
(259,3,37, 'Debe consultar los movimientos antes de descargar el recibo', 93902761, NOW()),
(260,3,37, 'El pago seleccionado ya fue cancelado', 93902761, NOW()),
(261,3,37, 'Seleccione uno de los pagos activos que desee cancelar', 93902761, NOW()),
(262,3,37, 'Seleccione un pago cancelado', 93902761, NOW()),
(263,3,37, 'No existen datos que mostrar', 93902761, NOW()),
(264,3,37, 'Debe especificar la póliza de cancelación', 93902761, NOW()),
(265,3,37, 'Debe especificar la clave de póliza', 93902761, NOW()),
(266,3,37, 'Debe especificar el motivo de cancelación', 93902761, NOW()),
(267,3,37, 'El pago pasará a la pantalla de Traspasos para su rechazo o autorización, ¿desea continuar?', 93902761, NOW()),
(268,3,38, 'No se generaron pagos para Bancomer  en esta fecha', 93902761, NOW()),
(269,3,39, 'No se generaron pagos para Bancoppel  en esta fecha', 93902761, NOW()),
(270,3,40, 'No se generaron pagos para Invernomina  en esta fecha', 93902761, NOW());
--41	ACEPTAR O RECHAZAR FACTURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(271,3,41, 'Colaborador no válido, favor de verificar', 93902761, NOW()),
(272,3,41, 'Colaborador dado de baja', 93902761, NOW()),
(273,3,41, 'No existe el número de colaborador', 93902761, NOW()),
(274,3,41, 'Marque al menos una factura para autorizar', 93902761, NOW()),
(275,3,41, 'Marque al menos una factura para rechazar', 93902761, NOW()),
(276,3,41, 'Marque una factura para enviar a aclaración', 93902761, NOW()),
(277,3,41, 'Solo se permite marcar una factura para enviar a aclaración', 93902761, NOW()),
(278,3,41, 'Seleccione el motivo de rechazo', 93902761, NOW()),
(279,3,41, 'Proporcione las observaciones por el rechazo', 93902761, NOW()),
(280,3,41, 'Favor de seleccionar la factura que desea mandar a aclaración', 93902761, NOW()),
(281,3,41, 'Seleccione el tipo de deducción', 93902761, NOW()),
(282,3,41, 'Favor de proporcione el número del colaborador', 93902761, NOW()),
(283,3,41, 'Seleccione la factura que desea modificar el importe a pagar', 93902761, NOW()),
(284,3,41, 'Seleccione solo una factura para modificar el importe a pagar', 93902761, NOW()),
(285,3,41, 'El importe no puede ser mayor que la factura, favor de verificar', 93902761, NOW()),
(286,3,41, 'Favor de proporcionar una justificación', 93902761, NOW()),
(287,3,41, 'Favor de proporcionar un comentario', 93902761, NOW()),
(288,3,41, 'Favor de seleccionar la factura que desea ver el blog', 93902761, NOW()),
(289,3,41, 'Seleccione solo una factura para a ver el blog', 93902761, NOW()),
(290,3,41, 'Favor de seleccionar la factura para a ver el blog', 93902761, NOW()),
(291,3,41, 'Verifique el valor de los importes pagados', 93902761, NOW()),
(292,3,41, 'El importe pagado no puede exceder el descuento calculado: $', 93902761, NOW()),
(293,3,41, 'No se han efectuado cambios para guardar', 93902761, NOW()),
(294,3,41, 'Seleccione la factura que desea descargar anexos', 93902761, NOW()),
(295,3,41, 'La factura seleccionada no tiene anexos', 93902761, NOW()),
(296,3,41, 'Seleccione la factura que desea descargar anexos', 93902761, NOW()),
(297,3,41, 'Seleccione solo una factura para descargar los anexos', 93902761, NOW()),
(298,3,41, 'Comentario enviado', 93902761, NOW()),
(299,3,41, 'El colaborador sobrepasa el tope anual ¿Desea marcar las facturas para pagarse?', 93902761, NOW()),
(300,3,41, '¿Desea marcar las facturas para pagarse?', 93902761, NOW()),
(301,3,41, '¿Desea rechazar las facturas?', 93902761, NOW()),
(302,3,41, '¿Desea mandar las facturas a aclaración?', 93902761, NOW()),
(303,3,41, 'Factura(s) autorizada correctamente', 93902761, NOW()),
(304,3,41, 'Factura(s) rechazada', 93902761, NOW()),
(305,3,41, 'Factura(s) enviada a aclaración', 93902761, NOW()),
(306,3,41, 'Debe de seleccionar una factura', 93902761, NOW());
--42	TRASPASO DE MOVIMEINTOS DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(307,3,42, 'Seleccione la factura que desea ver los beneficiarios', 93902761, NOW()),
(308,3,42, 'No existen información para traspasar', 93902761, NOW()),
(309,3,42, '¿Confirma que desea traspasar los movimientos seleccionados?', 93902761, NOW()),
(310,3,42, 'Favor de especificar que cFiltro se va a buscar', 93902761, NOW()),
(311,3,42, 'Proceso de traspaso realizado exitosamente', 93902761, NOW()),
(312,3,42, 'No hay cifras para mostrar', 93902761, NOW());
--43	GENERAR PAGOS DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES
(313,3,43, 'No existen traspasos para generar el pago de Colegiaturas', 93902761, NOW()),
(314,3,43, 'Se generaron los pagos de colegiaturas <br>Facturas traspasadas: sfacturas_traspasadas <br>Facturas pagadas: sfacturas_pagadas <br>Facturas rechazadas: sfacturas_rechazadas <br>Empleados dados de baja: sempleados_baja<br>', 93902761, NOW()),
(315,3,43, '¿Confirma que desea generar los pagos de colegiaturas?', 93902761, NOW());
--44 CIERRE DE COLEGIATURAS
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(316,3,44, '¿Confirma que desea realizar el cierre de Colegiaturas?', 93902761, NOW());
--49	REPORTE DE BECAS POR REGION  - ESCOLARIDAD
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(317,3,49, 'Solo se permite seleccionar un máximo de sMaximoEscolaridadesPorImpresion escolaridades', 93902761, NOW()),
(318,3,49, 'Debe seleccionar al menos una escolaridad para mostrar en el reporte', 93902761, NOW());
--51	REPORTE DE BECAS POR ESCUELA
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(319,3,51, 'La escuela seleccionada no tiene actualizado el RFC', 93902761, NOW()),
(320,3,51, 'Proporcione el nombre o la clave SEP de la escuela a buscar', 93902761, NOW());
--53	REPORTE DE BECAS POR CENTRO
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(321,3,53, 'Seleccione el estatus para generar el reporte', 93902761, NOW());
--54	SEGUIMIENTO DE FACTURAS ELECTRONICAS DE COLABORADORES
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(322,3,54, 'No existe el colaborador', 93902761, NOW()),
(323,3,54, 'Colaborador dado de baja', 93902761, NOW()),
(324,3,54, 'Seleccione la factura que desea descargar los anexos', 93902761, NOW()),
(325,3,54, 'La factura seleccionada no tiene anexos', 93902761, NOW()),
(326,3,54, '¿Desea eliminar la factura?', 93902761, NOW()),
(327,3,54, 'Factura eliminada correctamente', 93902761, NOW()),
(328,3,54, 'Solo se pueden eliminar facturas con estatus pendiente', 93902761, NOW()),
(329,3,54, 'Seleccione la factura que desea eliminar', 93902761, NOW()),
(330,3,54, 'Seleccione la factura que desea ver los beneficiarios', 93902761, NOW()),
(331,3,54, 'Seleccione la factura que desea modificar ', 93902761, NOW()),
(332,3,54, 'Solo se pueden modificar facturas con estatus pendiente', 93902761, NOW()),
(333,3,54, 'Seleccione la factura que desea ver las aclaraciones', 93902761, NOW()),
(334,3,54, 'Favor de proporcionar un comentario', 93902761, NOW()),
(335,3,54, 'Comentario enviado', 93902761, NOW());
--55	AUTORIZAR FACTURAS GERENTE
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(336,3,55, '¿Está seguro que la información que capturó su colaborador es la correcta?', 93902761, NOW()),
(337,3,55, 'Se ha autorizado la factura de cEscuelaSeleccionada<br>Fecha de factura : cFechaFactura<br>Importe Factura : cImportepagoF', 93902761, NOW()),
(338,3,55, 'Seleccione un centro ', 93902761, NOW()),
(339,3,55, 'Seleccione un colaborador', 93902761, NOW()),
(428,3,55, 'Debe seleccionar una factura para cancelarla', 93902761, NOW()),
(429,3,55, 'Seleccione un centro', 93902761, NOW()),
(430,3,55, 'Seleccione un colaborador', 93902761, NOW()),
(431,3,55, 'Solo se permiten autorizar facturas con estatus PENDIENTE', 93902761, NOW()),
(432,3,55, 'Debe seleccionar la factura para autorizarla', 93902761, NOW());
--56	SEGUIMIENTO DE FACTURAS POR PERSONAL ADMINISTRACION
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(340,3,56, 'El colaborador no existe', 93902761, NOW()),
(341,3,56, 'Colaborador dado de baja', 93902761, NOW()),
(342,3,56, 'Las facturas no se encuentran en proceso', 93902761, NOW()),
(343,3,56, 'Seleccione un colaborador para ver sus facturas', 93902761, NOW()),
(344,3,56, 'Solo se permiten cancelar facturas con estatus EN PROCESO', 93902761, NOW()),
(345,3,56, '¿Está seguro que desea cancelar la factura?', 93902761, NOW()),
(346,3,56, 'Se ha cancelado la factura de cEscuelaSeleccionada<br>Fecha de factura :  cFechaFactura<br>Importe Factura: cImportepagoF', 93902761, NOW()),
(347,3,56, 'La factura seleccionada no tiene anexos', 93902761, NOW()),
(348,3,56, 'Seleccione una factura', 93902761, NOW()),
(349,3,56, 'Seleccione la factura que desea ver los beneficiarios', 93902761, NOW());
--35	SUBIR FACTURA ELECTRONICA PARA ESCUELA PUBLICA	
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(350,3,35, 'El archivo seleccionado no es válido, favor de seleccionar un pdf o jpg', 93902761, NOW()),
(351,3,35, 'Favor de proporcionar el nombre o la clave SEP de la escuela', 93902761, NOW()),
(352,3,35, 'Seleccione la escuela, por favor', 93902761, NOW()),
(353,3,35, 'Proporcione el importe, por favor', 93902761, NOW()),
(354,3,35, 'Proporcione el beneficiario, por favor', 93902761, NOW()),
(355,3,35, 'Seleccione el tipo de pago, por favor', 93902761, NOW()),
(356,3,35, 'Seleccione los periodos, por favor', 93902761, NOW()),
(357,3,35, 'Seleccione la escolaridad, por favor', 93902761, NOW()),
(358,3,35, 'Seleccione el grado escolar, por favor', 93902761, NOW()),
(359,3,35, 'Seleccione el ciclo escolar, por favor', 93902761, NOW()),
(360,3,35, 'Seleccione el importe, por favor', 93902761, NOW()),
(361,3,35, 'No es posible generar esta factura, solo se pagan facturas de maestría a colaboradores', 93902761, NOW()),
(362,3,35, 'No existen registros para editar', 93902761, NOW()),
(363,3,35, 'Seleccione el registro para editar', 93902761, NOW()),
(364,3,35, 'No existen registros para eliminar', 93902761, NOW()),
(365,3,35, 'Seleccione el registro para eliminar', 93902761, NOW()),
(366,3,35, '¿Desea eliminar el registro?', 93902761, NOW()),
(367,3,35, 'Se eliminó el beneficiario de la factura', 93902761, NOW()),
(368,3,35, 'Seleccione el motivo de aclaración', 93902761, NOW()),
(369,3,35, 'Proporcione justificación de aclaración', 93902761, NOW()),	
(370,3,35, 'Favor de seleccionar el recibo de pago', 93902761, NOW()),
(371,3,35, 'Favor de seleccionar la carta / deposito', 93902761, NOW()),
(372,3,35, 'Agregue los detalles del pago, por favor', 93902761, NOW()),
(373,3,35, 'El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar', 93902761, NOW()),
(374,3,35, 'Favor de seleccionar el motivo y justificar la  aclaración', 93902761, NOW()),
(375,3,35, 'Favor de seleccionar el motivo y justificar la  aclaración', 93902761, NOW()),
(376,3,35, 'Favor de seleccionar el motivo y especificar aclaración', 93902761, NOW()),
(377,3,35, '¿Está seguro que la información de la factura es correcta?', 93902761, NOW()),
(378,3,35, 'Solo se permite subir facturas después de un año de antig&uuml;edad', 93902761, NOW()),
(379,3,35, 'No se permite subir facturas con diferentes porcentajes de descuento, favor de facturar por separado', 93902761, NOW()),
(380,3,35, 'Se agregó el detalle del beneficiario', 93902761, NOW()),
(381,3,35, 'Se actualizó el beneficiario', 93902761, NOW()),
(382,3,35, 'El beneficiario ya se agregó, favor de verificar', 93902761, NOW()),
(383,3,35, 'Ocurrio un error al subir el archivo, intentelo mas tarde', 93902761, NOW()),
(384,3,35, 'Factura registrada correctamente', 93902761, NOW()),
(385,3,35, 'La factura ya se capturo anteriormente', 93902761, NOW()),
(386,3,35, 'Escuela no registrada', 93902761, NOW()),
(387,3,35, 'Gerente pendiente de validar costos', 93902761, NOW()),
(388,3,35, 'Pendiente de capturar costos para el beneficiario seleccionado', 93902761, NOW());
--36	SUBIR FACTURA ELECTRONICA PARA ESCUELA PRIVADA
INSERT INTO cat_mensajesopcionessistemas (id_mensajesistemas, id_sistema,  id_opcion, desc_mensajesistema, num_capturo, fec_captura)
VALUES 
(389,3,36, 'El archivo seleccionado no es válido, favor de seleccionar un pdf o jpg', 93902761, NOW()),
(390,3,36, 'El archivo seleccionado no es un xml, favor de verificar', 93902761, NOW()),
(391,3,36, 'Debe importar un archivo', 93902761, NOW()),
(392,3,36, 'El archivo excede el máximo permitido: ', 93902761, NOW()),
(393,3,36, 'Ocurrió un error al subir el archivo', 93902761, NOW()),
(394,3,36, 'Archivo inválido (0 KB)', 93902761, NOW()),
(395,3,36, 'El archivo debe ser un XML', 93902761, NOW()),
(396,3,36, 'No fue posible subir su archivo por problemas de permisos', 93902761, NOW()),
(397,3,36, 'La fecha de expedición de la factura debe ser del año en curso', 93902761, NOW()),
(398,3,36, 'Favor de seleccionar el XML de la factura', 93902761, NOW()),
(399,3,36, 'Favor de seleccionar la escuela', 93902761, NOW()),
(400,3,36, 'Proporcione el nombre o clave SEP de la escuela a buscar', 93902761, NOW()),
(401,3,36, 'Solo se permite subir facturas después de un año de antig&uuml;edad', 93902761, NOW()),
(402,3,36, 'No se puede subir la factura, porque la escuela está bloqueada', 93902761, NOW()),
(403,3,36, 'RFC no se encuentra, busque la escuela para actualizarla', 93902761, NOW()),
(404,3,36, 'Escuela actualizada correctamente', 93902761, NOW()),
(405,3,36, 'Seleccione el beneficiario, por favor', 93902761, NOW()),
(406,3,36, 'Seleccione el tipo de pago, por favor', 93902761, NOW()),
(407,3,36, 'Seleccione los periodos, por favor', 93902761, NOW()),
(408,3,36, 'Seleccione la escolaridad, por favor', 93902761, NOW()),
(409,3,36, 'Seleccione el grado escolar, por favor', 93902761, NOW()),
(410,3,36, 'Seleccione el ciclo escolar, por favor', 93902761, NOW()),
(411,3,36, 'Seleccione el importe, por favor', 93902761, NOW()),
(412,3,36, 'No es posible generar esta factura', 93902761, NOW()),
(413,3,36, 'Seleccione el motivo de aclaración', 93902761, NOW()),
(414,3,36, 'Proporcione justificación de aclaración', 93902761, NOW()),
(415,3,36, 'Agregue los detalles de la factura, por favor', 93902761, NOW()),
(416,3,36, 'El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar', 93902761, NOW()),
(417,3,36, 'Favor de seleccionar el motivo y justificar la aclaración', 93902761, NOW()),
(418,3,36, 'Favor de seleccionar un pdf', 93902761, NOW()),
(419,3,36, '¿Está seguro que la información de la factura es correcta?', 93902761, NOW()),
(420,3,36, 'No existen registros para editar', 93902761, NOW()),
(421,3,36, 'Seleccione el registro para editar', 93902761, NOW()),
(422,3,36, 'No existen registros para eliminar', 93902761, NOW()),
(423,3,36, 'Seleccione el registro para eliminar', 93902761, NOW()),
(424,3,36, '¿Desea eliminar el registró?', 93902761, NOW()),
(425,3,36, 'Se eliminó el beneficiario de la factura', 93902761, NOW()),
(426,3,36, 'Gerente pendiente de validar costos', 93902761, NOW()),
(427,3,36, 'Pendiente de capturar costos para el beneficiario seleccionado', 93902761, NOW()),
(434,3,36, 'ATENCIÓN :', 93902761, NOW()),
(435,3,36, ' Si su factura paga más de un beneficiario deberás capturar el costo por cada uno de los beneficiarios.', 93902761, NOW());

