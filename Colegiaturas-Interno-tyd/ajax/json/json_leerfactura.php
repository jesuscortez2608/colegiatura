<?php
	/*ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);*/
 // session_name("Session-Gastos_de_Viaje");
 session_name("Session-Colegiaturas");
 session_start();
 header ('Content-type: text/html; charset=utf-8');
 $Session = $_POST['session_name'];
 
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/data/class_enletras.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    //-------------------------------------------------------------------------
    // $CDB = obtenConexion(DBFACTURAFISCALPOSTGRESQL);
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $_POSTS = filter_input_array(INPUT_POST, FILTER_SANITIZE_NUMBER_INT);

	$nIsFactura = (isset($_POST['nIsFactura']))?$_POST['nIsFactura']:'';//'0';
	// $sFacFiscal = (isset($_POST['sFacFiscal']))?$_POST['sFacFiscal']:'';//'95ACF0B8-A671-4BE3-945C-528082DFA809';//'39321C2E-F67C-46CF-81C3-7805C115AD35';
	$idFactura = isset($_POSTS['idFactura'])? $_POSTS['idFactura']:0;
	//$idFactura = filter_var($idFactura,FILTER_VALIDATE_INT);
	
	$sFilename = (isset($_POST['sFilename']))?$_POST['sFilename']:'';
	$sFiliePath = (isset($_POST['sFiliePath']))?$_POST['sFiliePath']:'';
	
	// echo "<pre>";
	// print_r('nIsFactura= '.$nIsFactura);
	// print_r('sFacFiscal= '.$sFacFiscal);
	// print_r('sFilename= '.$sFilename);
	// print_r('sFiliePath= '.$sFiliePath);
	// echo "</pre>";
	// exit();
	
 	$json = new stdClass();
	try
    {
		
    	if($estado != 0){
	    	throw new Exception("Error al conectarse y obtener informacion de BDSYSCOPPELPERSONALSQL. ".$mensaje);
	    }
		if($Session == '' || $nIsFactura == ''){
			
			throw new Exception("Error con las variables obtenidas.\n Session = $Session || nIsFactura = $nIsFactura");
		}
		if($nIsFactura != 0)//Es deducible imagen
		{

			
			if($nIsFactura != 0 && ($sFilename == '' || $sFiliePath == ''))
			{
				throw new Exception("Error con las variables obtenidas.\n nIsFactura = $nIsFactura != 0 && (sFilename == $sFilename || sFiliePath == $sFiliePath)");
			}
			/*
			$doc = new stdClass();
			$CDB = obtenConexion(ADMINISTRACIONALFRESCO);
			$estado = $CDB['estado'];   
			$mensaje = $CDB['mensaje']; 
			if($estado != 0)
			{
				throw new Exception("Error al conectarse y obtener informacion de ADMINISTRACIONALFRESCO. ". $mensaje);
			}
			$CDB['conexion'] = explode(';', $CDB['conexion']);
			$doc->user = explode('=', $CDB['conexion'][2]); 
			$doc->user = $doc->user[1];
			
			$doc->password = explode('=', $CDB['conexion'][3]); 
			$doc->password = $doc->password[1];
			
			$doc->password = explode('=', $CDB['conexion'][3]); 
			$doc->password = $doc->password[1];
			
			$doc->path = $sFiliePath .'/'. $nIsFactura;
			$wsdl = explode('=', $CDB['conexion'][1]); 
			$wsdl = $wsdl[1];
			$wsdl = "http://".$wsdl."/alfresco/ws_server.php?wsdl";
			$cliente = new SoapClient($wsdl);
			*/
			/*
			$response=$cliente->nodeExists($doc);
			if($response->success)
			{
				if(!$response->exists)
				{
					throw new Exception("No se encontro Comprobante");
				}
				else
				{
					$response=$cliente->getContent($doc);
					if(isset($response[0]->url))
					{
						//echo $response[0]->url;*/
						/*$response[0]->url = str_replace("http://", "http://$doc->user:$doc->password@", $response[0]->url);
						$img = base64_encode(file_get_contents($response[0]->url));*/
						/*
						$imageUrl = new stdClass();
						$imageUrl->url = str_replace("http://", "http://$doc->user:$doc->password@", $response[0]->url);
						$res = $cliente->getFileUrl($imageUrl);
						$img = $res[0]->fileContent64;
						
						$json->isFactura = 0;
						$json->noDeducible = "data:image/jpg;base64,".$img; 
						$json->mensaje = $mensaje;
						$json->estado = $estado;
						//echo "<img src='data:image/jpg;base64,".$img."' alt='Error al cargar No deducible'/>";
					}
					else
					{
						throw new Exception("Error al leer directorio. ". $doc->path);
					}
				}
			}
			else
			{
				throw new Exception("Error en la operaci�n. ". $doc->path);
			}*/
		}
		else//es una factura
		{
			
			if($idFactura == 0 || $idFactura == '')
			{
				throw new Exception("Error con las variables obtenidas.\n Factura = $idFactura");
			}
			$iCant = 4000;
			$iIni = 0;
			$con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			// echo ("CALL fun_obtenerFacturaEle($idFactura,$iIni,$iCant)");
			// exit();
			
	        $cmd->setCommandText("{CALL fun_obtenerFacturaEle($idFactura,$iIni,$iCant)}");
	        // $cmd->setCommandText("{CALL fun_obtenerFacturaEle('$sFacFiscal',$iIni,$iCant)}");
	        $ds = $cmd->executeDataSet();

			//Limpiamos las facturas que contienen ese caracter raro
			foreach ($ds as &$itemXml) {
				$itemXml = str_replace('ï»¿', '', $itemXml);
				//$itemXml = ltrim($itemXml);
			}
			unset($itemXml);
			// echo "<pre>";
			//print_r($ds);
			//exit;

			// echo "</pre>";
			// exit();
			/*******************************Se agrego* devido al limite de los 10000 caracteres***********/
			//El smail no aguanto los 10000 asi que se bajo hasta 4000
			if($ds[0]['sxml'] != '-1')
			{
				$xmlBuferr = $ds[0]['sxml'];
				$tamanio = $ds[0]['tamanio'];
				$veses = ceil($tamanio / $iCant);
				$iIni += 1;
				for($ves = 1; $ves < $veses; $ves++)
				{
					$iIni += $iCant;
                    $cmd->setCommandText("{CALL fun_obtenerFacturaEle($idFactura,$iIni,$iCant)}");
					$ds = $cmd->executeDataSet();
					$xmlBuferr .= $ds[0]['sxml'];
				}
				$ds[0]['sxml'] = $xmlBuferr;
			}
			/********************************************************************************************/
			$con->close();
			// echo ($ds[0]['sxml']);
			// exit();
	        if($ds[0]['sxml'] != '-1')
			{
				$json->estado = 0;
				$json->mensaje = "OK";
				$json->isFactura = 1;
				
				/*if(!(is_numeric($sFacFiscal)))
				{$folio=0;} 
				else{$folio = $sFacFiscal;}
				$dia=date("d");
		        $mes=date("m");
		        $year=date("Y");
		        $variable = $dia*($mes)*($year-1900);
				
				$json->url = "http://10.44.15.35/factura/impresion/verfactura.php?sesion=".$sFacFiscal."%24".$folio."%24".$variable;*/
				////////////////EXTRAER DATOS DE ARCHIVO XML//////////////////  				
				//proceso para leer factura
				$tipose=1; $flag_rep=0; 
				 $band_desc=0;
				 $subt=0;
				 $descuento=0;
				 $importe_total=0;
				 $cadenaoriginal="||";	
				 
				 $impresion = '';
				 $impresion2 = '';
				 $import_tot = 0; 
				 $bandretcedular = '';   
				 $bandtrasloc = '';
				 
				//$internal_errors = libxml_use_internal_errors(true);
				
				$dom = new DomDocument; //Carga, lee xml
				$dom->preserveWhiteSpace = FALSE;
				$xml = (@$dom->loadXML($ds[0]['sxml']) === FALSE)?@$dom->loadXML($ds[0]['sxml']):@$dom->loadXML($ds[0]['sxml']);

				
				//libxml_use_internal_errors($internal_errors);
				
			

				//foreach($parametrocomprobante as $params){
				//$version = ($params->getAttribute('version'));
				//$cadenaoriginal.=$version;
				//$serie="";
				//if($params->hasAttribute('serie'))
				
				$parametrocomprobante = $dom->getElementsByTagName('Comprobante');
				
				if($parametrocomprobante->item(0)->hasAttribute('version'))
				{
					
					$paramconcepto = $dom->getElementsByTagName('Concepto');
					$parametrocomprobante = $dom->getElementsByTagName('Comprobante');
					//$parametroemisor = $dom->getElementsByTagName('Emisor');
					$parametro_emisor_dom_fisc = $dom->getElementsByTagName('DomicilioFiscal');
					$parametro_ExpedidoEn = $dom->getElementsByTagName('ExpedidoEn');
					$parametro_RegimenFiscal = $dom->getElementsByTagName('RegimenFiscal');
					$parametroreceptor = $dom->getElementsByTagName('Receptor');
					$parametro_receptor_dom = $dom->getElementsByTagName('Domicilio');
					$parametro_retenciones = $dom->getElementsByTagName('Retencion');
					$parametro_traslados = $dom->getElementsByTagName('Traslado');
					$parametro_estatus = $dom->getElementsByTagName('Estatus');
					$parametro_ElementosExtra = $dom->getElementsByTagName('ElementosExtra');
					//$parametro_ElementosExtra = $dom->getElementsByTagName('ElementosExtra');
					
					if($parametro_ElementosExtra->length==1)
					   {
						 $cadenaoriginal2=$parametro_ElementosExtra->item(0)->getAttribute('cadenaOriginal');
					   }
					  
					
					//$parametro_predial = $dom->getElementsByTagName('CuentaPredial');
					//$parametro_info_aduanera = $dom->getElementsByTagName('InformacionAduanera');
			
		
						
					$band_desc=0;
					
					foreach($parametrocomprobante as $params){
					$version = ($params->getAttribute('version'));
					$cadenaoriginal.=$version;
					$serie="";
					if($params->hasAttribute('serie'))
					   {
						 $serie = ($params->getAttribute('serie'));  
						 if(!empty($serie))
							{$cadenaoriginal.="|".$serie;} 
					   }
					
					$folio = ($params->getAttribute('folio'));
					$fecha = ($params->getAttribute('fecha'));
					$sello = ($params->getAttribute('sello'));
					$f_pago = ($params->getAttribute('formaDePago'));
					$noAprobacion = ($params->getAttribute('noAprobacion'));
					$anoAprobacion = ($params->getAttribute('anoAprobacion'));
					$tipoDeComprobante = ($params->getAttribute('TipoDeComprobante'));
					$formaDePago = ($params->getAttribute('formaDePago'));
					$noCertificado = ($params->getAttribute('noCertificado'));
					$certificado = ($params->getAttribute('certificado'));
					$NumCtaPago = ($params->getAttribute('NumCtaPago'));
					$metodoDePago = ($params->getAttribute('formaDePago'));
					$FormaPago = ($params->getAttribute('metodoDePago'));
					$nVersion = ($params->getAttribute('version'));		
					
	
					$cadenaoriginal.="|".$folio."|".$fecha."|".$noAprobacion."|".$anoAprobacion."|".$tipoDeComprobante."|".$formaDePago;
					
					
					if($params->hasAttribute('condicionesDePago'))
							  {
								$condicionesDePago=$params -> getAttribute('condicionesDePago');
								if(!empty($condicionesDePago))
									{$cadenaoriginal.="|".$condicionesDePago;}
					
							  }
					
					  $subt = trim($params->getAttribute('subTotal'));
					  $importe_total = trim($params->getAttribute('total'));
					$cadenaoriginal.="|".$params->getAttribute('subTotal');
					
					if($params->hasAttribute('descuento'))
						{
						  $band_desc=1;
						  $descuento =trim($params->getAttribute('descuento'));
						  $cadenaoriginal.="|".$params->getAttribute('descuento');
						}
					$cadenaoriginal.="|".$params->getAttribute('total');	
					}
					
					
					if($params->hasAttribute('metodoDePago'))
					   {
						 $metodoDePago = ($params->getAttribute('metodoDePago'));  
						 if(!empty($metodoDePago))
							{$cadenaoriginal.="|".$metodoDePago;} 
					   }
					   
					 if($params->hasAttribute('formaDePago'))
					   {
						 $metodoDePago = ($params->getAttribute('formaDePago'));  
						 if(!empty($metodoDePago))
							{$cadenaoriginal.="|".$metodoDePago;} 
					   }  
					   
					   if($params->hasAttribute('metodoDePago'))
					   {
						 $FormaPago = ($params->getAttribute('metodoDePago'));  
						 if(!empty($FormaPago))
							{$cadenaoriginal.="|".$FormaPago;} 
					   }
					   
						$conceptoArc = idConceptoSat(6);
						$concepto = 'idSAT'.$FormaPago;
						$concepto = $conceptoArc->$concepto;
						$FormaPago = $concepto;
						$FormaPago = $FormaPago;
					
					
					if($params->hasAttribute('LugarExpedicion'))
					   {
						 $LugarExpedicion = ($params->getAttribute('LugarExpedicion'));  
						 if(!empty($LugarExpedicion))
							{$cadenaoriginal.="|".$LugarExpedicion;} 
					   }
					
					$e_Complemento = $dom->getElementsByTagName('Complemento');
						if($e_Complemento->length >= 1){
							   $e_TimbreFiscalDigital = $e_Complemento->item(0)->getElementsByTagName('TimbreFiscalDigital');
								if($e_TimbreFiscalDigital->length==1){
									 if($e_TimbreFiscalDigital->item(0)->hasAttribute('UUID'))
										{
											$foliofiscal=trim($e_TimbreFiscalDigital->item(0)->getAttribute('UUID'));
											$foliofiscal=strtoupper($foliofiscal);										
										}
									    
										if($e_TimbreFiscalDigital->item(0)->hasAttribute('FechaTimbrado'))
										{
											$FechaTimbrado=trim($e_TimbreFiscalDigital->item(0)->getAttribute('FechaTimbrado'));
										} 
										
										if($e_TimbreFiscalDigital->item(0)->hasAttribute('noCertificadoSAT') || $e_TimbreFiscalDigital->item(0)->hasAttribute('NoCertificadoSAT'))
										{
											$noCertificadoSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('noCertificadoSAT'));
											$noCertificadoSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('NoCertificadoSAT'));
										}
										
										if($e_TimbreFiscalDigital->item(0)->hasAttribute('selloSAT'))
										{
											$selloSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('selloSAT'));
										}
										
										if($e_TimbreFiscalDigital->item(0)->hasAttribute('selloCFD'))
										{
											$selloCFD=trim($e_TimbreFiscalDigital->item(0)->getAttribute('selloCFD'));
										} 
										
										if($e_TimbreFiscalDigital->item(0)->hasAttribute('version'))
										{
											$versiontimbre=trim($e_TimbreFiscalDigital->item(0)->getAttribute('version'));						
										}
								}
						
							   
								$e_implocales=$e_Complemento->item(0)->getElementsByTagName('ImpuestosLocales');
								
									if($e_implocales->length==1){
										$e_retencioneslocales = $e_implocales->item(0)->getElementsByTagName("RetencionesLocales");
										if($e_retencioneslocales->length==1){
											$bandretcedular=1;
											  
											if($e_retencioneslocales->item(0)->hasAttribute("TasadeRetencion")){
												  $tasaretencioncedular = $e_retencioneslocales->item(0)->getAttribute("TasadeRetencion");
											}
											if($e_retencioneslocales->item(0)->hasAttribute("Importe")){
												$importeretencioncedular = $e_retencioneslocales->item(0)->getAttribute("Importe");
											}
										}
										   
										   
										 $e_trasladoslocales = $e_implocales->item(0)->getElementsByTagName("TrasladosLocales");
										if($e_trasladoslocales->length==1){
										   $bandtrasloc=1;
										  
											if($e_trasladoslocales->item(0)->hasAttribute("TasadeTraslado")){
												  $tasatrasladoloc = $e_trasladoslocales->item(0)->getAttribute("TasadeTraslado");
											}
											if($e_trasladoslocales->item(0)->hasAttribute("Importe")){
												  $importetrasladoloc = $e_trasladoslocales->item(0)->getAttribute("Importe");
											}
										}
									}
						}
			
					$impresion.="<table width='95%' border='0' align='center' cellpadding=\"0\" cellspacing=\"0\">
							   <tr>
								   <td></td>
								   <td  align='right'>
									<table border='1' > 
										 <tr><th class='h1' style='color:#438EB9'>Tipo Documento</th><td class='h1'>$tipoDeComprobante</td></tr>
										 <tr><th class='h1' style='color:#438EB9'>Folio-Serie</th><td class='h1'>$folio-$serie</td></tr>
										 <tr><th class='h1' style='color:#438EB9'>Fecha</th><td class='h1'>$fecha</td></tr>
									";
									if($version >="3.0")
									  {
										 $impresion.="<tr><th class='h1' style='font-color:#438EB9'>Serie del Cert. del CSD</td><td>".$noCertificado."</td></tr>";
										 $impresion.="<tr><th class='h1 style='font-color:#438EB9'>Version</td><td>".$nVersion."</td></tr>";//--->RRG
									  }else{
										$impresion.="  
										 <tr><th class='h1' style='color:#438EB9'>Aprobaci&oacute;n</th><td class='h1'>$noAprobacion</td></tr>
										 <tr><th class='h1' style='color:#438EB9'>A&ntilde;o Aprobaci&oacute;n</th><td class='h1'>$anoAprobacion</td></tr>
										 ";
										  }
										  
								$impresion.=" </table>
								   </td>
								 </tr><tr><td>&nbsp;</td></tr>";
					
					$impresion2.="<table width='95%' border='0' align='center'>
								   <tr>
									 <td></td>
									 <td  align='right'>
										<table border='1' cellspacing='0' cellpadding='0'>
										   <tr><th class='h1' style='color:#438EB9'>Tipo Documento</th><td class='h1'>$tipoDeComprobante</td></tr>
										   <tr><th class='h1' style='color:#438EB9'>Folio-Serie</th><td class='h1'>$folio-$serie</td></tr>
										   <tr><th class='h1' style='color:#438EB9'>Fecha</th><td class='h1'>$fecha</td></tr>";
										   
									if($version >="3.0")
									  {
										 $impresion2.="<tr><th class='h1'>Serie del Cert. del CSD</td><td>".$noCertificado."</td></tr>";
									  }else{
										$impresion2.="  
										 <tr><th class='h1'>Aprobaci&oacute;n</th><td class='h1'>$noAprobacion</td></tr>
										 <tr><th class='h1'>A&ntilde;o Aprobaci&oacute;n</th><td class='h1'>$anoAprobacion</td></tr>
										 ";
										  }
										  
								$impresion2.=" </table>
								   </td>
								 </tr>";
					
					
					
					/*foreach($parametroemisor as $params){
					$nombre_emisor =addslashes(utf8_decode($params -> getAttribute('nombre')));
					$rfc_emisor =substr(($params -> getAttribute('rfc')),0,13);
					
					
					}*/
					$parametroemisor = $dom->getElementsByTagName('Emisor');
					
						 if($parametroemisor->length > 0)
							 {
								$nombre_emisor =addslashes($parametroemisor->item(0)-> getAttribute('nombre'));
								$rfc_emisor =substr(($parametroemisor->item(0) -> getAttribute('rfc')),0,13);
							 }
					
					
					$cadenaoriginal.="|".$rfc_emisor."|".$nombre_emisor;
										
					//foreach($parametro_RegimenFiscal as $params){
					$RegimenFiscal_Regimen = $parametro_RegimenFiscal->item(0) -> getAttribute('Regimen');
					if(!empty($RegimenFiscal_Regimen))
					   {
						 $cadenaoriginal.="|".$RegimenFiscal_Regimen;
					   }
					//}
					
					
					//foreach($parametro_emisor_dom_fisc as $params){
					if($parametro_emisor_dom_fisc->length>=1)
					{	
						$df_calle = $parametro_emisor_dom_fisc->item(0) -> getAttribute('calle');
						$cadenaoriginal.="|".$df_calle;
						
						$df_noExterior = trim($parametro_emisor_dom_fisc->item(0) -> getAttribute('noExterior'));
						if($df_noExterior!="")
						   {$cadenaoriginal.="|".$df_noExterior;}
						   
						$df_noInterior = trim($parametro_emisor_dom_fisc->item(0) -> getAttribute('noInterior'));
						if($df_noInterior!="")
						   {$cadenaoriginal.="|".$df_noInterior;}
						   
						$df_colonia = $parametro_emisor_dom_fisc->item(0) -> getAttribute('colonia');
						if(!empty($df_colonia))
						   {$cadenaoriginal.="|".$df_colonia;}
						   
						$df_localidad = $parametro_emisor_dom_fisc->item(0) -> getAttribute('localidad');
						if(!empty($df_localidad))
						   {$cadenaoriginal.="|".$df_localidad;}
						   
						$df_referencia = $parametro_emisor_dom_fisc->item(0) -> getAttribute('referencia');
						if(!empty($df_referencia))
						   {$cadenaoriginal.="|".$df_referencia;}
						   
						$df_municipio = $parametro_emisor_dom_fisc->item(0) -> getAttribute('municipio');
						$cadenaoriginal.="|".$df_municipio;
						$df_estado = $parametro_emisor_dom_fisc->item(0) -> getAttribute('estado');
						$cadenaoriginal.="|".$df_estado;
						$df_pais = $parametro_emisor_dom_fisc->item(0) -> getAttribute('pais');
						$cadenaoriginal.="|".$df_pais;
						$df_codigopostal = ($parametro_emisor_dom_fisc->item(0) -> getAttribute('codigoPostal'));
						$cadenaoriginal.="|".$df_codigopostal;
					}
					
					//}
					//$cadenaoriginal.="|".$df_calle."|".$df_noExterior."|".$df_noInterior."|".$df_colonia."|".$df_localidad."|".$df_referencia."|".$df_municipio."|".$df_estado."|".$df_pais."|".$df_codigopostal;
					
					if(empty($df_noExterior)){$df_noExterior=0;}
					if(empty($df_codigopostal)){$df_codigopostal=0; $cadcodpost_e="";}else{$cadcodpost_e=" CODIGO POSTAL $df_codigopostal";}
					
					
					$impresion.="<tr>
								   <td width='50%' id='tdt1' valign='top'>
									   <table width='100%' border='1'><tr><th colspan='2' class='h1'>Emisor</th></tr>
										 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
										 <tr><th>Nombre</th><td>$nombre_emisor</td></tr>
										  <tr><th>R&eacute;gimen Fiscal</th><td>$RegimenFiscal_Regimen</td></tr>
										 <tr><th colspan='2' class='h2'>Domiclio</th></tr>
										 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
										 <tr><td colspan='2'>$df_colonia</td></tr>
										 <tr><td colspan='2'>$df_localidad</td></tr>
										 <tr><td colspan='2'>$df_referencia</td></tr>
										 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
										 <tr><td colspan='2'>$df_estado</td></tr>
										 <tr><td colspan='2'>$df_pais</td></tr>
									   </table>
								   </td>";
							  
					$impresion2.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='0' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h1'>Emisor</th></tr>
									 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
									 <tr><th>Nombre</th><td>$nombre_emisor<br><b>R&eacute;gimen Fiscal:</b>$RegimenFiscal_Regimen</td></tr>
									 <tr><th colspan='2' class='h2'>Domiclio</th></tr>
									 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
									 <tr><td colspan='2'>$df_colonia</td></tr>
									 <tr><td colspan='2'>$df_localidad</td></tr>
									 <tr><td colspan='2'>$df_referencia</td></tr>
									 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
									 <tr><td colspan='2'>$df_estado</td></tr>
									 <tr><td colspan='2'>$df_pais</td></tr>
									 </table>
									</td>";		
									
					$impresion.="<tr>
								   <td width='50%' id='tdt1' valign='top'>
									   <table width='100%' border='1'><tr><th colspan='2' class='h1'>Emisor</th></tr>
										 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
										 <tr><th>Nombre</th><td>$nombre_emisor</td></tr>
										  <tr><th>R&eacute;gimen Fiscal</th><td>$RegimenFiscal_Regimen</td></tr>
										 <tr><th colspan='2' class='h2'>Domicilio Fiscal</th></tr>
										 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
										 <tr><td colspan='2'>$df_colonia</td></tr>
										 <tr><td colspan='2'>$df_localidad</td></tr>
										 <tr><td colspan='2'>$df_referencia</td></tr>
										 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
										 <tr><td colspan='2'>$df_estado</td></tr>
										 <tr><td colspan='2'>$df_pais</td></tr>
										</table>
								   </td>";
										 
					$impresion2.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='0' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h1'>Emisor</th></tr>
									 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
									 <tr><th>Nombre</th><td>$nombre_emisor<br><b>R&eacute;gimen Fiscal:</b>$RegimenFiscal_Regimen</td></tr>
									 <tr><th colspan='2' class='h2'>Domicilio Fiscal</th></tr>
									 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
									 <tr><td colspan='2'>$df_colonia</td></tr>
									 <tr><td colspan='2'>$df_localidad</td></tr>
									 <tr><td colspan='2'>$df_referencia</td></tr>
									 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
									 <tr><td colspan='2'>$df_estado</td></tr>
									 <tr><td colspan='2'>$df_pais</td></tr>	
									 </table>
									</td>";
					
					
					
					/*foreach($parametroreceptor as $params){
					
					$rfc_receptor =substr(($params -> getAttribute('rfc')),0,13);
					$cadenaoriginal.="|".$rfc_receptor;
					
					$nombre_receptor =utf8_decode($params -> getAttribute('nombre'));
					if(!empty($nombre_receptor))
					   {
						 $cadenaoriginal.="|".$nombre_receptor;
					   }
					}*/
					
					
					$parametroreceptor = $dom->getElementsByTagName('Receptor');
						 if($parametroemisor->length > 0)
							 {
								$rfc_receptor =substr(($parametroreceptor->item(0) -> getAttribute('rfc')),0,13);
								$cadenaoriginal.="|".$rfc_receptor;
								
								$nombre_receptor = $parametroreceptor->item(0) -> getAttribute('nombre');
								if(!empty($nombre_receptor))
								   {
									 $cadenaoriginal.="|".$nombre_receptor;
								   }
							 }
					
					
					$codigo="0";
					
					//foreach($parametro_receptor_dom as $params){
					
					 if($parametro_receptor_dom->length >= 1)
						{	
						
							  $dom_calle = ($parametro_receptor_dom->item(0) -> getAttribute('calle'));
							if(!empty($dom_calle))
							   {
								 $cadenaoriginal.="|".$dom_calle;
							   }
					
					
							$dom_noExterior = trim($parametro_receptor_dom->item(0) -> getAttribute('noExterior'));
							if($dom_noExterior!="")
							   {
								 $cadenaoriginal.="|".$dom_noExterior;
							   }
							
							$dom_noInterior = trim($parametro_receptor_dom->item(0) -> getAttribute('noInterior'));
							if($dom_noInterior!="")
							   {
								 $cadenaoriginal.="|".$dom_noInterior;
							   }
							
							$dom_colonia = $parametro_receptor_dom->item(0) -> getAttribute('colonia');
							if(!empty($dom_colonia))
							   {
								 $cadenaoriginal.="|".$dom_colonia;
							   }
							$dom_localidad = $parametro_receptor_dom->item(0) -> getAttribute('localidad');
							if(!empty($dom_localidad))
							   {
								 $cadenaoriginal.="|".$dom_localidad;
							   }
							$dom_referencia = $parametro_receptor_dom->item(0) -> getAttribute('referencia');
							if(!empty($dom_referencia))
							   {
								 $cadenaoriginal.="|".$dom_referencia;
							   }
							$dom_municipio = $parametro_receptor_dom->item(0) -> getAttribute('municipio');
							if(!empty($dom_municipio))
							   {
								 $cadenaoriginal.="|".$dom_municipio;
							   }
							$dom_estado = $parametro_receptor_dom->item(0) -> getAttribute('estado');
							if(!empty($dom_estado))
							   {
								 $cadenaoriginal.="|".$dom_estado;
							   }
							$dom_pais = $parametro_receptor_dom->item(0) -> getAttribute('pais');
							$cadenaoriginal.="|".$dom_pais;
							
							$dom_codigopostal = ($parametro_receptor_dom->item(0) -> getAttribute('codigoPostal'));
							if(!empty($dom_codigopostal))
							   {
								 $cadenaoriginal.="|".$dom_codigopostal;
							   }
						}
					//}
					
					
					//if(empty($dom_noExterior)){$dom_noExterior=0;}
					//if(empty($dom_codigopostal)){$dom_codigopostal=0;}
					if(empty($dom_codigopostal)){$dom_codigopostal=0; $cadcodpost_r="";}else{$cadcodpost_r=" CODIGO POSTAL $dom_codigopostal";}
					
					$impresion.="<td width='50%' id='tdt2' valign='top'>
								  <table width='100%' border='1'><tr><th colspan='2' class='h1'>Receptor</th></tr>
									 <tr><th>RFC</th><td>$rfc_receptor</td></tr>
									 <tr><th>Nombre</th><td>$nombre_receptor</td></tr>
									 <tr><th colspan='2' class='h2'>Domicilio</th></tr>
									 <tr><td colspan='2'>$dom_calle # $dom_noExterior - $dom_noInterior</td></tr>
									 <tr><td colspan='2'>$dom_colonia</td></tr>
									 <tr><td colspan='2'>$dom_localidad</td></tr>
									 <tr><td colspan='2'>$dom_referencia</td></tr>
									 <tr><td colspan='2'>$dom_municipio $cadcodpost_r</td></tr>
									 <tr><td colspan='2'>$dom_estado</td></tr>
									 <tr><td colspan='2'>$dom_pais</td></tr>
								   </table>
							   </td>
							 </tr>";
							 
					$impresion2.="<td width='50%' id='tdt'>
								   <table width='100%' border='0' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h1'>Receptor</th></tr>
									 <tr><th>RFC</th><td>$rfc_receptor</td></tr>
									 <tr><th>Nombre</th><td>$nombre_receptor</td></tr>
									 <tr><th colspan='2' class='h2'>Domicilio</th></tr>
									 <tr><td colspan='2'>$dom_calle # $dom_noExterior - $dom_noInterior</td></tr>
									 <tr><td colspan='2'>$dom_colonia</td></tr>
									 <tr><td colspan='2'>$dom_localidad</td></tr>
									 <tr><td colspan='2'>$dom_referencia</td></tr>
									 <tr><td colspan='2'>$dom_municipio $cadcodpost_r</td></tr>
									 <tr><td colspan='2'>$dom_estado</td></tr>
									 <tr><td colspan='2'>$dom_pais</td></tr>
									</table>
								   </td>
								  </tr>";		 
					
		//-->>		//foreach($parametro_ExpedidoEn as $params){
					if($parametro_ExpedidoEn->length>=1)
					{	
						$expedidoen_calle = $parametro_ExpedidoEn->item(0) -> getAttribute('calle');
						if(!empty($expedidoen_calle))
						   {
							 $cadenaoriginal.="|".$expedidoen_calle;
						   }
						$expedidoen_noExterior = trim($parametro_ExpedidoEn->item(0) -> getAttribute('noExterior'));
						if($expedidoen_noExterior!="")
						   {
							 $cadenaoriginal.="|".$expedidoen_noExterior;
						   }
						$expedidoen_noInterior = trim($parametro_ExpedidoEn->item(0) -> getAttribute('noInterior'));
						if($expedidoen_noInterior!="")
						   {
							 $cadenaoriginal.="|".$expedidoen_noInterior;
						   }
						$expedidoen_colonia = $parametro_ExpedidoEn->item(0) -> getAttribute('colonia');
						if(!empty($expedidoen_colonia))
						   {
							 $cadenaoriginal.="|".$expedidoen_colonia;
						   }
						$expedidoen_localidad = $parametro_ExpedidoEn->item(0) -> getAttribute('localidad');
						if(!empty($expedidoen_localidad))
						   {
							 $cadenaoriginal.="|".$expedidoen_localidad;
						   }
						$expedidoen_referencia = $parametro_ExpedidoEn->item(0) -> getAttribute('referencia');
						if(!empty($expedidoen_referencia))
						   {
							 $cadenaoriginal.="|".$expedidoen_referencia;
						   }
						$expedidoen_municipio = $parametro_ExpedidoEn->item(0) -> getAttribute('municipio');
						if(!empty($expedidoen_municipio))
						   {
							 $cadenaoriginal.="|".$expedidoen_municipio;
						   }
						$expedidoen_estado = $parametro_ExpedidoEn->item(0) -> getAttribute('estado');
						if(!empty($expedidoen_estado))
						   {
							 $cadenaoriginal.="|".$expedidoen_estado;
						   }
						$expedidoen_pais = $parametro_ExpedidoEn->item(0) -> getAttribute('pais');
						$cadenaoriginal.="|".$expedidoen_pais;
						
						$expedidoen_codigopostal = ($parametro_ExpedidoEn->item(0) -> getAttribute('codigoPostal'));
						if(!empty($expedidoen_codigopostal))
						   {
							 $cadenaoriginal.="|".$expedidoen_codigopostal;
						   }
					}
					//}
							  ///////////////////////////////////////////////
					//////////	Direcci�n de expedici�n, agego nuevo gabriel/////////////////
							 /////////////////////////////////////////////// se cambio la posicion este con el emisor
							
					if(empty($expedidoen_noExterior)){$expedidoen_noExterior=0;}
					if(empty($expedidoen_codigopostal)){$expedidoen_codigopostal=0; $expedidoen_codigopostal="";}else{$expedidoen_codigopostal=" CODIGO POSTAL $expedidoen_codigopostal";}
					
					
							 
					$impresion.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='1' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h2'>Domicilio Expedici&oacute;n</th></tr>
									 <tr><td colspan='2'>$expedidoen_calle # $expedidoen_noExterior - $expedidoen_noInterior</td></tr>
									 <tr><td colspan='2'>$expedidoen_colonia</td></tr>
									 <tr><td colspan='2'>$expedidoen_localidad</td></tr>
									 <tr><td colspan='2'>$expedidoen_referencia</td></tr>
									 <tr><td colspan='2'>$expedidoen_municipio $expedidoen_codigopostal</td></tr>
									 <tr><td colspan='2'>$expedidoen_estado</td></tr>
									 <tr><td colspan='2'>$expedidoen_pais</td></tr>
									</table>
								   </td>";
							  

					$impresion2.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='1' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h2'>Domicilio Expedici&oacute;n</th></tr>
									 <tr><td colspan='2'>$expedidoen_calle # $expedidoen_noExterior - $expedidoen_noInterior</td></tr>
									 <tr><td colspan='2'>$expedidoen_colonia</td></tr>
									 <tr><td colspan='2'>$expedidoen_localidad</td></tr>
									 <tr><td colspan='2'>$expedidoen_referencia</td></tr>
									 <tr><td colspan='2'>$expedidoen_municipio $expedidoen_codigopostal</td></tr>
									 <tr><td colspan='2'>$expedidoen_estado</td></tr>
									 <tr><td colspan='2'>$expedidoen_pais</td></tr>
									 </table>
									</td>";
									
					$impresion.="<tr><td>&nbsp;</td></tr><tr>
									 <td colspan='2'>
										<table width='100%' border='1' align='center'>
										  <tr>
											 <th>Cantidad</th>
											 <th>Unidad</th>
											 <th>Descripci&oacute;n</th>		 
											 <th>Precio</th>
											 <th>Importe</th>
										 </tr>";
					
					$impresion2.="<tr>
									  <td colspan='2'>
										<table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
										  <tr>
											<th>Cantidad</th><th>Unidad</th>
											<th>Descripci&oacute;n</th>
											<th>Precio</th>
											<th>Importe</th>
										  </tr>";
					
					$cont=0;
				
					foreach ($paramconcepto as $paramscon) {
						  $cantidad[$cont] =trim($paramscon -> getAttribute('cantidad')) ;
						  $cadenaoriginal.="|".($paramscon -> getAttribute('cantidad'));
						   if($paramscon -> hasAttribute('unidad'))
					
							  {
								$unidaddemedida[$cont]=$paramscon -> getAttribute('unidad');
								if(!empty($unidaddemedida[$cont]))
									{$cadenaoriginal.="|".$unidaddemedida[$cont];}
					
							  }
							  if($paramscon -> hasAttribute('noIdentificacion'))
							  {
								$noIdentificacion=$paramscon -> getAttribute('noIdentificacion');
								if(!empty($noIdentificacion))
									{$cadenaoriginal.="|".$noIdentificacion;}
					
							  }
						   $descripcion[$cont] = $paramscon -> getAttribute('descripcion');

						   $cadenaoriginal.="|".($paramscon -> getAttribute('descripcion'));
						  
						   $ValorUnitario[$cont] =trim($paramscon -> getAttribute('valorUnitario'));
						   $cadenaoriginal.="|".($paramscon -> getAttribute('valorUnitario'));
						   
						   $importe[$cont] =trim($paramscon -> getAttribute('importe'));
						   $cadenaoriginal.="|".($paramscon -> getAttribute('importe'));
							
							//print_r($paramscon);
							// $parametro_info_aduanera = $paramscon->item($cont)->getElementsByTagName('InformacionAduanera');		
							 $parametro_info_aduanera = $paramscon->getElementsByTagName('InformacionAduanera');		 
							 if($parametro_info_aduanera->length > 0)
								  {
									 if($parametro_info_aduanera->item(0)->hasAttribute('numero'))
										 {
										   $no_aduana[$cont] =($parametro_info_aduanera ->item(0)-> getAttribute('numero'));
											$cadenaoriginal.="|".($parametro_info_aduanera ->item(0)-> getAttribute('numero'));
										 }
									 else{
											$no_aduana[$cont] ="";
								
										 }
									
									 if($parametro_info_aduanera->item(0)->hasAttribute('fecha'))
										 {
										   $ad_fecha[$cont] =($parametro_info_aduanera ->item(0)-> getAttribute('fecha'));
										   $cadenaoriginal.="|".($parametro_info_aduanera ->item(0)-> getAttribute('fecha'));
										  // echo "fecha:".$ad_fecha[$cont]."<br>";
										 }
									 else{
											$ad_fecha[$cont] ="1900-01-01";
								
										 }
									 
									 if($parametro_info_aduanera->item(0)->hasAttribute('aduana'))
										 {
										   $aduana[$cont] =substr(($parametro_info_aduanera->item(0) -> getAttribute('aduana')),0,49);
										   $cadenaoriginal.="|".($parametro_info_aduanera ->item(0)-> getAttribute('aduana'));
										 }
									 else{
											$aduana[$cont] ="";
								
										 }
						   
								  }
							 else{
									$no_aduana[$cont] ="";
									$ad_fecha[$cont] ="1900-01-01";
									$aduana[$cont] ="";
								 }
							  
							  
							$parametro_cta_predial = $paramscon->getElementsByTagName('CuentaPredial');		 
							 if($parametro_cta_predial->length > 0)
								  {
									 if($parametro_cta_predial->item(0)->hasAttribute('numero'))
										 {
											$cadenaoriginal.="|".($parametro_cta_predial ->item(0)-> getAttribute('numero'));
										 }
								   }
							$impresion.="<tr>
											 <td align='center'>".$cantidad[$cont]."</td>
											 <td align='center'>".$unidaddemedida[$cont]."</td>				  
											 <td>".$descripcion[$cont]."</td>
											 <td align='right'>".number_format($ValorUnitario[$cont],2,'.',',')."</td>
											 <td align='right'>".number_format($importe[$cont],2,'.',',')."</td>
									 </tr>";
									 
							$impresion2.="<tr>
											  <td align='center'>".$cantidad[$cont]."</td>
											  <td align='center'>".$unidaddemedida[$cont]."</td>
											  <td>".$descripcion[$cont]."</td>
											  <td align='right'>".number_format($ValorUnitario[$cont],2,'.',',')."</td>
											  <td align='right'>".number_format($importe[$cont],2,'.',',')."</td>
										  </tr>";
							
								$import_tot+=$importe[$cont];  	
					  $cont++;
						
					}
					
					
					
					
					$cont_ret=0;
					$retencion_t=0;
					foreach($parametro_retenciones as $params){
					$desc_retencion[$cont_ret] = ($params -> getAttribute('impuesto'));
					$retencion[$cont_ret] =trim($params -> getAttribute('importe'));
					
					$cadenaoriginal.="|".($params -> getAttribute('impuesto'));
					$cadenaoriginal.="|".($params -> getAttribute('importe'));
					
					$retencion_t+=$retencion[$cont_ret];
					if($desc_retencion[$cont_ret]=='IVA')
					   {
						$tipo_r[$cont_ret]=5;
					   }
					elseif($desc_retencion[$cont_ret]=='ISR')
					  {
						$tipo_r[$cont_ret]=6; 
					  }
					   $cont_ret+=1;
					}
					/*if(!empty($retencion_t))
					   {
						 $cadenaoriginal.="|".($retencion_t/100);
					   }*/ 
					
					//if(empty($retencion)){$retencion=0;}
					
					$cont_tras=0;
					$traslado_t=0;
					foreach($parametro_traslados as $params){
					$desc_traslado[$cont_tras] = ($params -> getAttribute('impuesto'));
					$traslado[$cont_tras] = trim($params -> getAttribute('importe'));
					$traslado_t+=$traslado[$cont_tras];
					
					$cadenaoriginal.="|".($params -> getAttribute('impuesto'));
					$cadenaoriginal.="|".($params -> getAttribute('tasa'));
					$cadenaoriginal.="|".($params -> getAttribute('importe'));
					
					if($desc_traslado[$cont_tras]=='IVA')
					   {
						$tipo_t[$cont_tras]=1;
					   }
					elseif($desc_traslado[$cont_tras]=='IEPS')
					  {
						$tipo_t[$cont_tras]=2; 
					  }
					$cont_tras+=1;
					}
					/*if(!empty($traslado_t))
					   {
					
					   $cadenaoriginal.="|".($traslado_t/100);
					   }*/
					   $cadenaoriginal.="||";  
					$iva_r=$retencion_t;
					$iva_t=$traslado_t;
					//if(empty($traslado)){$traslado=0;}
					
					foreach($parametro_estatus as $params){
					$tienda =($params -> getAttribute('tienda'));
					$factura =($params -> getAttribute('factura'));
					$status =($params -> getAttribute('estatus'));
					$sello_status =($params -> getAttribute('selloestatus'));
					
					}   
					
					/*if($total!=0)
						{$importe_total=$total;}
					else{$importe_total=($import_tot+$iva_t);}*/
					
					
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Subtotal</td>		
									 <td align='right'>".number_format($subt,2,'.',',')."</td>
								 </tr>
								 <tr><td colspan='3'></td>
									 <td align='right'>- Descuento</td>
									<td align='right'>".number_format($descuento,2,'.',',')."</td>
								 </tr>
					
								  <tr><td colspan='3'></td>
									 <td align='right'>Subtotal</td>
									 <td align='right'>".number_format(($subt - $descuento),2,'.',',')."</td>
								 </tr>";
					
					if($bandretcedular==1)
					{			 
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>- Imp. Local Retenido($tasaretencioncedular %)</td>
									 <td align='right'>".number_format($importeretencioncedular,2,'.',',')."</td>
								 </tr>";
								 
					$impresion2.="<tr><td colspan='3'></td>
									 <td align='right'>- Imp. Local Retenido($tasaretencioncedular %)</td>
									 <td align='right'>".number_format($importeretencioncedular,2,'.',',')."</td>
								 </tr>";			 
					}	
								 
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Iva</td>
									 <td align='right'>".number_format($iva_t,2,'.',',')."</td>
								 </tr>";
					if($bandtrasloc==1)
					{
						
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Imp. local Trasladado($tasatrasladoloc %)</td>
									 <td align='right'>".number_format($importetrasladoloc,2,'.',',')."</td>
								 </tr>";	
					}
					$impresion2.="<tr>
									 <td colspan='3'></td>
									 <td align='right'>Subtotal   </td>
									 <td align='right'>".number_format($subt,2,'.',',')."</td>
								  </tr>
								  <tr>
									  <td colspan='3'></td>
									  <td align='right'>- Descuento</td>
									  <td></td>
								 </tr>			 
								 <tr>
									<td colspan='3'></td>
									<td align='right'>Subtotal</td>
									<td align='right'>".number_format(($subt - $descuento),2,'.',',')."</td>
								 </tr>
								 <tr>
								 <td colspan='3'></td>
								 <td align='right'>Iva</td>
								 <td align='right'>".number_format($iva_t,2,'.',',')."</td>
								</tr>";
					if($iva_r>0)
						   {
							  $impresion.="<tr>
											<td colspan='3'></td>
											<td align='right'>Retencion Iva</td>
											<td align='right'>".number_format($iva_r,2,'.',',')."</td>
										  </tr>";
							 
							 $impresion2.="<tr>
											 <td colspan='3'></td>
											 <td align='right'>- Retencion Iva</td>
											 <td align='right'>".number_format($iva_r,2,'.',',')."</td>
										  </tr>";
					
							}
					
						
						 $impresion.="<tr>
									   <td colspan='3'></td>
									   <td align='right'>Total</td>		
									   <td align='right'>".number_format($importe_total,2,'.',',')."</td>
									 </tr>
								</table>
								</td>
							 </tr> ";
						
						 $impresion2.="<tr>
										 <td colspan='3'></td>
										 <td align='right'>Total</td>
										 <td align='right'>".number_format($importe_total,2,'.',',')."</td>
										</tr>
									</table>
								  </td>
								</tr>";
					
								 
								 /** Impresion Importe en letras**/
					$V=new EnLetras();
					$impresion.="<tr>
								  <td colspan='2'>
								   <table width='100%' border='1' align='center'>
									<tr>
									  <td align='center'>". $V->ValorEnLetras($importe_total,"Pesos") ."</td>
									</tr>
								   </table>
								  </td>
								 </tr>";
								 
					$impresion2.="<tr>
								   <td colspan='2'>
									 <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
									   <tr>
										 <td align='center'>". $V->ValorEnLetras($importe_total,"Pesos") ."</td>
									   </tr>
									 </table>
								   </td>
								  </tr>";
					
					/******/
					if($version < "3.0")
					 {
						if($cadenaoriginal2!=""){$cadenaoriginal=$cadenaoriginal2;}		 
					$impresion.="<tr>
								   <td colspan='2'><hr/></td>
								 </tr>
								 <tr>
								   <td colspan='2'>
									<table width='100%' border='1' align='center'>
										<tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".$metodoDePago."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
										<tr><th>Numero de serie del Certificado</th></tr>
										<tr><td>$noCertificado</td></tr>
										<tr><th>Cadena Original</th></tr>
										<tr><td> <small><small>".$cadenaoriginal."</small></small></td></tr>
										<tr><th>Sello Digital</th></tr>
										<tr><td colspan='2' rowspan='2' id='sello'><small><small><small>$sello</small></small></small></td></tr>
									</table>
								   </td>
								</tr>
							</table>
							<center>
							Este documento es una representaci&oacute;n impresa de un CFDI
							</center>";
					
					$impresion2.="<tr>
								   <td colspan='2'></td>
								  </tr>
								  <tr>
									<td colspan='2'>
										<table width='100%' border='0' align='center' cellspacing='0' cellpadding='0'>
										   <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".$metodoDePago."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
										   <tr><th>Numero de serie del Certificado</th></tr>
										   <tr><td>$noCertificado</td></tr>
										   <tr><th>Cadena Original</th></tr>
										   <tr><td> <small><small>".$cadenaoriginal."</small></small></td></tr>
										   <tr><th>Sello Digital</th></tr>
										   <tr><td colspan='2' rowspan='2' id='sello'><small><small><small>$sello</small></small></small></td></tr>
										 </table>
									</td>
								 </tr>
							</table>
							<center> 
								   Este documento es una representaci&oacute;n impresa de un CFDI
							</center>";
					
					 }
					 else{
					//	 echo ."<br>".."<br>".."<br>//".$selloSAT."<br>//".$selloCFD;	
					$cadenaorg_tmbre="||".trim($versiontimbre)."|".trim($foliofiscal)."|".trim($FechaTimbrado)."|".trim($selloCFD)."|".trim($noCertificadoSAT)."||";	      
						   $impresion.="
									  <tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".$metodoDePago."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='5'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$nVersion</td><td><b>FOLIO FISCAL:</b></td><td>$foliofiscal</td></tr>
												   <tr> <td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td colspan='4' width='90%'><b>Sello Digital CFDI:</b> <small><small><small>$selloCFD</small></small></small></td></tr>
												   <tr><td colspan='4' width='90%'><b>Sello del SAT:</b> <small><small><small>$selloSAT</small></small></small></td></tr>	
																		
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small><small><small>$cadenaorg_tmbre</small></small></small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>	
						   ";
						   
					  $impresion2.="<tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".$metodoDePago."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='5'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$nVersion</td><td><b>UUID:</b></td><td>$foliofiscal</td></tr>
												   <tr> <td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td colspan='4'><b>Sello Digital CFDI:</b><small>$selloCFD</small></td></tr>
												   <tr><td colspan='4'><b>Sello del SAT:</b> <small>$selloSAT</small></td></tr>	
																		
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small>$cadenaorg_tmbre</small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>	
						   ";	   
						 }
					/////////////////////////////////////////////////////////////////////////////////
					$json->factura = $impresion;
				}
				else //Factura 3.3
				{
					$paramconcepto = $dom->getElementsByTagName('Concepto');
					//$parametrocomprobante = $dom->getElementsByTagName('Comprobante');
					//$parametroemisor = $dom->getElementsByTagName('Emisor');
					$parametro_emisor_dom_fisc = $dom->getElementsByTagName('DomicilioFiscal');
					$parametro_ExpedidoEn = $dom->getElementsByTagName('ExpedidoEn');
					$parametro_RegimenFiscal = $dom->getElementsByTagName('RegimenFiscal');
					$parametroreceptor = $dom->getElementsByTagName('Receptor');
					$parametro_receptor_dom = $dom->getElementsByTagName('Domicilio');
					
					//$parametro_retenciones2 = $dom->getElementsByTagName('Retenciones'); //Se agrego
					//$parametro_retenciones = $dom->getElementsByTagName('Retencion');
					
					$parametro_traslados2 = $dom->getElementsByTagName('Traslados');
					$parametro_traslados = $dom->getElementsByTagName('Traslado');
					
					$parametro_estatus = $dom->getElementsByTagName('Estatus');
					$parametro_ElementosExtra = $dom->getElementsByTagName('ElementosExtra');
					//$parametro_ElementosExtra = $dom->getElementsByTagName('ElementosExtra');
					
					//Se comenta ElementosExtra para version 3.3
					
					if($parametro_ElementosExtra->length==1)
					   {
						 $cadenaoriginal2=$parametro_ElementosExtra->item(0)->getAttribute('cadenaOriginal');
					   }
					  
					$band_desc=0;
					
					foreach($parametrocomprobante as $params){
						$version = ($params->getAttribute('Version'));
						$cadenaoriginal.=$version;
						$serie="";
						if($params->hasAttribute('Serie'))
						   {
							 $serie = ($params->getAttribute('Serie'));  
							 if(!empty($serie))
								{$cadenaoriginal.="|".$serie;} 
						   }
					
						$folio = ($params->getAttribute('Folio'));
						$fecha = ($params->getAttribute('Fecha'));
						$sello = ($params->getAttribute('Sello'));
						$f_pago = ($params->getAttribute('FormaDePago')); 						// Cambiar a leer por cat�logo	////
						//$noAprobacion = ($params->getAttribute('noAprobacion'));
						//$anoAprobacion = ($params->getAttribute('anoAprobacion'));
						$tipoMoneda = ($params->getAttribute('Moneda'));
						$tipoDeComprobante = ($params->getAttribute('TipoDeComprobante')); 		// Cambiar a leer por cat�logo	////
						$formaDePago = ($params->getAttribute('FormaDePago'));					////
						$noCertificado = ($params->getAttribute('NoCertificado'));
						$certificado = ($params->getAttribute('Certificado'));
						$NumCtaPago = ($params->getAttribute('NumCtaPago'));
						//$metodoDePago = ($params->getAttribute('MetodoDePago'));				// Cambiar a leer por cat�logo
						$metodoDePago = ($params->getAttribute('MetodoPago'));				// Cambiar a leer por cat�logo						
						$FormaPago = ($params->getAttribute('FormaPago'));				// Cambiar a leer por cat�logo
						$nVersion = ($params->getAttribute('Version'));						
	
			
						$cadenaoriginal.="|".$folio."|".$fecha."|".$noAprobacion."|".$anoAprobacion."|".$tipoDeComprobante."|".$formaDePago;
						/*
						if($tipoMoneda == 'MXN'){
							$tipoMoneda = 'Peso Mexicano';
						}
						*/
						$conceptoArc = idConceptoSat(6);
						$concepto = 'idSAT'.$f_pago;
						$concepto = $conceptoArc->$concepto;
						$f_pago = $concepto;
						
						
						$conceptoArc = idConceptoSat(6);
						$concepto = 'idSAT'.$formaDePago;
						$concepto = $conceptoArc->$concepto;
						$formaDePago = $concepto;

						$conceptoArc = idConceptoSat(9);
						$concepto = 'idSAT'.$tipoDeComprobante;
						$concepto = $conceptoArc->$concepto;
						$tipoDeComprobante = $concepto;
						$tipoDeComprobante = $tipoDeComprobante;


						if($params->hasAttribute('CondicionesDePago'))
								  {
									$condicionesDePago=$params -> getAttribute('CondicionesDePago');
									if(!empty($condicionesDePago))
										{$cadenaoriginal.="|".$condicionesDePago;}
						
								  }
						
						  $subt = trim($params->getAttribute('SubTotal'));
						  $importe_total = trim($params->getAttribute('Total'));
						$cadenaoriginal.="|".$params->getAttribute('SubTotal');
						
						if($params->hasAttribute('Descuento'))
							{
							  $band_desc=1;
							  $descuento =trim($params->getAttribute('Descuento'));
							  $cadenaoriginal.="|".$params->getAttribute('Descuento');
							}
						$cadenaoriginal.="|".$params->getAttribute('Total');	
					}
					
					
					//if($params->hasAttribute('MetodoDePago'))
					if($params->hasAttribute('MetodoPago'))
					   {
						 //$metodoDePago = ($params->getAttribute('MetodoDePago'));  
						 $metodoDePago = ($params->getAttribute('MetodoPago'));  
						 if(!empty($metodoDePago))
							{$cadenaoriginal.="|".$metodoDePago;} 
					   }

						$conceptoArc = idConceptoSat(5);
						$concepto = 'idSAT'.$metodoDePago;
						$concepto = $conceptoArc->$concepto;
						$metodoDePago = $concepto;

					if($params->hasAttribute('FormaPago'))
					   {
						 $FormaPago = ($params->getAttribute('FormaPago'));  
						 if(!empty($FormaPago))
							{$cadenaoriginal.="|".$FormaPago;} 
					   }

						$conceptoArc = idConceptoSat(6);
						$concepto = 'idSAT'.$FormaPago;
						$concepto = $conceptoArc->$concepto;
						$FormaPago = $concepto;

					//echo(utf8_encode($metodoDePago).'*'.utf8_decode($metodoDePago).'*'.json_decode($metodoDePago).'*'.json_encode($metodoDePago));
					//echo($metodoDePago);
					//exit(0);
					
					if($params->hasAttribute('LugarExpedicion')){
						 $LugarExpedicion = ($params->getAttribute('LugarExpedicion'));  
						 if(!empty($LugarExpedicion))
							{$cadenaoriginal.="|".$LugarExpedicion;} 
					}				
					
					$parametroComprobante = $dom->getElementsByTagName('CfdiRelacionados');
					if($parametroComprobante->length >= 1){
						$e_CfdiRelacionado = $parametroComprobante->item(0)->getElementsByTagName('CfdiRelacionado');
						if($e_CfdiRelacionado->length == 1){
							if($e_CfdiRelacionado->item(0)->hasAttribute('UUID')){
								$UUIDRelacionadoNota = trim($e_CfdiRelacionado->item(0)->getAttribute('UUID'));
								$UUIDRelacionadoNota = strtoupper($UUIDRelacionadoNota);
							}
						}
					}
					
					$e_Complemento = $dom->getElementsByTagName('Complemento');
					if($e_Complemento->length >= 1){
						$e_TimbreFiscalDigital = $e_Complemento->item(0)->getElementsByTagName('TimbreFiscalDigital');
						if($e_TimbreFiscalDigital->length==1){
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('UUID')){
								$foliofiscal=trim($e_TimbreFiscalDigital->item(0)->getAttribute('UUID'));
								$foliofiscal=strtoupper($foliofiscal);										
							}
							
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('FechaTimbrado')){
								$FechaTimbrado=trim($e_TimbreFiscalDigital->item(0)->getAttribute('FechaTimbrado'));
							} 
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('NoCertificadoSAT')){
								$noCertificadoSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('NoCertificadoSAT'));
							}
										
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('SelloSAT')){
								$selloSAT=trim($e_TimbreFiscalDigital->item(0)->getAttribute('SelloSAT'));
							}
										
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('SelloCFD')){
								$selloCFD=trim($e_TimbreFiscalDigital->item(0)->getAttribute('SelloCFD'));
							} 
										
							if($e_TimbreFiscalDigital->item(0)->hasAttribute('Version')){
								$versiontimbre=trim($e_TimbreFiscalDigital->item(0)->getAttribute('Version'));
							}
						}
						//Se agregan lineas para cuando es un documento de PAGO RRG-->
						$e_Pago = $e_Complemento->item(0)->getElementsByTagName('Pago');
						if($e_Pago->length == 1){
							if($e_Pago->item(0)->hasAttribute('FechaPago')){
							   $fechaPago = TRIM($e_Pago->item(0)->getAttribute('FechaPago'));
							   // $fechaPago = strtoupper($fechaPago);
							}
							if($e_Pago->item(0)->hasAttribute('FormaDePagoP')){
								$forma_PagoP = TRIM($e_Pago->item(0)->getAttribute('FormaDePagoP'));
								$forma_PagoP = strtoupper($forma_PagoP);
								
								$conceptoArc = idConceptoSat(6);
								$concepto = 'idSAT'.$forma_PagoP;
								$concepto = $conceptoArc->$concepto;
								$forma_PagoP = $concepto;
							}
							if($e_Pago->item(0)->hasAttribute('MonedaP')){
								$MonedaP = TRIM($e_Pago->item(0)->getAttribute('MonedaP'));
								$MonedaP = strtoupper($MonedaP);
							}
							if($e_Pago->item(0)->hasAttribute('Monto')){
								$MontoPago = TRIM($e_Pago->item(0)->getAttribute('Monto'));
								$MontoPago = strtoupper($MontoPago);
							}
						}
						$e_DoctoRelacionado = $e_Complemento->item(0)->getElementsByTagName('DoctoRelacionado');
						if($e_DoctoRelacionado->length == 1){
							if($e_DoctoRelacionado->item(0)->hasAttribute('IdDocumento')){
								$folioRelacionado = TRIM($e_DoctoRelacionado->item(0)->getAttribute('IdDocumento'));
								$folioRelacionado = strtoupper($folioRelacionado);
							}
							if($e_DoctoRelacionado->item(0)->hasAttribute('MonedaDR')){
								$MonedaDR = TRIM($e_DoctoRelacionado->item(0)->getAttribute('MonedaDR'));
								$MonedaDR = strtoupper($MonedaDR);
							}
							if($e_DoctoRelacionado->item(0)->hasAttribute('MetodoDePagoDR')){
								$MetodoDePagoDR = TRIM($e_DoctoRelacionado->item(0)->getAttribute('MetodoDePagoDR'));
								$MetodoDePagoDR = strtoupper($MetodoDePagoDR);
								
								$conceptoArc = idConceptoSat(5);
								$concepto = 'idSAT'.$MetodoDePagoDR;
								$concepto = $conceptoArc->$concepto;
								$MetodoDePagoDR = $concepto;
							}
							// echo "<pre>";
							// print_r($MetodoDePagoDR);
							// echo "</pre>";
							// exit();
						}
						// $e_CfdiRelacionados = $
					}
					if($tipoDeComprobante == 'Pago'){
						$tipoMoneda = $MonedaDR;
						$metodoDePago = $MetodoDePagoDR;
						$importe_total = $MontoPago;
						$FormaPago = $forma_PagoP;
						
					}
					$impresion.="<table width='95%' border='0' align='center' cellpadding=\"0\" cellspacing=\"0\">
							   <tr>
								   <td></td>
								   <td  align='right'>
									<table border='1'>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Tipo Documento</th><td class='h1'>$tipoDeComprobante</td></tr>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Folio-Serie</th><td class='h1'>$folio-$serie</td></tr>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Fecha</th><td class='h1'>$fecha</td></tr>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Moneda</th><td class='h1'>$tipoMoneda</td></tr>
									";
									if($version >="3.0"){
										 $impresion.="<tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Serie del Cert. del CSD</td><td>".$noCertificado."</td></tr>";
										 $impresion.="<tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Version</td><td>".$nVersion."</td></tr>";
									}else{
										$impresion.="  
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Aprobaci&oacute;n</th><td class='h1'>$noAprobacion</td></tr>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>A&ntilde;o Aprobaci&oacute;n</th><td class='h1'>$anoAprobacion</td></tr>
										 ";
									}
										  
								$impresion.=" </table>
								   </td>
								 </tr><tr><td>&nbsp;</td></tr>";
					
					$impresion2.="<table width='95%' border='0' align='center'>
								   <tr>
									 <td></td>
									 <td  align='right'>
										<table border='1' cellspacing='0' cellpadding='0'>
										   <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Tipo Documento</th><td class='h1'>$tipoDeComprobante</td></tr>
										   <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Folio-Serie</th><td class='h1'>$folio-$serie</td></tr>
										   <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Fecha</th><td class='h1'>$fecha</td></tr>
										   <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Moneda</th><td class='h1'>$tipoMoneda</td></tr>";
										   
									if($version >="3.0")
									  {
										 $impresion2.="<tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Serie del Cert. del CSD</td><td>".$noCertificado."</td></tr>";
										 $impresion2.="<tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Version</td><td>".$nVersion."</td></tr>";
									  }else{
										$impresion2.="  
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>Aprobaci&oacute;n</th><td class='h1'>$noAprobacion</td></tr>
										 <tr><th class='h1' style='background-color:#307ECC; color:#FFFFFF'>A&ntilde;o Aprobaci&oacute;n</th><td class='h1'>$anoAprobacion</td></tr>
										 ";
										  }
										  
								$impresion2.=" </table>
								   </td>
								 </tr>";
								
					$parametroemisor = $dom->getElementsByTagName('Emisor');
					
						 if($parametroemisor->length > 0)
							 {
								$nombre_emisor =addslashes($parametroemisor->item(0)-> getAttribute('Nombre'));
								$rfc_emisor =substr(($parametroemisor->item(0) -> getAttribute('Rfc')),0,13);
							 }
					
					
					$cadenaoriginal.="|".$rfc_emisor."|".$nombre_emisor;
					
					$RegimenFiscal_Regimen = $parametroemisor->item(0)->getAttribute('RegimenFiscal');	// Cambiar a leer por cat�logo
					if(!empty($RegimenFiscal_Regimen))
					{
						$cadenaoriginal.="|".$RegimenFiscal_Regimen;
					}
					
					$conceptoArc = idConceptoSat(10);
					$concepto = 'idSAT'.$RegimenFiscal_Regimen;
					$concepto = $conceptoArc->$concepto;

					$RegimenFiscal_Regimen = $concepto;
					$RegimenFiscal_Regimen = $RegimenFiscal_Regimen;
					
					//foreach($parametro_RegimenFiscal as $params){
					
					//Se cambio a nodo emisor regimenfiscal. Descrito arriba
					
					/*$RegimenFiscal_Regimen = utf8_decode($parametro_RegimenFiscal->item(0) -> getAttribute('Regimen'));
					if(!empty($RegimenFiscal_Regimen))
					   {
						 $cadenaoriginal.="|".$RegimenFiscal_Regimen;
					   }*/
					//}
					
					//foreach($parametro_emisor_dom_fisc as $params){
					
					//Se comenta DomicilioFiscal para version 3.3
					
					/*if($parametro_emisor_dom_fisc->length>=1)
					{	
						$df_calle = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Calle'));
						$cadenaoriginal.="|".$df_calle;
						
						$df_noExterior = trim($parametro_emisor_dom_fisc->item(0) -> getAttribute('NoExterior'));
						if($df_noExterior!="")
						   {$cadenaoriginal.="|".$df_noExterior;}
						   
						$df_noInterior = trim($parametro_emisor_dom_fisc->item(0) -> getAttribute('NoInterior'));
						if($df_noInterior!="")
						   {$cadenaoriginal.="|".$df_noInterior;}
						   
						$df_colonia = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Colonia'));
						if(!empty($df_colonia))
						   {$cadenaoriginal.="|".$df_colonia;}
						   
						$df_localidad = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Localidad'));
						if(!empty($df_localidad))
						   {$cadenaoriginal.="|".$df_localidad;}
						   
						$df_referencia = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Referencia'));
						if(!empty($df_referencia))
						   {$cadenaoriginal.="|".$df_referencia;}
						   
						$df_municipio = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Municipio'));
						$cadenaoriginal.="|".$df_municipio;
						$df_estado = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Estado'));
						$cadenaoriginal.="|".$df_estado;
						$df_pais = utf8_decode($parametro_emisor_dom_fisc->item(0) -> getAttribute('Pais'));
						$cadenaoriginal.="|".$df_pais;
						$df_codigopostal = ($parametro_emisor_dom_fisc->item(0) -> getAttribute('CodigoPostal'));
						$cadenaoriginal.="|".$df_codigopostal;
					}*/
					
					//}
					//$cadenaoriginal.="|".$df_calle."|".$df_noExterior."|".$df_noInterior."|".$df_colonia."|".$df_localidad."|".$df_referencia."|".$df_municipio."|".$df_estado."|".$df_pais."|".$df_codigopostal;
					
					//Se comenta DomicilioFiscal para version 3.3
					
					/*if(empty($df_noExterior)){$df_noExterior=0;}
					if(empty($df_codigopostal)){$df_codigopostal=0; $cadcodpost_e="";}else{$cadcodpost_e=" CODIGO POSTAL $df_codigopostal";}*/
					
					/*
					$impresion.="<tr>
								   <td width='50%' id='tdt1' valign='top'>
									   <table width='100%' border='1'><tr><th colspan='2' class='h1'>Emisor</th></tr>
										 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
										 <tr><th>Nombre</th><td>$nombre_emisor</td></tr>
										  <tr><th>R&eacute;gimen Fiscal</th><td>$RegimenFiscal_Regimen</td></tr>
										 <tr><th colspan='2' class='h2'>Domiclio</th></tr>
										 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
										 <tr><td colspan='2'>$df_colonia</td></tr>
										 <tr><td colspan='2'>$df_localidad</td></tr>
										 <tr><td colspan='2'>$df_referencia</td></tr>
										 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
										 <tr><td colspan='2'>$df_estado</td></tr>
										 <tr><td colspan='2'>$df_pais</td></tr>
									   </table>
								   </td>";
							  
					$impresion2.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='0' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h1'>Emisor</th></tr>
									 <tr><th>RFC</th><td>$rfc_emisor</td></tr>
									 <tr><th>Nombre</th><td>$nombre_emisor<br><b>R&eacute;gimen Fiscal:</b>$RegimenFiscal_Regimen</td></tr>
									 <tr><th colspan='2' class='h2'>Domiclio</th></tr>
									 <tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
									 <tr><td colspan='2'>$df_colonia</td></tr>
									 <tr><td colspan='2'>$df_localidad</td></tr>
									 <tr><td colspan='2'>$df_referencia</td></tr>
									 <tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
									 <tr><td colspan='2'>$df_estado</td></tr>
									 <tr><td colspan='2'>$df_pais</td></tr>
									 </table>
									</td>";		
									*/
					
					$impresion.="<tr>
								   <td width='50%' id='tdt1' valign='top'>
									   <table width='100%' border='1'>
											<tr><th colspan='2' class='h1' style='background-color:#307ECC; color:#FFFFFF'>Emisor</th></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>RFC</th><td>$rfc_emisor</td></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>Nombre</th><td>$nombre_emisor</td></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>R&eacute;gimen Fiscal</th><td>$RegimenFiscal_Regimen</td></tr>
											<!-- SE COMENTA DOMICILIO FISCAL PARA FACTURAS 3.3   RRG-->
											<tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio Fiscal</th></tr>
											<tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
										</table>
								   </td>";
										 
					$impresion2.="<tr>
									<td width='50%' id='tdt' valign='top'>
										<table width='100%' border='1' cellspacing='0' cellpadding='0'>
											<tr><th colspan='2' class='h1' style='background-color:#307ECC; color:#FFFFFF'>Emisor</th></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>RFC</th><td>$rfc_emisor</td></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>Nombre</th><td>$nombre_emisor</td></tr>
											<tr><th style='background-color:#307ECC; color:#FFFFFF'>R&eacute;gimen Fiscal</th><td>$RegimenFiscal_Regimen</td></tr>
											<tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio Fiscal</th></tr>
											<tr><td colspan='2'>$df_calle # $df_noExterior - $df_noInterior</td></tr>
											<tr><td colspan='2'>$df_colonia</td></tr>
											<tr><td colspan='2'>$df_localidad</td></tr>
											<tr><td colspan='2'>$df_referencia</td></tr>
											<tr><td colspan='2'>$df_municipio $cadcodpost_e</td></tr>
											<tr><td colspan='2'>$df_estado</td></tr>
											<tr><td colspan='2'>$df_pais</td></tr>	
										</table>
									</td>";
					
					/*foreach($parametroreceptor as $params){
					
					$rfc_receptor =substr(($params -> getAttribute('rfc')),0,13);
					$cadenaoriginal.="|".$rfc_receptor;
					
					$nombre_receptor =utf8_decode($params -> getAttribute('nombre'));
					if(!empty($nombre_receptor))
					   {
						 $cadenaoriginal.="|".$nombre_receptor;
					   }
					}*/
					
					$parametroreceptor = $dom->getElementsByTagName('Receptor');
						 if($parametroemisor->length > 0)
							 {
								$rfc_receptor =substr(($parametroreceptor->item(0) -> getAttribute('Rfc')),0,13);
								$cadenaoriginal.="|".$rfc_receptor;
								
								$nombre_receptor =$parametroreceptor->item(0) -> getAttribute('Nombre');
								if(!empty($nombre_receptor))
								   {
									 $cadenaoriginal.="|".$nombre_receptor;
								   }
								$clv_Uso = $parametroreceptor->item(0) -> getAttribute('UsoCFDI');
							 }
					
					
					$codigo="0";
					
					//foreach($parametro_receptor_dom as $params){
					
					//Se comenta Domicilio para version 3.3
					 /*if($parametro_receptor_dom->length >= 1)
						{	
						
							  $dom_calle = ($parametro_receptor_dom->item(0) -> getAttribute('calle'));
							if(!empty($dom_calle))
							   {
								 $cadenaoriginal.="|".$dom_calle;
							   }
					
					
							$dom_noExterior = trim($parametro_receptor_dom->item(0) -> getAttribute('noExterior'));
							if($dom_noExterior!="")
							   {
								 $cadenaoriginal.="|".$dom_noExterior;
							   }
							
							$dom_noInterior = trim($parametro_receptor_dom->item(0) -> getAttribute('noInterior'));
							if($dom_noInterior!="")
							   {
								 $cadenaoriginal.="|".$dom_noInterior;
							   }
							
							$dom_colonia = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('colonia'));
							if(!empty($dom_colonia))
							   {
								 $cadenaoriginal.="|".$dom_colonia;
							   }
							$dom_localidad = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('localidad'));
							if(!empty($dom_localidad))
							   {
								 $cadenaoriginal.="|".$dom_localidad;
							   }
							$dom_referencia = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('referencia'));
							if(!empty($dom_referencia))
							   {
								 $cadenaoriginal.="|".$dom_referencia;
							   }
							$dom_municipio = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('municipio'));
							if(!empty($dom_municipio))
							   {
								 $cadenaoriginal.="|".$dom_municipio;
							   }
							$dom_estado = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('estado'));
							if(!empty($dom_estado))
							   {
								 $cadenaoriginal.="|".$dom_estado;
							   }
							$dom_pais = utf8_decode($parametro_receptor_dom->item(0) -> getAttribute('pais'));
							$cadenaoriginal.="|".$dom_pais;
							
							$dom_codigopostal = ($parametro_receptor_dom->item(0) -> getAttribute('codigoPostal'));
							if(!empty($dom_codigopostal))
							   {
								 $cadenaoriginal.="|".$dom_codigopostal;
							   }
						}*/
					//}
					
					
					//if(empty($dom_noExterior)){$dom_noExterior=0;}
					//if(empty($dom_codigopostal)){$dom_codigopostal=0;}
					
					//Se comenta Domicilio para version 3.3
					//if(empty($dom_codigopostal)){$dom_codigopostal=0; $cadcodpost_r="";}else{$cadcodpost_r=" CODIGO POSTAL $dom_codigopostal";}
					
					$impresion.="<td width='50%' id='tdt2' valign='top'>
								  <table width='100%' border='1'>
										<tr><th colspan='2' class='h1' style='background-color:#307ECC; color:#FFFFFF'>Receptor</th></tr>
										<tr><th style='background-color:#307ECC; color:#FFFFFF'>RFC</th><td>$rfc_receptor</td></tr>
										<tr><th style='background-color:#307ECC; color:#FFFFFF'>Nombre</th><td>$nombre_receptor</td></tr>
										<tr><th style='background-color:#307ECC; color:#FFFFFF'>Clave de Uso</th><td>$clv_Uso</td></tr>
										<tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio</th></tr>
										<tr><td colspan='2'>$dom_calle # $dom_noExterior - $dom_noInterior</td></tr>
								   </table>
							   </td>
							 </tr>";
							 
					$impresion2.="<td width='50%' id='tdt'>
								   <table width='100%' border='0' cellspacing='0' cellpadding='0'>
									 <tr><th colspan='2' class='h1' style='background-color:#307ECC; color:#FFFFFF'>Receptor</th></tr>
									 <tr><th style='background-color:#307ECC; color:#FFFFFF'>RFC</th><td>$rfc_receptor</td></tr>
									 <tr><th style='background-color:#307ECC; color:#FFFFFF'>Nombre</th><td>$nombre_receptor</td></tr>
									 <tr><th style='background-color:#307ECC; color:#FFFFFF'>Clave de Uso</th><td>$clv_Uso</td></tr>
									 <tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio</th></tr>
									 <tr><td colspan='2'>$dom_calle # $dom_noExterior - $dom_noInterior</td></tr>
									 <tr><td colspan='2'>$dom_colonia</td></tr>
									 <tr><td colspan='2'>$dom_localidad</td></tr>
									 <tr><td colspan='2'>$dom_referencia</td></tr>
									 <tr><td colspan='2'>$dom_municipio $cadcodpost_r</td></tr>
									 <tr><td colspan='2'>$dom_estado</td></tr>
									 <tr><td colspan='2'>$dom_pais</td></tr>
									</table>
								   </td>
								  </tr>";
					
		//-->>		//foreach($parametro_ExpedidoEn as $params){
					
					//Se comenta ExpedidoEn para version 3.3
					
					/*if($parametro_ExpedidoEn->length>=1)
					{	
						$expedidoen_calle = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('calle'));
						if(!empty($expedidoen_calle))
						   {
							 $cadenaoriginal.="|".$expedidoen_calle;
						   }
						$expedidoen_noExterior = trim($parametro_ExpedidoEn->item(0) -> getAttribute('noExterior'));
						if($expedidoen_noExterior!="")
						   {
							 $cadenaoriginal.="|".$expedidoen_noExterior;
						   }
						$expedidoen_noInterior = trim($parametro_ExpedidoEn->item(0) -> getAttribute('noInterior'));
						if($expedidoen_noInterior!="")
						   {
							 $cadenaoriginal.="|".$expedidoen_noInterior;
						   }
						$expedidoen_colonia = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('colonia'));
						if(!empty($expedidoen_colonia))
						   {
							 $cadenaoriginal.="|".$expedidoen_colonia;
						   }
						$expedidoen_localidad = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('localidad'));
						if(!empty($expedidoen_localidad))
						   {
							 $cadenaoriginal.="|".$expedidoen_localidad;
						   }
						$expedidoen_referencia = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('referencia'));
						if(!empty($expedidoen_referencia))
						   {
							 $cadenaoriginal.="|".$expedidoen_referencia;
						   }
						$expedidoen_municipio = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('municipio'));
						if(!empty($expedidoen_municipio))
						   {
							 $cadenaoriginal.="|".$expedidoen_municipio;
						   }
						$expedidoen_estado = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('estado'));
						if(!empty($expedidoen_estado))
						   {
							 $cadenaoriginal.="|".$expedidoen_estado;
						   }
						$expedidoen_pais = utf8_decode($parametro_ExpedidoEn->item(0) -> getAttribute('pais'));
						$cadenaoriginal.="|".$expedidoen_pais;
						
						$expedidoen_codigopostal = ($parametro_ExpedidoEn->item(0) -> getAttribute('codigoPostal'));
						if(!empty($expedidoen_codigopostal))
						   {
							 $cadenaoriginal.="|".$expedidoen_codigopostal;
						   }
					}*/
					//}
							  ///////////////////////////////////////////////
					//////////	Direcci�n de expedici�n, agego nuevo gabriel/////////////////
							 /////////////////////////////////////////////// se cambio la posicion este con el emisor
					
					//Se comenta ExpedidoEn para version 3.3
					/*if(empty($expedidoen_noExterior)){$expedidoen_noExterior=0;}
					if(empty($expedidoen_codigopostal)){$expedidoen_codigopostal=0; $expedidoen_codigopostal="";}else{$expedidoen_codigopostal=" CODIGO POSTAL $expedidoen_codigopostal";}*/
					
								 
					$impresion.="<tr>
									<td width='50%' id='tdt'>
									 <table width='100%' border='1' cellspacing='0' cellpadding='0'>
									 <!-- SE COMENTA LUGAR EXPEDICION RRG-->
									 <tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio Expedici&oacute;n</th></tr>
									 <tr><td colspan='2'># $LugarExpedicion</td></tr>
									</table>
								   </td>";
							  

					$impresion2.="<tr>
									<td width='50%' id='tdt'>
									    <table width='100%' border='1' cellspacing='0' cellpadding='0'>
									        <!-- SE COMENTA LUGAR EXPEDICION RRG-->
									        <tr><th colspan='2' class='h2' style='background-color:#307ECC; color:#FFFFFF'>Domicilio Expedici&oacute;n</th></tr>
									        <tr><td colspan='2'># $LugarExpedicion</td></tr>
									    </table>
									</td>";
					
					$impresion.="<tr><td>&nbsp;</td></tr><tr>
									 <td colspan='2'>
										<table width='100%' border='1' align='center'>
										  <tr>
											 <th style='background-color:#307ECC; color:#FFFFFF'>Cantidad</th>
											 <th style='background-color:#307ECC; color:#FFFFFF'>Unidad</th>
											 <th style='background-color:#307ECC; color:#FFFFFF'>Descripci&oacute;n</th>		 
											 <th style='background-color:#307ECC; color:#FFFFFF'>Precio</th>
											 <th style='background-color:#307ECC; color:#FFFFFF'>Importe</th>
										 </tr>";
					
					$impresion2.="<tr>
									  <td colspan='2'>
										<table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
										  <tr>
											<th style='background-color:#307ECC; color:#FFFFFF'>Cantidad</th>
											<th style='background-color:#307ECC; color:#FFFFFF'>Unidad</th>
											<th style='background-color:#307ECC; color:#FFFFFF'>Descripci&oacute;n</th>
											<th style='background-color:#307ECC; color:#FFFFFF'>Precio</th>
											<th style='background-color:#307ECC; color:#FFFFFF'>Importe</th>
										  </tr>";
					
					$cont=0;
					
					
					foreach ($paramconcepto as $paramscon) 
					{
						
						  $cantidad[$cont] =trim($paramscon -> getAttribute('Cantidad')) ;
						  $cadenaoriginal.="|".($paramscon -> getAttribute('Cantidad'));
						   if($paramscon->hasAttribute('Unidad')){
								$unidaddemedida[$cont]=$paramscon->getAttribute('Unidad');
								if(!empty($unidaddemedida[$cont]))
									{$cadenaoriginal.="|".$unidaddemedida[$cont];}
					
							}
							if($paramscon -> hasAttribute('NoIdentificacion')){
							$noIdentificacion=$paramscon -> getAttribute('NoIdentificacion');
							if(!empty($noIdentificacion))
								{$cadenaoriginal.="|".$noIdentificacion;}
				
							}
						   $descripcion[$cont] =$paramscon -> getAttribute('Descripcion');
						   $cadenaoriginal.="|".($paramscon -> getAttribute('Descripcion'));

						   if($paramscon->hasAttribute('ValorUnitario')){
						   		$ValorUnitario[$cont] = trim($paramscon->getAttribute('ValorUnitario'));
								$cadenaoriginal.="|".($paramscon -> getAttribute('ValorUnitario'));
						   }
						   
						   if($paramscon->hasAttribute('Importe')){
								$importe[$cont] =trim($paramscon->getAttribute('Importe'));
								$cadenaoriginal.="|".($paramscon->getAttribute('Importe'));
							}
						
							$impresion.="<tr>
											 <td align='center'>".$cantidad[$cont]."</td>
											 <td align='center'>".$unidaddemedida[$cont]."</td>				  
											 <td>".$descripcion[$cont]."</td>
											 <td align='right'>".number_format($ValorUnitario[$cont],2,'.',',')."</td>
											 <td align='right'>".number_format($importe[$cont],2,'.',',')."</td>
									 </tr>";
							
							$impresion2.="<tr>
											  <td align='center'>".$cantidad[$cont]."</td>
											  <td align='center'>".$unidaddemedida[$cont]."</td>
											  <td>".$descripcion[$cont]."</td>
											  <td align='right'>".number_format($ValorUnitario[$cont],2,'.',',')."</td>
											  <td align='right'>".number_format($importe[$cont],2,'.',',')."</td>
										  </tr>";
							
								$import_tot+=$importe[$cont];  	
					  $cont++;
						
					}
		///////////////////////////////////Impuestos Retenciones///////////////////////////////////new		
										
					$Impuestos = $dom->getElementsByTagName('Impuestos');
					foreach($Impuestos as $impuesto){
						if ($impuesto->hasAttribute('TotalImpuestosRetenidos') || $impuesto->hasAttribute('TotalImpuestosTrasladados')) {
							$domImpuestos = $impuesto;
							$TotalImpuestosRetenidos = $impuesto->hasAttribute('TotalImpuestosRetenidos') ? $domImpuestos->getAttribute('TotalImpuestosRetenidos') : 0.0;
							$TotalImpuestosiva = $impuesto->hasAttribute('TotalImpuestosTrasladados') ? $domImpuestos->getAttribute('TotalImpuestosTrasladados') : 0.0;
						}
					}
					
					$retencion_t = $TotalImpuestosRetenidos;				
					
					$traslado_t=$TotalImpuestosiva;
					
					$cadenaoriginal.="||";  
					$iva_r=$retencion_t;
					$iva_t=$traslado_t;
								
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Subtotal</td>		
									 <td align='right'>".number_format($subt,2,'.',',')."</td>
								 </tr>
								 <tr><td colspan='3'></td>
									 <td align='right'>- Descuento</td>
									<td align='right'>".number_format($descuento,2,'.',',')."</td>
								 </tr>
					
								  <tr><td colspan='3'></td>
									 <td align='right'>Subtotal</td>
									 <td align='right'>".number_format(($subt - $descuento),2,'.',',')."</td>
								 </tr>";
					
					if($bandretcedular==1)
					{			 
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>- Imp. Local Retenido($tasaretencioncedular %)</td>
									 <td align='right'>".number_format($importeretencioncedular,2,'.',',')."</td>
								 </tr>";
								 
					$impresion2.="<tr><td colspan='3'></td>
									 <td align='right'>- Imp. Local Retenido($tasaretencioncedular %)</td>
									 <td align='right'>".number_format($importeretencioncedular,2,'.',',')."</td>
								 </tr>";			 
					}	
						 
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Iva</td>
									 <td align='right'>".number_format($iva_t,2,'.',',')."</td>
								 </tr>";
					if($bandtrasloc==1)
					{
						
					$impresion.="<tr><td colspan='3'></td>
									 <td align='right'>Imp. local Trasladado($tasatrasladoloc %)</td>
									 <td align='right'>".number_format($importetrasladoloc,2,'.',',')."</td>
								 </tr>";	
					}
					$impresion2.="<tr>
									 <td colspan='3'></td>
									 <td align='right'>Subtotal   </td>
									 <td align='right'>".number_format($subt,2,'.',',')."</td>
								  </tr>
								  <tr>
									  <td colspan='3'></td>
									  <td align='right'>- Descuento</td>
									  <td></td>
								 </tr>			 
								 <tr>
									<td colspan='3'></td>
									<td align='right'>Subtotal</td>
									<td align='right'>".number_format(($subt - $descuento),2,'.',',')."</td>
								 </tr>
								 <tr>
								 <td colspan='3'></td>
								 <td align='right'>Iva</td>
								 <td align='right'>".number_format($iva_t,2,'.',',')."</td>
								</tr>";
					
					if($iva_r>0)
						   {
							  $impresion.="<tr>
											<td colspan='3'></td>
											<td align='right'>Retencion Iva</td>
											<td align='right'>".number_format($iva_r,2,'.',',')."</td>
										  </tr>";
							 
							 $impresion2.="<tr>
											 <td colspan='3'></td>
											 <td align='right'>- Retencion Iva</td>
											 <td align='right'>".number_format($iva_r,2,'.',',')."</td>
										  </tr>";
					
							}
					
						
						 $impresion.="<tr>
									   <td colspan='3'></td>
									   <td align='right'>Total</td>		
									   <td align='right'>".number_format($importe_total,2,'.',',')."</td>
									 </tr>
								</table>
								</td>
							 </tr> ";
						
						 $impresion2.="<tr>
										 <td colspan='3'></td>
										 <td align='right'>Total</td>
										 <td align='right'>".number_format($importe_total,2,'.',',')."</td>
										</tr>
									</table>
								  </td>
								</tr>";
					
					 
								 /** Impresion Importe en letras**/
					$V=new EnLetras();
					$impresion.="<tr>
								  <td colspan='2'>
								   <table width='100%' border='1' align='center'>
									<tr>
									  <td align='center'>". $V->ValorEnLetras($importe_total,"Pesos") ."</td>
									</tr>
								   </table>
								  </td>
								 </tr>";
								 
					$impresion2.="<tr>
								   <td colspan='2'>
									 <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
									   <tr>
										 <td align='center'>". $V->ValorEnLetras($importe_total,"Pesos") ."</td>
									   </tr>
									 </table>
								   </td>
								  </tr>";
					
					if($version <= "3.0")
					{
						
						if($cadenaoriginal2!=""){$cadenaoriginal=$cadenaoriginal2;}		 
						$impresion.="<tr>
								   <td colspan='2'><hr/></td>
								 </tr>
								 <tr>
								   <td colspan='2'>
									<table width='100%' border='1' align='center'>
										<tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".$metodoDePago."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
										<tr><th>Numero de serie del Certificado</th></tr>
										<tr><td>$noCertificado</td></tr>
										<tr><th>Cadena Original</th></tr>
										<tr><td> <small><small>".$cadenaoriginal."</small></small></td></tr>
										<tr><th>Sello Digital</th></tr>
										<tr><td colspan='2' rowspan='2' id='sello'><small><small><small>$sello</small></small></small></td></tr>
									</table>
								   </td>
								</tr>
							</table>
							<center>
							Este documento es una representaci&oacute;n impresa de un CFDI
							</center>";
					
					$impresion2.="<tr>
								   <td colspan='2'></td>
								  </tr>
								  <tr>
									<td colspan='2'>
										<table width='100%' border='0' align='center' cellspacing='0' cellpadding='0'>
										   <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".($metodoDePago)."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
										   <tr><th>Numero de serie del Certificado</th></tr>
										   <tr><td>$noCertificado</td></tr>
										   <tr><th>Cadena Original</th></tr>
										   <tr><td> <small><small>".$cadenaoriginal."</small></small></td></tr>
										   <tr><th>Sello Digital</th></tr>
										   <tr><td colspan='2' rowspan='2' id='sello'><small><small><small>$sello</small></small></small></td></tr>
										 </table>
									</td>
								 </tr>
							</table>
							<center> 
								   Este documento es una representaci&oacute;n impresa de un CFDI
							</center>";
					
					}else{
						$cadenaorg_tmbre="||".trim($versiontimbre)."|".trim($foliofiscal)."|".trim($FechaTimbrado)."|".trim($selloCFD)."|".trim($noCertificadoSAT)."||";
						if($tipoDeComprobante == 'Ingreso'){
							$impresion.="
									  <tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".($metodoDePago)."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th style='background-color:#307ECC; color:#FFFFFF'>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='5'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$versiontimbre</td><td><b>FOLIO FISCAL:</b></td><td>$foliofiscal</td></tr>
												   <tr> <td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td colspan='4' width='90%'><b>Sello Digital CFDI:</b> <small><small><small>$selloCFD</small></small></small></td></tr>
												   <tr><td colspan='4' width='90%'><b>Sello del SAT:</b> <small><small><small>$selloSAT</small></small></small></td></tr>	
																		
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th style='background-color:#307ECC; color:#FFFFFF'>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small><small><small>$cadenaorg_tmbre</small></small></small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>";
						   
							$impresion2.="<tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".($metodoDePago)."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th style='background-color:#307ECC; color:#FFFFFF'>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='5'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$versiontimbre</td><td><b>UUID:</b></td><td>$foliofiscal</td></tr>
												   <tr> <td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td colspan='4'><b>Sello Digital CFDI:</b><small>$selloCFD</small></td></tr>
												   <tr><td colspan='4'><b>Sello del SAT:</b> <small>$selloSAT</small></td></tr>	
																		
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th style='background-color:#307ECC; color:#FFFFFF'>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small>$cadenaorg_tmbre</small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>";
						}else if($tipoDeComprobante == 'Pago'){
							$impresion.="
									  <tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".($metodoDePago)."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th style='background-color:#307ECC; color:#FFFFFF'>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='6'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$versiontimbre</td><td><b>FOLIO FISCAL:</b></td><td>$foliofiscal</td></tr>
												   <tr><td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td><b>FECHA PAGO:</b></td><td>$fechaPago</td><td><b>DOCTO. RELACIONADO:</b></td><td>$folioRelacionado</td>
												   <tr><td colspan='4' width='90%'><b>Sello Digital CFDI:</b> <small><small><small>$selloCFD</small></small></small></td></tr>
												   <tr><td colspan='4' width='90%'><b>Sello del SAT:</b> <small><small><small>$selloSAT</small></small></small></td></tr>
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th style='background-color:#307ECC; color:#FFFFFF'>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small><small><small>$cadenaorg_tmbre</small></small></small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>";
						} else if($tipoDeComprobante == 'Egreso'){
							$impresion.="
									  <tr>
									  <td colspan='2'>
									  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
									  <tr><td align='center'><strong>M&eacute;todo de pago:</strong>&nbsp;&nbsp;".($metodoDePago)."&nbsp;&nbsp;&nbsp;&nbsp;<strong>Forma de pago:</strong>&nbsp;&nbsp;".($FormaPago)."</td></tr>
									  </table>
									  </td>
									  </tr>
									   <tr>
										  <td colspan='2'>
											 <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
												<tr>
												   <th style='background-color:#307ECC; color:#FFFFFF'>TIMBRE FISCAL</th>
												   
												<tr>   
											</table>
										  </td>
									  </tr>
									   <tr>
										   <td colspan='2'>
											  <table width='100%' border='1' align='center' cellspacing='0' cellpadding='0'>
												<tr>
												   <td rowspan='6'><img class='qrcode' src='ajax/lib/imgqrcode.php?emisor_rfc=$rfc_emisor&receptor_rfc=$rfc_receptor&Comprobante_total=$importe_total&tfd_UUID=$foliofiscal'></td>
												</tr>
												   <tr><td><b>VERSION:</b></td><td>$versiontimbre</td><td><b>FOLIO FISCAL:</b></td><td>$foliofiscal</td></tr>
												   <tr><td><b>FECHA TIMBRADO:</b></td><td>$FechaTimbrado</td><td><b>No. CERTIFICADO SAT:</b></td><td>$noCertificadoSAT</td>
												   <tr><td><b></b></td><td></td><td><b>DOCTO. RELACIONADO:</b></td><td>$UUIDRelacionadoNota</td>
												   <tr><td colspan='4' width='90%'><b>Sello Digital CFDI:</b> <small><small><small>$selloCFD</small></small></small></td></tr>
												   <tr><td colspan='4' width='90%'><b>Sello del SAT:</b> <small><small><small>$selloSAT</small></small></small></td></tr>
											</table>
										</td>
									  </tr>	
									  <tr>
										<td colspan='2'>
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											  <th style='background-color:#307ECC; color:#FFFFFF'>Cadena Original del complemento de certificaci&oacute;n digital del SAT:</th>
											</tr>
										 </table>
										 </td>
									  </tr>			
									  <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td>
											   <small><small><small><small>$cadenaorg_tmbre</small></small></small></small>
											  </td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									 <tr>
										<td colspan='2' >
										  <table width='100%' border='1' align='center' cellspacing='1' cellpadding='1'>
											<tr>
											<td align='center'>Este documento es una representaci&oacute;n impresa de un CFDI</td> 
											 </tr>
										  </table>	   
										</td>
									 </tr>	
									</table>";
						}
					}
					/*
					echo "<pre>";
					print_r("TC: ");
					print_r($tipoDeComprobante);
					echo "</pre>";
					echo "<pre>";
					print_r($impresion);
					echo "</pre>";
					echo "<pre>";
					print_r($impresion2);
					echo "</pre>";
					exit();*/
					
					/////////////////////////////////////////////////////////////////////////////////
					$json->factura = $impresion;
				}
			} else {
				throw new Exception("Error al leer Factura.");
			}
		}

    }
    catch(exception $ex)
    {
        $json->mensaje = "Error al leer factura";
        $json->estado=-2;
		// error_log(date("g:i:s a")." -> Error en ejecucion... \n",3,"log".date('d-m-Y')."_json_verfactura.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_verfactura.txt");
    }
	// print_r($json);
	// exit();
	
	try {
		echo json_encode($json);
	} catch (JsonException $e) {
		echo 'Error en la codificación JSON: ';
	}
	
	function idConceptoSat($id){
		$idcatalogo = $id;
		$file = "../../files/values/strval_" . $idcatalogo . ".json";
		$json123 = new stdClass();
		if(file_exists($file) ) {
			// Se supone que deber�a de existir
			$file_string = file_get_contents($file);
			
			try {
				$json123 = json_decode($file_string);			
				return $json123;
			} catch (JsonException $e) {
				echo 'Error en la codificación JSON: ';
				exit;
			}
		}
	}	
 ?>