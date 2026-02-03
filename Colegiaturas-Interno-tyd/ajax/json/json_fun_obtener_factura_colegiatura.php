<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$iFactura = isset($_POST['Factura']) ? $_POST['Factura'] : 0;
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_factura_colegiatura.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// echo("select * from fun_obtener_factura_colegiatura($iFactura)");
			// exit();
			$cmd->setCommandText("select * from fun_obtener_factura_colegiatura($iFactura)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			// $json->mensaje = "OK";
			$json->datos = array();
			$i = 0;
			$arr = array();
			if ($ds[0]!=null)
			{
				$arr[] = array(
					'rfc' => $ds[0]['rfc'],
					'escuela' =>$ds[0]['escuela'],
					'foliofiscal' =>trim($ds[0]['foliofiscal']),
					'importe' =>number_format($ds[0]['importe'],2),
					'fecha' =>$ds[0]['fecha']
				);
			}
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
		}
    }
	try{
	$json->datos = $arr;
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 93";
		$estado=-2;
	}
 ?>