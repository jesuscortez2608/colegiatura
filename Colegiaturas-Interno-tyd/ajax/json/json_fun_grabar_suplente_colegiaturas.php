<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	$json = new stdClass();
    // $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    // $estado = $CDB['estado'];  
    // $mensaje = $CDB['mensaje'];

	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
    $iEmpleadoSuplente = isset($_POST['iEmpleadoSuplente']) ? $_POST['iEmpleadoSuplente'] : 0;
	$iEmpleadoRegistro = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;	
	
	$cFechaInicial = isset($_POST['cFechaInicial']) ? $_POST['cFechaInicial'] : '19000101';
	$cFechaFinal = isset($_POST['cFechaFinal']) ? $_POST['cFechaFinal'] : '19000101';
	$iIdentificador = isset($_POST['iIdentificador']) ? $_POST['iIdentificador'] : 0;
	$iID = isset($_POST['iID']) ? $_POST['iID'] : 0;
	
	$estado=0;
	$mensaje='OK';
	
	// echo('iEmpleadoRegistro='.$iEmpleadoRegistro);
	// exit();
	
	if($iIdentificador==1)
	{
		$cFechaInicial 	= '19000101';
		$cFechaFinal 	= '19000101';	
	}
	
	
	$json = new stdClass(); 
	$datos = array();	
	// if($estado != 0)
	// {
		// $json->mensaje=$mensaje;
		// $json->estado=$estado;
		// echo json_encode($json);
		
		// exit;
	// }
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}
		
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		 // print_r("SELECT fun_grabar_suplente_colegiaturas($iEmpleado, $iEmpleadoSuplente, $iEmpleadoRegistro, '$cFechaInicial', '$cFechaFinal', $iIdentificador,$iID )");
		 // exit;
		$cmd->setCommandText("SELECT fun_grabar_suplente_colegiaturas($iEmpleado, $iEmpleadoSuplente, $iEmpleadoRegistro, '$cFechaInicial', '$cFechaFinal', $iIdentificador,$iID )");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		//$json->estado = 0;
		//$json->mensaje = $ds[0][1];
		$estado=0;
		$mensaje=$ds[0][0];
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
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