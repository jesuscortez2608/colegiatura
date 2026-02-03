<?php
	//JSON//OBSOLETO// LA ACTUALIZACION DE LOS DETALLES DE LA FACTURA SE HARA DESDE EL JSON (json_fun_grabar_importe_pagado.php);
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$cRFC = isset($_POST['cRFC']) ? $_POST['cRFC'] : '';
	
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
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
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT * from fun_actualizar_escuelas_colegiaturas_sep($iEscuela, '$cRFC')";
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 1;
		$json->mensaje ='Escuala actualizada correctamente';
	}
	catch(exception $ex)
	{
		$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
		$json->estado=-2;
	}
	try{
		echo json_encode($json);
	}
	catch(JsonException $ex){
		$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
		$json->estado=-2;
	}
	
?>