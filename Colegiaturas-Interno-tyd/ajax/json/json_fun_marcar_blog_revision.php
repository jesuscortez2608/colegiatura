<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	$json = new stdClass();

	$iFactura = isset($_POST['Factura']) ? $_POST['Factura'] : 0;
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	$estado=0;
	$mensaje='OK';
	
	$json = new stdClass(); 
	$datos = array();	
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
			exit;
		}
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT fun_marcar_blog_revision( $iFactura, $iEmpleado)");
		// exit;
		$cmd->setCommandText("SELECT fun_marcar_blog_revision($iFactura, $iEmpleado)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado=0;
	}
	catch(exception $ex)
	{
		$mensaje="Error error al cargar datos en blog revisión";
	//	$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar datos en Json"; //$ex->getMessage();
		$estado = -1;
	}
?>