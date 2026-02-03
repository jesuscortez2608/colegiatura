<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
	
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	$actualizar = isset($_GET['actualizar']) ? $_GET['actualizar'] : '0';
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	$arr = array();
	
	if($estado != 0){
		$json->estado = $estado;
		$json->mensaje = "ERROR";
	} else {
		try{
			
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("SELECT fecha, fecha_mostrar FROM fun_obtener_quincenas_colegiaturas()");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i = 0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			foreach($ds as $value){
				$arr[] = array('fec_quincena' => $value['fecha'], 'fec_mostrar' => $value['fecha_mostrar']);
			}
		} catch (Exception $ex){
			//$json->mensaje = $ex->getMessage();
			$mensaje = "error de conexion a OdbcConnection";
			$json->estado = -2;
		}
	}
	$json->estado = $estado;
	$json->datos = $arr;
	try{
	echo json_encode($json);
	}
	catch(JsonException $ex)
	{
		$mensaje = "error Codificando Json";
		$json->estado = -2;
	}
?>