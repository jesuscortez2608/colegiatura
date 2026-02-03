<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	//VARIABLES DE FILTRADO.
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iCentro = isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : -1;
	$sOrderColumn = isset($_GET['sidx']) ? $_GET['sidx'] : 'fec_ingreso';
	$sOrderType = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$sColumns = 'numemp,nombre,num_centro,nom_centro,num_puesto,nom_puesto,porcentaje,escolaridad,seccion,parentesco,justificacion,fec_ingreso,fec_movimiento,numemp_autorizo,nombre_autorizo,
	num_centro_autorizo,nom_centro_autorizo,num_puesto_autorizo,nom_puesto_autorizo';
	
	// if($iTipoMovimientoBitacora == 7){
		// $sOrderColumn = 'fec_registro,idu_empleado';
	// }
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
		
		$query = "SELECT *
				FROM FUN_OBTEN_BIT_COLEGIATURAS_CONFIG_DESCUENTOS(
					  '$dFechaInicio'
					, '$dFechaFin'
					, $iRegion
					, $iCiudad
					, $iEmpleado
					, $iCentro
					, $iRowsPerPage
					, $iCurrentPage
					, '$sOrderColumn'
					, '$sOrderType'
					, '$sColumns')";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);

		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		
		$respuesta = new stdClass();
		$respuesta->page = $ds[0]['page'];
		$respuesta->total = $ds[0]['pages'];
		$respuesta->records = $ds[0]['records'];

		foreach($ds as $fila){
			$fechaIngreso = date("d/m/Y", strtotime($fila['fec_ingreso']));
			$fechaMovimiento = date("d/m/Y", strtotime($fila['fec_movimiento']));

			$respuesta->rows[$i]['cell'] = array(
				  ($fila['numemp']) ? trim($fila['numemp']).' - '.trim(encodeToUtf8($fila['nombre'])) : ''
				, ($fila['num_centro']) ? trim($fila['num_centro']).' - '.trim(encodeToUtf8($fila['nom_centro'])) : ''
				, ($fila['num_puesto']) ? trim($fila['num_puesto']).' - '.trim(encodeToUtf8($fila['nom_puesto'])) : ''
				, trim(encodeToUtf8($fila['porcentaje']).'%')
				, trim(encodeToUtf8($fila['escolaridad']))
				, trim(encodeToUtf8($fila['parentesco']))
				, trim(encodeToUtf8($fila['seccion']))
				, trim(encodeToIso($fila['justificacion']))
				, $fechaIngreso
				, $fechaMovimiento // Revisar Fecha Movimiento
				, ($fila['numemp_autorizo']) ? trim($fila['numemp_autorizo']).' - '.trim(encodeToUtf8($fila['nombre_autorizo'])) : ''
				, ($fila['num_centro_autorizo']) ? trim($fila['num_centro_autorizo']).' - '.trim(encodeToUtf8($fila['nom_centro_autorizo'])) : ''
				, ($fila['num_puesto_autorizo']) ? trim($fila['num_puesto_autorizo']).' - '.trim(encodeToUtf8($fila['nom_puesto_autorizo'])) : ''
			);
			$i++;
		}

		// print_r($respuesta);
		// exit();
	}
	catch(exception $ex)
	{
		$mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
		$estado = -2;
	}
	
	try{
		echo json_encode($respuesta);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
	
?>