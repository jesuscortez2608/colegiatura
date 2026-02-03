<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	
	//VARIABLES DE FILTRADO.
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iTipoDeduccion = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;	
	$iCicloEscolar = isset($_GET['iCicloEscolar']) ? $_GET['iCicloEscolar'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';	
	$iNumEmp = isset($_GET['iNumEmp']) ? $_GET['iNumEmp'] : 0;
	
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	$respuesta = new stdClass();
	$json->resultado=array();
	$datos = array();
	
	if($estado != 0)
	{

		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	try
	{	
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		$query = "{CALL FUN_OBTENER_REPORTE_FACTURAS_AJUSTE($iRutaPago,$iEscolaridad,$iRegion,$iCiudad,$iTipoDeduccion,$iCicloEscolar,'$dFechaInicio','$dFechaFin',$iNumEmp)}";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		
		//TOTALES.
		$TotalColaboradores=0;
		$TotalFacturasIngresadas=0;
		$TotalImporte=0;
		$TotalReembolso=0;		

		$empresa='';
		foreach ($ds as $fila)
		{
			$TotalColaboradores=$fila['itotal_colaboradores'];
			$TotalFacturasIngresadas=$fila['itotal_facturas_ingresadas'];
			$FechaFactura = date("d/m/Y", strtotime($fila['dfechafactura']));
			// $TotalImporte+=$fila['nimporte'];
			// $TotalReembolso+=$fila['nreembolso'];
			/*
			if ($fila['iidu_escolaridad']==99){
				$empresa='<b>'.trim(utf8_encode($fila['snom_empresa'])).'</b>';
			}else{
				$empresa=trim(utf8_encode($fila['snom_empresa']));
			}*/
			
			$respuesta->rows[$i]['cell'] = array(			
				$fila['iidfactura'],
				number_format($fila['iimportefactura'],2),
				$fila['nporc_pagado'],
				number_format($fila['iimportepagado'],2),
				// $fila['dfechafactura'],
				$FechaFactura,
				trim($fila['sfoliofiscal']),
				$fila['iidu_empleado'],
				trim($fila['snom_empleado']),
				trim($fila['sbecado']),
				trim($fila['sparentesco']),
				$fila['iidu_estatus'],
				trim($fila['snom_estatus'])			
			);
			$i++;
		}
		/*if($i>0){
			$respuesta->rows[$i]['cell']=array(
				0,
				'<b>TOTAL</b>',
				number_format($TotalColaboradores,0),
				number_format($TotalFacturasIngresadas,0),
				number_format($TotalImporte, 2),
				number_format($TotalReembolso, 2),
				'100.00%',
				'100.00%'
			);
		}*/
	}
	catch(exception $ex)
	{
		$mensaje = "";
		$mensaje = $ex->getMessage();
		$estado = -2;
	}

	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
?>