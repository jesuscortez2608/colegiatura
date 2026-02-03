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
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	//$cFolio = isset($_POST['cFolio']) ? $_POST['cFolio'] : 0;
	$iKeyx = isset($_POST['iKeyx']) ? $_POST['iKeyx'] : 0;
    
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("{CALL fun_eliminar_stmp_detalle_factura_colegiatura($iEmpleado,$iKeyx)}");
		// exit;
		
		$cmd->setCommandText("{CALL fun_eliminar_stmp_detalle_factura_colegiatura($iEmpleado,$iKeyx)}");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0][0];
		$mensaje='Se eliminó el beneficiario de la factura';

	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
		
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>