<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	function url_encode($string){
        return urlencode($string);
    }
	
	function actualizarISR2($method, $url, $data)
	{
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 60);
		curl_setopt($ch, CURLOPT_TIMEOUT, 60);

		if ($method == 'POST') {
			// This should be the default Content-type for POST requests
			curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-type: application/x-www-form-urlencoded"));
		} else {
			curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-type: application/json"));
		}
		
		$result = curl_exec($ch);
		
		return $result;
	}
	
	function actualizarISR($method, $url, $data) {
		if ($method == "POST") {
			$options = array(
				'http' => array(
					'header'  => "Content-type: application/x-www-form-urlencoded",
					'method'  => "POST",
					'content' => http_build_query($data)
				)
			);
		} else {
			$options = array(
				'http' => array(
					'header'  => "Content-type: application/json",
					'method'  => $method,
					'content' => http_build_query($data)
				)
			);
		}
		
		$context  = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		// echo "<pre>";
		// print_r($result);
		// echo "</pre>";
		// exit();
		return $result;
	}

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$Usuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	
	$json = new stdClass(); 
	$json->idu_generacion = 0;
	$json->facturas_traspasadas = 0;
	$json->facturas_pagadas = 0;
	$json->facturas_rechazadas = 0;
	$json->empleados_baja = 0;
	$datos = array();
	
	if($estado != 0)
	{

		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	
	try {		
		
		
//--GENERAR EMPLEADOS QUE POSIBLEMENTE SEAN BAJA
		if($iOpcion==0){
			
			$con2 = new OdbcConnection($CDB['conexion']);
			$con2->open();	
			$cmd2 = $con2->createCommand();			
			
			//--OBTENER EMPLEADOS QUE AL PARECER NO ESTAN DADOS DE BAJA Y SE VAN A TRASPASAR
			// echo ("{CALL fun_genera_empleados_revisar_baja($Usuario)}");
			// exit();
			$cmd2->setCommandText("{CALL fun_genera_empleados_revisar_baja($Usuario)}");
			$ds2 = $cmd2->executeDataSet();
			$con2->close();			
			
			//--
			$i=0;
			$arrXml = array();
			$xml = '<Root>';
			foreach ($ds2 as $fila)
			{
				$numemp=$fila['inumemp'];	
				//echo($numemp);
				$xml .= "
				<r
					a=\"$numemp\"
				>
				</r>";
				
				$i++;
				
				if ($i == 50) {					
					$xml = $xml.'</Root>' ;
					$arrXml[] = $xml;
					// echo ($xml);
					// echo('--AQUI VAN 50--');
					$xml = "";
					$xml = $xml.'<Root>' ;
					$i = 0;
				}			
			}
			
			//$xml = $xml.'</Root>' ;
			if ($i > 0) {
				$xml = $xml.'</Root>' ;
				$arrXml[] = $xml;
			}
			// echo ('xml='.$xml);
			// echo('---ULTIMO------');
			//exit();
			
//--VALIDAR EMPLEADOS DADOS DE BAJA
			if ($ds2 != null){
				//echo ('VALIDAR EMPLEADOS DE BAJA');
				$CDBSql = obtenConexion(BDSYSCOPPELPERSONALSQL);
				$estadoSql = $CDBSql['estado'];	
				$cadenaconexion_personal_sql = $CDBSql['conexion'];
				$mensajeSql = $CDBSql['mensaje'];	
				
				$conSql = new OdbcConnection($cadenaconexion_personal_sql);
				$conSql->open();
				$cmdSql = $conSql->createCommand();
				
				$xml="";
				//echo ("{CALL Proc_validar_empleados_cancelados '$xml'");
				$arrXml2 = array();
				
				for ($i = 0; $i < count($arrXml); $i++) {
					$xml=$arrXml[$i];
					$dsSql="";
					// echo ("{CALL Proc_validar_empleados_cancelados $i,'$xml'");
					//echo ("{CALL Proc_validar_empleados_cancelados $i");
					$cmdSql->setCommandText("{CALL Proc_validar_empleados_cancelados $i,'$xml', $Usuario}");
					$dsSql = $cmdSql->executeDataSet();
										
					$arrEmpSql = array();
					foreach ($dsSql as $value)
					{
						$numempSql=$value['numemp'];						
						$arrEmpSql[]=$numempSql;
					}				
				}	
				
				$xml2 = '<Root>';
				$b=0;
				for ($a = 0; $a < count($arrEmpSql); $a++) {
					$numempSql=$arrEmpSql[$a];
					$xml2 .= "
					<r>
						<e>$numempSql</e>
						<u>$Usuario</u>				
					</r>";	
					$b++;
					if ($b == 2) {					
						$xml2 = $xml2.'</Root>' ;
						$arrXml2[] = $xml2;
						
						$xml2 = "";
						$xml2 = $xml2.'<Root>' ;
						$b = 0;
					}			
					
				}
				$xml2 = $xml2.'</Root>' ;
				$arrXml2[] = $xml2;
				
				
				// echo ($xml2);
				// echo('---------');
				$conSql->close();
				//}
				
				// exit();
			
//--CONFIRMAR EMPLEADOS BAJA
				//echo('dsSql='.$dsSql.' xml2='.$xml2);
				//exit();
				//if ($xml2 !="" ){
					//echo ('CONFIRMAR BAJA');
					$con3 = new OdbcConnection($CDB['conexion']);
					$con3->open();	
					$cmd3 = $con3->createCommand();			
					
					$xml2="";
					 //echo ('cuantos='.count($arrXml2));
					//--GUARDAR EMPLEADOS QUE ESTAN DADOS DE BAJA EN POSTGRES			
					for ($i = 0; $i < count($arrXml2); $i++) {
						//echo ('i='.count($arrXml2));						
						$xml2=$arrXml2[$i];
						//echo ("{CALL fun_confirmar_empleados_baja($i, '$xml2',$Usuario)}");
						$cmd3->setCommandText("{CALL fun_confirmar_empleados_baja($i, '$xml2',$Usuario)}");
						$ds3= $cmd3->executeDataSet();
					}
					$con3->close();	
				//}
			}
			//exit();
		}
		
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT idu_generacion
			, facturas_traspasadas
			, facturas_rechazadas
			, empleados_baja
			, estatus
			, mensaje
		FROM fun_generar_pagos_colegiaturas($Usuario::integer)";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		
	    $ds = $cmd->executeDataSet();
		
		$json->idu_generacion = $ds[0]["idu_generacion"];
		$json->facturas_traspasadas = $ds[0]["facturas_traspasadas"];
		$json->facturas_pagadas = 0;
		$json->facturas_rechazadas = $ds[0]["facturas_rechazadas"];
		$json->empleados_baja = $ds[0]["empleados_baja"];
		$json->estatus = $ds[0]["estatus"];
		$json->mensaje = $ds[0]["mensaje"];
		
		if ($json->estatus < 0) {

			try {
				echo json_encode($json);
				exit();
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
		}		
		
		// Obtener listado de pagos (mov_generacion_pagos_colegiaturas)
		$cmd=$con->createCommand();
		$query="SELECT * FROM fun_obtener_generacion_pagos_colegiaturas()";
		$cmd->setCommandText($query);
		$ds2 = $cmd->executeDataSet();
		// $con->close();
		$tabla = '';
		if($ds2 != null){
			$ii=0;
			foreach($ds2 as $fila){
				// $tabla+='<r e="'.$fila['idu_empleado'].'"';
				$tabla=$tabla.'<r e="'.$fila['idu_empleado'].'" i="'.$fila['importe_pagado'].'"></r>';
			}
		// echo "<pre>";
		// print_r($tabla);
		// echo "</pre>";
		// exit();
		}
		
		// idu_empleado, importe_pagado
		// Generar Xml con la siguiente estructura
		
		$xml = '<Root>'.$tabla.'</Root>';
		// echo "<pre>";
		// print_r("VALOR DEL XML PARA ENVIAR = ".$xml);
		// echo "</pre>";
		// exit();
		// '<Root>
					// <r e="95194185" i="125000"></r>
					// <r e="91729815" i="10000"></r>
					// <r e="91815381" i="68100"></r>
					// <r e="90874897" i="25000"></r>
				// </Root>';
		$param = array("usuario" => $Usuario
					, "datosXml" => $xml);

		// Obtener URL de la variable URL_SERVICIO_COLEGIATURAS para conformar la URL del servicio
		try{
			$sNomParametro = 'URL_SERVICIO_COLEGIATURAS';
			$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
			$ds = $cmd->executeDataSet();
			$con->close();
			$estado = 0;

			$valorParametro=$ds[0][2];
		}catch(Exception $ex){
			
		}
		$url = "$valorParametro/isr/actualizar";
		// $url = "http://10.44.15.183:8080/WsColegiaturas/rest/isr/actualizar";
		
		// Actualizar el ISR
		$result = actualizarISR("POST", $url, $param);
		
		// echo "<pre>";
		// print_r($result);
		// echo "</pre>";
		// exit();
		
		$con->close();
	} catch(exception $ex) {
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
		$estado=-2;
	}

	try {	
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>