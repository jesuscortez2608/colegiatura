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
	//$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
	
	$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
    $estado = $CDB['estado'];   
    $cadenaconexion = $CDB['conexion'];
    $mensaje = $CDB['mensaje']; 
    $json = new stdClass();

	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] :0;
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
		
	if ($iEmpleado==0)
	{
		$iEmpleado = $iCapturo;
	}
	
	// $estado = $CDB['estado'];	
	// $cadenaconexion_personal_sql = $CDB['conexion'];
	// $mensaje = $CDB['mensaje'];	
	$term =(isset($_POST['term']) ? $_POST['term'] : 'yui');
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
	
		try {
			echo json_encode($json);
		} catch (JsonException $e) {
			echo 'Error en la codificación JSON: ';
		}
		
		exit;
	}
	//-------------------------------------------------------------------------

	//declaro el arreglo a regresar en el JSon 
	$respuesta = new stdClass();
	
	$estado = 0;
	$ds=""; //guardo los datos en la consulta del procedimiento
	//$fechaacomparar = $_POST['fechaacomparar'];  
		
	
	//$con = new OdbcConnection($cadenaconexion_personal_sql);
	// $con = new OdbcConnection($CDB['conexion']);
	// $con->open();
	// $cmd = $con->createCommand();
	// print_r();
		
	try
	{
		$con = new OdbcConnection($cadenaconexion);
        $con->open();
        $cmd = $con->createCommand();
		
		$cmd->setCommandText("{CALL proc_obtener_datos_colaborador_colegiaturas ($iEmpleado)}");
		$ds = $cmd->executeDataSet();
		$con->close();
		$mensaje="Ok_consulta_general";
		$json->datos = array();
		// if ($ds[0]==null) {
			// $ds[0]=0;
		//}
		
		
		if ($ds[0]!=null)
		{
			
			$arr = array();
			
			$arr[] = array(
				'numemp' => $ds[0]['numemp'],
				'nombre' =>trim($ds[0]['nombre']),
				'appat' =>trim($ds[0]['appat']),
				'apmat' =>trim($ds[0]['apmat']),
				'centro' =>$ds[0]['centro'],
				'nombrecentro' =>trim($ds[0]['nombrecentro']),
				'puesto' =>$ds[0]['puesto'],
				'nombrepuesto' =>trim($ds[0]['nombrepuesto']),
				'seccion' =>$ds[0]['seccion'],
				'nombreseccion' =>trim($ds[0]['nombreseccion']),
				'fec_alta' =>$ds[0]['fec_alta'],
				'cancelado' =>$ds[0]['cancelado'],
				'sueldo' =>number_format(($ds[0]['sueldo']/100),2),
				'rutapago' =>$ds[0]['rutapago'],
				'nombrerutapago' =>$ds[0]['nombrerutapago'],
				'antiguedad' =>$ds[0]['antiguedad'],
				'topeproporcion' =>number_format(($ds[0]['topeproporcion']/100),2),
				'numerotarjeta'=>$ds[0]['numerotarjeta'],
				'rfc'=>$ds[0]['rfc'],
				'empresa'=>$ds[0]['empresa']
			);
		}
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
		$estado=-2;
	}
	$json->datos=$arr;
	
	try {
		echo json_encode($arr);
	} catch (JsonException $e) {
		echo 'Error en la codificación JSON: ';
	}
?>