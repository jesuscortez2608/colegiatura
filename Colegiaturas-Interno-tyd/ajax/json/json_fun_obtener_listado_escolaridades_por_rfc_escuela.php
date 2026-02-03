<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; 
	// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	
	//$nOpcion = isset($_POST['nOpcion']) ? $_POST['nOpcion'] : 1;
	// $cRFCescuela = encodeToIso($_POST['cRFCescuela']) ? $_POST['cRFCescuela'] : '';
	// $iestado = encodeToIso($_POST['iestado']) ? $_POST['iestado'] : 0;
	// $imunicipio = encodeToIso($_POST['imunicipio']) ? $_POST['imunicipio'] : '';
	// $ilocalidad = encodeToIso($_POST['ilocalidad']) ? $_POST['ilocalidad'] : '';
	// $sNombre = encodeToIso($_POST['sNombre']) ? $_POST['sNombre'] : '';
	
	$cRFCescuela = ($_POST['cRFCescuela']) ? $_POST['cRFCescuela'] : '';
	$iestado = ($_POST['iestado']) ? $_POST['iestado'] : 0;
	$imunicipio = ($_POST['imunicipio']) ? $_POST['imunicipio'] : '';
	$ilocalidad = ($_POST['ilocalidad']) ? $_POST['ilocalidad'] : '';
	$sNombre = ($_POST['sNombre']) ? $_POST['sNombre'] : '';
	
	//$sNombre = str_replace('+','',$sNombre);
	
	$json = new stdClass(); 
	
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
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		//echo ("SELECT iescolaridad, sescolaridad, iopc_carrera, iescuela,iestatus  FROM fun_obtener_listado_escolaridades_por_rfc_escuela('$cRFCescuela',$iestado,$imunicipio,$ilocalidad,'$sNombre')");
		//exit();
			$sNombre = json_decode($sNombre);
		
		$query = "SELECT iescolaridad, sescolaridad, iopc_carrera, iescuela,iestatus FROM fun_obtener_listado_escolaridades_por_rfc_escuela('$cRFCescuela',$iestado,$imunicipio,$ilocalidad,'$sNombre')";
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
// var_dump($ds);
// exit();

		$json->datos = array();
		
		
		$arr = array();
		$id=0;
		
		if( $ds != null)
		{
			//$estado=0;
			$estado=$ds[0]['iestatus'];
			// echo ('estado='.$estado);
			// exit();
			
			$ii = 0;			

			foreach($ds as $value) {
				// if($value['idu_escuela']!=0)
					//print_r($value);
					$arr[] = array(
						'value' => $value['iescolaridad'], 
						'sescolaridad' => $value['sescolaridad'],
						'opc_carrera' => $value['iopc_carrera'] ,
						'iescuela' => $value['iescuela'] ,						
					);
					$id++;
				// }	
			}

			// print_r($arr);
			// exit();
		}else{
			$estado=2; //no trae datos
		}
		$con->close();
		
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = $ex->getMessage();
		$estado=-2;
	}
		
	try {
		$json->estado = $estado;
		$json->datos=$arr;
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
?>