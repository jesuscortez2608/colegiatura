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
	
	$iclave = isset($_POST['iclave']) ? $_POST['iclave'] : 0;
	$sMensaje = isset($_POST['sMensaje']) ? $_POST['sMensaje'] : '';
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$iIndefinido = isset($_POST['iIndefinido']) ? $_POST['iIndefinido'] : 0;
	$dFec_ini = isset($_POST['dFec_ini']) ? $_POST['dFec_ini'] : 0;
	$dFec_fin = isset($_POST['dFec_fin']) ? $_POST['dFec_fin'] : 0;
	
	
	$Numusuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{		
		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
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
		
		$query = "{CALL fun_eliminar_aviso_colegiaturas($iclave,'$sMensaje',$iOpcion,$iIndefinido,'$dFec_ini','$dFec_fin',$Numusuario)}";
		
		$cmd->setCommandText($query);
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];

	}
	catch(exception $ex)
	{
		$mensaje="Error al consumir json_fun_eliminar_configuracion_avisos";
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