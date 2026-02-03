<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
	
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	require_once '../../cache/cache.class.php';
	
	$actualizar = isset($_GET['actualizar']) ? $_GET['actualizar'] : '0';
	
	$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	if($estado != 0){
		$json->estado = $estado;
		$json->mensaje = "ERROR";
	} else {
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("{CALL proc_obtenerempresasactivas}");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i = 0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			$arr = array();
			foreach($ds as $value){
				$arr[] = array(
					'value' => $value['Clave'], 'nombre' => encodeToUtf8($value['nombre'])
					);
			}
			$mensaje = 'OK';
		} catch (Exception $ex){
			$json->mensaje = "Ocurrió un error al intentar conectarse a la base de datos.";
			$json->estado = -2;
		}
	}

	try {
		$json->estado = $estado;
		$json->datos = $arr;
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

?>