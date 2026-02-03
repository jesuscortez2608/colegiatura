<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iTipo = isset($_POST['iTipo']) ? $_POST['iTipo'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$iopcion= isset($_POST['iopcion']) ? $_POST['iopcion'] : 0;
	$crfc= isset($_POST['crfc']) ? $_POST['crfc'] : '';
	$nEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt";
		//error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt");
		//error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt");
    } 
	else 
	{
		try
		{	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			//if ($iopcion==2){
				// echo ("select * from fun_obtener_beneficiario_empleado_rfc($iopcion,'$crfc',$nEmpleado)");
				// exit();
			//}
			$cmd->setCommandText("select * from fun_obtener_beneficiario_empleado_rfc($iopcion,'$crfc',$nEmpleado)");
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
					'value' => $value['id'], 
					'nombre' => $value['nombre'],
					'parentesco' => $value['parentesco'],					
					'escolaridad' => $value['escolaridad'],
					'ciclo' => $value['ciclo'],
					'grado' => $value['grado'],
					'carrera' => $value['carrera']
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			//error_log(date("g:i:s a")." -> Error al consumir fun_obtener_beneficiario_empleado_rfc \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
			//error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
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