<?php

	session_name("Session-Colegiaturas");
	session_start();
	header ('Content-type: text/html; charset=utf-8');
	$Session = isset($_POST['session_name1']) ?  $_POST['session_name1'] : "Session-Colegiaturas";
		
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/data/class_enletras.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	
	$myXML = (isset($_POST['xml'])?$_POST['xml']:'');
	$iOpcion = (isset($_POST['txt_iOpcion'])?$_POST['txt_iOpcion']:0);
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$txt_Rfc_Emp = isset($_POST['txt_Rfc_Emp']) ? $_POST['txt_Rfc_Emp'] : '';

	


	//VARIABLES DE FECHAS
	$dFecha = date('Ymd'); //Variable que se utiliza 
	$fechaactual = date('d-m-Y');   // Se utiliza en el proceso de obtencion y calculos de antiguedad del colaborador,
									// para saber contra que informacion validar la fecha de la factura
	$diasAntiguedad = 0;
	
	$anioactual = date("Y"); // Para validar que las facturas sean del año actual
	
	$json = new stdClass();
	$json->estado = 0;
	$json->mensaje = "OK";
	
	
	$uploaddir = '../../files/tmp/';
	// $uploadfile = $uploaddir . basename($_FILES['fileXml']['name']);
	$uploadfile = $uploaddir . basename("$iUsuario" . "_" . "$dFecha.xml");
	$Revision=0;
	$tipoDoc='';
	$TipoCom='';
	$DocRel='';
	// --------------------------------------------------------
	// Validar que se haya enviado un archivo (name != '')
	$nombrearchivo = basename($_FILES['fileXml']['name']);
	if ($nombrearchivo == '') {
		generarResultado(-1, 'Debe importar un archivo', array());
		return;
	}
	
	// --------------------------------------------------------
	// Validar que se haya importado sin errores
	$error = $_FILES['fileXml']['error'];
	if ($error != 0) {
		if ($error == 1){
			$maxperm = ini_get('upload_max_filesize');
			generarResultado(-1, "El archivo excede el máximo permitido: $maxperm", array());
		} else {
			generarResultado(-1, 'Ocurrió un error al subir el archivo', array());
		}
		return;
	}
	
	// --------------------------------------------------------
	// Validar el peso del archivo (tamaño > 0)
	$size = $_FILES['fileXml']['size'];
	if ($size <= 0){
		generarResultado(-1, 'Archivo inválido (0 KB)', array());
		return;
	}
	
	// --------------------------------------------------------
	// Validar que el archivo sea una imagen
	$formato = $_FILES['fileXml']['type'];
	$extension = strtolower(trim(extension($nombrearchivo)));
	
	if ($extension != "xml" || $formato != "text/xml") {
		generarResultado(-1, 'El archivo debe ser un XML ', array());
		return;
	}
	
	// --------------------------------------------------------
	// Validar que el archivo se pueda subir a la carpeta 
	// de destino
	$tmpName = "/tmp/".basename($_FILES['fileXml']['tmp_name']);
	if (move_uploaded_file($tmpName, $uploadfile)) {
		// El archivo se subió con éxito al servidor
		// Borrar el archivo
		// unlink($uploadfile);
	} else {

		generarResultado(-1, 'No fue posible subir su archivo por problemas de permisos', array());
		
	}
	
	$myXML = trim(file_get_contents($uploadfile));
	
	// Reemplaza solo la línea inicial si tiene comillas simples
    if (strpos($myXML, "<?xml version='1.0'") !== false) {
        $myXML = str_replace(
            "<?xml version='1.0' encoding='UTF-8'?>",
            '<?xml version="1.0" encoding="UTF-8"?>',
            $myXML
        ); 
    }
	
	$myXML = str_replace("'", "", $myXML);
	

	//BORRAR IFNORMACION DE ADDENDA - LUIS HERNANDEZ 90244610
		$xmlAddendaBorrar = new SimpleXMLElement($myXML);
		
		// Buscar el nodo <cfdi:Addenda>
		$addendaBorrar = $xmlAddendaBorrar->xpath('//cfdi:Addenda');

		// Eliminar el nodo si existe
		if (!empty($addendaBorrar)) {
			$dom = dom_import_simplexml($addendaBorrar[0]);
			$dom->parentNode->removeChild($dom);
		}
		//Nueva variable para no modificar el XML original
		$myXMLNoAddenda = $xmlAddendaBorrar -> asXML(); 

	
	// $myXML = simplexml_load_file($uploadfile);
	// if (file_exists($myXML)) {
		// $xml = simplexml_load_file($myXML);
		// print_r($xml);
	// } else {
		// exit('Error abriendo '.$myXML);
	// }
          
