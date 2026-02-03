<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	$Empleado = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_cifras_de_control.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_cifras_de_control.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_cifras_de_control.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$query = "SELECT * FROM fun_imprimir_rechazos_generacion_pagos()";
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			//TOTALES.
			$TotalFactura=0;
			$TotalPagado=0;
			
			if($ds!="")
			{
				foreach ($ds as $fila)
				{
					$TotalFactura+=$fila['importe_factura'];
					$TotalPagado+=$fila['importe_pagado'];
					$TipoMov = $fila['idu_ajuste'];
					if($TipoMov > 0){
						$TipoMov = 'AJUSTE';
					}else{
						$TipoMov = 'FACTURA';
					}
					
					$respuesta->rows[$i]['cell']=array(
					
						trim($fila['num_empleado']),
						trim($fila['nombre_empleado']),
						$fila['idfactura'],
						$TipoMov,
						trim($fila['folio_factura']),
						'$'.number_format($fila['importe_factura'],2),
						'$'.number_format($fila['importe_pagado'],2)
						
					);
					$i++;
				}
				$respuesta->rows[$i]['cell']=array(
						'',
						'',
						'',
						'',
						'<b>TOTAL</b>',
						'<b>$'.number_format($TotalFactura,2).'</b>',
						'<b>$'.number_format($TotalPagado,2).'</b>'
					);
			}	
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_cifras_de_control \n",3,"log".date('d-m-Y')."json_fun_obtener_cifras_de_control.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_cifras_de_control.txt");
		}
    }

	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

 ?>