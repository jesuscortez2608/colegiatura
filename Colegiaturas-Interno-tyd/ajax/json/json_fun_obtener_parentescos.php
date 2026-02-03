<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iTipo = isset($_POST['iTipo']) ? $_POST['iTipo'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_parentescos.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_parentescos.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_parentescos.txt");
    } 
	else 
	{
		try
		{
	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select * from fun_obtener_parentescos($iTipo)");
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
					'value' => $value['idu_parentesco'], 'nombre' => mb_convert_encoding($value['des_parentesco'], 'UTF-8', 'ISO-8859-1')
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_parentescos \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
		}
    }
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 64"; //$ex->getMessage();
		$json->estado=-2;
	}
 ?>