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
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	$iMarca = isset($_POST['iMarca']) ? $_POST['iMarca'] : 0;
	$iQuincena = isset($_POST['iQuincena']) ? $_POST['iQuincena'] : 0;
	$iTipoNom = isset($_POST['iTipoNom']) ? $_POST['iTipoNom'] : 0;
    $iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		
		try{
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		}
		catch(JsonException $ex){
			$mensaje = "Error al cargar el Json";
			exit;
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// echo "<pre>";
		// print_r("SELECT * from fun_marcar_traspaso_colegiaturas($iFactura, $iMarca, $iCapturo, $iQuincena, $iTipoNom)");
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText("SELECT * from fun_marcar_traspaso_colegiaturas($iFactura, $iMarca, $iCapturo, $iQuincena, $iTipoNom)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = 0;
		$mensaje = 'OK';
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Error al marcar el traspaso";
		$estado=-2;
	}
	
	try{
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
?>