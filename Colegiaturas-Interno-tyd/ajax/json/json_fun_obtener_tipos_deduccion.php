<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	
    
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_tipos_deduccion.txt";
    } 
	else 
	{
		try
		{
	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select tipo, deduccion from fun_obtener_tipos_deduccion()");
			$ds = $cmd->executeDataSet();
			$con->close();	
			
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			$arr = array();
			foreach ($ds as $value)
			{
				$arr[] = array(
					//'value' => $value['tipo'], 'nombre' => utf8_encode($value['deduccion'])
					'value' => $value['tipo'], 'nombre' => mb_convert_encoding($value['deduccion'], 'UTF-8', 'ISO-8859-1')
				);
			}			
		}
		catch(exception $ex)
		{
			//$json->mensaje = $ex->getMessage();
			$json->mensaje = "Error al conectar a Base de Datos";
			$json->estado=-2;
		}
    }
	$json->estado = $estado;
	$json->datos=$arr;
	try{
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje="";
		$mensaje = $ex->getMessage();
	}
 ?>