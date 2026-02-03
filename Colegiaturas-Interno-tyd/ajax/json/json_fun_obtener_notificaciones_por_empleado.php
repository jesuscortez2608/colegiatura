<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = isset($_POST['session_name'])?$_POST['session_name']:'';
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	if($iEmpleado==0)
	{
		$iEmpleado=$_SESSION[$Session]["USUARIO"]['num_empleado'];
	}
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_notificaciones_por_empleado.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_notificaciones_por_empleado.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_notificaciones_por_empleado.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			// print_r("select * from fun_obtener_notificaciones_por_empleado($iEmpleado, $iFactura)");
			// exit();
			$cmd->setCommandText("select * from fun_obtener_notificaciones_por_empleado($iEmpleado, $iFactura)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$i = 0;
			$arr = array();
			foreach ($ds as $fila)
			{
				$arr[] = array(
					'origen' => $fila['empleado_origen'], 
					'nombreOrigen' => $fila['nom_origen'],
					'destino' => $fila['empleado_des'], 
					'nombreDestino' => $fila['nom_des'],
					'comentario' => $fila['comentario'],
					'leido' => $fila['opc_leido'], 
					'fecha'=> $fila['fecha'], 
					'hora'=> $fila['hora'], 
					'notificar'=> $fila['notificar'],
					'id_factura'=> $fila['id_factura'],
					'empleado'=>$iEmpleado
				);
				$i++;
			}
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_notificaciones_por_empleado \n",3,"log".date('d-m-Y')."json_fun_obtener_notificaciones_por_empleado.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_notificaciones_por_empleado.txt");
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