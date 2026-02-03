<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iTipoPago = isset($_POST['iTipoPago']) ? $_POST['iTipoPago'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_periodos_pagos.txt";
    } 
	else 
	{
		try
		{	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// echo ("select * from fun_obtener_periodos_pagos($iTipoPago)");
			// exit();
			
			$cmd->setCommandText("select * from fun_obtener_periodos_pagos($iTipoPago)");
			$ds = $cmd->executeDataSet();
			$con->close();	
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			$arr = array();
			foreach ($ds as $value)
			{
				$arr[] = array(
					'value' => $value['idu_periodo'], 'nombre' => encodeToUtf8($value['des_periodo'])
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
		}
    }
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 60"; //$ex->getMessage();
		$json->estado=-2;
	}
 ?>