<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		
	$idAjuste=isset($_POST['idAjuste']) ? $_POST['idAjuste'] : 0;	
	$iUsuario=(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';

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
		// echo("{ CALL FUN_GRABAR_AJUSTE_POR_FACTURA ($iFactura, $iPorcentaje, $iUsuario, '$sObservaciones')}");
		// exit();
		$cmd->setCommandText("{ CALL FUN_BORRAR_AJUSTE_POR_FACTURA ($idAjuste)}");
		$ds = $cmd->executeDataSet();
		$estado =$ds[0][0];
		$mensaje=mb_convert_encoding($ds[0][1], 'UTF-8', 'ISO-8859-1');
	}
	catch (exception $ex){
		$mensaje="Error al consultar FUN_BORRAR_AJUSTE_POR_FACTURA";
	//	$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	echo json_encode($json);
	}
	catch (JsonException){
		echo ("Error: no se pudo realizar carga de Json");
	}
?>