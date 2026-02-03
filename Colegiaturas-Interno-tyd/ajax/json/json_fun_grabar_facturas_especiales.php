<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//-------------------------------------------------------------------------
	$json = new stdClass();
	$iidu_empleado_registro = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$iempresa = isset($_POST['iempresa']) ? $_POST['iempresa'] : 0;	
	$sfoliofiscal= isset($_POST['sfoliofiscal']) ? $_POST['sfoliofiscal'] : 0;
	$iidu_empleado = isset($_POST['iidu_empleado']) ? $_POST['iidu_empleado'] : 0;
	$dfec_factura = isset($_POST['dfec_factura']) ? $_POST['dfec_factura'] : '';
	$iidu_centro = isset($_POST['iidu_centro']) ? $_POST['iidu_centro'] : 0;	
	$iidu_escuela = isset($_POST['iidu_escuela']) ? $_POST['iidu_escuela'] : 0;
	$srfc_clave = isset($_POST['srfc_clave']) ? $_POST['srfc_clave'] : '';
	$iimporte_factura = isset($_POST['iimporte_factura']) ? $_POST['iimporte_factura'] : 0;
	$iidu_tipo_documento = isset($_POST['iidu_tipo_documento']) ? $_POST['iidu_tipo_documento'] : 0;		
	$snom_pdf_carta = isset($_POST['snom_pdf_carta']) ? $_POST['snom_pdf_carta'] : 0;
	//Detalle
	$iidu_beneficiario = isset($_POST['iidu_beneficiario']) ? $_POST['iidu_beneficiario'] : 0;
	$ibeneficiario_hoja_azul = isset($_POST['ibeneficiario_hoja_azul']) ? $_POST['ibeneficiario_hoja_azul'] : 0;
	$iidu_parentesco = isset($_POST['iidu_parentesco']) ? $_POST['iidu_parentesco'] : 0;
	$iidu_tipopago = isset($_POST['iidu_tipopago']) ? $_POST['iidu_tipopago'] : 0;
	$speriodo = isset($_POST['speriodo']) ? $_POST['speriodo'] : '';
	$iidu_escolaridad = isset($_POST['iidu_escolaridad']) ? $_POST['iidu_escolaridad'] : 0;
	$iidu_grado_escolar = isset($_POST['iidu_grado_escolar']) ? $_POST['iidu_grado_escolar'] : 0;
	$idu_ciclo_escolar = isset($_POST['idu_ciclo_escolar']) ? $_POST['idu_ciclo_escolar'] : 0;
	
	
	$estado=0;
	$mensaje='OK';
	try {
		
		//if (trim($iidu_empleado_registro)  == "" ) {
		//	throw new Exception(encodeToUtf8("Sesi�n inv�lida"));
		//} else if ( !is_numeric($iFactura) ) {
		//	throw new Exception(encodeToUtf8("Factura inv�lida"));
		//} else if ( !is_numeric($iEstatus) ) {
		//	throw new Exception(encodeToUtf8("Estatus inv�lido"));
		//}
		
		// $sDesObservaciones = str_replace("'", "", $sDesObservaciones);
		// $sDesObservaciones = encodeToIso($sDesObservaciones);
		
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
	/*
		echo("{CALL FUN_GRABAR_FACTURAS_ESPECIALES(
							$iempresa
							, '$sfoliofiscal'
							, $iidu_empleado
							, '$dfec_factura'
							, $iidu_centro
							, $iidu_escuela
							, '$srfc_clave'
							, $iimporte_factura
							, $iidu_tipo_documento
							, $iidu_empleado_registro
							, '$snom_pdf_carta'
							, $iidu_beneficiario
							, $ibeneficiario_hoja_azul
							, $iidu_parentesco
							, $iidu_tipopago
							, '$speriodo'
							, $iidu_escolaridad
							, $iidu_grado_escolar
							, $idu_ciclo_escolar)}");
		 exit();
	*/
		$cmd->setCommandText("{CALL FUN_GRABAR_FACTURAS_ESPECIALES(
							$iempresa
							, '$sfoliofiscal'
							, $iidu_empleado
							, '$dfec_factura'
							, $iidu_centro
							, $iidu_escuela
							, '$srfc_clave'
							, $iimporte_factura
							, $iidu_tipo_documento
							, $iidu_empleado_registro
							, '$snom_pdf_carta'
							, $iidu_beneficiario
							, $ibeneficiario_hoja_azul
							, $iidu_parentesco
							, $iidu_tipopago
							, '$speriodo'
							, $iidu_escolaridad
							, $iidu_grado_escolar
							, $idu_ciclo_escolar)}");
		$ds=$cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0][0];
		$mensaje = encodeToUtf8($ds[0][1]);
	} catch(exception $ex) {
	    $mensaje = "Error al obtener Facturas Espciales"; //$ex->getMessage();
		$estado = -1;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
	echo (json_encode($json));
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar datos en Json"; //$ex->getMessage();
		$estado = -1;
	}
?>