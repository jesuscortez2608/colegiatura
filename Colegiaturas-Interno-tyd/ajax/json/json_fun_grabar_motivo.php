<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iClaveMotivo = isset($_POST['iClaveMotivo']) ? $_POST['iClaveMotivo'] : 0;
    $iTipoMotivo = isset($_POST['iTipoMotivo']) ? $_POST['iTipoMotivo'] : 0;
	$desMotivo = isset($_POST['desMotivo']) ? $_POST['desMotivo'] : "";
	$desMotivo = encodeToIso($desMotivo);
	
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{

		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$cmd->setCommandText("SELECT fun_grabar_motivo($iClaveMotivo,$iTipoMotivo,'$desMotivo',$iCapturo)");
		// print_r("SELECT fun_grabar_motivo($iClaveMotivo,$iTipoMotivo,'$desMotivo',$iCapturo)");
		// exit();
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];
		//$json->mensaje = $ds[0][1];
		
		//$mensaje="OK";
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar a la base de datos json_fun_grabar_motivo";
		$estado=-2;
	}

	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>