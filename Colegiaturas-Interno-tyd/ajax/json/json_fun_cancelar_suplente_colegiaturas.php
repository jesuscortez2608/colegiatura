<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$sjson = isset($_POST['sjson']) ? $_POST['sjson'] : '';
    $iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	try {
		$arr = json_decode($sjson);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
	if($estado != 0)
	{
		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;

			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		foreach($arr as $row) {
			$id = $row->id;
			$cmd->setCommandText("SELECT fun_cancelar_suplente_colegiaturas($id,$iCapturo)");
			$ds = $cmd->executeDataSet();
		}
		$con->close();
		$estado=1;
		$mensaje="OK";
	} catch(exception $ex) {
		$mensaje="Ocurrió un problema al intentar conectar con la base de datos.";
		$estado=-2;
	}

	// Ensure $json is an object (initialized or not) // Se agrega esta línea porque estaba mandando al catch
	$json = $json ?? new stdClass();
	
	try {	
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>