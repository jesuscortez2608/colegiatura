<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
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
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_ciclos_escolares.txt";
    } 
	else 
	{
		try
		{
	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select * from fun_obtener_ciclos_escolares()");
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
					//'value' => $value['idu_ciclo'], 'nombre' => utf8_encode($value['des_ciclo'])
					'value' => $value['idu_ciclo'], 'nombre' => mb_convert_encoding($value['des_ciclo'], 'UTF-8', 'ISO-8859-1')
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			//$json->mensaje = $ex->getMessage();
			$json->mensaje = "Error al conectar a Base de Datos";
			$json->estado=-2;
		}
    }
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}catch(JsonException $ex){
		$mensaje="";
		$mensaje = $ex->getMessage();
	}
 ?>