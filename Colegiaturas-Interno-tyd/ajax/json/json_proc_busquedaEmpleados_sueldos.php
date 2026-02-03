<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	$iEmpleado = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$nombre = isset($_GET['nombre']) ? $_GET['nombre'] : '';
	$apepat = isset($_GET['apepat']) ? $_GET['apepat'] : '';
	$apemat = isset($_GET['apemat']) ? $_GET['apemat'] : '';
	$Mostrarbaja = isset($_GET['Mostrarbaja']) ? $_GET['Mostrarbaja'] : '0';
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$respuesta = new stdClass();
	
	try
	{
		$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
		$estado = $CDB['estado'];	
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
		
		
		if($estado != 0)
		{
			throw new Exception($mensaje);
		}
		
		
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		$sql="{CALL proc_ayudaempleados_grid $iEmpleado, $Mostrarbaja, 0, '$apepat', '$apemat', '$nombre', -1, -1, 'ape_paterno', 'asc', '*'}";
		// echo "<pre>";
		// print_r($sql);
		// echo "</pre>";
		// exit();
		//$sql="{CALL PROC_BUSQUEDAEMPLEADOS_SUELDOS ('$NOMBRE', '$APELLIDOPATERNO', '$APELLIDOMATERNO', 0, 1)}";
	// print_r($sql);
		$cmd->setCommandText($sql);
	    $ds = $cmd->executeDataSet();
		//$_SESSION[$Session]["imprimirjesus"]=$ds;
		$con->close();
		$i=0;

		
		foreach ($ds as $fila)
		{			
			$respuesta->rows[$i]['cell']=array(
				trim($fila['idu_empleado']),
				trim($fila['nombre']),
				trim($fila['ape_paterno']),
				trim($fila['ape_materno']),
				$fila['idu_centro'],
				trim($fila['nom_centro']),				
				$fila['idu_puesto'],
				$fila['nom_puesto']
			);			
			$i++;							
		}	
		$estado = 0;	
		$mensaje="Ok";		
	}
	
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}	
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>