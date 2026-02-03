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
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
    $iBeneficiario = isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
   
	
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
		
		$cmd->setCommandText("SELECT fun_eliminar_estudio_beneficiario($iEmpleado, $iBeneficiario, $iEscuela,$iEscolaridad )");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];
		//$json->mensaje = $ds[0][1];
		
		//$mensaje="OK";
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar a la base de datos json_fun_eliminar_estudio_beneficiario.";
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