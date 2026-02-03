<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$query = "SELECT * FROM fun_obtener_tipos_movimientos_bitacora()";
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
			$cmd->setCommandText($query);
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
					'value' => $value['idu_tipo_movimiento'], 
					'nombre' => encodeToUtf8($value['nom_tipo_movimiento'])
				);
			}	
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar a la base de datos";
			$json->estado=-2;
		}
    }
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
 ?>