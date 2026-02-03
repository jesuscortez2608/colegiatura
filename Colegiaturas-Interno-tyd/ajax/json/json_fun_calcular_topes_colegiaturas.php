<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	//-------------------------------------------------------------------------
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	
	$iNumEmp = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	$iSueldo = isset($_POST['iSueldo']) ? $_POST['iSueldo'] : 0;
	$iSueldo=$iSueldo*100;
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];	
	$mensaje = $CDB['mensaje'];	
	$json = new stdClass();
		// echo $iSueldo;
	if($iEmpleado!=0)
	{	
	
		$iNumEmp=$iEmpleado;
	}
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
	$con = new OdbcConnection($CDB['conexion']);
	try
	{
		$con->open();
		$cmd = $con->createCommand();
		// print_r("{CALL fun_calcular_topes_colegiaturas ($iNumEmp, $iSueldo)}");
		// exit;
		$cmd->setCommandText("{CALL fun_calcular_topes_colegiaturas ($iNumEmp, $iSueldo)}");
	    $ds = $cmd->executeDataSet();
		$mensaje="Ok";
		$con->close();
		$estado = 0;
		$json->sueldo = $ds[0][0];
		$json->topeAnual = $ds[0][1];
		$json->topeMensual = $ds[0][2];
	}
	catch(exception $ex)
	{
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}
	if($estado==0)
	{
		try
		{
			$con->open();
			$cmd = $con->createCommand();
			// print_r("{CALL fun_obtener_acumulado_facturas_pagadas ($iNumEmp, $iSueldo)}");
			// exit;
			$cmd->setCommandText("{CALL fun_obtener_acumulado_facturas_pagadas ($iNumEmp, $iSueldo)}");
			$ds = $cmd->executeDataSet();
			$mensaje="Ok";
			$con->close();
			$estado = 0;
			$json->acumulado = $ds[0][0];
			$json->restante = $ds[0][1];
			// $json->totalanual = $ds[0][2];
		}
		catch(exception $ex)
		{
			$mensaje = "Ocurrió un error al conectar a la base de datos.";
			$estado=-2;
		}
	}
	$json->estado=$estado;
	$json->mensaje=$mensaje;	
	try {
		echo json_encode($json);
	} catch (JsonException $e) {
		echo 'Error en la codificación JSON: ';
	}
?>