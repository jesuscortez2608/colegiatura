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
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_regiones.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select * from fun_catalogoregiones()");
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
					'value' => $value['numero'], 'nombre' => $value['nombre']
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
	$json->estado = $estado;
	$json->datos=$arr;

	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>