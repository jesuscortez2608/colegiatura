<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	function ObtenerArea($method, $url, $data){
		if($method == "POST"){
			$options = array(
				'http' => array(
					'header' => "Content-type: application/x-www-form-urlencoded",
					'method' => "POST",
					'content' => http_build_query($data)
				)
			);
		} else {
			$option = array(
				'http' => array(
					'header' => "Content-type: applicacion/json",
					'method' => $method,
					'content' => http_build_query($data)
				)
			);
		}
		
		$context = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		// echo "<pre>";
		// print_r($result);
		// echo "</pre>";
		// exit();
		return $result;
	}
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_NUMBER_INT);

    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$idArea = isset($_POST['idArea']) ? $_POSTS['idArea'] : 0;
	$Usuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	try{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$sNomParametro = 'URL_SERVICIO_COLEGIATURAS';
		$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
		$ds = $cmd->executeDataSet();

		$con->close();
		$estado = 0;

		$valorParametro=$ds[0][2];
	} catch(Exception $ex){
		$estado = -1;
		$mensaje = $ex->getMessage();
	}

	try {
		$url = "$valorParametro/catalogos/secciones/$idArea";
		$param = array();
		$result = ObtenerArea("GET", $url, $param);
		$result = json_decode($result);
		echo json_encode($result);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>