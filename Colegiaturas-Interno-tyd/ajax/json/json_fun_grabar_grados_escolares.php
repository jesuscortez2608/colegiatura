<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
	$iGrado = isset($_POST['iGrado']) ? $_POST['iGrado'] : -1;
	$sNomGrado = encodeToIso(isset($_POST['sNomGrado'])) ? encodeToIso($_POST['sNomGrado']) : '';
	
	$json = new stdClass();
	try {
		$CDB	= obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];
		
		if($estado != 0) {
			throw new Exception($mensaje);
		}
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT estado, mensaje FROM fun_grabar_grados_escolares($iEscolaridad, $iGrado, '$sNomGrado')";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = $ds[0]['estado'];
		$mensaje = $ds[0]['mensaje'];
	} catch (Exception $ex) {
		$mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
		$estado = -2;
	}
		
	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>