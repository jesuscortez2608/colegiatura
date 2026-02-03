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
	
	$nOpcion = isset($_POST['nOpcion']) ? $_POST['nOpcion'] : 1;
	$cRFCescuela = isset($_POST['cRFCescuela']) ? $_POST['cRFCescuela'] : '';
	$cNomEscuela = isset($_POST['cNomEscuela']) ? $_POST['cNomEscuela'] : '';
	$cNomEscuela=mb_convert_encoding($cNomEscuela, 'UTF-8', 'ISO-8859-1');
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
	
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
			$mensaje = "no se pudo realizar conexión en línea 35";
			$estado=-2;
		}

	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// if ($nOpcion==3)
		// {
			
		// }
		// echo("select idu_escuela, nom_escuela, pdf from fun_consultar_escuela_rfc($nOpcion,'$cRFCescuela', '$cNomEscuela', $iUsuario)");
		// exit();
		
		$cmd->setCommandText("select idu_escuela, nom_escuela, pdf from fun_consultar_escuela_rfc($nOpcion,'$cRFCescuela', '$cNomEscuela', $iUsuario)");

		$ds = $cmd->executeDataSet();
		
		//$mensaje = $ds[0][0];
		
		//$estado = $ds[0][0];
		$json->datos = array();
		
		$arr = array();
		$id=0;
		if( $ds != null)
		{
			$estado=1;
			foreach($ds as $value) {
				// if($value['idu_escuela']!=0)
					$arr[] = array(
						// 'value' => $value['idu_escuela'], 'nombre' => (utf8_encode($value['nom_escuela'])), 'pdf' => ($value['pdf'])
						'value' => $value['idu_escuela'], 'nombre' => (encodeToUtf8($value['nom_escuela'])), 'pdf' => ($value['pdf'])
					);
					$id++;
				// }	
			}
		}else{
			$estado=-1;
		}	
		$con->close();
		
	}
	catch(exception $ex)
	{
		$mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 93";
		$estado=-2;
	}
?>