////////////////EXTRAER DATOS DE ARCHIVO XML//////////////////  				
//proceso para leer factura
	$tipose=1; $flag_rep=0; 
	$band_desc=0;
	$subt=0;
	$descuento=0;
	$importe_total=0;
	$cadenaoriginal="||";	
	$rfc_emisor ="";
	
	
	$dom = new DomDocument; //Carga, lee xml
	$dom->preserveWhiteSpace = FALSE;
	$xml = (@$dom->loadxml($myXMLNoAddenda) === FALSE)?@$dom->loadxml($myXMLNoAddenda):@$dom->loadxml($myXMLNoAddenda);
	unlink($uploadfile);
	
	$parametrocomprobante = $dom->getElementsByTagName('Comprobante');
	$paramconcepto = $dom->getElementsByTagName('Concepto');
	
	$parametroemisor = $dom->getElementsByTagName('Emisor');
	$parametro_RegimenFiscal = $dom->getElementsByTagName('RegimenFiscal');
	$parametroreceptor = $dom->getElementsByTagName('Receptor');
	$parametro_traslados = $dom->getElementsByTagName('Traslado');

	
	
	$band_desc=0;
	foreach($parametrocomprobante as $params) {
		$version = ($params->getAttribute('Version'));
		$cadenaoriginal.=$version;
		$serie="";
		if($params->hasAttribute('Serie'))
		{
			$serie = ($params->getAttribute('Serie'));  
			if(!empty($serie))
			{
				$cadenaoriginal.="|".$serie;
			} 
		}
		$folio = ($params->getAttribute('Folio'));
		$fecha = ($params->getAttribute('Fecha'));
		$sello = ($params->getAttribute('Sello'));
		$f_pago = ($params->getAttribute('FormaPago'));
		$t_comprobante = ($params->getAttribute('TipoDeComprobante'));
		$m_pago = ($params->getAttribute('MetodoPago'));
	}
	$anioFactura = date('Y', strtotime($fecha));
	// Fecha factura sin tiempo
	// $fechaFactura = date('d/m/Y', strtotime($fecha));
	$fechaFactura = date('Ymd', strtotime($fecha));
	
	// echo "<pre>";
	// print_r('FECHA FACTURA = '.$fechaFactura);
	// echo "</pre>";
	// exit();
	// ----------------------------------------------------------------------------------
	// -----------------Obtener la fecha de alta del Colaborador-------------------------
	try {
		$CDB4 = obtenConexion(BDSYSCOPPELPERSONALSQL);
		$estado = $CDB4['estado'];
		$cadenaconexion = $CDB4['conexion'];
		$mensaje = $CDB4['mensaje'];
		if ( $estado != 0 ) {
			generarResultado(-1, $mensaje, array());
		}
		$respuesta = new stdClass();
		$estado = 0;
		$ds4 = "";
		
		$con4 = new OdbcConnection($cadenaconexion);
		$con4->open();
		$cmd4 = $con4->createCommand();
		try {
			// echo("{CALL proc_obtener_datos_colaborador_colegiaturas ($iUsuario)}");
			// exit;
			$cmd4->setCommandText("{CALL proc_obtener_datos_colaborador_colegiaturas ($iUsuario)}");
			$ds4 = $cmd4->executeDataSet();
			$con4->close();
			$mensaje = 'OK_consulta_general';
			
			$fecAlta = $ds4[0]['fec_alta'];
			// echo "<pre>";
			// print_r('FECHA DE ALTA NORMAL= '.$fecAlta);
			// echo "</pre>";
			// exit();
			$fechaAlta = $ds4[0]['fec_alta'];
			
			$separator = explode('/', $fechaAlta);
			// echo "<pre>";
			// print_r($separator);
			// echo "</pre>";
			// exit();
			$dia = $separator[0];
			$mes = $separator[1];
			$anio = $separator[2] + 1;
			$fechaAlta2 = $dia.'/'.$mes.'/'.$anio;
			$fechaAlta = $anio.''.$mes.''.$dia;
			// FECHA ALTA MAS 1 AÑO
			// echo "<pre>";
			// print_r('FECHA ALTA MAS 1 AÑO = '.$fechaAlta);
			// echo "</pre>";
			// exit();
			
			$fecAlta = str_replace('/','-', $fecAlta);
			$date1 = new DateTime($fecAlta);
			$date2 = new DateTime($fechaactual);
			$interval = $date1->diff($date2);
			
			$diasAntiguedad = $interval->days;
			// echo "<pre>";
			// print_r('DIAS ANTIGÜEDAD = '.$diasAntiguedad);
			// echo "</pre>";
			// exit();
		} catch (Exception $ex) {
			generarResultado(-1, "Ocurrió un error al conectar a la base de datos.", array());
		}
	} catch (Exception $ex) {
		generarResultado(-1, "Ocurrió un error al conectar a la base de datos.", array());
	}
	
	// ---------------------------------------------------------------------------------
	// ---------Obtener la fecha de alta de la tabla cat_empleados_colegiaturas---------
	try {
		$CDB5 = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);		
		$estado = $CDB5['estado'];
		$cadenaconexion = $CDB5['conexion'];
		$mensaje = $CDB5['mensaje'];
		if ( $estado != 0 ) {
			generarResultado(-1, $mensaje, array());
		}
		$respuesta = new stdClass();
		$estado = 0;
		$ds5 = "";
		
		$con5 = new OdbcConnection($cadenaconexion);
		$con5->open();
		$cmd5 = $con5->createCommand();
		try {
			// echo("{CALL fun_consulta_empleado_colegiatura ($iUsuario)}");
			// exit;
			$cmd5->setCommandText("{CALL fun_consulta_empleado_colegiatura ($iUsuario)}");
			$ds5 = $cmd5->executeDataSet();
			$con5->close();
			$mensaje = 'OK_consulta_general';
			
			$fechaPrestacion = date('d/m/Y', strtotime($ds5[0]['fec_registro']));
			// echo "<pre>";
		    // print_r('fecha prestacion: ' . $fechaPrestacion);
		    // print_r($ds5);
			// echo "</pre>";
			// exit();
			$separator = explode('/', $fechaPrestacion);
			$dia = $separator[0];
			$mes = $separator[1];
			$anio = $separator[2];
			
			$fechaPrestacion2 = $dia.'/'.$mes.'/'.$anio;
			$fechaPrestacion = $anio.''.$mes.''.$dia;
			$clave_uso = $clave_uso;
			// echo "<pre>";
			// print_r('FECHA DE REGISTRO EN CAT = '.$fechaPrestacion);
			// echo "</pre>";
			// exit();
		} catch (Exception $ex) {
			generarResultado(-1, "Ocurrió un error al conectar a la base de datos.", array());
		}
	} catch (Exception $ex) {
		generarResultado(-1, "Ocurrió un error al conectar a la base de datos.", array());
	}
	// ----------------------------------------------------------------------------------
	//------------------------------------------------------------
	//-------Flag para validar si es que se permiten subir facturas de años anteriores
	$valorParametro = 0;
	
	$CDB3 = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado3 = $CDB3['estado'];
	$mensaje3 = $CDB3['mensaje'];
	try {
		$con3 = new OdbcConnection($CDB3['conexion']);
		$con3->open();
		$cmd3 = $con3->createCommand();
		
		$sNomParametro = 'PERMITIR_FACTURAS_ANIOS_ANTERIORES';
		$query = "SELECT idparametro
							, stipoparametro
							, svalorparametro
							, snomparametro
				  FROM fun_obtener_parametros_colegiaturas('$sNomParametro')";

		// echo "<pre>";
		//print_r($query);
		//echo "</pre>";
		//exit();
		$cmd3->setCommandText($query);
		$ds3 = $cmd3->executeDataSet();
		
		$con3->close();
		$valorParametro = $ds3[0]['svalorparametro'];
		// echo "<pre>";
		// print_r($valorParametro);
		// echo "</pre>";
		// exit();
	} catch (Exception $ex) {
		$estado3 = -1;
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
	}
	// echo "<pre>";
	// print_r('Antiguedad: '.$diasAntiguedad);
	// echo "</pre>";
	// exit();
	if ( $iOpcion == 0 ) { // En la configuración de beneficiarios este parametro se manda con 1, en esa opcion no se necesita validar esta situación de fechas
		//if ($t_comprobante.strtoupper() != 'E') {
		//		if ( ($t_comprobante.strtoupper() == 'I' || $t_comprobante.strtoupper() == 'P') && $m_pago.strtoupper() != 'PPD' ) {
			if (strtoupper($t_comprobante) != 'E') {
					if ( (strtoupper($t_comprobante) == 'I' || strtoupper($t_comprobante) == 'P') && strtoupper($m_pago) != 'PPD' ) {
				if ( $valorParametro == 0 ) {
					if ( $diasAntiguedad >= 730 ) { // Mayor de 2 años de antigüedad
						if ( $anioFactura < $anioactual ) {
							generarResultado(-1, 'La fecha de expedición de la factura debe ser del año en curso', array());
						}
					} else if ( $diasAntiguedad < 365 ) { // Menos del año de antigüedad
						if ( $fechaFactura < $fechaPrestacion ) {
							generarResultado(-1, 'Su factura deberá estar facturada a partir del dia: <b><strong>'.$fechaPrestacion2.'</strong></b>', array());
						}
						if ( $anioFactura < $anioactual ) {
							generarResultado(-1, 'La fecha de expedición de la factura debe ser del año en curso', array());
						}
					} else if ( $diasAntiguedad >= 365 && $diasAntiguedad < 730 ) {
						// echo("FECHA FACTURA =".$fechaFactura);
						// echo("FECHA ALTA COLABORADOR =".$fechaAlta);
						if ( $fechaFactura < $fechaAlta ) {
							generarResultado(-1, 'Su factura deberá estar facturada a partir del dia: <b><strong>'.$fechaAlta2.'</strong></b>', array());
						}
						if ( $anioFactura < $anioactual ) {
							generarResultado(-1, 'La fecha de expedición de la factura debe ser del año en curso', array());
						}
					}
				}
			}
		}
	}
	
	//Validar que no tenga una clave de uso especial
	if($clave_uso != ""){
		generarResultado(-1, 'El empleado cuenta con una clave de uso especial.', array());
	}
	// Validar que el año de la factura no sea menor al año actual
	if ( $version < 3.3 )
	{
		generarResultado(-1, 'Versión del xml no válida', array());
	}
	
	if ( $fecha == '' ){
		generarResultado(-1, 'Versión del xml no contiene el atributo fecha', array());
		exit();
	}
	
	//OBTIENE LOS IMPORTES DE LOS CONCEPTOS
	$imp_concetos = array();
	foreach ($paramconcepto as $paramscon) 
	{
		if($paramscon -> hasAttribute('Importe'))	
		{
			$importe =trim($paramscon -> getAttribute('Importe'));
			if($paramscon -> hasAttribute('Descuento'))	
			{
				$importe -=trim($paramscon -> getAttribute('Descuento'));
			}
		}
		//echo( $importe);
		$imp_concetos[] = array('value' =>  $importe);
	} 
	
	foreach($parametroemisor as $params){
		if($params->hasAttribute('Rfc'))
		{
			$rfc_emisor =substr(($params -> getAttribute('Rfc')),0,13);
			$nombre_emisor = $params -> getAttribute('Nombre');	
		}
	}
	foreach($parametroreceptor as $params){
		if($params->hasAttribute('Rfc'))
		{
			$rfc_receptor = strtoupper(substr(($params -> getAttribute('Rfc')),0,13));			
		}
		$node = $params->parentNode->nodeName;
		if($params->hasAttribute('UsoCFDI') && !str_contains($node, 'Addenda')) 
		{
			$clv_uso = strtoupper(($params -> getAttribute('UsoCFDI')));
		}
	}
	if(trim($clv_uso) == ''){
		generarResultado(-1, 'No cuenta con clave de uso', array());
	}

	if(trim($txt_Rfc_Emp) != trim($rfc_receptor)) {
		generarResultado(-1, 'El Rfc del colaborador no es correcto', array());
	}

	
	foreach($parametrocomprobante as $params){
		$importe_total = trim($params->getAttribute('Total'));
	}
	//Buscar el folio fiscal
	$foliofiscal = "";
	$e_Complemento = $dom->getElementsByTagName('Complemento');
	if($e_Complemento->length >= 1) {
		$e_TimbreFiscalDigital = $e_Complemento->item(0)->getElementsByTagName('TimbreFiscalDigital');
		if($e_TimbreFiscalDigital->length==1) {
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('UUID')) {
				$foliofiscal=trim($e_TimbreFiscalDigital->item(0)->getAttribute('UUID'));
				$foliofiscal=strtoupper($foliofiscal);										
			}
			   
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('FechaTimbrado'))
			{
				$FechaTimbrado=trim($e_TimbreFiscalDigital->item(0)->getAttribute('FechaTimbrado'));
			} 
			
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('NoCertificadoSAT'))
			{
				$noCertificadoSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('NoCertificadoSAT'));
			}
			
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('SelloSAT'))
			{
				$selloSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('SelloSAT'));
			}
			
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('SelloCFD'))
			{
				$selloCFD=trim($e_TimbreFiscalDigital->item(0)->getAttribute('SelloCFD'));
			} 
			
			if($e_TimbreFiscalDigital->item(0)->hasAttribute('Version'))
			{
				$versiontimbre=trim($e_TimbreFiscalDigital->item(0)->getAttribute('Version'));						
			}
		}
		
		$e_implocales=$e_Complemento->item(0)->getElementsByTagName('ImpuestosLocales');
	}
	try {
		//-----------------------------------------------------------------------------
		//$CDB2 = obtenConexion(BDADMINISTRACIONPOSTGRESQL);
		//$estado2 = $CDB2['estado'];
		//$mensaje2 = $CDB2['mensaje'];
		// $data = array();
		// if($estado2 != 0){
		// 	throw new Exception("Error al conectarse y obtener informacion de BDADMINISTRACIONPOSTGRESQL. ". $mensaje2);
		// }
		
		// $con2 = new OdbcConnection($CDB2['conexion']);
		// $con2->open();
		// $cmd2 = $con2->createCommand();
		// // echo("{CALL fun_existe_factura_en_sistema_anterior($iUsuario, '$foliofiscal')}");
		// // exit();
		// $cmd2->setCommandText("{CALL fun_existe_factura_en_sistema_anterior($iUsuario, '$foliofiscal')}");
		// $ds2 = $cmd2->executeDataSet();
		// $con2->close();
		// $estado2 = $ds2[0][0];
		
		// $mensaje2 = encodeToUtf8($ds2[0][1]);
		// $estado2 = 0;
		// if($estado2 == 1) {
		// 	generarResultado(-1, $mensaje2, array());
		// } else 
		// if($estado2 == 0) {
			try {
				$CDB2 = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
				$estado2 = $CDB2['estado'];
				$mensaje2 = $CDB2['mensaje'];
				
				$con2 = new OdbcConnection($CDB2['conexion']);
				$con2->open();
				$cmd2 = $con2->createCommand();
				// echo("{CALL fun_existe_factura_en_sistema_nuevo('$rfc_emisor', '$foliofiscal')}");
				// exit();
				$cmd2->setCommandText("{CALL fun_existe_factura_en_sistema_nuevo('$rfc_emisor', '$foliofiscal')}");
				$ds2 = $cmd2->executeDataSet();
				$con2->close();
				$estado2 = $ds2[0][0];
				$mensaje2 = encodeToUtf8($ds2[0][1]);
				// echo "<pre>";
				// print_r($mensaje2);
				// echo "</pre>";
				// exit();
				
				if($estado2 == 1){
					generarResultado(-1, $mensaje2, array());
				}
			} catch (Exception $ex) {
				$estado2 = -1;
				$mensaje2 = "Ocurrió un error al conectar a la base de datos.";
				generarResultado($estado2, $mensaje2, array());
			}
		// }
	} catch (Exception $ex) {
		$estado2 = -1;
		$mensaje2 = "Ocurrió un error al conectar a la base de datos.";
		generarResultado($estado2, $mensaje2, array());
	}
	//--------------rrg--------------------------------------------------------------------------------------------------------
	if (trim($foliofiscal) == "") {
		generarResultado(-1, 'Folio fiscal inválido (UUID)', array());
	}
	
	$folioRelacionado='';

	//-- CFDIRelacionados
	$e_Relacionados= $dom->getElementsByTagName('CfdiRelacionados');
	if($e_Relacionados->length>0) {
		
		$tipoRelacion = $e_Relacionados->item(0)->getAttribute('TipoRelacion');
		if ($tipoRelacion != '') {
			
			$iValido = 0;
			$sMensaje = '';
			// Validar que el tipo de relacion del XML este dentro de los permitidos
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$cmd->setCommandText ("SELECT istatus, smensaje FROM fun_validar_tipo_relacion_cfdi_colegiaturas($tipoRelacion)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$iValido = $ds[0]['istatus'];
			$sMensaje = $ds[0]['smensaje'];
			
			if ( $iValido < 1 ) {
				generarResultado (-1, $sMensaje, array());
			} else {
				if ( $tipoRelacion != 01 && $tipoRelacion != 1 ) {
					$e_Relacion=$e_Relacionados->item(0)->getElementsByTagName('CfdiRelacionado');
					if($e_Relacion->length>0) {
						$sFecha='';
						$i = 0;
						$folioRelacionado = '';
						for ($i = 0; $i < $e_Relacion->length; $i++) {
							$folioRelacionado = $e_Relacion->item($i)->getAttribute('UUID');
							if($folioRelacionado!='')	// validar complemento
							{
								$folioRelacionado = strtoupper($folioRelacionado);
								$iExiste = 0;
								$iEstatus = 0;
								$iCtl = 0;
								$con = new OdbcConnection($CDB['conexion']);
								$con->open();
								$cmd = $con->createCommand();
								
								// echo "<pre>";
								// print_r("SELECT existefolio, estatusfolio, ictl_factura FROM fun_validar_folio_relacionado_colegiatura('".trim($folioRelacionado)."', '".trim($rfc_emisor)."')");
								// echo "</pre>";
								// exit();
								$cmd->setCommandText("SELECT existefolio, estatusfolio, ictl_factura FROM fun_validar_folio_relacionado_colegiatura('".trim($folioRelacionado)."', '".trim($rfc_emisor)."')");
								
								$ds = $cmd->executeDataSet();
								$con->close();
								$iExiste = $ds[0]['existefolio'];
								$iEstatus = $ds[0]['estatusfolio'];
								$iCtl = $ds[0]['ictl_factura'];
								
								if ($iExiste == 1) {
									if ($iCtl == 1) {
										if ( ($tipoRelacion == 04 || $tipoRelacion == 4) && ($iEstatus != 2 && $iEstatus != 4 && $iEstatus != 8) ) {
											generarResultado(-1, 'La factura relacionada: '.$folioRelacionado.' se encuentra en proceso de pago', array());
										}
									} else {
										if ( ($tipoRelacion == 04 || $tipoRelacion == 4) && ($iEstatus != 3 ) ) {
											generarResultado(-1, 'La factura relacionada: '.$folioRelacionado.' se encuentra en proceso de pago', array());
										}
									}
								}
								if ( $iExiste == 0 && ($tipoRelacion != 04 || $tipoRelacion != 4) ) {
									generarResultado(-1, 'Primero deberá de subir la factura relacionada con el folio: '.$folioRelacionado, array());
								}
							}
						}
					}
				}
			}
		}
	}
	//Datos de los complementos
	
	$e_DocRelacionado=$e_Complemento->item(0)->getElementsByTagName('DoctoRelacionado');
	if($e_DocRelacionado->length>0)
	{
		$folioRelacionado=trim($e_DocRelacionado->item(0)->getAttribute('IdDocumento'));
		$folioRelacionado=strtoupper($folioRelacionado);
		// echo('Folio Relacionado = '.$folioRelacionado);
		// exit();
		if($folioRelacionado!='')	// validar complemento
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// echo("SELECT * FROM fun_validar_folio_relacionado_colegiatura('".trim($folioRelacionado)."', '".trim($rfc_emisor)."')");
			// exit(); 
			
			$cmd->setCommandText("SELECT * FROM fun_validar_folio_relacionado_colegiatura('".trim($folioRelacionado)."', '".trim($rfc_emisor)."')");
			
			$ds = $cmd->executeDataSet();
			$con->close();
			$iExiste = $ds[0][0];
			
			if($iExiste==0 and $iOpcion!=1)//NO SE A SUBIDO LA FACTURA RELACIONADA
			{
				generarResultado(-1, 'Primero debera de subir la factura relacionada con el folio '.$folioRelacionado, array());
			}
			
		}
		if($importe_total==0)
		{
			$e_Pago=$e_Complemento->item(0)->getElementsByTagName('Pago');
			if($e_Pago->length>0)
			{
				$importe_total=trim($e_Pago->item(0)->getAttribute('Monto'));
			}
		}
		if($e_DocRelacionado->item(0)->hasAttribute('MetodoDePagoDR'))
		{
			$m_pago=trim($e_DocRelacionado->item(0)->getAttribute('MetodoDePagoDR'));
		}
// echo ('Documento Relacionado'.$m_pago);
// exit();
		
	/*
		$folioRelacionado=trim($e_DocRelacionado->item(0)->getAttribute('IdDocumento'));
		if($folioRelacionado!='')	// validar complemento
		{
			$folioRelacionado=strtoupper($folioRelacionado);
			// $sqldatosfactura="SELECT * FROM fun_validar_folio_factura_colegiatura('".trim($folioRelacionado)."')"; 
			// $id = $dbfe->query($sqldatosfactura);
			// $eer = $dbfe->getError();
			// if($eer){echo "Error: ".$eer; return;}
			
			// $iExiste=0;
			// foreach ($id as $row)
			// {
				// $iExiste=1;
			// }
			// if($iExiste==0)//NO SE A SUBIDO LA FACTURA RELACIONADA
			// {
				// $msj= 'Primero debera de subir la factura Relacionada con el folio '.$folioRelacionado;
				// echo "{";
				// echo	"msj: 	 '".$msj	."'\n";
				// echo "}";	
				// return;
			// }
		}
		if($total==0)
		{
			$e_Pago=$e_Complemento->item(0)->getElementsByTagName('Pago');
			if($e_Pago->length>0)
			{
				$total=trim($e_Pago->item(0)->getAttribute('Monto'));
				$total = Regresa_int($total);
			}
		}
		if($e_DocRelacionado->item(0)->hasAttribute('MetodoDePagoDR'))
		{
			$metodoPago=trim($e_DocRelacionado->item(0)->getAttribute('MetodoDePagoDR'));
		}
		*/	
	}		
			
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		try {
            $json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	}
	try{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();

		$cmd->setCommandText("SELECT * from fun_validar_clave_uso('$clv_uso'::VARCHAR, $iUsuario)");
		//$cmd->setCommandText("SELECT * from fun_validar_clave_uso('$clv_uso'::VARCHAR)");
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = $ds[0][0];
		if($estado != 1){
			generarResultado(-1, "La clave de uso no coincide", array());
		}
		
		
	}catch(exception $ex){
		$mensaje="";
		$mensaje="Ocurrió un error al conectar a la base de datos.";
		$estado=-1;
		generarResultado($estado,$mensaje,array());
	}
	
	
