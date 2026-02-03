<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$iRegion = isset($_POST['region']) ? $_POST['region'] : 0;	
	$iRegion= str_pad($iRegion, 2, "0", STR_PAD_LEFT); // Imprime '01'
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_catalogociudades.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_catalogociudades.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_catalogociudades.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			//print_r("select * from fun_catalogociudades('$iRegion')");
			$cmd->setCommandText("select * from fun_catalogociudades('$iRegion')");
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
					'value' => $value['numero'], 'nombre' => $value['nombreciudad']
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_catalogociudades \n",3,"log".date('d-m-Y')."json_fun_catalogociudades.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_catalogociudades.txt");
		}
    }
	$json->estado = $estado;
	$json->datos=$arr;
	
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
?>