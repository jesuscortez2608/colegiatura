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
	
	//$nOpcion = isset($_POST['nOpcion']) ? $_POST['nOpcion'] : 1;
	$cRFCescuela = isset($_POST['cRFCescuela']) ? $_POST['cRFCescuela'] : '';
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : '';
	//$cNomEscuela = isset($_POST['cNomEscuela']) ? $_POST['cNomEscuela'] : '';
	//$cNomEscuela=utf8_decode($cNomEscuela);
	
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
				
		$cmd->setCommandText("SELECT idescuela,replace(escuela,'Ó','[123]') as escuela, iestado, estado, imunicipio, municipio, ilocalidad, localidad  FROM fun_consultar_escuelas_distintas_por_rfc('$cRFCescuela',$iEscuela)");
		 //print_r("SELECT escuela, iestado, estado, imunicipio, municipio, ilocalidad, localidad  FROM fun_consultar_escuelas_distintas_por_rfc('$cRFCescuela', $iEscuela)");	
		 //exit();
		$ds = $cmd->executeDataSet();
		
		//$mensaje = $ds[0][0];
		
		//$estado = $ds[0][0];
		$json->datos = array();
		
		
		$arr = array();
		$id=0;
		// echo('valor='.$ds[0][0]);
		// exit();
		
		
		
		
		if( $ds != null)
		{
			$estado=1;
			
			$ii = 0;
			/*foreach ($ds as $fila)
			{
				$json->datos[$ii] = new stdClass();
				$json->datos[$ii]->value = (isset($fila['idescuela']))?$fila['idescuela']:'';
				$json->datos[$ii]->nombre = (utf8_encode($value['escuela'])).' | '.(utf8_encode($value['estado'])).' | '.(utf8_encode($value['municipio'])).' | '.(utf8_encode($value['localidad']));
				$json->datos[$ii]->iestado = trim(utf8_encode($fila['iestado']));
				$json->datos[$ii]->imunicipio = trim(utf8_encode($fila['imunicipio']));
				$json->datos[$ii]->ilocalidad = trim(utf8_encode($fila['ilocalidad']));				
				$ii++;
			}*/
			
			foreach($ds as $value) {
				// if($value['idu_escuela']!=0)
					//print_r($value);					

					$arr[] = array(
						'value' => $value['idescuela'], 
						'nombre' => $value['escuela'].' | '.$value['estado'].' | '.$value['municipio'].' | '.$value['localidad'],
						//'nombre' => $value['escuela'],
						'escuela' => $value['escuela'],
						'iestado' => $value['iestado'] ,
						'imunicipio' => $value['imunicipio'] ,
						'ilocalidad' => $value['ilocalidad'] ,
						
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