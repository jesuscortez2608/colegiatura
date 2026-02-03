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
	$iEstatus = isset($_POST['iEstatus']) ? $_POST['iEstatus'] : 0;
    $iDeducion = isset($_POST['iDeducion']) ? $_POST['iDeducion'] : 0;
	$iRechazo = isset($_POST['iRechazo']) ? $_POST['iRechazo'] : 0;
	$iRevision = isset($_POST['iRevision']) ? $_POST['iRevision'] : 0;
	//$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
    $cComentario= isset($_POST['cComentario']) ? $_POST['cComentario'] : '';
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$nomColaborador = 	isset($_SESSION[$Session]["USUARIO"]['nom_empleado'])?$_SESSION[$Session]['USUARIO']['nom_empleado']:'';
	$apePaColaborador = isset($_SESSION[$Session]["USUARIO"]['nom_apellidopaterno'])?$_SESSION[$Session]['USUARIO']['nom_apellidopaterno']:'';
	$apeMaColaborador = isset($_SESSION[$Session]["USUARIO"]['nom_apellidomaterno'])?$_SESSION[$Session]['USUARIO']['nom_apellidomaterno']:'';
	$nomCompletoColaborador = $nomColaborador . ' ' . $apePaColaborador . ' ' . $apeMaColaborador;
	$json_data= (isset($_POST['json']))? $_POST['json'] : '';
	$numEmp = isset($_POST['numEmp']) ? $_POST['numEmp'] : 0;
	
	try{
	$json_data = json_decode(str_replace('\\', '',$json_data));
	}catch(JsonException $ex)
	{
		$mensaje="Error al cargar Json";	
	}
	//echo('json_data='.$json_data);
	//exit();
	$json = new stdClass(); 
	$datos = array();	
	
	//$cComentario = utf8_decode($cComentario);
	$cComentario = mb_convert_encoding($cComentario, 'UTF-8', 'ISO-8859-1');
	
	
	$arr_grid = array();
	foreach ($json_data as $da)
	{
			$arr_grid[] = array(
			'factura' => trim($da->factura),
			//echo ('factura='.trim($da->factura));			
			);
	}
	
	//exit();
	if($estado != 0)
	{
		try{
		$json->mensaje=$mensaje;
		//$json->estado=utf8_decode( $estado);
		$json->estado=mb_convert_encoding($estado, 'UTF-8', 'ISO-8859-1');
		echo json_encode($json);
		exit;
		}
		catch(JsonException $ex){
			$mensaje="";
			$mensaje = $ex->getMessage();
		}
	}
	
	$sSql = "";
	$sSql2 = '';
	$iEstatusBit = $iEstatus + 1;
	
	if ($iEstatus ==1 ) //Autorizado	
	{
		//$sSql="(SELECT * from fun_grabar_estatus_aceptar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo))";
		$mensaje='Factura(s) autorizada correctamente';
		// echo ("SELECT * from fun_grabar_estatus_aceptar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo)");
		// exit();
		foreach ($arr_grid as $val)	{
			$iFactura = $val['factura'];
			// echo("(SELECT * from fun_grabar_estatus_aceptar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo); ");
			// exit();
			$sSql.="(SELECT * from fun_grabar_estatus_aceptar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo)); ";	
			$sSql2.="(SELECT * from fun_grabar_bit_estatus_factura_colegiaturas($iFactura, $numEmp, $iEstatusBit, $iCapturo, '$nomCompletoColaborador', ''));";
					
		}
		
	}
	else if ($iEstatus ==2 ) //Rechazado	
	{
		//$sSql="(SELECT * from fun_grabar_estatus_rechazar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo, ' $cComentario'))";
		$mensaje='Factura(s) rechazada';
		foreach ($arr_grid as $val)	{
			$iFactura = $val['factura'];
			$sSql.="(SELECT * from fun_grabar_estatus_rechazar_factura($iFactura, $iRechazo, $iDeducion, $iCapturo, '$cComentario')); ";
			$sSql2.="(SELECT * from fun_grabar_bit_estatus_factura_colegiaturas($iFactura, $numEmp, $iEstatusBit, $iCapturo, '$nomCompletoColaborador', '$iRechazo'));";
		}
	}
	else if ($iEstatus == 4 )//Revision
	{
		$mensaje='Factura(s) en Revision';
		foreach($arr_grid as $val){
			$iFactura=$val['factura'];
			// echo("(SELECT * from fun_grabar_estatus_revisar_factura($iFactura, $iDeducion, $iCapturo, '$cComentario', $iRevision)); ");
			// exit();
			$sSql.="(SELECT * from fun_grabar_estatus_revisar_factura($iFactura, $iDeducion, $iCapturo, '$cComentario', $iRevision)); ";
		}
	}
	else//Aclaracion
	{
		//$sSql="(SELECT * from fun_grabar_estatus_aclarar_factura($iFactura, $iCapturo))";
		$mensaje='Factura(s) enviada a aclaración';
		foreach ($arr_grid as $val)	{
			$iFactura = $val['factura'];
			$sSql.="(SELECT * from fun_grabar_estatus_aclarar_factura($iFactura, $iCapturo)); ";
			$sSql2.="(SELECT * from fun_grabar_bit_estatus_factura_colegiaturas($iFactura, $numEmp, $iEstatusBit, $iCapturo, '$nomCompletoColaborador', ''));";

		}
	}
	
	// echo $sSql;
	// exit();
	
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		$cmd2 = $con->createCommand();
		// print_r($sSql);
		// exit();
		$cmd->setCommandText($sSql);
		$cmd2->setCommandText($sSql2);
	
		$ds = $cmd->executeDataSet();
		$ds2 = $cmd2->executeDataSet();
		$con->close();
		$estado= $ds[0][0];
		//$mensaje="OK";
	}
	catch(exception $ex)
	{
		$mensaje="";
		//$mensaje = $ex->getMessage();
		$mensaje = "Ocurrio error en conexion a base de datos";
		$estado=-2;
	}
	//$json->estado = utf8_encode($estado);
	try{
	$json->estado = mb_convert_encoding($estado, 'UTF-8', 'ISO-8859-1');
	$json->mensaje = $mensaje;
	
	echo json_encode($json);
	}
	catch(JsonException $ex)
	{
		$mensaje="Error al cargar Json";	
	}
?>