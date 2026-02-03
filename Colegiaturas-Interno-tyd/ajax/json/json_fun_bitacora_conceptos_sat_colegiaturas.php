<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO.
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'fec_registro';
	$sOrderType = 'DESC';
	$sColumns = 'des_tipo_movimiento, des_clave, des_concepto, fec_registro, idu_empleado_registro, nom_colaborador';
				
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	
	if($estado != 0)
	{		
		try{
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		}
		catch(JsonException $ex){
			$json->mensaje = "Error al cargar el Json";
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		$query = "{CALL fun_bitacora_conceptos_sat_colegiaturas('$dFechaInicio', '$dFechaFin', $iEmpleado, $iRowsPerPage, $iCurrentPage, '$sOrderColumn', '$sOrderType','$sColumns')}";
		
		echo($query);
		exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		$respuesta = new stdClass();
		$respuesta->page = $ds[0]['page'];
		$respuesta->total = $ds[0]['pages'];
		$respuesta->records = $ds[0]['records'];
		foreach ($ds as $fila)
		{	
			$respuesta->rows[$i]['cell'] = array(
				date("d/m/Y", strtotime($fila['fec_registro'])), 
				trim($fila['des_tipo']),
				trim($fila['des_clave']),
				trim($fila['des_concepto']),
				$fila['idu_empleado_registro'],
				trim($fila['nom_colaborador'])
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
	
	try{
		echo json_encode($respuesta);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
	
?>