//SI VIENE DE LA CONFIGURACION DE BENEFICIARIOS SALIR
	
	/*
	if ($iConfig_Beneficiario==1){
		
		$arr[] = array('resultado' => 0,
						'mensaje' => 'ok'
						//'json' => $arrayjson
						);
		echo '' . json_encode($arr) . '';
		exit();
	}*/
	
	try
	{
		$fechaR=substr($fecha,0,4).substr($fecha,5,2).substr($fecha,8,2);
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT resultado, factura, mensaje from  fun_grabar_stmp_facturas_colegiaturas(0::INTEGER,'$foliofiscal'::VARCHAR,'$folio'::VARCHAR,'$serie'::VARCHAR, $iUsuario::INTEGER,0::INTEGER, 0::INTEGER, '$rfc_emisor'::VARCHAR,$importe_total::numeric, '$myXML'::TEXT,  '$fechaR'::DATE,$Revision::SMALLINT, '$t_comprobante'::VARCHAR, '$m_pago'::VARCHAR,'$folioRelacionado'::VARCHAR)");
		// exit();
		$cmd->setCommandText("SELECT resultado, factura, mensaje from fun_grabar_stmp_facturas_colegiaturas(0::INTEGER,'$foliofiscal'::VARCHAR,'$folio'::VARCHAR,'$serie'::VARCHAR, $iUsuario::INTEGER,0::INTEGER, 0::INTEGER, '$rfc_emisor'::VARCHAR,$importe_total::numeric, '$myXML'::TEXT,  '$fechaR'::DATE,$Revision::SMALLINT, '$t_comprobante'::VARCHAR, '$m_pago'::VARCHAR,'$folioRelacionado'::VARCHAR)");
		

	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0][0];
		$ifactura=$ds[0][1];
		$mensaje=$ds[0][2];
		
		if ($t_comprobante=='I'){			//INGRESO
			$n_comprobante=1;
		}else if ($t_comprobante=='E'){ 	//NOTA DE CREDITO
			$n_comprobante=2;
		}else if ($t_comprobante=='P'){ 	//PAGO
			$n_comprobante=3;
		//}else if ($t_comprobante==''){ 	//ESPECIAL
		//$n_comprobante=4;
		}
		
		// echo ('mensaje='.$mensaje);
		// exit();
		
		generarResultado($estado, $mensaje, 
		array('fecha' => substr($fecha,8,2).'/'.substr($fecha,5,2).'/'.substr($fecha,0,4),
			'folio_fiscal' => $foliofiscal,
			'folio' => $folio,
			'serie' => $serie,
			//'sello' => $sello,
			'emisor' => $nombre_emisor,
			'rfc_emisor' => $rfc_emisor,
			'importe_total' => $importe_total,
			'ifactura'=>$ifactura,
			'mensaje' => $mensaje,
			'importes'=>$imp_concetos,
			't_comprobante'=>$t_comprobante,
			'n_comprobante'=>$n_comprobante,
			'clave_uso'=>$clv_uso,
			'foliorelacionado'=>$folioRelacionado
			));
		
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-1;
		generarResultado($estado, $mensaje, array());
	}
	// echo -1002;exit();
	// generarResultado($estado, $mensaje, 
		// array('fecha' => substr($fecha,8,2).'/'.substr($fecha,5,2).'/'.substr($fecha,0,4),
			// 'folio_fiscal' => $foliofiscal,
			// 'folio' => $folio,
			// 'serie' => $serie,
			// 'sello' => $sello,
			// 'emisor' => $nombre_emisor,
			// 'rfc_emisor' => $rfc_emisor,
			// 'importe_total' => $importe_total,
			// 'ifactura'=>$ifactura,
			// 'mensaje' => $mensaje));
	function generarResultado($resultado, $mensaje, $arrayjson){
		try {
            $arr[] = array('resultado' => $resultado,
						'mensaje' => $mensaje,
						'json' => $arrayjson);
			echo '' . json_encode($arr) . '';
			exit();
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }
	}
	
	function extension($filename) {
		return substr(strrchr($filename, '.'), 1);
	}
	
	function fechaarchivo($filename, $tipoarchivo) {
		$parteFecha = substr(strstr($filename, $tipoarchivo), 4, 6);
		$dia = substr($parteFecha,0,2);
		$mes = substr($parteFecha,2,2);
		$anio = substr($parteFecha,4,2) + 2000;
		$timestamp = mktime(0, 0, 0, $mes, $dia, $anio);
		return date('Y-m-d', $timestamp);
	}
	
 ?>