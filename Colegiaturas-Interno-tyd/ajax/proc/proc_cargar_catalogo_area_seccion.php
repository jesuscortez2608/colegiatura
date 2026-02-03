<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// sleep(1);
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = "Colegiaturas";
	
    
	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);


	$url_servicio_colegiaturas = isset($_POST['url_servicio_colegiaturas']) ? $_POSTS['url_servicio_colegiaturas'] : '';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	if ( trim($url_servicio_colegiaturas) == "" ) {
		try {
			$json = new stdClass();
			$json->estado = -1;
			$json->mensaje = "Es necesario el servicio de colegiaturas para actualizar el catalogo de area y seccion";
			$json->datos = array();
			
			echo json_encode($ret);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit();
	}
	
	function actualizar_areas_secciones($method, $url, $data) {
		if ($method == "POST") {
			$options = array(
				'http' => array(
					'header'  => "Content-type: application/x-www-form-urlencoded",
					'method'  => "POST",
					'content' => http_build_query($data)
				)
			);
		} else {
			$options = array(
				'http' => array(
					'header'  => "Content-type: application/json",
					'method'  => $method,
					'content' => http_build_query($data)
				)
			);
		}
		
		$context  = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		return $result;
	}
	
	require_once '../../cache/cache.class.php';
	$result = new stdClass();
	$mensaje = "";
	$estado = 0;
	try {
		$url="$url_servicio_colegiaturas/catalogos/actualizar_areas_secciones";
		$cacheApp = new CacheApp($Session, 'areas_secciones', $_SERVER['SCRIPT_NAME'], $url);
		$cacheApp->set_hours_for_update(24); // Cada día
		$cache = $cacheApp->get_cache();
		
		if ( count($cache["data"]) <= 0 ) {
			try {
				$param=array();
				$result = actualizar_areas_secciones("GET", $url, $param);
				$result = json_decode($result);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
			
			$cacheApp->set_cache($url, $result);
			
			$estado = 1;
			$mensaje = "Resultados obtenidos con la ejecución del servicio";
		} else {
			$estado = 2;
			$mensaje = "Resultados obtenidos del caché";
			$result = $cache["data"];
		}
	} catch (Exception $ex) {
		$estado=-2;
		$mensaje = "Ocurrió un error.";
	}
	try {	
		$respuesta = new stdClass();
		$respuesta->estado = $estado;
		$respuesta->mensaje = $mensaje;
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}