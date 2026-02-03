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
			$query = "select * FROM fun_generar_cifrascontrol_pago()";
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			//TOTALES.
			$TotalEmpleados=0;
			$TotalMovtos=0;
			$TotalImporte=0;
			$TotalPrestacion=0;
			$TotalAjuste=0;
			$TotalGral = 0;
			
			if($ds!="")
			{
				foreach ($ds as $fila)
				{
					$TotalEmpleados=$fila['empleados'];
					$TotalMovtos=$fila['movimientos'];
					$TotalImporte+=$fila['importe_factura'];
					$TotalPrestacion+=$fila['importe_pagado'];
					$TotalAjuste+=$fila['importe_ajuste'];
					$TotalISR+=$fila['importe_isr'];
					$TotalGral = $TotalPrestacion + $TotalAjuste + $TotalISR;
					// SI SE REQUIERE QUE SE MUESTRE EL DETALLE DE LAS CIFRAS, DESCOMENTAR LAS LAS SIG. LINEAS.
					//INICIO
					// $respuesta->rows[$i]['cell']=array('',
						// number_format($fila['movimientos'],0),
						// '$'.number_format($fila['importe_factura'],2),
						// '$'.number_format($fila['importe_pagado'],2),
						// '$'.number_format($fila['importe_ajuste'],2),
						// '$'.number_format($fila['importe_isr'],2)
					// );
					// $i++;
					//FIN
				}
				$respuesta->rows[$i]['cell']=array(
						'<b>TOTAL</b>',
						'<b>'.number_format($TotalEmpleados,0).'</b>',
						'<b>'.number_format($TotalMovtos,0).'</b>',
						'<b>$'.number_format($TotalImporte,2).'</b>',
						'<b>$'.number_format($TotalPrestacion,2).'</b>',
						'<b>$'.number_format($TotalAjuste,2).'</b>',
						'<b>$'.number_format($TotalISR,2).'</b>',
						'<b>$'.number_format($TotalGral,2).'</b>'
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