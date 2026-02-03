<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = isset($_POST['session_name1']) ?  $_POST['session_name1'] : "Session-Colegiaturas";
	
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/data/class_enletras.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    //-------------------------------------------------------------------------
	$iFactura = (isset($_POST['hid_factura'])?$_POST['hid_factura']:0);
	$iEmpleado = (isset($_POST['iEmpleado'])?$_POST['iEmpleado']:0);
	$cComentario = (isset($_POST['txt_mensaje'])?$_POST['txt_mensaje']:'');
	//$cComentario = encodeToIso($cComentario);
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$nomColaborador = 	isset($_SESSION[$Session]["USUARIO"]['nom_empleado'])?$_SESSION[$Session]['USUARIO']['nom_empleado']:'';
	$apePaColaborador = isset($_SESSION[$Session]["USUARIO"]['nom_apellidopaterno'])?$_SESSION[$Session]['USUARIO']['nom_apellidopaterno']:'';
	$apeMaColaborador = isset($_SESSION[$Session]["USUARIO"]['nom_apellidomaterno'])?$_SESSION[$Session]['USUARIO']['nom_apellidomaterno']:'';
	$nomCompletoColaborador = $nomColaborador . ' ' . $apePaColaborador . ' ' . $apeMaColaborador;
	$json = new stdClass(); 
	$cComentario = encodeToIso($cComentario);
	$json->estado = 0;
	$json->mensaje = "OK";
	
 	$json = new stdClass();
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
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
		$cmd2 = $con->createCommand();
		// print_r("SELECT * from  fun_grabar_blog_aclaraciones($iFactura,$iUsuario,$iEmpleado,'$cComentario')");
		// exit();	
		$cmd->setCommandText("SELECT * from  fun_grabar_blog_aclaraciones($iFactura,$iUsuario,$iEmpleado,'$cComentario')");
		$cmd2->setCommandText("SELECT * FROM fun_grabar_bit_estatus_factura_colegiaturas($iFactura, $iEmpleado, 4, $iUsuario, '$nomCompletoColaborador', '$cComentario')");
		$ds = $cmd->executeDataSet();
		$ds2 = $cmd2->executeDataSet();
		$con->close();
		
		$estado = 1;
		$mensaje="Comentario enviado";
		
	}catch(JsonException $ex){
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
	}catch(JsonException $ex){
	$mensaje="Error al cargar Json";
	
	}
 ?>