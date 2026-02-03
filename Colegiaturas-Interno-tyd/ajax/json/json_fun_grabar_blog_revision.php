<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = isset($_POST['session_name1_csc']) ?  $_POST['session_name1_csc'] : "Session-Colegiaturas";
	
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/data/class_enletras.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    //-------------------------------------------------------------------------
	$iFactura = (isset($_POST['hid_factura_csc'])?$_POST['hid_factura_csc']:0);
	$iEmpleado = (isset($_POST['iEmpleado'])?$_POST['iEmpleado']:0);
	$cComentario = (isset($_POST['txt_mensaje_csc'])?$_POST['txt_mensaje_csc']:'');
	//$cComentario = encodeToIso($cComentario);
    $iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$json = new stdClass();
	$cComentario = encodeToIso($cComentario);
	$json->estado = 0;
	$json->mensaje = "OK";
	
 	

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
			$mensaje="Error al cargar Json";	
			}
	}
	try
	{
		
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT * FROM FUN_GRABAR_BLOG_REVISION($iFactura,$iUsuario,$iEmpleado,'$cComentario')");
		// exit();	
		$cmd->setCommandText("SELECT * from  FUN_GRABAR_BLOG_REVISION($iFactura,$iUsuario,$iEmpleado,'$cComentario')");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = 1;
		$mensaje="Comentario enviado";
		
	}
	catch(JsonException $ex)
	{
		$mensaje="Error al cargar Json";	
	}
	catch(exception $ex)
	{
		$mensaje="";
		//$mensaje = $ex->getMessage();
		$mensaje = "Error a conectar a Base de Datos";
		$estado=-2;
	
	}
	try{
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
		}
		catch(JsonException $ex)
		{
		$mensaje="";
		$mensaje = $ex->getMessage();
		}
 ?>