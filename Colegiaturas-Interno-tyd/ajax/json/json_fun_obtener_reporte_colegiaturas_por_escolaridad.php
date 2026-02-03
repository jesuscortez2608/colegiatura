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
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iTipoDeduccion = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;
	//$iTipoEscuela = isset($_GET['iTipoEscuela']) ? $_GET['iTipoEscuela'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	
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
		$query = "{CALL fun_obtener_reporte_colegiaturas_por_escolaridad($iRutaPago, $iEstatus, $iRegion, $iCiudad, $iTipoDeduccion, $iEmpresa, '$dFechaInicio', '$dFechaFin')}";
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
			// $TotalImporte+=$fila['nimporte'];
			// $TotalReembolso+=$fila['nreembolso'];
			if ($fila['iidu_escolaridad'] >= 99){
				$empresa='<b>'.trim($fila['snom_empresa']).'</b>';
				if ($fila['iidu_escolaridad'] == 999) {
					// Inserta línea en blanco antes del total general
					$respuesta->rows[$i]['cell'] = array('','','','','','','','','','');
					$i++;
				}
			}else{
				$empresa=trim($fila['snom_empresa']);
			}
			$respuesta->rows[$i]['cell'] = array(			
				number_format($fila['iidu_empresa'],0),
				//trim(utf8_encode($fila['snom_empresa'])),
				$empresa,
				number_format($fila['iidu_escolaridad'],0),
				trim($fila['snom_escolaridad']),
				number_format($fila['icolaboradores_por_nivel'],0),
				number_format($fila['ifacturas_ingresadas'],0),
				number_format($fila['nimporte'],2),
				number_format($fila['nreembolso'],2),
				number_format($fila['nporcentaje_colaboradores'],2).'%',
				number_format($fila['nporcentaje_facturas'],2).'%'
			);
			$i++;
		}
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