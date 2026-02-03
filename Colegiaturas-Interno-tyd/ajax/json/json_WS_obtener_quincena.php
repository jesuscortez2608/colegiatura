<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	function url_encode($string){
        return urlencode($string);
    }
	
	function ObtenerQuincena($method, $url, $data) {
		// print_r("METODO=".$method."     URL=".$url."      DATOS=".$data);
		// exit();
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
		// echo "<pre>";
		// print_r($result);
		// echo "</pre>";
		// exit();
		return $result;
	}
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$Usuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	try{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
			$sNomParametro = 'URL_SERVICIO_COLEGIATURAS_SPRING';
			$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
			$ds = $cmd->executeDataSet();

			$con->close();
			$estado = 0;

			$valorParametro=$ds[0][2];
	}catch(Exception $ex){
		$estado = -1;
		$mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
	}

	try {
	
		$url="$valorParametro/quincena";
		$param=array();
		$result = ObtenerQuincena("GET", $url, $param);
		$result = json_decode($result);
		echo json_encode($result);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}	
?>