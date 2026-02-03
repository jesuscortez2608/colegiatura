<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	//-----------------------------------------------------------------------------

	$iEmpresa	= isset($_POST['iEmpresa'])	? $_POST['iEmpresa'] : 0;

	$json = new stdClass();
try{
		$CDB			= obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado			= $CDB['estado'];
		$cadenaconexion	= $CDB['conexion'];
		$mensaje		= $CDB['mensaje'];

		if ($estado != 0){
			throw new Exception($mensaje);
		}
	
		$con = new OdbcConnection($cadenaconexion);
			
		$con->open();
		
		$cmd = $con->createCommand();
		
		// echo("{CALL fun_obtener_rfc_empresa($iEmpresa)}");
		// exit();
		
		$cmd->setCommandText("{CALL fun_obtener_rfc_empresa($iEmpresa)}");
		$ds = $cmd->executeDataSet();
		
		$rfc = $ds[0][0];
		// print_r($rfc);
		// exit();
	}	
	catch(exception $ex){
		$mensaje = "Error al obtener rfc Empresa";
		//$mensaje = $ex->getMessage();
		$estado = -2;
	}
	try{
	$json->rfc = $rfc;
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	echo json_encode($json);	
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 54"; //$ex->getMessage();
		$json->estado=-2;
	}
?>