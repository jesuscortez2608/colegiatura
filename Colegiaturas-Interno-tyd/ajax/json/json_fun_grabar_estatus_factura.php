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
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	$iEmpleadoMarcoEstatus = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$iEstatus = isset($_POST['iEstatus']) ? $_POST['iEstatus'] : 0;
	$sDesObservaciones = isset($_POST['sDesObservaciones']) ? $_POST['sDesObservaciones'] : '';
	$iMotivo = isset($_POST['iMotivo']) ? $_POST['iMotivo'] : 0;
	$iColaborador = isset($_POST['iColaborador']) ? $_POST['iColaborador'] : 0;
	$nombreUsuario = isset($_POST['nombreUsuario']) ? $_POST['nombreUsuario'] : '';
	$apellidoPaterno = isset($_SESSION[$Session]["USUARIO"]['nom_apellidopaterno']) ? $_SESSION[$Session]["USUARIO"]['nom_apellidopaterno'] : ''; 
	$apellidoMaterno = isset($_SESSION[$Session]["USUARIO"]['nom_apellidomaterno']) ? $_SESSION[$Session]["USUARIO"]['nom_apellidomaterno'] : '';
	$nombreUsuario = $nombreUsuario . ' ' . $apellidoPaterno . ' ' . $apellidoMaterno;
	$aclaracion = '';
	$estado=0;
	$mensaje='OK';

	try {
		if (trim($iEmpleadoMarcoEstatus)  == "" ) {
			throw new Exception(encodeToUtf8("Sesión inválida"));
		} else if ( !is_numeric($iFactura) ) {
			throw new Exception(encodeToUtf8("Factura inválida"));
		} else if ( !is_numeric($iEstatus) ) {
			throw new Exception(encodeToUtf8("Estatus inválido"));
		}
		
		$sDesObservaciones = str_replace("'", "", $sDesObservaciones);
		$sDesObservaciones = encodeToIso($sDesObservaciones);
		
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}
		
		$ds=""; //guardo los datos en la consulta del procedimiento
		$ds2=""; //guardo los datos en la consulta del procedimiento de bitacora de facturas
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		$cmd2 = $con->createCommand();
		
		
		// throw new Exception("{CALL fun_grabar_estatus_factura($iFactura::INTEGER, $iEmpleadoMarcoEstatus::INTEGER, $iEstatus::INTEGER, '$sDesObservaciones'::TEXT)}");
		
		// print_r("{CALL fun_grabar_estatus_factura($iFactura::INTEGER, $iEmpleadoMarcoEstatus::INTEGER, $iEstatus::INTEGER, '$sDesObservaciones'::TEXT, $iMotivo::INTEGER)}");
		// exit();
		$cmd->setCommandText("{CALL fun_grabar_estatus_factura($iFactura::INTEGER, $iEmpleadoMarcoEstatus::INTEGER, $iEstatus::INTEGER, '$sDesObservaciones'::TEXT, $iMotivo::INTEGER)}");
		$ds=$cmd->executeDataSet();
		$cmd2->setCommandText("{CALL fun_grabar_bit_estatus_factura_colegiaturas($iFactura, $iColaborador, $iEstatus, $iEmpleadoMarcoEstatus, '$nombreUsuario', '$aclaracion')}");
		$ds2 = $cmd2->executeDataSet();
		$con->close();
		$estado = $ds[0][0];
		$mensaje = encodeToUtf8($ds2[0][1]);
	} catch(exception $ex) {
		$mensaje = $ex->getMessage();
	    //$mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
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