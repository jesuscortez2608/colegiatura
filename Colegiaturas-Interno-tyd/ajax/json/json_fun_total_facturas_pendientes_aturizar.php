<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = isset($_POST['session_name'])?$_POST['session_name']:'';
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$nOpcion = isset($_POST['nOpcion']) ? $_POST['nOpcion'] : 1;
	$sListadoCentros = isset($_POST['sListadoCentros']) ? $_POST['sListadoCentros'] : '0';
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    //$respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_total_facturas_pendientes_aturizar.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_total_facturas_pendientes_aturizar.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_total_facturas_pendientes_aturizar.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			// print_r("select * from fun_total_facturas_pendientes_aturizar($nOpcion::integer,'$sListadoCentros'::VARCHAR)");
			// exit();
			$cmd->setCommandText("select * from fun_total_facturas_pendientes_aturizar($nOpcion::integer,'$sListadoCentros'::VARCHAR)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$json->estado = 0;
			$total=0;
			if($ds!="")
			{
				$empleados='';
				foreach ($ds as $fila)
				{
					$total+=$fila['total'];
					
					$empleados.=' / '.$fila['numemp'].' '.trim($fila['empleado']).' ';
					$i++;
					
				}
				
			}
			$json->total = $total;
			$json->empleados=$empleados;
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_total_facturas_pendientes_aturizar \n",3,"log".date('d-m-Y')."json_fun_total_facturas_pendientes_aturizar.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_total_facturas_pendientes_aturizar.txt");
		}
    }
	
	try {	
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>