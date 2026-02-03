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
    $iEmpleadoSuplente = isset($_POST['iEmpleadoSuplente']) ? $_POST['iEmpleadoSuplente'] : 0;
	$iEmpleadoRegistro = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	$cFechaInicial = isset($_POST['cFechaInicial']) ? $_POST['cFechaInicial'] : '';
    $cFechaFinal = isset($_POST['cFechaFinal']) ? $_POST['cFechaFinal'] : 0;
	$iIdentificador = isset($_POST['iIdentificador']) ? $_POST['iIdentificador'] : 0;
    $iCancelado = isset($_POST['iCancelado']) ? $_POST['iCancelado'] : 0;
	$iEmpleadoCancela = isset($_POST['iEmpleadoCancela']) ? $_POST['iEmpleadoCancela'] : 0;
    
	
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
		//echo ("SELECT fun_grabar_bitacora_suplentes($iRegistro)");
		$cmd->setCommandText("SELECT fun_grabar_bitacora_suplentes($iEmpleado,$iEmpleadoSuplente,$iEmpleadoRegistro,'$cFechaInicial','$cFechaFinal', $iIdentificador,$iCancelado,$iEmpleadoCancela)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		//$json->estado = 0;
		//$json->mensaje = $ds[0][1];
		$estado=0;
		//$mensaje=$ds[0][0];
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