<?php
// echo("2");
// exit();
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    //-------------------------------------------------------------------------

    $json = new stdClass();

	$iIduEmpleado = isset($_REQUEST['iIduEmpleado']) ? $_REQUEST['iIduEmpleado'] : '0';
	
	try{
		$CDB            = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado         = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje        = $CDB['mensaje'];
		if($estado != 0){
			throw new Exception($mensaje);
		}
			
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo("{CALL fun_validar_usuario_externo($iIduEmpleado)}");
		// exit();
		
		$cmd->setCommandText("{CALL fun_validar_usuario_externo($iIduEmpleado)}");
		$ds = $cmd->executeDataSet();
		$estado = $ds[0][0];
		$mensaje= mb_convert_encoding($ds[0][1], 'UTF-8', 'ISO-8859-1');
		$con->close();
	}catch(exception $ex){
		$mensaje="Error al validar usuario externo";
		//$mensaje =  $ex->getMessage();
		$estado=-2;
	}
	// print_r($mensaje);
	// exit();
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	echo json_encode($json);
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 53"; //$ex->getMessage();
		$json->estado=-2;
	}
?>		