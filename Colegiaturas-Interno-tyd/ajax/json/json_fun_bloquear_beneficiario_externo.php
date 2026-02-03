<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$iBeneficiario = isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;    
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	
	$json = new stdClass(); 
	$datos = array();	

	try
	{
		$CDB 			= obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado 		= $CDB['estado'];  
		$cadenaconexion	= $CDB['conexion'];
		$mensaje 		= $CDB['mensaje'];		
		
		if($estado != 0){
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		}
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		// echo("{ select fun_bloquear_beneficiario_externo($iBeneficiario,$iUsuario);}");
		// exit();
		$cmd->setCommandText("{CALL fun_bloquear_beneficiario_externo($iBeneficiario,$iUsuario)}");
		$ds = $cmd->executeDataSet();
		$estado = $ds[0][0];
		//$mensaje = utf8_encode($ds[0][1]);
		$mensaje = mb_convert_encoding($ds[0][1],  'UTF-8', 'ISO-8859-1');
		// print_r($ds);
		// exit();
		$con->close();
	}
	catch(JsonException $ex)
	{
		$mensaje="Error al capturar Json";
		//$mensaje = $ex->getMessage();
		$estado=-2;
	}
	catch(exception $ex)
	{
		$mensaje="Error al consultar fun_bloquear_beneficiario_externo";
		//$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	echo json_encode($json);
	}
	catch(JsonException $ex)
	{
		$mensaje="Error al capturar Json";
		//$mensaje = $ex->getMessage();
		$estado=-2;
	}
?>