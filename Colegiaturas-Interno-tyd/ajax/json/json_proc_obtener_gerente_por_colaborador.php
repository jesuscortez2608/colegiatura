<?php
	//ini_set('display_errors', 1); // Muestra los errores en la salida
	//ini_set('display_startup_errors', 1); // Muestra errores de inicio
	//error_reporting(E_ALL); // Reporta todos los errores
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	
	
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	
    $CDB = obtenConexion(BDPERSONALSQLSERVER);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $respuesta = new stdClass();
	$sUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$iUsuario = filter_var($sUsuario, FILTER_VALIDATE_INT);
    if($estado != 0)
    {
    	$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALSQLSERVER ver -> log".date('d-m-Y')."_json_proc_ayudacentros.txt";
		
    }
    //-------------------------------------------------------------------------
	else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();		
			
	        $cmd->setCommandText("{CALL proc_obtener_gerente_por_colaborador $iUsuario}");
			// echo "<pre>";
			// print_r("{CALL  proc_ayudacentros_grid $iUsuario, $iCentro,'$cNomCentro',$iNumCiudad,$iNumRegion,$iRowsPerPage,$iCurrentPage ,'idu_centro','asc','*'}");
			// echo "</pre>";
			// exit();
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			
			$respuesta->numemp = $ds[0]['numemp'];
			$respuesta->nombre = $ds[0]['nombre'];
			
	    }
	    catch(exception $ex)
	    {
	        $json->mensaje = "Ocurrió un error al conectar a la base de datos.";
	        $json->estado=-2;
	    }
	}
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>