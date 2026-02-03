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
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$cObservaciones = isset($_POST['cObservaciones']) ? $_POST['cObservaciones'] : 0;	
    
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
		$cmd->setCommandText("select fun_bloquear_desbloquear_escuela from fun_bloquear_desbloquear_escuela($iEscuela,'$cObservaciones', $iCapturo);");
		$ds = $cmd->executeDataSet();

		$mensaje = $ds[0][0];
		$con->close();
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar comunicar con la base de datos json_fun_bloquear_desbloquear_escuela";
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