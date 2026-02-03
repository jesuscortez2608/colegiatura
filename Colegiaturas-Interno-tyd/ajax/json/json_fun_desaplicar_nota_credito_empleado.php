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
	
	$iNotaCredito= isset($_POST['iNotaCredito']) ? $_POST['iNotaCredito'] : 0;  //=0 Guarda,!=0  Actualiza
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;   
    	
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
			$mensaje="Error al cargar Json";
			
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT * FROM fun_desaplicar_nota_credito_empleado($iFactura, $iNotaCredito)");
		// exit;
		$cmd->setCommandText("SELECT * FROM fun_desaplicar_nota_credito_empleado($iFactura, $iNotaCredito)");
	    $ds = $cmd->executeDataSet();
		$con->close();		
		$estado = 0 ; //$ds[0][0];
		$mensaje='Proceso realizado con �xito'; //utf8_encode($ds[0][1]);
		
		
		//$mensaje="OK";
	}
	catch(JsonException $ex){
		$mensaje="Error al cargar Json";
		
		$estado=-2;
	}
	catch(exception $ex)
	{
		$mensaje="";
		//$mensaje = $ex->getMessage();
		$mensaje = "Error a conectar a Base de Datos";
		$estado=-2;
	}
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	try{
	echo json_encode($json);
	}catch(JsonException $ex){
		$mensaje="Error al cargar Json";
		
	}
?>