<?php
	// ini_set('display_errors', 1);
	// ini_set('display_startup_errors', 1);
	// error_reporting(E_ALL);
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	//$Session = $_POST['session_name'];
	$Session = isset($_POST['session_name1']) ?  $_POST['session_name1'] : "Session-Colegiaturas";
	
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	require_once "proc_interaccionalfresco.php";
    //-------------------------------------------------------------------------
	$estado = 0;
	$mensaje = 'OK';
	// $MensajesError = "idMSG48";
	$data = array();
	$res = 0;
	$Session = isset($_POST['session_name1']) ?  $_POST['session_name1'] : "Session-Colegiaturas";
	$iFactura = isset($_POST['txt_ifactura']) ? $_POST['txt_ifactura'] : 0;
	$iEditar = isset($_POST['txt_EditarFactura']) ? $_POST['txt_EditarFactura'] : 0;

	$numGte = isset($_POST['txt_Num_Gte']) ? $_POST['txt_Num_Gte'] : 0;
	$nomGte = isset($_POST['txt_Nom_Gte']) ? $_POST['txt_Nom_Gte'] : '';

	$cComentario = isset($_POST['hidden_MotivoAclaracion']) ? $_POST['hidden_MotivoAclaracion'] : 0;
	//VARIABLES DE LA SESSION
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$iEmpresa = isset($_SESSION[$Session]["USUARIO"]['num_empresa'])?$_SESSION[$Session]['USUARIO']['num_empresa']:'';
	$iCentro = isset($_SESSION[$Session]["USUARIO"]['num_centro'])?$_SESSION[$Session]['USUARIO']['num_centro']:'';
	
	$iCentro = str_replace ("-", "", $iCentro);
	$iTipoComprobante=isset($_POST['txt_tipo_comprobante']) ? $_POST['txt_tipo_comprobante'] : 0;
	if($iTipoComprobante == ""){ $iTipoComprobante = 0; }
	$iExterno=isset($_POST['txt_externo']) ? $_POST['txt_externo'] : 0;
	$iBeneficiarioExt=isset($_POST['txt_beneficiario_ext']) ? $_POST['txt_beneficiario_ext'] : 0;
	// $FolioRelacionado = isset($_POST['txt_FolioRelacionado']) ? $_POST['txt_FolioRelacionado']: '';
	
	$sFechaFac = isset($_POST['txt_FechaFactura']) ? $_POST['txt_FechaFactura'] : 0;
	
	$sRfc = isset($_POST['txt_Rfc_fac']) ? $_POST['txt_Rfc_fac'] : 0;
	
	$tipoXml= isset($_POST['txt_tipoXml']) ? $_POST['txt_tipoXml'] : 1;
	$cMoneda = '';
	if($iExterno == 1) {
		$iTipoComprobante = 4;
	}
	// echo ('tipoComprobante='.$iTipoComprobante.' iEditar='.	$iEditar.' iFactura='.$iFactura);
	// exit();
	$cComentario= mb_convert_encoding($cComentario, 'UTF-8', 'ISO-8859-1');
	$serie='';
	$foliofiscal='';
	$rfc_emisor='';
	$iNuevoFactura=0;
	$nom_archivo1='';
	$nom_archivo2='';
	// $cliente = '';
	$estado = 0;
	$mensaje = "OK";
	//Obtener la ruta para el WS para subir la factura
	try{
		$CDB=obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado=$CDB['estado'];
		$mensaje=$CDB['mensaje'];
		$sNomParametro='URL_SERVICIO_FACTURACION';	//---------> Con ese valor,  Obtiene la ruta de pruebas para desarrollo(ASI SE TIENE AL MOMENTO)
													//Para tester toma la ruta de produccion previamente cargada en la tabla ctl_parametros_colegiaturas(SE INCLUYE EN EL SCRIPT DE LA TABLA COMO UN REGISTRO DE INSERCION)

		// $sNomParametro='URL_SERVICIO_FACTURACION_PRODUCCION';
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// echo ("SELECT * from fun_obtener_parametros_colegiaturas('$sNomParametro')");
		// exit();
		$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = 0;
		

		//http://10.44.15.35/WsReceptorFacturacion/WsReceptorFacturacion.php?wsdl
		
		$valorParametro=$ds[0][2];
	
		// echo "<pre>";
		// print_r($valorParametro);
		// echo "</pre>";
		// exit();
		
	}catch(Exception $ex){
		salir($estado, "Ocurrió un error al obtener los parametros de colegiaturas ", array(), 0, 0);
	}
	
	// Subir archivo en Alfresco
	// -------------------------------------------------------------------
		
	if( (isset($_FILES["fileXml"])) || (isset($_FILES["fileXml"]["tmp_name"])) ||  (isset($_FILES["filePdf"])) || $iEditar!=0 )//Si existe PDF o XML
	{
		try
		{
			$anio=date('Y');
			$anioFactura = substr($sFechaFac,0,4);
					
			$objAlfresco = new InteraccionAlfresco();
		
			$objAlfresco->setCiclo($anioFactura);
			
			foreach ($_FILES as $file) {
				$extension = $objAlfresco->getExtensionArchivo($file['name']);
				$secuencia_documento =$objAlfresco->obtenerSecuenciaDocumento();
				$nom_archivo = "$sFechaFac-$sRfc-$secuencia_documento.$extension";
				$b64 = $objAlfresco->getBase64($file['tmp_name']);
				$objAlfresco->guardarDocumento($iUsuario, $nom_archivo, $b64);
				if($nom_archivo1=='')
				{
					$nom_archivo1=$nom_archivo;
				}
				else
				{
					$nom_archivo2=$nom_archivo;
				}
			}
			
			$estado=0;
		} 
		catch (Exception $ex) {
			$mensaje="Ocurrio un error al subir el archivo en Alfresco, intentelo mas tarde.";
			$estado=-1001;
		}
		
		
	} else {
		$mensaje = "No existe archivo XML o PDF";
		$estado = -1002; 
	}
	
	if ($estado < 0) {
		salir($estado, $mensaje, array(), 0, 0);
	}
	
	// Utilizar webservice para validar XML y subir archivo 
	// en bd facturafiscal
	// -------------------------------------------------------------------
	$data = array();
	$iNuevoFactura = 0;
	$file = $_FILES['fileXml'];
	
	if($file['error'] === UPLOAD_ERR_OK){
		
	if( (isset($file)) && ($_FILES["fileXml"]['type'] == "text/xml") )
	{
		try {
			$xmlstr = file_get_contents(filter_var($_FILES["fileXml"]["tmp_name"], FILTER_SANITIZE_FULL_SPECIAL_CHARS));
			
			// -----> Quita basura al XMl que inpide leerlo
			$pos = strpos($xmlstr,"<?");
			$xmlstr = substr($xmlstr,$pos);
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd'", '"http://www.sat.gob.mx/cfd"', $xmlstr,$num1);
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd/2'", '"http://www.sat.gob.mx/cfd/2"', $xmlstr,$num1); 
			$xmlstr=str_replace("'http://www.w3.org/2001/XMLSchema-instance'", '"http://www.w3.org/2001/XMLSchema-instance"', $xmlstr,$num2); 
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv2.xsd'", '"http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv2.xsd"', $xmlstr,$num3); 
			$xmlstr=str_replace("'http://www.edcinvoice.com/lev1add'", '"http://www.edcinvoice.com/lev1add"', $xmlstr,$num5); 
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv2.xsd http://www.sat.gob.mx/psgecfd http://www.sat.gob.mx/sitio_internet/cfd/psgecfd/psgecfd.xsd http://www.edcinvoice.com/lev1add http://www.edcinvoice.com/lev1add/lev1add.xsd'", '"http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv2.xsd http://www.sat.gob.mx/psgecfd http://www.sat.gob.mx/sitio_internet/cfd/psgecfd/psgecfd.xsd http://www.edcinvoice.com/lev1add http://www.edcinvoice.com/lev1add/lev1add.xsd"', $xmlstr,$num6); 
			$xmlstr=str_replace("'http://www.sat.gob.mx/psgecfd'", '"http://www.sat.gob.mx/psgecfd"', $xmlstr,$num7); 
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/cfd/2/cfdv2.xsd'", '"http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/cfd/2/cfdv2.xsd"', $xmlstr,$num8);
			$xmlstr=str_replace("'http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv22.xsd'", '"http://www.sat.gob.mx/cfd/2 http://www.sat.gob.mx/sitio_internet/cfd/2/cfdv22.xsd"', $xmlstr,$num9);
			$xmlstr=str_replace("version='1.0' encoding='UTF-8'",'version="1.0" encoding="UTF-8"',$xmlstr,$num10);
			
			//Cambios
			$xmlstr = str_replace("�","Ñ",$xmlstr); //Ñ
			//$xmlstr = eliminarAcentos($xmlstr);
			$xmlstr = encodeToUtf8($xmlstr);
			$xmlstr = remplazarCfdi($xmlstr);


			$dom = new DomDocument; //Carga, lee xml
			$dom->preserveWhiteSpace = FALSE;
			$xml = @$dom->loadXML($xmlstr);

			if($xml)
			{
				$xml = $dom->getElementsByTagName('Comprobante');
			
				if($xml->length==1)
				{
					$serie = "";
					$foliofiscal = "";
					$folio = 0;
					$totalIva = 0;
					$subtotal = 0;
					$version = "";
					//$cMoneda = trim($xml->item(0)->getAttribute('Moneda'));
					
					if ($xml->item(0)->hasAttribute('version')) {
						$version = $xml->item(0)->getAttribute('version');
					} else if ($xml->item(0)->hasAttribute('Version')) {
						$version = $xml->item(0)->getAttribute('Version');
					}

					if ($version<"3.3")
					{
						$estado = -1006;
						throw new Exception("Versión de XML no válido");
					}
					
					if($xml->item(0)->hasAttribute('folio'))
					{
						$folio=trim($xml->item(0)->getAttribute('folio'));
						
						$arrayletras=array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",".","_","-"," ");
						$folio=str_ireplace($arrayletras,"",$folio);
						
						if($folio==""){
							$folio=0;
						}
						if(!(is_numeric($folio))){
							$folio=0;
						}
					} else if($xml->item(0)->hasAttribute('Folio')) {
						$folio=trim($xml->item(0)->getAttribute('Folio'));
						
						$arrayletras=array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",".","_","-"," ");
						$folio=str_ireplace($arrayletras,"",$folio);
						
						if($folio==""){
							$folio=0;
						}
						if(!(is_numeric($folio))){
							$folio=0;
						}
					/*} else {
						$estado = -1007;
						throw new Exception("No tiene el atributo Folio");*/
					}
					
					if($xml->item(0)->hasAttribute('serie'))
					{
						$serie=$xml->item(0)->getAttribute('serie');
					} else if($xml->item(0)->hasAttribute('Serie')) {
						$serie=$xml->item(0)->getAttribute('Serie');
					/*
					} else {
						$estado = -1008;
						throw new Exception("No tiene el atributo Serie");
					*/
					}
					
					if($xml->item(0)->hasAttribute('fecha'))
					{
						$fecha=$xml->item(0)->getAttribute('fecha');
						$annio = substr($fecha,0,4);
						// if($annio < date("Y"))
						// {
							// $estado = -1007;
							// throw new Exception("El archivo XML pertenece a un ejercicio anterior a este año");
						// }
						$fFechaFactura = substr($fecha,0,10);
						$fFechaFactura = str_replace('-', '', $fFechaFactura);
					} else if($xml->item(0)->hasAttribute('Fecha'))
					{
						$fecha=$xml->item(0)->getAttribute('Fecha');
						$annio = substr($fecha,0,4);
						// if($annio < date("Y"))
						// {
							// $estado = -1007;
							// throw new Exception("El archivo XML pertenece a un ejercicio anterior a este año");
						// }
						$fFechaFactura = substr($fecha,0,10);
						$fFechaFactura = str_replace('-', '', $fFechaFactura);
					} else {
						$estado = -1009;
						throw new Exception("No tiene el atributo Fecha");
					}

					if($xml->item(0)->hasAttribute('version'))
					{
						if(trim($xml->item(0)->getAttribute('version')) == "3.3" || trim($xml->item(0)->getAttribute('version')) == "4.0")
						{   
							$foliofiscal=trim($xml->item(0)->getElementsByTagName('TimbreFiscalDigital')->item(0)->getAttribute('UUID'));
							$foliofiscal=strtoupper($foliofiscal);              
						} //fin Version 3
					} else if($xml->item(0)->hasAttribute('Version'))
					{
						if(trim($xml->item(0)->getAttribute('Version')) == "3.3" || trim($xml->item(0)->getAttribute('Version')) == "4.0")
						{   
							$foliofiscal=trim($xml->item(0)->getElementsByTagName('TimbreFiscalDigital')->item(0)->getAttribute('UUID'));
							$foliofiscal=strtoupper($foliofiscal);
						} //fin Version 3
					} else {
						$estado = -1010;
						throw new Exception("No tiene el atributo Version");
					}

					if($foliofiscal=="")
					{
						// Si no tuviera TimbreFiscalDigital - UUID, se tomará el UUID del Comprobante
						$foliofiscal=$folio;
					}
					
					$rfc_emisor=trim($xml->item(0)->getElementsByTagName('Emisor')->item(0)->getAttribute('Rfc'));
					if($xml->item(0)->getElementsByTagName('Emisor')->item(0)->hasAttribute('Nombre'))
					{
						$nombre_emisor=trim($xml->item(0)->getElementsByTagName('Emisor')->item(0)->getAttribute('Nombre'));
						$nombre_emisor = mb_convert_encoding($nombre_emisor, 'UTF-8', 'ISO-8859-1');
						$nombre_emisor = str_replace("'","''",$nombre_emisor);
						$nombre_emisor = substr($nombre_emisor, 0,100);
					} else if($xml->item(0)->getElementsByTagName('Emisor')->item(0)->hasAttribute('nombre'))
					{
						$nombre_emisor=trim($xml->item(0)->getElementsByTagName('Emisor')->item(0)->getAttribute('nombre'));
						$nombre_emisor = mb_convert_encoding($nombre_emisor, 'UTF-8', 'ISO-8859-1');
						$nombre_emisor = str_replace("'","''",$nombre_emisor);
						$nombre_emisor = substr($nombre_emisor, 0,100);
					}
					
					if (trim($rfc_emisor) == "")
					{
						$estado=-1011;
						throw new Exception('No tiene atributo RFC del emisor');
					}
					
					if( $xml->item(0)->hasAttribute('Total') ) 
					{
						// echo('si tiene atributo total'.'<br>');
						$total=trim($xml->item(0)->getAttribute('Total'));
						
						$total = Regresa_int($total);
						$data[] = array("total" => $total);
					} else if( $xml->item(0)->hasAttribute('total') ) 
					{
						// echo('si tiene atributo total'.'<br>');
						$total=trim($xml->item(0)->getAttribute('total'));

						$data[] = array("total" => $total);
						$total = Regresa_int($total);
					}
					else
					{
						$estado=-1012;
						throw new Exception('No tiene atributo Total');
					}
					
					
					if($xml->item(0)->getElementsByTagName('Traslado')->length > 0)
					{
						for($h = 0; $h < $xml->item(0)->getElementsByTagName('Traslado')->length; $h++)
						{
						   if($xml->item(0)->getElementsByTagName('Traslado')->item($h)->hasAttribute('impuesto') == 'IVA')
							{
								//if nuevo
								if($xml->item(0)->getElementsByTagName('Traslado')->item($h)->getAttribute('TipoFactor') == 'Tasa' ||
								$xml->item(0)->getElementsByTagName('Traslado')->item($h)->getAttribute('TipoFactor') == 'Couta')
								{
									$totalIva = trim($xml->item(0)->getElementsByTagName('Traslado')->item($h)->getAttribute('importe'));
									$totalIva = Regresa_int($totalIva);
								   break;
								}
						   }
						}
					}
					
					if($xml->item(0)->hasAttribute('subTotal')){
						$subtotal=trim($xml->item(0)->getAttribute('subTotal'));
						$subtotal = Regresa_int($subtotal);
					} else if($xml->item(0)->hasAttribute('SubTotal')) {
						$subtotal=trim($xml->item(0)->getAttribute('SubTotal'));
						$subtotal = Regresa_int($subtotal);
					}
					//INICIA CONSUMO DEL WEBSERVICE PARA GUARDAR LA FACTURA EN FACTURA FISCAL
					//iniciar proceso para el consumo de el wsdl y la factura xml.
					$wsdl = "$valorParametro"; //	--> PRUEBA OBTENIENDO EL PARAMETRO DE LA TABLA CTL_PARAMETROS_COLEGIATURSA
					
					// $wsdl="http://10.44.15.35/WsReceptorFacturacion/WsReceptorFacturacion.php?wsdl"; //	--> pruebas					
					//$wsdl="http://".$_SESSION[$Session]['SERVICIOUPFACT']."/WsReceptorFacturacion/WsReceptorFacturacion.php?wsdl&tm=".time();	 // --> produccion
					//$cliente = new SoapClient($wsdl, array('proxy_host' => "proxy.coppel.com", 'proxy_port' => "8080", 'cache_wsdl' => WSDL_CACHE_NONE));
					
					//try {
						
						$cliente = new SoapClient($wsdl, array('cache_wsdl' => WSDL_CACHE_NONE));
						
					// } catch (SoapFault $fault) {
						// $estado = -1018;
						// $mensaje = 'Ocurrio un problema al subir la factura';
						// echo "<pre>";
						// print_r("VALIO BARRI");
						// echo "</pre>";
						// exit();
					// }
					
					if (!$cliente) {
						$estado = -1013;
						throw new Exception("...");
					
					}
					else
					{
					
						
						$estado_aux = $estado;
						$estado = -1014;
						$paramsgcfdie=array("numeroe"=>$iUsuario,"xml"=>base64_encode($xmlstr));
						
						
						// print_r($paramsgcfdie);
						// exit();
						
						if ($tipoXml==1){ 
							// XML de colaborador con prestación de colegiaturas
							$mensaje = "Error en la ejecución del método GuardarCFDI_colegiaturas_64";
							$responsegcfdie = $cliente->__soapCall('GuardarCFDI_colegiaturas_64',$paramsgcfdie);
							//echo("RESPUESTA CFDIE = ".$responsegcfdie);
							// exit();
						}else{
							// XML de colaborador externo

							$mensaje = "Error en la ejecución del método GuardarCFDI_empleados_64";
							$responsegcfdie = $cliente->__soapCall('GuardarCFDI_empleados_64',$paramsgcfdie);
						}
						try{
						
						$arrrespuesta = json_decode($responsegcfdie,true);
						$estado = $estado_aux;
						$mensaje = "";
						}
						catch(JsonException $ex){
							$mensaje = "no se pudo realizar conexión en línea 412";
							$estado=-2;
						}
					}
					
					$iNuevoFactura=$arrrespuesta['id_factura'];
					
					if ($arrrespuesta['estatus'] == 1 || $arrrespuesta['estatus'] == 2) {
						// $estado = 1;
						$estado = $arrrespuesta['estatus'];
						$mensaje = ($arrrespuesta['estatus'] == 1) ? "Se subió la factura" : "Ya existe la factura en facturafiscal";
						// salir($estado, $mensaje,array(), 0, 0);
					} else {
						
						$i=0;
						$tErrores = count($arrrespuesta["errores"]);
						$arrrespuesta['estatus'] = ($tErrores != 0)? -1:$arrrespuesta['estatus'];
						$mensaje = $arrrespuesta["mensaje"] . '--> ';
						while($i < $tErrores)
						{
							$mensaje .=  $arrrespuesta["errores"][$i].". ";
							$i++;
						}
						
						$estado = -1015;
						throw new Exception($mensaje);
					
					}
				}
				else
				{
					$estado = -1005;
					throw new Exception("No existe elemento Comprobante en archivo XML");
				}
			}
			else
			{
				$estado = -1004;
				throw new Exception("El archivo XML tiene un formato invalido");
			}			
		} catch(Exception $ex) {
			$mensaje = "Ocurrió un error al intentar subir el archivo.";//;
		}
	} else {
		if ($iEditar==0){
			$estado = -1003;
			$mensaje = "El archivo proporcionado no es un XML";
		}else{
			$iTipoComprobante=0;
		}
	}
}


	if ($estado < 0) {
		salir($estado, $mensaje, $data, $iFactura, $iNuevoFactura);
	}
	// Guardar el XML en las tablas stmp de Personal Postgres (Colegiaturas)
	// -------------------------------------------------------------------------
	// try {
		// fun_grabar_stmp_facturas_colegiaturas
	// }
	// echo "<pre>";
	// print_r($estado);
	// echo "</pre>";
	// exit();

	// Función Monedas
	/*try {
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];   
		$mensaje = $CDB['mensaje']; 
		
		if($estado != 0)
		{
			throw new Exception("Error al conectarse y obtener informacion de BDPERSONALPOSTGRESQL. ". $mensaje. " Función Monedas");
		}
		
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();

		$cmd->setCommandText("{CALL fun_tipo_moneda_colegiaturas(0, $iFactura, $iUsuario, '$cMoneda')}");
		$ds = $cmd->executeDataSet();
		$con->close();
	} catch (\Throwable $th) {
		salir($estado,"Ocurrió un error al guardar tipo moneda en base de datos ", array(), 0, 0);
	}*/
	
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];   
		$mensaje = $CDB['mensaje']; 
		$data = array();
		if($estado != 0)
		{
			throw new Exception("Error al conectarse y obtener informacion de BDPERSONALPOSTGRESQL. ". $mensaje);
		}
		
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		$cmd->setCommandText("{CALL fun_grabar_factura_colegiatura($iUsuario,$iBeneficiarioExt,$iFactura,$iEditar,'$cComentario','$nom_archivo1','$nom_archivo2', $iEmpresa, $iCentro, $iTipoComprobante, $numGte, '$nomGte')}"); 
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado=$ds[0][0];
		
		if($estado!=0)
		{
			$iNuevoFactura=$estado;
			$estado=1;
		}
		
		$estado= ($estado == NULL) ? -1017: $estado;
		$mensaje=$ds[0][1]; 
		
		if ($estado < 0)
			throw new Exception("Ocurrió un error al guardar la factura del colaborador en Personal: $mensaje");
		
		$data = array("iFactura" => $iFactura, "idfactura" => $iNuevoFactura);
		
		salir($estado, $mensaje, $data, $iFactura, $iNuevoFactura);
	}
	catch(exception $ex)
	{
                   
		salir($estado,"Ocurrió un error al conectar a la base de datos para guardar factura del colaborador ", array(), 0, 0);
	}

	function salir($estado,$mensaje,$data, $iFactura, $iNuevoFactura)
	{
		// echo('ESTADO:'.$estado.'     
			// MENSAJE:'.$mensaje.'    
			// FACTURA:'.$iFactura.'
			// INUEVOFACTURA:'.$iNuevoFactura);
		// exit();
		if($estado == 1){
			BorrarDatosFactura(1, $iFactura);
		}
		if($estado != 1){
			BorrarDatosFactura(0, $iNuevoFactura);
		}
		$json = new stdClass();
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		$json->data = $data;
		
		switch($estado) {
			case -1001:
				break; // No pudo guardar en Alfresco
			case -1002:
				break; // No se incluyó XML o PDF
			case -1003:
				break; // El archivo proporcionado no es un XML
			case -1004:
				break; // El archivo XML tiene un formato invalido
			case -1005:
				break; // No existe elemento Comprobante en archivo XML
			case -1006:
				break; // Versión de XML no válido, menor a la v. 3.3;
			case -1007:
				break; // No tiene el elemento Folio
			case -1008:
				break; // No tiene el atributo Fecha
			case -1009:
				break; // No tiene el atributo Fecha
			case -1010:
				break; // No tiene el atributo Version
			case -1011:
				break; // No tiene atributo RFC del emisor
			case -1012:
				break; // No tiene atributo Total
			case -1013:
				break; // Error en la conexion con el SoapClient
			case -1014:
				break; // Error en la ejecución del método GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1015:
				break; // Despliega el error que se generó al invocar alguno de los métodos GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1016:
				break; // Despliega el error que se generó al invocar alguno de los métodos GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1017:
				break; // Ocurrió un error al guardar la factura del colaborador en Personal
			case -1018:
				break; // Ocurrió un error en la creación del objeto de SoapClient
			default:
				break;
		}
		
		if ($estado < 0) {
			
		}
		
		try{
			echo json_encode($json); 
			die();
		}
		catch(JsonException $ex){
			$json->mensaje = "error al codificar Json"; //$ex->getMessage();
			$json->estado=-2;
		}
	}
	
	function Regresa_int($varcant) //quita decimales ...varia dependiendo ya que maneja varios . decimales en el total
	{
		if(strpos($varcant,".")!==false)
		{
			$longitud = strlen($varcant);
			$punto = strpos($varcant,".");
			if (($punto+2)>=$longitud){
				$varcant = $varcant."00";
			}
			$valantesdpunto=substr($varcant,0,strpos($varcant,"."));
			if($valantesdpunto=="")
			{
				$valantesdpunto="0";
			}
			$valor= $valantesdpunto.substr($varcant,strpos($varcant,".")+1,2); 
		}else
		{
			$valor= $varcant."00";
		}
		$resp = $valor;
		return $resp;
	}
	
	function BorrarDatosFactura($iOpcion, $iFactura)
	{
		try
		{
			$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
			$estado = $CDB['estado'];
			$mensaje = $CDB['mensaje'];
			if($estado != 0)
			{
				throw new Exception("Error al conectarse y obtener informacion de BDPERSONALPOSTGRESQL. ". $mensaje);
			}
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$cmd->setCommandText("{CALL fun_eliminar_facturas_colegiaturas($iOpcion, $iFactura)}"); 
			$ds = $cmd->executeDataSet();
			$con->close();
		}
		catch(exception $ex)
		{			
			$mensaje = "Ocurrió un error al conectar a la base de datos para Borrar Datos de Facturas ";
			$estado=-1;
		}
	}


	/*unction eliminarAcentos($xmlStr) {
		$map = ['á' => 'a', 'é' => 'e', 'í'=> 'i', 'ó' => 'o', 'ú' => 'u',
				'Á' => 'A', 'É' => 'E', 'Í'=> 'I', 'Ó' => 'O', 'Ú' => 'U'];

		return strtr($xmlStr, $map);
	}*/

	function remplazarCfdi($xmlStr) {

		$mapCfid = ['<Comprobante' => '<cfdi:Comprobante', '</Comprobante>' => '</cfdi:Comprobante>', 
					'<Emisor' => '<cfdi:Emisor', '</Emisor>' => '</cfdi:Emisor>',
					'<Receptor' => '<cfdi:Receptor', '</Receptor>' => '</cfdi:Receptor>',
					'<Conceptos>' => '<cfdi:Conceptos>', '</Conceptos>' => '</cfdi:Conceptos>',
					'<Concepto' => '<cfdi:Concepto', '<Impuestos>' => '<cfdi:Impuestos>',
					'</Impuestos>' => '</cfdi:Impuestos>', '<Traslados>' => '<cfdi:Traslados>',
					'<Traslado' => '<cfdi:Traslado', '</Traslados>' => '</cfdi:Traslados>',
					'</Concepto>' => '</cfdi:Concepto>', '' => '',
					'<ComplementoConcepto' => '<cfdi:ComplementoConcepto', '</ComplementoConcepto>' => '</cfdi:ComplementoConcepto>',
					'<Complemento>' => '<cfdi:Complemento>', '</Complemento>' => '</cfdi:Complemento>',
					'<TimbreFiscalDigital' => '<tfd:TimbreFiscalDigital',
					'<Impuestos' => '<cfdi:Impuestos'];


		return strtr($xmlStr, $mapCfid);
	}
