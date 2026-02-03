<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	// $rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	// $page = isset($_GET['page']) ? $_GET['page'] : 1;
	// $orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'fechaFactura';
	// $ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	//$columns = isset($_GET['columns']) ? $_GET['columns'] : '';	
		
	$iFactura = isset($_GET['iFactura']) ? $_GET['iFactura'] : 0;	
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	
	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();		
		
		// echo ("SELECT * FROM FUN_OBTENER_FACTURAS_PARA_AJUSTES ($page, $rowsperpage, $iCapturo, $iNumEmp, '$cFolio')");
		// exit();
		$query = "SELECT * FROM fun_obtener_ajustes_por_factura ($iFactura)";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		// $respuesta->page = $ds[0]['page'];
		// $respuesta->total = $ds[0]['pages'];
		// $respuesta->records = $ds[0]['records'];
		$id=0;
	
		foreach($ds as $fila) {
				
			//Usuario Traspaso
			if ($fila['iusuariotraspaso']==0){
				$UsuarioTraspaso='';
			}else{
				$UsuarioTraspaso=$fila['iusuariotraspaso'].' '.$fila['snomusuariotraspaso'];
			}
			
			//Fecha Trapaso
			if ($fila['dfechatraspaso']=='01-01-1900'){
				$FechaTraspaso='';
			}else{
				$FechaTraspaso=$fila['dfechatraspaso'];
			}
			
			//Usuario Cierre
			if ($fila['iusuariocierre']==0){
				$UsuarioCierre='';
			}else{
				$UsuarioCierre=$fila['iusuariocierre'].' '.$fila['snomusuariocierre'];
			}
			
			//Fecha Cierre
			if ($fila['dfechacierre']=='01-01-1900'){
				$FechaCierre='';
			}else{
				$FechaCierre=$fila['dfechacierre'];
			}
			
			$respuesta->rows[$id]['cell']=
			array(
				$fila['iidajuste']
				,$fila['iidfactura']
				,'$'.number_format($fila['nimportefactura'], 2 ,"." ,"," )
				,'$'.number_format($fila['nimportepagado'] , 2 ,"." ,"," )
				,$fila['ipctajuste'].' %'
				,'$'.number_format($fila['nimporteajuste'] , 2 ,"." ,"," )
				,$fila['sobservaciones']
				//,$fila['iusuariotraspaso'].' '.$fila['snomusuariotraspaso']
				,$UsuarioTraspaso
				,$FechaTraspaso				
				,$fila['iusuarioregistro'].' '.$fila['snomusuarioregistro']
				,$fila['dfecharegistro']
				,$UsuarioCierre 
				,$FechaCierre 
			);
			$id++;
		}		
		echo json_encode($respuesta);
	}
	catch (JsonException $ex) {
		echo "Error: no se pudo obtener carga de Json";
	} 
	catch (Exception $ex) {
		echo "Error: al consultar fun_obtener_ajustes_por_factura";
	}
 ?>