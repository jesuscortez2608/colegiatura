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
	$iTipoDeduccion = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	
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
		$query = "{CALL fun_obtener_reporte_colegiaturas_region_escolaridad_dinamica($iRutaPago, $iEstatus, $iTipoDeduccion, $iEmpresa, '$dFechaInicio','$dFechaFin')}";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		$con->close();
		
		$i = 0;
		$respuesta = new stdClass();
		
		foreach ($ds as $fila)
		{
			$respuesta->rows[$i]['cell'] = array(
				$fila['idu_empresa'],
				$fila['nom_empresa'] == '' ? '[NOMBRE NO DISPONIBLE]' : trim($fila['nom_empresa']),
				$fila['idu_region'],
				trim($fila['nom_region']),
				$fila['idu_escolaridad_1'],
				$fila['idu_escolaridad_2'],
				$fila['idu_escolaridad_3'],
				$fila['idu_escolaridad_4'],
				$fila['idu_escolaridad_5'],
				$fila['idu_escolaridad_6'],
				$fila['idu_escolaridad_7'],
				$fila['idu_escolaridad_8'],
				$fila['idu_escolaridad_9'],
				$fila['idu_escolaridad_10'],
				number_format($fila['total_general'], 0)
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