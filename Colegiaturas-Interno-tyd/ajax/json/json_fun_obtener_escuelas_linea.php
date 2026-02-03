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
			
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		try{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		echo json_encode($json);
		exit;
		}
		catch(JsonException $ex){
			$mensaje = "error al cargar el Json";
			$estado = "-2";
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo ("SELECT iidu_escuela, snom_escuela, srfc FROM fun_obtener_escuelas_linea()");
		// exit();
				
		$cmd->setCommandText("SELECT iidu_escuela, snom_escuela, srfc FROM fun_obtener_escuelas_linea()");
		
		$ds = $cmd->executeDataSet();
		$con->close();
		//$mensaje = $ds[0][0];
		
		//$estado = $ds[0][0];
		$json->datos = array();
		
		$arr = array();
		$id=0;
		if( $ds != null)
		{
			$estado=0;
			foreach($ds as $value) {
				// if($value['idu_escuela']!=0)
				$arr[] = array(
					'value' => $value['iidu_escuela'], 'nombre' => (mb_convert_encoding($value['snom_escuela'], "UTF-8", mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))), 'rfc' => ($value['srfc'])
				);
				$id++;
				// }	
			}
		}	
		$con->close();
		
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "error al cargar Json";
		$estado=-2;
	}
?>