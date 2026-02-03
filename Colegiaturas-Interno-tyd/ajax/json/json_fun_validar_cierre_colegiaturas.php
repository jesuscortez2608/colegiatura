<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	//---------------------------------------------------------------------------------------------------
	
	$iUsuario = (isset($_SESSION[$Session]["USUARIO"]["num_empleado"])) ? $_SESSION[$Session]["USUARIO"]["num_empleado"] : 0;
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
	$mensaje = $CDB['mensaje'];
	$json = new stdClass();
	
	if ($estado != 0) {
		$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectarse a Personal PosgreSQL";
	} else {
		try {
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$Query = "SELECT iestado, smensaje FROM fun_validar_cierre_colegiaturas($iUsuario)";
			// echo "<pre>";
			// print_r($Query);
			// echo "</pre>";
			// exit();
			
			$cmd->setCommandText($Query);
			$ds = $cmd->executeDataSet();
			
			// echo "<pre>";
			// print_r($ds);
			// echo "</pre>";
			// exit();
			
			$estado = $ds[0]['iestado'];
			$mensaje = $ds[0]['smensaje'];
			$mensaje = encodeToUtf8($mensaje);
		} catch (Exception $ex) {
			$estado = -1;
			$mensaje = 'Ocurrio un problema al realizar la consulta';
		}
	}
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		try{
		echo json_encode($json);
		}
		catch(JsonException $ex){
			$mensaje="";
			$mensaje = $ex->getMessage();
		}
?>
