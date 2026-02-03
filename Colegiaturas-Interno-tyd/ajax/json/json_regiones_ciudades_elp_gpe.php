<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	//-------------------------------------------------------------------------
	//RECOJO LA CADENA DE CONEXION   utilidadesweb/librerias/cnfg/conexiones.php
	$CDB = obtenConexion(BDPERSONALSQLSERVER);
	
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] :0;
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	$iNumEmp = isset($_POST['iNumEmp']) ? $_POST['iNumEmp'] :0;
	$estado = $CDB['estado'];	
	$cadenaconexion_personal_sql = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];	
	
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
	//-------------------------------------------------------------------------

	//declaro el arreglo a regresar en el JSon 
	$respuesta = new stdClass();
	
	$estado = 0;
	$ds=""; //guardo los datos en la consulta del procedimiento
	
	$con = new OdbcConnection($cadenaconexion_personal_sql);
	$con->open();
	$cmd = $con->createCommand();
	
	try
	{
		if($iOpcion==1)//region
		{
			$sql="{CALL proc_ayudaregiones_grid  $iUsuario, 0, '', -1, -1, 'idu_region', 'asc', '*'}";
		}
		else if($iOpcion==2)//Ciudades
		{
			$sql="{CALL proc_ayudaciudades_grid $iUsuario, 0, '', 0, -1, -1, 'idu_region, idu_ciudad', 'asc', '*'}";
		}
		else //empleados
		{
			$sql="{CALL proc_ayudaempleados_grid $iUsuario, 1, $iNumEmp, '', '', '', -1, -1, 'idu_empleado', 'asc', '*'}";
		}
			// echo "<pre>";
			// print_r($sql);
			// echo "</pre>";
			// exit();
		$cmd->setCommandText($sql);
	    $ds = $cmd->executeDataSet();
		$con->close();
		$mensaje="Ok";
		//$json->datos = array();
		///print_r('res '.$ds[0]['idu_region']);
		if($iOpcion==1)//region
		{
			
			$arr="";
			foreach ($ds as $fila)
			{	
				$arr=$arr.$fila['idu_region'].',';
			}
		}
		else if($iOpcion==2)//Ciudades
		{
			$arr="";
			foreach ($ds as $fila)
			{
				$arr=$arr.$fila['idu_ciudad'].',';
			}
		}
		else //empleados
		{
			foreach ($ds as $fila)
			{
				$arr=$fila['idu_empleado'] . ',';
			}
		}
		
		$arr = substr($arr,0, strlen($arr) - 1);
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = $ex->getMessage();
		$estado=-2;
	}
	//$json->datos=$arr;

	try {
		echo json_encode($arr);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

?>