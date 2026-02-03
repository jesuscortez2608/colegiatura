<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		
	$prc_descuento	=	isset($_POST['prc_descuento']) ? $_POST['prc_descuento'] : 0;
	$iUsuario		=	(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';

	$json = new stdClass();

	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];  
	$cadenaconexion = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];

	try{

		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		// echo("en");
		// exit();
		$cmd = $con->createCommand();
		// echo("{ CALL fun_guardar_descuentos_colegiaturas ($prc_descuento,'$prc_descuento', $iUsuario)}");
		// exit();
		$cmd->setCommandText("{ CALL fun_guardar_descuentos_colegiaturas ($prc_descuento,'$prc_descuento', $iUsuario)}");
		$ds = $cmd->executeDataSet();
		$mensaje =$ds[0][0];
	}
	catch (exception $ex){
		$mensaje="Ocurrió un error al intentar conectarse a la base de datos";
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