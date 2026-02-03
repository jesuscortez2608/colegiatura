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
	
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	$nImporteOriginal = isset($_POST['nImporteOriginal']) ? $_POST['nImporteOriginal'] : 0;
    $nImporteNuevo = isset($_POST['nImporteNuevo']) ? $_POST['nImporteNuevo'] : 0;
	$sJustificacion = isset($_POST['sJustificacion']) ? $_POST['sJustificacion'] : 0;
	$iEmpleadoRegistro = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	//Detalles de la factura con los importes actualizados.
	$importes_actualizados = isset($_POST['importes_actualizados']) ? $_POST['importes_actualizados'] : '';
	$importes_actualizados = str_replace("\\","", $importes_actualizados);
	try
	{
	$importes_actualizados = json_decode($importes_actualizados);
	}
	catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
	}

	//Crear el xml de transporte de los importes pagados nuevos
	$detallesXML = "<Root>";
		foreach($importes_actualizados as $row) {
			$detallesXML.= "<detalleFactura>";
			
				$iFacturaX = $row->idfactura;
				$iKeyX = $row->keyx;
				$nImportePagadoNuevo = $row->imp_importe_pagado;
				
				$detallesXML.= "<iFactura>".$iFacturaX."</iFactura>";
				$detallesXML.= "<iKeyX>".$iKeyX."</iKeyX>";
				$detallesXML.= "<nImportePagadoNuevo>".$nImportePagadoNuevo."</nImportePagadoNuevo>";
				
			$detallesXML.= "</detalleFactura>";
		}
	$detallesXML.= "</Root>";
	
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
		$query = "SELECT fun_grabar_importe_pagado($iFactura, $nImporteOriginal, $nImporteNuevo, $iEmpleadoRegistro, '$detallesXML','$sJustificacion')";
		
		// print_r($query);
		// exit();
		
		$cmd->setCommandText($query);
	
	    $ds = $cmd->executeDataSet();
		
		$con->close();
		
		$json->estado = 0;
		$mensaje='Importe actualizado';
	}
	catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
		}
	catch(exception $ex)
	{
		$mensaje="";
		//$mensaje = $ex->getMessage();
		$mensaje = "Error al conectar a Base de Datos";
		$estado=-2;
	}
	//$json->estado = $estado;
	//$json->mensaje = $mensaje;
	
	try{
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
		}catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
		}
?>