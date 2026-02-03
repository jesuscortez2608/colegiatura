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
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'fechaFactura';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] : 'FechaFactura,FolFiscal,ImporteFactura,PorcentajeDescuento,ImporteCalculado,idu_beneficiario_externo,NomBeneficiario,IdFactura,Conexion';	
		
	$iBeneficiarioExterno = isset($_GET['BeneficiarioExt']) ? $_GET['BeneficiarioExt'] : 0;
	$iEstatus = isset($_GET['Estatus']) ? $_GET['Estatus'] : 0;
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
		// echo( "SELECT * FROM FUN_OBTENER_FACTURAS_EXTERNOS ($page,$rowsperpage, $iCapturo,'$orderby','$ordertype','$columns',$iBeneficiarioExterno,$iEstatus)");
		// exit();
		$query = "SELECT * FROM FUN_OBTENER_FACTURAS_EXTERNOS ($page,$rowsperpage,$iCapturo,'$orderby','$ordertype','$columns',$iBeneficiarioExterno,$iEstatus)";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		$respuesta->page = $ds[0]['page'];
		$respuesta->total = $ds[0]['pages'];
		$respuesta->records = $ds[0]['records'];
		$id=0;
		
		foreach($ds as $fila) {
			//$respuesta->rows[$id]['id']=$id;

			$respuesta->rows[$id]['cell']=
			array(
				$fila['id']
				,$fila['dfechafactura']
				//,utf8_encode($fila['cfolfiscal'])
				,mb_convert_encoding($fila['cfolfiscal'], 'UTF-8', 'ISO-8859-1')				
				//,$fila['nimportefactura']
				,'$'.number_format($fila['nimportefactura'], 2 ,"." ,"," )
				,$fila['nporcentajedescuento']
				,number_format($fila['nimportecalculado'],2)
				,$fila['iidubeneficiario']
				//,utf8_encode($fila['cnombeneficiario'])
				,mb_convert_encoding($fila['cnombeneficiario'], 'UTF-8', 'ISO-8859-1')				
				,$fila['iidfactura']				
			);
			$id++;
		}		
		echo json_encode($respuesta);
	} 
	catch (JsonException $ex) {
		echo "Error al cargar Json";
	}
	catch (Exception $ex) {
		echo "Error al cargar base de Datos";
	}
 ?>