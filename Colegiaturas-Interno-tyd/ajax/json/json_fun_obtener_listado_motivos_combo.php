<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_motivos_combo.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select * from fun_obtener_listado_motivos($iOpcion)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$i = 0;
			$arr = array();
			foreach ($ds as $fila)
			{
				$arr[] = array(
					'value' => $fila['idu_motivo'], 'nombre' => $fila['des_motivo']
				);
				$i++;
			}
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
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 57";
		$estado=-2;
	}
 ?>