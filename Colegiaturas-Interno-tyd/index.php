<?php
 /******************************************************************************************
 * Autor: Bernardo Manuel Segura Muñoz
 * Fecha: 21/03/2014
 * Fecha Actualizacion: 10/11/2014
 * Lenguaje: PHP
 * Tipo: index principal para los Sistemas Coppel
 * Descripción: Archivo generado automaticamente con la herramienta Generar Estructura Basica
 *  			Generador de codigo desarrollado para optimizar tiempos en el desarrollo de
 *  			Sistemas en entorno web.
 * Nombre: index
 * Version: Beta
 ********************************************************************************************/
 session_name("Session-Colegiaturas");
 session_start();
 if (!isset($_SESSION['csrf_token'])) {
	$_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
 header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
 header ('Content-type: text/html; charset=utf-8');
 header('X-Content-Type-Options: nosniff'); 
 
 $test = FALSE;
	
 //error_reporting(0);
	require_once ("../utilidadesweb/librerias/crypto/crypto.php");
	require_once ("../utilidadesweb/librerias/data/odbcclient.php");
	require_once ("../utilidadesweb/librerias/cnfg/conexiones.php");
	require_once("../IDC/confidc.php");
	
	/*----------------------------------------------------------------------------------------
	 * El archivo debe recibir  un parámetro por POST que indique el índice del sistema
	 */
	  /*var_dump($_SERVER['SERVER_PORT']);
	  exit;*/
	
	// VULNERABILIDADES
	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);

	$localurl = "files/values";
	$mensajes = "mensaje.json";
	$hours_for_update = 0.1; // Tiempo que tardará en actualizar el caché en horas
	$one_hour = 3600;
	$json = new stdClass();
	$file_controller = -1;
	if (!is_dir( $localurl)) 
	{
		mkdir( $localurl);
	}
	/*
	// Se debe reprogramar script para mensajes
	// Se comenta hasta que se reprograme el script de mensajes
	
	try 
	{
		$file = $localurl . "/" .  $mensajes;
		
		$age_of_file = time() - filemtime($file);
		
		if(file_exists($file) && ( $age_of_file < ( $hours_for_update * $one_hour ) )) {
			// Revisa si el archivo existe y si no ha expirado aún
			$file_string = file_get_contents($file);
			
		} 
		else 
		{	
			if(file_exists($file)) {
				unlink($file);
			}
			
			$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
			$estado = $CDB['estado'];   
			$mensaje = $CDB['mensaje']; 
			$json = new stdClass();
			if($estado != 0)
			{
				$json->estado = $estado;
				$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_index.txt";
				error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_index.txt");
				error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_index.txt");
			}
			else
			{
				try
				{
					$con = new OdbcConnection($CDB['conexion']);
					$con->open();
					$cmd = $con->createCommand();	    
				
					$cmd->setCommandText("{CALL fun_consultarcatalogomensajes(3, 0)}");
					$ds = $cmd->executeDataSet();
					
					$con->close();
					$i=0;
					$json->estado = 0;
					$json->mensaje = "OK";
					$json->datos = new stdClass();
					
					foreach ($ds as $fila) 
					{
						$nombre='idMSG'.$fila['iid_mensajesistemas'];
						$json->datos->$nombre=(trim(utf8_encode($fila['tdesc_mensajesistema'])));
					}
				}
				catch(exception $ex)
				{
					$json->mensaje = $ex->getMessage();
					$json->estado=-2;
					error_log(date("g:i:s a")." -> Error al consumir fun_consultarcatalogomensajes \n",3,"log".date('d-m-Y')."_index.txt");
					error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_index.txt");
				}
			}
			$strJson = json_encode($json->datos);
			file_put_contents ($file, $strJson);
		}
	} 
	catch (Exception $ex) 
	{
		$json->mensaje = $ex->getMessage();
		$json->estado=-2;
	}	
	*/
	$json = '';
	$iconoApp = '/plantilla/coppel/assets/img/icn_sc.ico';
	$Session = "Colegiaturas";//cambiar dependiendo del sistema
	//$DirSis = 'sueldosespeciales';//cambiar por el nombre del directorio de trabajo del sistema origen
	$jsPrincipal = "colegiaturas";
	$plantilla = "template";
	$strValjson = "files/values/json_colegiaturas.json";
	$strValue = "";
	//Mensajes BD
	$strValjsonMSG = "files/values/mensaje.json";
	$strValueMSG = " ; LengStrMSG=";


	$ExepcionModulos = array();//Arreglo para indicar que modulos no es necesario que se muestren sin afectar la estructura del sistema.
	$_SESSION[$Session]['PROXY'] =	 array();
	$urlIntranet = 'https://intranet.coppel.io/login.php';
	
	function errorhandler($input)
	{ 
	  //  var_dump($input);
		// $_SESSION['params'] = "";
		// $_SESSION['token'] = "";
		// $_SESSION['G_nemp'] = "";
		// $_SESSION['G_user'] = "";
		// $_SESSION['G_name'] = "";
		// $_SESSION['G_token'] = "";
		echo "<script language='javascript'>window.location.href='$urlIntranet';</script>";
		exit(0);
	}

	/*----------------------------------------------------------------------------------------
	 * El archivo debe recibir  un parámetro por POST que indique el índice del sistema
	 */
	// require ('ajax/json/json_testdata.php');
	// $_POST['jsonInfo'] = getTestData();
	if(isset($_POST['jsonInfo']))
	{
		//VULNERABILIDADES
		try {
			$json = str_replace('\\/', '/',desencriptar($_POSTS['jsonInfo'])); // Se quitan las diagonales invertidas
			$json = json_decode($json, TRUE);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		
		
		if(!isset($json['USUARIO']['num_empleado'] ) ||
			!isset($json['USUARIO']['num_centro'] )){
			// Si no están declaradas las variables de sesión anteriores
			// Lanza un mensaje de error
			header('Content-type: text/html; charset=utf-8');
			header('X-Content-Type-Options: nosniff');
			header('HTTP/1.0 404 Not Found');
			echo "<b><h1>Error 404 </h1><h2>Pagina No Encontrada</h2></b>La página a la cual quieres acceder no está disponible o no existe.";
			exit(); 
		}
		$_SESSION[$Session] = $json;
	} else if ($test) {
		require_once ("ajax/json/json_test.php");
		$json = getJson();
		if(!isset($json['USUARIO']['num_empleado'] ) || !isset($json['USUARIO']['num_centro'] )){
			// Si no están declaradas las variables de sesión anteriores
			// Lanza un mensaje de error
			header ('Content-type: text/html; charset=utf-8');
			header('X-Content-Type-Options: nosniff');
			header('HTTP/1.0 404 Not Found');
			echo "<b><h1>Error 404 </h1><h2>Pagina No Encontrada</h2></b>La página a la cual quieres acceder no está disponible o no existe.";
			exit();
		}
		$_SESSION[$Session] = $json;
	} else if( isset($_POST['session']) ) 
	{
		//Recibir desde otro sistema diferente a sistemas coppel
		require_once '../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once '../utilidadesweb/librerias/cnfg/obteneripwebserv.php';
		
		$_SESSION[$Session]['IPWEBSERV'] = getIpConsultaPerfil();
		if ($_SESSION[$Session]['IPWEBSERV'] == '') {
			echo "Error al obtener la ip para consultar el perfil de usuario";
			exit;
		}
		else
		{
			require_once('ajax/proc/proc_validaracceso.php');

			//VULNERABILIDADES
			try {
				$json = obtenerJson($_POSTS['session'],$_SESSION[$Session]['IPWEBSERV'],0,'');
				$json = json_decode($json, TRUE);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
			
			$dir = explode('/', dirname(__FILE__));//para linux
			$DirSis = $dir[sizeof($dir)-1];
			unset($dir);
			$_SESSION[$Session] = $json;
			$_SESSION[$Session]['DIRSIS'] = $DirSis;
			$_SESSION[$Session]['INDEX'] = "http://" . $_SERVER['HTTP_HOST'] . ':' . $_SERVER["SERVER_PORT"]. rtrim(dirname($_SERVER['PHP_SELF']), '/\\') . '/';
			// $_SESSION[$Session]['ORIGEN'] = isset($_POST['urlorigen']) ? $_POST['urlorigen'] : $_SESSION[$Session]['INDEX'];
			$_SESSION[$Session]['ORIGEN'] = isset($_POST['urlorigen']) ? $_POSTS['urlorigen'] : $urlIntranet;
			$_SESSION[$Session]['SESSION_ORIGEN'] = $Session;
		}
		
	} 
	else if(isset($_POST['token'])){//IDC
		// validacion y consumo de perfil a partir del token recibido.
		$apiidc = $get_apiidc;
		$fechaactual = date("Y-m-d\TH:i:s.Z\Z", time()); //fecha con formato requerido para peticiones
		$tautoriza = "";
		$nameSistem = "Colegiaturas";

		

		if ((isset($_POST['token']) && trim($_POST['token'])!="") || (isset($_SESSION['token']) && trim($_SESSION['token'])!="")) {
			if(isset($_POST['token']) && trim($_POST['token'])!=""){
				$_SESSION['token'] = $_POST['token'];
				$tautoriza = $_POST['token'];
			}
			else{
				$tautoriza = $_SESSION['token'];
			}
		   try{
			   $curl = curl_init();
	   
			   curl_setopt_array($curl, array(
				 CURLOPT_URL => $apiidc . "party-identity/oauth2/v1/validate",
				 CURLOPT_RETURNTRANSFER => true,
				 CURLOPT_ENCODING => '',
				 CURLOPT_MAXREDIRS => 10,
				 CURLOPT_TIMEOUT => 0,
				 CURLOPT_FOLLOWLOCATION => true,
				 CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
				 CURLOPT_CUSTOMREQUEST => 'POST',
				 CURLOPT_HTTPHEADER => array(
				   'X-Coppel-Date-Request: ' . $fechaactual,
				   'X-Coppel-Latitude: 20.270460',
				   'X-Coppel-Longitude: -99.985171',
				   'X-Coppel-TransactionId: fs9999c7q86c33cdfd5f55',
				   'Content-Length: 0',
				   'Authorization: Bearer ' . $tautoriza,
				 ),
			   ));
	   
			   $response = curl_exec($curl);
			   $jresponse = json_decode($response, true);
	   
			   curl_close($curl);
			  				  
			   if (isset($jresponse["error"])) errorhandler($jresponse["error_description"]);
		   }
		   catch(exception $ex){
				   errorhandler($ex);
		   }
	   }
	   else{
		   errorhandler("Error de token");
	   }

	   if (isset($_SESSION['token'])) {
			try{
				$curl = curl_init();

				//echo($_SESSION['Authorization']);
				//exit;

				curl_setopt_array($curl, array(
					CURLOPT_URL => $apiidc . "party-identity/oauth2/v1/profile?params=" . urlencode("displayName,givenName,surname,employeeId,mail,jobTitle,department,companyName"),
					CURLOPT_RETURNTRANSFER => true,
					CURLOPT_ENCODING => '',
					CURLOPT_MAXREDIRS => 10,
					CURLOPT_TIMEOUT => 0,
					CURLOPT_FOLLOWLOCATION => true,
					CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
					CURLOPT_CUSTOMREQUEST => 'GET',
					CURLOPT_HTTPHEADER => array(
					'X-Coppel-Date-Request: ' . $fechaactual,
					'X-Coppel-Latitude: 20.270460',
					'X-Coppel-Longitude: -99.985171',
					'X-Coppel-TransactionId: fs9999c7q86c33cdfd5f55',
					'Authorization: Bearer ' . $_SESSION['token'],
					),
				));

				$response = curl_exec($curl);

				if(curl_errno($curl)){
					$msgError = curl_error($curl);

					errorhandler($msgError);
				}			

				$jresponse = json_decode($response, true);
				
				curl_close($curl);

				if (isset($jresponse["error"])) errorhandler($jresponse["error_description"]);
				
				$_SESSION['params'] = $jresponse["employeeId"];
				$_SESSION['G_nemp'] = $jresponse["employeeId"];
				$_SESSION['G_user'] =  $jresponse["employeeId"];
				$_SESSION['G_name'] = $jresponse["displayName"];
				$_SESSION['G_idioma'] = 0;
				$_SESSION['G_country'] = "Mexico";

			}
			catch(exception $ex){
				errorhandler($ex);
			}

		} else{
			echo "<script language='javascript'>window.location.href='$urlIntranet';</script>";
			die();
		}

		if($_SESSION['G_nemp'] != ''){
			require_once '../utilidadesweb/librerias/cnfg/conexiones.php';
			require_once '../utilidadesweb/librerias/cnfg/obteneripwebserv.php';
			
			$_SESSION[$Session]['IPWEBSERV'] = getIpConsultaPerfil();
			if ($_SESSION[$Session]['IPWEBSERV'] == '') {
				echo "Error al obtener la ip para consultar el perfil de usuario";
				exit;
			}
			else
			{
				require_once('ajax/proc/proc_validaracceso.php');
				//$json = obtenerJson($_POST['session'],$_SESSION[$Session]['IPWEBSERV']);
				$json = obtenerJson('',$_SESSION[$Session]['IPWEBSERV'],$_SESSION['G_nemp'],$nameSistem);

				if($json != '0'){
					$json = filter_var_array(json_decode($json, TRUE));
					$dir = explode('/', dirname(__FILE__));//para linux
					$DirSis = $dir[sizeof($dir)-1];
					unset($dir);
					$_SESSION[$Session] = $json;
					$_SESSION[$Session]['DIRSIS'] = $DirSis;
					$_SESSION[$Session]['INDEX'] = "http://" . $_SERVER['HTTP_HOST'] . ':' . $_SERVER["SERVER_PORT"]. rtrim(dirname($_SERVER['PHP_SELF']), '/\\') . '/';
					// echo('sesion index: '.$_SESSION[$Session]['INDEX']);
					// die();
					$_SESSION[$Session]['SESSION_ORIGEN'] = $Session;
				}
				else{
					header ('Content-type: text/html; charset=utf-8');
					header('HTTP/1.0 404 Not Found');
					//echo "<b><h1>Error 404 </h1><h2>Pagina No Encontrada</h2></b>La página a la cual quieres acceder no está disponible o no existe.";
					echo "<script language='javascript'>window.location.href='$urlIntranet';</script>";  
					session_destroy();
					exit();
				}
			}
		}
	}
	else 
	{
		if(!isset($_SESSION[$Session]))//revizar mas delante
		{
			/*header ('Content-type: text/html; charset=utf-8');
			header('HTTP/1.0 404 Not Found');
			echo "<b><h1>Error 404 </h1><h2>Pagina No Encontrada</h2></b>La página a la cual quieres acceder no está disponible o no existe.";*/
			echo "<script language='javascript'>window.location.href='$urlIntranet';</script>";
			exit(0);
		}
		else {
			$plantilla = "error-404";
		}
	}
		
	/*----------------------------------------------------------------------------------------
	 * La carpeta utilidadesweb
	 * SistemasCoppel
	 */
	 $indexSistema = $_SESSION[$Session]['INDEX'];//"http://" . $_SERVER['SERVER_ADDR'] . rtrim(dirname($_SERVER['PHP_SELF']), '/\\') . '/';
	// $indexSistema = 'http://10.44.15.182:80/administracion/Colegiaturas/';
	 $utilidadesweb = str_replace($_SESSION[$Session]['DIRSIS'], 'utilidadesweb', $indexSistema);//cambiar dependiedo del diorectori del sistema
	 $utilidadesweb = '../utilidadesweb/'; 
	 
	/*----------------------------------------------------------------------------------------
	 * Variables que definen la ubicación de la plantilla que se va a usar
	 * y 
	 * 
	 */
		
		$url_template = '';
		$url_template = $utilidadesweb . 'plantilla/coppel/'.$plantilla.'.html';
		
		if($archivo_texto = fopen ("$url_template", "r"))
        {
	      $contenido_archivo = '';
	      while (!feof($archivo_texto)) {
		  $contenido_archivo .= fgets($archivo_texto,4096);
	      }
	      fclose ($archivo_texto);
		}
		
		/*$archivo_texto = fopen ("$url_template", "r");
		$contenido_archivo = '';
		while (!feof($archivo_texto)) {
			$contenido_archivo .= fgets($archivo_texto,4096);
		}
		fclose ($archivo_texto);*/
		
		/*$strValjson = fopen("$strValjson", "r");
		$strValue = '';
		while (!feof($strValjson)) {
			$strValue .= fgets($strValjson,4096);
		}
		fclose ($strValjson);*/
		if($strValjson = fopen("$strValjson", "r"))
    	{
		  $strValue = '';
		  while (!feof($strValjson)) {
		  $strValue .= filter_var(fgets($strValjson,5096), FILTER_SANITIZE_FULL_SPECIAL_CHARS);
		  }
		  fclose ($strValjson);
		}
		$strValue = str_replace('&quot;', '"', $strValue);

		$strValjsonMSG = fopen("$strValjsonMSG", "r");
		while (!feof($strValjsonMSG)) {
			$strValueMSG .= filter_var(fgets($strValjsonMSG,4096), FILTER_SANITIZE_FULL_SPECIAL_CHARS);
		}		
		$strValueMSG = str_replace('&quot;', '"', $strValueMSG);
		fclose ($strValjsonMSG);
		
		$contenido_archivo = str_replace('<!--url-->/', $utilidadesweb, $contenido_archivo); // Direccionando la ruta de las librerías
		
		/****************************************************************************************************/	
		//para agrgar las libs Extras que se necesiten en tu sistema
		
		$LibsExtras = '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/jquery-ui-1.10.3.custom.min.css" />';
		$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/ui.jqgrid.css" />';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/plantilla/coppel/assets/js/jquery-ui-1.10.3.custom.min.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/plantilla/coppel/assets/js/chosen.jquery.min.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/plantilla/coppel/assets/js/jquery.gritter.min.js"></script>';
		//$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/chosen.css" />';
		$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/ace.min.css"/>';
		
		$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/ace-responsive.min.css"/>';
		$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/ace-skins.min.css"/>';
		$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/font-awesome.min.css"/>';
		//$LibsExtras .= '<link rel="stylesheet" href="'.$utilidadesweb.'/plantilla/coppel/assets/css/chosen.scroll.css"/>';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>';
		$LibsExtras .= '<link rel="stylesheet" href="files/css/jquery.gritter.css"/>';
		$LibsExtras .= '<link rel="stylesheet" href="files/css/utils.css"/>';
		$LibsExtras .= '<link rel="stylesheet" href="files/css/chosen.scroll.css"/>';
		$LibsExtras .= '<link rel="stylesheet" href="files/css/chosen.css"/>';
		//$LibsExtras .= '<link rel="stylesheet" href="files/css/chosen.min.css"/>';
		$LibsExtras .= '<script type="text/javascript" src="files/js/accounting.min.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="files/js/general.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="files/js/utils.js"></script>';
		$LibsExtras .= '<script type="text/javascript" src="'.$utilidadesweb.'/src/com/coppel/utils/jquery.utils.js"></script>';
		
		$LibsExtras .= '<script type="text/javascript" src="files/Lib DomPurify/purify.min.js"></script>';
		
		/*******************************************************************************************************/
		
		/* Modificar el título de la aplicación
		*/

		$tituloSistema = ucwords(strtolower($_SESSION[$Session]['APLICACION'][0]['nom_nombresistema']));
		$contenido_archivo = str_replace('<!--%TituloSistema%-->', $tituloSistema, $contenido_archivo);
	
		/********Aqui llenar arreglo de exepcion modulos en caso de validar algo extra**********/
		// $ExepcionModulos[] = 'frm_moduloXXX.php';
		/***************************************************************************************/
		/*	//Bitacora
			$ExepcionModulos[] = 'frm_bitacoraMovimientosColegiaturas.php';
			//Costos
			$ExepcionModulos[] = 'frm_autorizacionCostosdeColegiatura.php';
			$ExepcionModulos[] = 'frm_consultaCostosAutorizados.php';
			//Configuraciones
			$ExepcionModulos[] = 'frm_cargaEscuelas.php';
			$ExepcionModulos[] = 'frm_configuracionSuplentes.php';
			$ExepcionModulos[] = 'frm_configuracionEscolaridad.php';
			$ExepcionModulos[] = 'frm_configuracionEscuelas-Escolaridad.php';
			$ExepcionModulos[] = 'frm_configuracionMotivosRechazo.php';
			$ExepcionModulos[] = 'frm_configuracionDescuentosEspeciales.php';
			$ExepcionModulos[] = 'frm_capturaEmpleadosPrestacionColegiatura.php';
			$ExepcionModulos[] = 'frm_configuracionAvisosColaboradores.php';
			//Consultas
			$ExepcionModulos[] = 'frm_consultaFacturas.php';
			$ExepcionModulos[] = 'frm_consultaMovimientos-ELP.php';
			$ExepcionModulos[] = 'frm_consultaMovimientosPersonalAdministracion.php';
			//Generar Archivos
			$ExepcionModulos[] = 'frm_banamex.php';
			$ExepcionModulos[] = 'frm_bancomer.php';
			$ExepcionModulos[] = 'frm_bancoppel.php';
			$ExepcionModulos[] = 'frm_invernomina.php';
			//Procesos Especiales
			$ExepcionModulos[] = 'frm_aceptarRechazarFacturas.php';
			$ExepcionModulos[] = 'frm_traspasoMovimientos.php';
			$ExepcionModulos[] = 'frm_generarPagosPregunta.php';
			$ExepcionModulos[] = 'frm_generarCierre.php';
			//Reportes
			$ExepcionModulos[] = 'frm_reporteAcumuladoColegiaturas.php';
			$ExepcionModulos[] = 'frm_reporteBecasCentro.php';
			$ExepcionModulos[] = 'frm_reporteBecasEscolaridad.php';
			$ExepcionModulos[] = 'frm_reporteBecasEscuela.php';
			$ExepcionModulos[] = 'frm_reporteBecasParentesco.php';
			$ExepcionModulos[] = 'frm_reporteBecasPuesto.php';
			$ExepcionModulos[] = 'frm_reporteBecasRegion-Escolaridad.php';
			$ExepcionModulos[] = 'frm_reportePagos.php';
			$ExepcionModulos[] = 'frm_reportePagosPorcentaje.php';
			//Seguimiento
			$ExepcionModulos[] = 'frm_seguimientoFacturasPersonalAdministracion.php';
			$ExepcionModulos[] = 'frm_autorizarFacturaGerente.php';
		*/	
			$menu_sistema = array();
			$separador = '';
			$ind = 0;
			$indice = 0;
			$indexAnterior = '';
			$indiCierre = false;

			foreach ($_SESSION[$Session]['APLICACION'] as $opcion) {
				
				if(!in_array($opcion['urlaplicacion'],$ExepcionModulos))
				{	
					if(($opcion['indice'] == $opcion['nom_nombreaplicacion']) && $separador == '')
					{
						if($indiCierre == true){ $menu_sistema[$indice] .= ']}';$indice++;$indiCierre = false;}
						$menu_sistema[$indice] = '{"idu_sistema":"'.$opcion['idu_sistema'].'","indice":"'.$opcion['indice'].'","nom_nombresistema":"'.$opcion['nom_nombresistema'].'","nom_nombreaplicacion":"'.$opcion['nom_nombreaplicacion'].'","urlaplicacion":"'.$opcion['urlaplicacion'].'","ordenmenuaplicacion":"'.$opcion['ordenmenuaplicacion'].'","iconoaplicacion":"'.$opcion['iconoaplicacion'].'","desc_ayudaaplicacion":"'.$opcion['desc_ayudaaplicacion'].'","opciones":"0"}';
						$indice++;
					}
					else
						{
							
							if(($indexAnterior == $opcion['indice']) || ($indexAnterior == ''))
							{
								if($ind > 0)
								{
									$separador = ',';
								}
								else
								 {
								 	$menu_sistema[$indice] = '{"idu_sistema":"'.$opcion['idu_sistema'].'","indice":"'.$opcion['indice'].'","nom_nombresistema":"'.$opcion['nom_nombresistema'].'","nom_nombreaplicacion":"'.$opcion['nom_nombreaplicacion'].'","urlaplicacion":"'.$opcion['urlaplicacion'].'","ordenmenuaplicacion":"'.$opcion['ordenmenuaplicacion'].'","iconoaplicacion":"'.$opcion['iconoaplicacion'].'","desc_ayudaaplicacion":"'.$opcion['desc_ayudaaplicacion'].'","opciones":"1","submenu":[';
								 }


								try {
									$menu_sistema[$indice] .= $separador . json_encode($opcion);
								} catch (\Throwable $th) {
									echo 'Error en la codificación JSON: ';
								}
						
								$ind++;
								$indexAnterior = $opcion['indice'];
								$indiCierre = true;
							}
							else {
								
								$separador = '';
								$ind = 0;
								//if($menu_sistema[$indice] != '')
								$menu_sistema[$indice] .= ']}';
								$indice++;
								if($opcion['indice'] != $opcion['nom_nombreaplicacion'])
								{
									try {
										$menu_sistema[$indice] = '{"idu_sistema":"'.$opcion['idu_sistema'].'","indice":"'.$opcion['indice'].'","nom_nombresistema":"'.$opcion['nom_nombresistema'].'","nom_nombreaplicacion":"'.$opcion['nom_nombreaplicacion'].'","urlaplicacion":"'.$opcion['urlaplicacion'].'","ordenmenuaplicacion":"'.$opcion['ordenmenuaplicacion'].'","iconoaplicacion":"'.$opcion['iconoaplicacion'].'","desc_ayudaaplicacion":"'.$opcion['desc_ayudaaplicacion'].'","opciones":"1","submenu":[';
										$menu_sistema[$indice] .= $separador . json_encode($opcion);
									} catch (\Throwable $th) {
										echo 'Error en la codificación JSON: ';
									}

									$ind++;
									$indexAnterior = $opcion['indice'];
									$indiCierre = true;
								}
								else
								{
									$menu_sistema[$indice] = '{"idu_sistema":"'.$opcion['idu_sistema'].'","indice":"'.$opcion['indice'].'","nom_nombresistema":"'.$opcion['nom_nombresistema'].'","nom_nombreaplicacion":"'.$opcion['nom_nombreaplicacion'].'","urlaplicacion":"'.$opcion['urlaplicacion'].'","ordenmenuaplicacion":"'.$opcion['ordenmenuaplicacion'].'","iconoaplicacion":"'.$opcion['iconoaplicacion'].'","desc_ayudaaplicacion":"'.$opcion['desc_ayudaaplicacion'].'","opciones":"0"}';
									$indice++;
									$indexAnterior = '';
									$indiCierre = false;
								}
							}
						}
				}	
			}
			if($indiCierre == true) $menu_sistema[$indice--] .= ']}';
			
			$Menu = '{"menu":[';
			$separador = '';
			$ind = 0;
			foreach($menu_sistema as $datosOpc)
			{
				if($ind > 0)
				{
					$separador = ',';
				}
				$Menu .= $separador . $datosOpc;
				$ind++;
			}
			$Menu .= ']}';
			$Menu = str_replace('},]}','}', $Menu);//parche para acceso indirecto....
	// Establecer campos hidden que pueden ser útiles en la aplicación
		$contenido_archivo = str_replace('<!--%hid_index%-->',$indexSistema, $contenido_archivo);
		//$contenido_archivo = str_replace('<!--%hid_iduempleado%-->', /*$aUsuario['numeroempleado']*/'null', $contenido_archivo);

		$dia = array("Domingo","Lunes","Martes","Miercoles","Jueves","Viernes","Sábado");
		$mes = array("Meses","Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");

		$contenido_archivo = str_replace('<!--%Fecha%-->',$dia[@date('w',time())] . @date(' d \d\e ',time()). $mes[@date('m',time()) * 1] . @date(' \d\e Y',time()), $contenido_archivo);
				
		$contenido_archivo = str_replace('<!--%Nom_Usuraio%-->', $_SESSION[$Session]['USUARIO']['nom_empleado'] . " " . $_SESSION[$Session]['USUARIO']['nom_apellidopaterno'] . " " . $_SESSION[$Session]['USUARIO']['nom_apellidomaterno'], $contenido_archivo);
		
		$contenido_archivo = str_replace('<!--Menu_Sistema-->', $Menu, $contenido_archivo);

		//$contenido_archivo = str_replace('<!--%UrlImagenMaketa%-->', 'files/img/icns_maketa.png', $contenido_archivo);

		//$contenido_archivo = str_replace('<!--%IP_Cliente%-->', $_SESSION[$Session]->clientIP, $contenido_archivo);
	
		//colocar js con las funciones a cargar al inicviar el sistema
		$contenido_archivo = str_replace('<!--%dirjs%-->', $LibsExtras.'<script src="files/js/'.$jsPrincipal.'.js"></script>', $contenido_archivo);
		
		$avatar = "user" . $_SESSION[$Session]['USUARIO']['sexo'] .".jpg";
		$saludo = "Bienvenid";
		$saludo .= ($_SESSION[$Session]['USUARIO']['sexo'] == '1')? 'a,':'o,'; 
		
		$contenido_archivo = str_replace('<!--%avatar%-->', $avatar, $contenido_archivo);
		$contenido_archivo = str_replace('<!--%Saludo%-->', $saludo, $contenido_archivo);
		
		// default
		$iconoApp = $utilidadesweb . $iconoApp;//icono default
		//$iconoApp = 'files/img/appicn.ico';//icono propio
		$contenido_archivo = str_replace('<!--icono-->', $iconoApp, $contenido_archivo);
		
		$contenido_archivo = str_replace('<!--unirTitulo-->', 'false', $contenido_archivo);//union del Indice y la Aplicacion desactivada
		$contenido_archivo = str_replace('<!--session_name-->',$Session , $contenido_archivo);
		$contenido_archivo = str_replace('<!--session_Org-->',$_SESSION[$Session]['SESSION_ORIGEN'] , $contenido_archivo);
		//$contenido_archivo = str_replace('<!--var_Global-->', '/*Aqui van variables Globales para cada Sisetma*/', $contenido_archivo);
		$contenido_archivo = str_replace('<!--var_Global-->', 'var usuario = '. $_SESSION[$Session]['USUARIO']['num_empleado'].";", $contenido_archivo);
		$OctBtn = (strpos( $_SESSION[$Session]['INDEX'], "http://".$_SERVER['SERVER_NAME']) === FALSE)? "":"ocultabtn('close','block');";
		$contenido_archivo = str_replace('<!--fCerrarSession-->',$OctBtn, $contenido_archivo);
		if($strValue != "")
		{
		
			$strValueMSG = str_replace('"id', 'id',$strValueMSG);
			$strValueMSG = str_replace('":', ':',$strValueMSG);
			//$contenido_archivo = str_replace('"<!--str_values-->"', $strValue,$contenido_archivo);
			//print_r( $strValue.$strValueMSG);
			$contenido_archivo = str_replace('"<!--str_values-->"', $strValue.$strValueMSG,$contenido_archivo);
			
	  		 $strValue = str_replace(chr (13), '',$strValue);
			 $strValue = str_replace(chr (10), '',$strValue);
			 $strValue = str_replace(chr (9), '',$strValue);
			 
			 $strValue = str_replace('{', '{"',$strValue);
			 
			 $strValue = str_replace(':"', '":"',$strValue);
			 $strValue = str_replace(': "', '":"',$strValue);
			 
			 $strValue = str_replace('",', '","',$strValue);
			
			try {
				$_SESSION[$Session]['LengStr'] = new stdClass();
				$_SESSION[$Session]['LengStr'] = json_decode($strValue);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
	
		}
		$contenido_archivo = str_replace('<!--Emp_Fto-->', $_SESSION[$Session]['USUARIO']['num_empleado'], $contenido_archivo);

	// Imprimir el contenido del archivo

		$contenido_archivo_quotes = htmlspecialchars($contenido_archivo,  ENT_QUOTES, 'UTF-8');
		$contenido_archivo_clean = htmlspecialchars_decode($contenido_archivo_quotes); 
		if ($contenido_archivo_clean==$contenido_archivo){
			echo $contenido_archivo_clean;
			echo '<input type="hidden" id="csrfToken" data-token="' . $_SESSION['csrf_token'] . '">';
		}

		
		//echo $contenido_archivo;
		
		//$_SESSION[$Session]['utilidadesweb'] = $utilidadesweb;

?>
<div id="dialog-session" style="display:none;" data-keyboard="false" data-backdrop="static">
	Su sesión finalizará en <span class="mtimer" style="color:#FF0000;"></span> minutos, ¿Desea continuar en la sesión?
</div>
<button  type="button" style="display:none;" id="btn_modalValidarCorreos" data-toggle="modal" data-target="#modalValidarCorreos">Validar Correo</button>
<!-- Modal Validar Correos 39116.1-->

<div class="modal" id="modalValidarCorreos" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true" style="display:none" id="close_modalValidarCorreos">&times;</button>
                 <h4 class="modal-title"><i class=" icon-comments-alt bigger-110"></i> Correo Institucional</h4>
            </div>
            <div class="modal-body">
				<h5 id="mensajeCorreo"></h5>
				<label for="correo_institucional">Correo Institucional:</label>
				<input type="text" id="correo_institucional" class="span5" maxlength="100" autocomplete="off">
				<br>
				<input type="checkbox" id="check_bPersonal"> Personal
				<div align="right">

				</div>
			</div>
            <div class="modal-footer">
        		<button type="button" class="btn btn-primary" id="guardar_correo">Guardar</button>
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>

<!-- //VULNERABILIDAD --> 
<script>
if (self === top) {
	document.documentElement.style.display = 'block';
	
}
</script>

<script>
	EmpezarConteoDeSesion(1);
	validarCorreo();
	// $("#modalValidarCorreos").hide();	
 // $("#modalValidarCorreos");
	var mySetTimeOut
	var myFinalSession
	
	function startTimer(duration, display) {
		var timer = duration, minutes, seconds;
		myFinalSession = setInterval(function () {
			minutes = parseInt(timer / 60, 10)
			seconds = parseInt(timer % 60, 10);

			minutes = minutes < 10 ? "0" + minutes : minutes;
			seconds = seconds < 10 ? "0" + seconds : seconds;

			display.textContent = minutes + ":" + seconds;

			if (--timer < 0) {
				timer = duration;
			}
		}, 1000);
	}

	function CargaTiempo() {
		var fiveMinutes = 60 * 3,
			display = document.querySelector('.mtimer');
		startTimer(fiveMinutes, display);
	};

	function EmpezarConteoDeSesion(Opcion)
	{
		if(Opcion == 1)
		{
			mySetTimeOut = setTimeout(function(){ConfirmarSession(Opcion)}, 1200000); // 20 minutos
		}
		else if(Opcion == 2)
		{
			mySetTimeOut = setTimeout(function(){ConfirmarSession(Opcion)}, 182000); // 3 minutos
		}
	}

	function ConfirmarSession(Opcion)
	{
		EmpezarConteoDeSesion(2);
		if(Opcion == 1)
		{
			definirDialogo();
		}
		else if (Opcion == 2)
		{
			$("#dialog-session").html("Su sesión finalizará en <span class=\"mtimer\" style=\"color:#FF0000;\">0:00</span> minutos.");
			clearTimeout(myFinalSession);
			clearTimeout(mySetTimeOut);
			$("#btn_Si").hide();
			$("#btn_No").hide();
			bootbox.dialog("Se cerrará la sesión",[{
				modal: true,
				"label" : "Aceptar",
				title : "<div class='widget-header widget-header-small'><h4 class='smaller' style='color:#FF0000'><i class='icon-fire'></i> <b>ATENCI&OacuteN!</b></h4></div>",
				"class" : "btn btn-primary",
				"callback": function(){
				$("#dialog-session").hide(); 
					cerrarSession();
					
				}
			}]);
		}
	}

	function ResetSession()
	{
		$.ajax({type: "POST",
			url: "ajax/proc/proc_resetsesion.php",
			data: {session_name:Session}
			}).done(function(data){});
		
		clearTimeout(mySetTimeOut);
		EmpezarConteoDeSesion(1);	 
	}

	var cerrarSession = function()
	{
		var val_hid_index = $("#hid_index").val();
		var url = "ajax/proc/proc_cerrarsesion.php";
		$.ajax({type: "POST",
			url: url,
			data: {session_name:Session}
				})
		.done(function(data){
				data = JSON.parse(data);
				if(data.idu_estado == 0 && data.mensaje == 'OK')
				{
					if (val_hid_index == "#") {
						//window.close();
						window.location.href=data.url;
					} else {
						window.location.href=data.url;
					}
				}
				else
				{
					alert(data.mensaje);
				}
			})
		.fail(function(s) {alert("Error al cargar " + url ); $('#pag_content').fadeOut();})
		.always(function() {});
		return true;
	}

	var cerrarSessionServer = function(url)
	{
		if (url == '#') {
			$.ajax({type:'POST',
				url:'ajax/proc/proc_cerrarsesion.php',
				data:{session_name:Session_Org},
				beforeSend:function(){},
				success:function(data){
					var dataJson = JSON.parse(data);
					if(data.idu_estado == 0 && data.mensaje == 'OK')
					{
						window.location.href=data.url;
					}
					else
					{
						window.location.href='http://ccuentaweb.coppel.com/SistemasCoppel/index.php';
						
					}
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		} else {
			if(url == undefined)
			{
				url = "";
			}
			url += "ajax/proc/proc_cerrarsesion.php";
			$.ajax({type: "POST",
					url: url,
					data: {session_name:Session_Org}
						})
				.done(function(data){
						data = JSON.parse(data);
						if(data.idu_estado == 0 && data.mensaje == 'OK')
						{
							window.location.href=data.url;
						}
						else
						{
							alert(data.mensaje);
						}
					})
				.fail(function(s) {alert("Error al cargar " + url ); $('#pag_content').fadeOut();})
				.always(function() {});
		}
		return true;
	}

	function definirDialogo() {
		$("#dialog-session").dialog({
			modal: true,
			title: "<div class='widget-header widget-header-small'><h4 class='smaller' style='color:#FF0000'><i class='icon-fire'></i> <b>ATENCI&OacuteN!</b></h4></div>",
			title_html: true,
			width:'500px',
			resizable: false,
			closeOnEscape: false,
			draggable:false,
			buttons: [ 
			{
				text: "Sí",
				"class" : "btn btn-success",
				"id"	: "btn_Si",
				click: function() 
				{
					$( this ).dialog( "close" ); 
					ResetSession();
				}
			},
			{
				text: "No",
				"class" : "btn btn-danger",
				"id"	: "btn_No",
				click: function() 
				{
					$( this ).dialog( "close" ); 
					bootbox.dialog("Favor de guardar sus cambios, de lo contrario se perderán.",[{
						"label" : "Aceptar",
						"class" : "btn btn-primary",
						"callback" : function(){
							// No hace nada...
						}
					}]);
				}
			}],
			open: function (event, ui) 
			{
				$(".ui-dialog-titlebar-close").css("display", "none");
				CargaTiempo();
			},
			close: function() 
			{
				$("#dialog-session").html("Su sesión finalizará en <span class=\"mtimer\" style=\"color:#FF0000;\"></span> minutos, ¿Desea continuar en la sesión?");
			}
		});
	}

	/*VALIDAR CORREO INSTITUCIONAL 39116.1*/
	function validarCorreo()
	{		
		$("#modalValidarCorreos").hide();
		$.ajax({type: "GET",
			url: "ajax/proc/proc_validarCorreoInstitucional.php",
			data: {session_name:Session}
		}).done(function(dataS){
			var data = JSON.parse(dataS);
			
			if(data.rnotifica == 1 || (data.rcorreo == '' && data.rpersonal== 0)){
				$("#btn_modalValidarCorreos").click();
				if(data.rPersonal == 1){
					$("#check_bPersonal").prop("checked")
				}else{
					$("#correo_institucional").val(data.rcorreo);
				}

				if( (data.rcorreo == null && data.rPersonal== 0)){
					$("#mensajeCorreo").html('Colaborador, no cuenta con correo institucional. <br>Marque la casilla "Personal" si no tiene correo institucional.');
				}else{				
					$("#mensajeCorreo").html('Colaborador, favor de confirmar que esta siga siendo su información.');
				}

				$("#guardar_correo").click(function(){
					ins_upd_Correo();				
				})
			}	
		}); 
	} 

	$('#check_bPersonal').click(function() {
    if ($(this).is(':checked')) {
		$('#correo_institucional').prop('disabled', true);
		$('#correo_institucional').val("");
    } else {
        $('#correo_institucional').prop('disabled', false);
    }
	});

	function ins_upd_Correo(){
		var dominio
		
		sCorreo = $("#correo_institucional").val();
		var pattern = /coppel\.com$/;
		dominio = pattern.test(sCorreo) ? 1 : 0;
		bPersonal = ($("#check_bPersonal").prop("checked")) ? 1 : 0;
		if (bPersonal == 0){
			
			if (sCorreo.length < 11 && dominio != 1){
				showalert("Correo invalido, solo se acepta correo con dominio", "", "gritter-info")
			}
		}
		
		$.ajax({type: "GET",
			url: "ajax/proc/proc_afecta_correoInstitucional.php",
			data: {
				session_name:Session,
				sCorreo: sCorreo,
				bPersonal: bPersonal,
				bNotifica: 0 // hay que modificar 
			}
		}).done(function(data){
			data = JSON.parse(data);
			if(data.correo == "Ok"){
				$("#close_modalValidarCorreos").click();
				showalert("Correo modificado con éxito.", "", "gritter-success");
			}else{				
				showalert("Algo ocurrió, por favor intenta de nuevo.", "", "gritter-warning");
			}
		});
	
	};

</script>