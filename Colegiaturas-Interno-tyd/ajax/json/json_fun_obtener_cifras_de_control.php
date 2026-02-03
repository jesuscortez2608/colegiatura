<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	function url_encode($string){
        return urlencode(encodeToUtf8($string));
    } 
	
	function calcularISR($method, $url, $data){

		if($method == "POST"){
			$options = array(
				'http'=>array(
					'header' => "Content-type: application/x-www-form-urlencoded",
					'method' => "POST",
					'content' => http_build_query($data)
				)
			);
		} else{
			$options = array(
				'http' => array(
					'header'  => "Content-type:application/json",
					'method'  => $method,
					'content' => http_build_query($data)
				)
			);
		}
		$context = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		// echo "<pre>";
		// print_r($result);
		// echo "</pre>";
		// exit();
		return $result;
	}
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	$Empleado = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0){
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
			
			$query = "SELECT icolaborador, nimportepagado FROM fun_obtener_totales_traspaso($Empleado)";
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			if($ds != null){
				$i=0;
				foreach($ds as $fila){
					$tabla = $tabla.'<r e="'.$fila['icolaborador'].'" i="'.$fila['nimportepagado'].'"></r>';
				}
				// echo "<pre>";
				// print_r($tabla);
				// echo "</pre>";
				// exit();
			}
			$xml = '<Root>'.$tabla.'</Root>';
			
			$param = array("usuario" => $Empleado
						, "datosXml" => $xml);
			try{
				$sNomParametro = 'URL_SERVICIO_COLEGIATURAS_SPRING';
				$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
				$ds = $cmd->executeDataSet();
				$estado = 0;
				
				$valorParametro = $ds[0][2];
			}catch(Exception $ex){
				
			}
			$url = "$valorParametro/isr/calcular";
			// echo "<pre>";
			// print_r($url);
			// echo "</pre>";
			// exit();
			//Calcular el ISR
			$result = calcularISR("POST", $url, $param);
			$result = json_decode($result);

			// echo "<pre>";
			// print_r($result);
			// echo "</pre>";
			// exit();
			
			$importe_isr = 0;
			
			if ($result->datos > 0) {
				$importe_isr = $result->datos / 100;
			}
			
			// echo ("select * from fun_obtener_cifras_de_control($Empleado)");
			// exit();
			$cmd->setCommandText("select * from fun_obtener_cifras_de_control($Empleado)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$i = 0;
			$TotalEmpleados = 0;
			$TotalMovimientos = 0;
			$TotalImporteFac = 0;
			$TotalImportePagos = 0;
			$TotalImporteAjuste = 0;
			$TotalGral = 0;
			if($ds!="")
			{
				foreach ($ds as $fila)
				{	
					$TotalGral = $fila['importe_pagos'] + $fila['importe_ajuste'] + $importe_isr;
					$respuesta->rows[$i]['cell']=array(
						'<b>TOTAL</b>',
						number_format($fila['empleados'],0),
						number_format($fila['movimientos'],0),
						'$'.number_format($fila['importe_factura'],2),
						'$'.number_format($fila['importe_pagos'],2),
						'$'.number_format($fila['importe_ajuste'],2),
						'$'.number_format($importe_isr,2),
						number_format($importe_isr),
						'$'.number_format($TotalGral,2)
					);
					$i++;
				}

			}		
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_cifras_de_control \n",3,"log".date('d-m-Y')."json_fun_obtener_cifras_de_control.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_cifras_de_control.txt");
		}
    }
	
	try{
		echo json_encode($respuesta);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
 ?>