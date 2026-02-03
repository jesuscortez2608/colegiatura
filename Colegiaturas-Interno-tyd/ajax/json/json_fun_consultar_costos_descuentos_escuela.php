<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	$iFactura = isset($_GET['idFactura']) ? $_GET['idFactura'] : 0;
	$OpcCiclo = isset($_GET['iCicloEscolar']) ? $_GET['iCicloEscolar'] : '0';
	$Escolaridades = isset($_GET['sEscolaridades']) ? $_GET['sEscolaridades'] : '';
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 2;
	
	$estado = $CDB['estado'];
	$mensaje = $CDB['mensaje'];
	$json = new stdClass();
	if($estado != 0){
		$json->estado = $estado;
	} else {
		try {
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			if ($Escolaridades == '0' || $Escolaridades == 0){
				$Escolaridades = '';
			}
			// echo "<pre>";
			// print_r($Escolaridades);
			// echo "</pre>";
			// exit();
			$query = "SELECT * 
						FROM fun_consultar_costos_descuentos_escuela($iFactura::INTEGER, $OpcCiclo::INTEGER, '$Escolaridades'::VARCHAR, $iOpcion::INTEGER)";
						
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();

			$i=0;
			foreach ($ds as $fila) {
				if($iOpcion == 1){
					if($fila['sfecha_rev'] == '01/01/1900' || $fila['sfecha_rev'] == '01-01-1900'){
						$FechaRev = '';
					}else{
						$FechaRev = $fila['sfecha_rev'];
					}
					$json->rows[$i]['cell']=array(
						trim(encodeToUtf8($fila['snom_escuela']))
						,trim(encodeToUtf8($fila['sciclo_escolar']))
						, trim(encodeToUtf8($fila['snom_escolaridad']))
						, trim(encodeToUtf8($fila['snom_carrera']))
						, trim(encodeToUtf8($fila['stpp']))
						, number_format($fila['iimporte'],2)
						, trim(encodeToUtf8($fila['smotivo_descto']))
						, $FechaRev
					);
					$i++;
				}else{
					if($fila['sfecha_rev'] == '01/01/1900' || $fila['sfecha_rev'] == '01-01-1900'){
						$FechaRev = '';
					}else{
						$FechaRev = $fila['sfecha_rev'];
					}
					$json->rows[$i]['cell'] = array(
						 trim(encodeToUtf8($fila['snom_escuela']))
						,trim(encodeToUtf8($fila['sciclo_escolar'])) 
						, trim(encodeToUtf8($fila['snom_escolaridad']))
						, trim(encodeToUtf8($fila['snom_carrera']))
						, trim(encodeToUtf8($fila['stpp']))
						, $fila['iprc_descuento']
						, trim(encodeToUtf8($fila['smotivo_descto']))
						, $FechaRev
					);
					$i++;
				}
			}
		} catch (Exception $ex) {
			//$json->mensaje = $ex->getMessage();
			$json->mensaje = "Error al conectar a la Base de Datos";
			$json->estado=-2;
		}
	}
	try{
		echo json_encode($json);
	   }catch(JsonException $ex){
		   $mensaje="";
		   $mensaje = $ex->getMessage();
		   $estado=-2;
	   }

	
	
	
	
	
?>