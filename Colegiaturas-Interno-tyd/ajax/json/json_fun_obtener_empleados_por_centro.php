<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	
	$sListadoCentros = isset($_POST['sListadoCentros']) ? $_POST['sListadoCentros'] : '0';
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		try {	
			$json->estado=$estado;
			$json->mensaje=$mensaje;
			$json->resultado=array();
			echo json_encode($json);
			exit;
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo("SELECT idu_centro
			// , idu_empleado
			// , nom_empleado
		// FROM fun_obtener_empleados_por_centro('$sListadoCentros'::VARCHAR)");
		// exit();
		
		$cmd->setCommandText("SELECT idu_centro
			, idu_empleado
			, nom_empleado
		FROM fun_obtener_empleados_por_centro('$sListadoCentros'::VARCHAR)");
		$ds = $cmd->executeDataSet();
		$con->close();
		$cnt = sizeof($ds);
		
		if ($cnt > 1) {
			$resultado[] = array("idu_centro" => "0"
				, "idu_empleado" => "0"
				, "nom_empleado" => "TODOS");
		}
		
		foreach($ds as $row) {
			$resultado[] = array("idu_centro" => $row["idu_centro"]
				, "idu_empleado" => $row["idu_empleado"]
				, "nom_empleado" => encodeToUtf8(trim($row["nom_empleado"]))
			);
		}
		$json->estado = 1;
		$json->mensaje = "OK";
		$json->resultado = $resultado;
	}
	catch(exception $ex)
	{
		$json->estado = -2;
		$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
		$json->resultado = array();
	}
	
	try {	
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>