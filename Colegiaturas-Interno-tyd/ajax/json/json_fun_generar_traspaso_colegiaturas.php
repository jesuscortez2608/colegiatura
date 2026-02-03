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
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$iQuincena = isset($_POST['iQuincena']) ? $_POST['iQuincena'] : 0;
	$Usuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	

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
		// print_r("CALL fun_generar_traspaso_colegiaturas($iOpcion, $Usuario, $iQuincena)");
		// echo "</pre>";
		// exit();
		$cmd->setCommandText("{CALL fun_generar_traspaso_colegiaturas($iOpcion, $Usuario, $iQuincena)}");
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0][0];
		$mensaje='';
		
		if($iOpcion==2 && $estado == 0) {
			// Valida si existen movimientos seleccionados para el traspaso
			$mensaje='No se han seleccionado registros para el traspaso';
		} else if ($iOpcion==1 && $estado > 0) {
			// Realiza el traspaso
			$mensaje='Total de Movimientos Traspasados ' .$ds[0][0].'  Total de Importe = '.number_format($ds[0][1],2);
		} else if ($iOpcion==0 && $estado == 1) {
			// Valida si ya se realizó el traspaso
			$mensaje='Ya se realizo traspaso de movimientos el día de hoy, ¿Desea realizar otro traspaso?';
		}
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Error al generar el traspaso";
		$estado=-2;
	}
	
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
	try{
		echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
?>