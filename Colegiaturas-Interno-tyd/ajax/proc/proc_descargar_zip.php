<?php
	session_name("Session-Colegiaturas");
	session_start();
	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
	date_default_timezone_set('America/Denver');
	
	
	$_REQUESTiN = filter_input_array(INPUT_POST, FILTER_SANITIZE_NUMBER_INT); //para gets y post
	//$_REQUESTsT = filter_input_array(INPUT_REQUEST, FILTER_SANITIZE_SPECIAL_CHARS); //para gets y post
	$_POSTS = filter_input_array(INPUT_POST, FILTER_SANITIZE_SPECIAL_CHARS); //para gets y post
	$_GETS = filter_input_array(INPUT_POST, FILTER_SANITIZE_SPECIAL_CHARS ); //para gets y post
	//var_dump($_POST['ajax/proc/proc_descargar_zip_php?txt_ciclo']);
	//$ciclo =  $_GET['txt_ciclo']; 

	if ($_POST['csrf_token'] === $_SESSION['csrf_token']) {
        $ciclo =  $_GET['txt_ciclo'];
    }

	if ($_SERVER['REQUEST_METHOD'] == 'POST') {
		if (isset($_POST['token'], $_SESSION['token']) &&  hash_equals($_SESSION['token'], $_POST['token'])) {
			if (isset($_GET['txt_ciclo'])) {
				$ciclo =  FILTER_VAR($_GETS['txt_ciclo'], FILTER_SANITIZE_SPECIAL_CHARS) ?? ''; 
			}
		}
 	} else {
		$_SESSION['token'] = bin2hex(random_bytes(32));
	}

			$nom_archivo1 = isset($_POST['txt_archivo1']) ? htmlspecialchars($_POSTS['txt_archivo1'] ?? '') : '';
			$nom_archivo2 = isset($_POST['txt_archivo2']) ? htmlspecialchars($_POSTS['txt_archivo2'] ?? '') : '';
			$idu_empleado = isset($_POST['txt_empleado']) ? htmlspecialchars($_POSTS['txt_empleado']?? '') : 0;
		

	$ciclo = htmlspecialchars($ciclo, ENT_QUOTES, 'UTF-8');
	$nom_archivo1 = htmlspecialchars($nom_archivo1, ENT_QUOTES, 'UTF-8');
	$nom_archivo2 = htmlspecialchars($nom_archivo2, ENT_QUOTES, 'UTF-8');
	$idu_empleado = htmlspecialchars($idu_empleado, ENT_QUOTES, 'UTF-8');
	


	function generarResultado($resultado, $mensaje){
		try{
		$arr[] = array('resultado' => $resultado,
						'mensaje' => $mensaje
						);
		echo '' . json_encode($arr) . '';
		exit();
					}
					catch(JsonException $ex){
						$mensaje="";
						$mensaje = $ex->getMessage();
					}
	}


	require_once "proc_interaccionalfresco.php";

	try {
		$objAlfresco = new InteraccionAlfresco();
		//$objAlfresco->setCiclo($ciclo);
		$objAlfresco->setCiclo(FILTER_VAR($ciclo, FILTER_SANITIZE_SPECIAL_CHARS));
		$context = $objAlfresco->getContext();
	
		$url1 = $objAlfresco->obtenerUrlImagen($idu_empleado, htmlspecialchars($nom_archivo1, ENT_QUOTES, 'UTF-8'));
		//$url1 = str_replace(' ', '%20', $url1);
		//$url2 = $objAlfresco->obtenerUrlImagen($idu_empleado, $nom_archivo2);
		$url2 = $objAlfresco->obtenerUrlImagen($idu_empleado, htmlspecialchars($nom_archivo2, ENT_QUOTES, 'UTF-8'));
		//$url2 = str_replace(' ', '%20', $url2);
		// Crear el zip
		$zip = new ZipArchive();
		$path = "../../files/tmp/download.zip";
		$zipfile = htmlspecialchars($path, ENT_QUOTES, 'UTF-8');
	
	
		
		$cnt = 0;
		
		if( file_exists($zipfile) ) {
			unlink($zipfile);
		}
		
		if ($zip->open($zipfile, ZipArchive::CREATE) !== TRUE) {
			throw new Exception("No se puede crear el archivo <$zipfile>\n");
		}
		
		if ($url1 != "") {
			
			$download_file = file_get_contents(filter_var($url1, FILTER_SANITIZE_STRING), false, $context);
			$res = $zip->addFromString(basename($url1),$download_file);
			$cnt++;
		}
		
		if ($url2 != "") {
			$download_file = file_get_contents(FILTER_VAR($url2, FILTER_SANITIZE_SPECIAL_CHARS), false, $context);
			$res = $zip->addFromString(basename($url2),$download_file);
			$cnt++;
		}
		
	    $zip->close();
		
		if ($cnt == 0) {
			header("HTTP/1.0 404 No existen archivos en Alfresco");
			die();
		} else if (file_exists(  htmlspecialchars($zipfile, ENT_QUOTES, 'UTF-8'))) {
			
		// Abrir el archivo remoto

			$archivo = fopen("$zipfile", 'r');

			// verificar si la apertura fue exitosa

			if ($archivo === false){
				generarResultado (-1, 'Error al leer archivo');
			}

			header('Content-Description: File Transfer');
			header('Content-Type: application/zip');
			header('Content-Transfer-Encoding: binary');
			header('Content-Disposition: attachment; filename="'.basename($zipfile).'"');
			header('Cache-Control: must-revalidate');
			header('Pragma: no-cache');
			header('Expires: 0');
			header('Content-Length: ' . filesize($zipfile));
			
			// Leer y enviar el contenido del archivo al navegador

			fpassthru($archivo);
			fclose($archivo);
			

		}
		
	} catch (Exception $ex) {
		generarResultado(-1, $ex->getMessage());
		//generarResultado(-1, "Tarea finalizada");
	}

	
?>