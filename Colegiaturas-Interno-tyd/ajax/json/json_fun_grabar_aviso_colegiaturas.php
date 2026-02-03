<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//-------------------------------------------------------------------------
	
	$json = new stdClass();
	$NumuEmp = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$id_aviso = isset($_POST['iAviso']) ? $_POST['iAviso'] : 0;
	$DesAviso = isset($_POST['cMensaje']) ? $_POST['cMensaje'] : '';
	$Fec_ini = isset($_POST['Fec_ini']) ? $_POST['Fec_ini'] : '19000101';
	$Fec_fin = isset($_POST['Fec_fin']) ? $_POST['Fec_fin'] : '19000101';
	$Indefinido = isset($_POST['indefinido']) ? $_POST['indefinido'] : 0;
	$Opcion = isset($_POST['Opcion']) ? $_POST['Opcion'] : 0;
	$DesAviso = encodeToIso($DesAviso);
	$estado=0;
	$mensaje='OK';
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}

		$ds=""; //guardo los datos en la consulta del procedimiento
			
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo("{CALL fun_grabar_aviso_colegiaturas($id_aviso,'$DesAviso','$Fec_ini','$Fec_fin',$Indefinido,$Opcion,$NumuEmp)}");
		// exit();
		
		$cmd->setCommandText("{CALL fun_grabar_aviso_colegiaturas($id_aviso,'$DesAviso','$Fec_ini','$Fec_fin',$Indefinido,$Opcion,$NumuEmp)}");	
							
		$ds = $cmd->executeDataSet();
		
		$estado = $ds[0]['estado'];
		$mensaje = $ds[0]['mensaje'];
		$con->close();
	}
	catch(exception $ex)
	{
	    $mensaje = $ex->getMessage();
		$estado = -1;
	}
	
	
	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo (json_encode($json));
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>