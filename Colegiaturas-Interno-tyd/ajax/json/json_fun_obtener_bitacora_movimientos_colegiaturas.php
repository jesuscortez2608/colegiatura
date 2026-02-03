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
	$iTipoMovimientoBitacora = isset($_GET['iTipoMovimientoBitacora']) ? $_GET['iTipoMovimientoBitacora'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iCentro = isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : -1;
	$sOrderColumn = isset($_GET['sidx']) ? $_GET['sidx'] : 'fec_registro';
	$sOrderType = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$sColumns = 'fec_registro, idu_tipo_movimiento, nom_tipo_movimiento, folio_factura, importe_original
					, importe_pagado, opc_bloqueado_estatus, idu_empleado, nombre_empleado, numero_puesto, nombre_puesto
					, fec_alta, idu_centro, nombre_centro, idu_ciudad, nombre_ciudad, idu_region, nombre_region, justificacion
					, estatus_empleado, idu_usuario, nom_usuario, idu_puesto_usuario, nom_puesto_usuario, idu_centro_usuario, nom_centro_usuario, porcentaje, nom_escolaridad';
	
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
		
		$query = "SELECT records
						, page
						, pages
						, id
						, fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, folio_factura
						, importe_original
						, importe_pagado
						, opc_bloqueado_estatus
						, idu_empleado
						, nombre_empleado
						, numero_puesto
						, nombre_puesto
						, fec_alta
						, idu_centro
						, nombre_centro
						, idu_ciudad
						, nombre_ciudad
						, idu_region
						, nombre_region
						, justificacion
						, estatus_empleado
						, idu_usuario
						, nom_usuario
						, idu_puesto_usuario
						, nom_puesto_usuario
						, idu_centro_usuario
						, nom_centro_usuario
						, porcentaje
						, nom_escolaridad
				FROM fun_obtener_bitacora_movimientos_colegiaturas(
					'$dFechaInicio'
					, '$dFechaFin'
					, $iEmpleado
					, $iTipoMovimientoBitacora
					, $iRegion
					, $iCiudad
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
	
		if($iTipoMovimientoBitacora==1){//Editar Importe a pagar
			foreach ($ds as $fila){	
				$fechaRegistro = date("d/m/Y", strtotime($fila['fec_registro']));
				$respuesta->rows[$i]['cell'] = array(
					$fechaRegistro,
					$fila['nom_tipo_movimiento'],
					$fila['folio_factura'],
					number_format($fila['importe_original'],2),
					number_format($fila['importe_pagado'],2),
					trim($fila['idu_empleado']).'  '.$fila['nombre_empleado'],
					trim($fila['numero_puesto']).'  '.$fila['nombre_puesto'],
					$fila['porcentaje'].'%',
					$fila['nom_escolaridad'],
					trim($fila['idu_centro']).' '.encodeToUtf8($fila['nombre_centro']),
					trim($fila['idu_ciudad']).' '.$fila['nombre_ciudad'],
					trim($fila['idu_region']).' '.$fila['nombre_region'],
					trim(encodeToUtf8($fila['justificacion'])),
					trim($fila['idu_usuario']).' '.$fila['nom_usuario'],
					trim($fila['idu_puesto_usuario']).' '.$fila['nom_puesto_usuario'],
					trim($fila['idu_centro_usuario']).' '.$fila['nom_centro_usuario'],
				);
				$i++;
			}

			// print_r($respuesta);
			// exit();
		}else if($iTipoMovimientoBitacora==2){			//Colaborador Bloqueado
			foreach ($ds as $fila)
			{	
				$fechaRegistro = date("d/m/Y H:i:s", strtotime($fila['fec_registro']));
				$respuesta->rows[$i]['cell'] = array(
					$fechaRegistro,
					trim($fila['idu_empleado']).' '.trim(encodeToUtf8($fila['nombre_empleado'])),
					trim($fila['numero_puesto']).' '.trim(encodeToUtf8($fila['nombre_puesto'])),
					trim(encodeToUtf8($fila['porcentaje']).'%'),
					trim(encodeToUtf8($fila['nom_escolaridad'])),
					trim($fila['idu_centro']).' '.trim(encodeToUtf8($fila['nombre_centro'])),
					trim($fila['idu_ciudad']).' '.trim(encodeToUtf8($fila['nombre_ciudad'])),
					trim($fila['idu_region']).' '.trim(encodeToUtf8($fila['nombre_region'])),
					trim(encodeToUtf8($fila['estatus_empleado'])),
					trim(encodeToUtf8($fila['opc_bloqueado_estatus'])),
					trim(encodeToIso($fila['justificacion'])),
					trim($fila['idu_usuario']).' '.trim(encodeToUtf8($fila['nom_usuario'])),
					trim($fila['idu_puesto_usuario']).' '.trim(encodeToUtf8($fila['nom_puesto_usuario'])),
					trim($fila['idu_centro_usuario']).' '.trim(encodeToUtf8($fila['nom_centro_usuario']))
				);
				$i++;
			}
		}else if($iTipoMovimientoBitacora==3){		//Cancelar Pago
			foreach ($ds as $fila){
				$fechaRegistro = date("d/m/Y", strtotime($fila['fec_registro']));
				$respuesta->rows[$i]['cell'] = array(
					$fechaRegistro,
					substr($fila['fec_registro'], 11, 8),
					$iTipoMovimientoBitacora == 3 ? 'CANCELAR PAGO' :  trim(encodeToUtf8($fila['nom_tipo_movimiento'])),
					$fila['folio_factura'],
					number_format($fila['importe_original'],2),
					number_format($fila['importe_pagado'],2),
					trim($fila['opc_bloqueado_estatus']),
					trim($fila['idu_empleado']).' '.trim(encodeToUtf8($fila['nombre_empleado'])),
					trim($fila['numero_puesto']).' '.trim(encodeToUtf8($fila['nombre_puesto'])),
					trim($fila['idu_centro']).' '.trim(encodeToUtf8($fila['nombre_centro'])),
					trim($fila['idu_ciudad']).' '.trim(encodeToUtf8($fila['nombre_ciudad'])),
					trim($fila['idu_region']).' '.trim(encodeToUtf8($fila['nombre_region'])),
					//trim($fila['id_beneficiario_especial']).' '.trim(encodeToUtf8($fila['nombre_de_beneficiario_especial'])),
					//trim($fila['marcado_especial']),
					trim(encodeToUtf8($fila['justificacion'])),
					trim(encodeToUtf8($fila['estatus_empleado'])),
					trim($fila['idu_usuario']).' '.trim(encodeToUtf8($fila['nom_usuario'])),
					trim($fila['idu_puesto_usuario']).' '.trim(encodeToUtf8($fila['nom_puesto_usuario'])),
					trim($fila['idu_centro_usuario']).' '.trim(encodeToUtf8($fila['nom_centro_usuario']))
				);
				$i++;
			}
		}else if(($iTipoMovimientoBitacora == 4) || ($iTipoMovimientoBitacora == 5)){
			foreach($ds as $fila){
				$fechaRegistro = date("d/m/Y H:i:s", strtotime($fila['fec_registro']));
				$respuesta->rows[$i]['cell'] = array(
					$fechaRegistro
					, trim(encodeToUtf8($fila['nom_tipo_movimiento']))
					, trim($fila['idu_empleado']).'  '.trim(encodeToUtf8($fila['nombre_empleado']))
					, trim($fila['numero_puesto']).'  '.trim(encodeToUtf8($fila['nombre_puesto']))
					, trim(encodeToUtf8($fila['porcentaje']).'%')
					, trim(encodeToUtf8($fila['nom_escolaridad']))
					, trim($fila['idu_centro']).'  '.trim(encodeToUtf8($fila['nombre_centro']))
					, trim($fila['idu_ciudad']).'  '.trim(encodeToUtf8($fila['nombre_ciudad']))
					, trim($fila['idu_region']).'  '.trim(encodeToUtf8($fila['nombre_region']))
					, trim(encodeToIso($fila['justificacion']))
					, trim(encodeToUtf8($fila['estatus_empleado']))
					, trim($fila['idu_usuario']).'  '.trim(encodeToUtf8($fila['nom_usuario']))
					, trim($fila['idu_puesto_usuario']).'  '.trim(encodeToUtf8($fila['nom_puesto_usuario']))
					, trim($fila['idu_centro_usuario']).'  '.trim(encodeToUtf8($fila['nom_centro_usuario']))
				);
				$i++;
			}
		}else if($iTipoMovimientoBitacora == 7){
			foreach($ds as $fila){
				$fechaRegistro = date("d/m/Y", strtotime($fila['fec_registro']));
				$fechaIngreso = date("d/m/Y", strtotime($fila['fec_alta']));
				$respuesta->rows[$i]['cell'] = array(
					// trim($fila['idu_empleado'])
					trim($fila['idu_empleado']).'  '.trim(encodeToUtf8($fila['nombre_empleado']))
					// , trim($fila['idu_centro'])
					, trim($fila['idu_centro']).'  '.trim(encodeToUtf8($fila['nombre_centro']))
					// , trim($fila['numero_puesto'])
					, trim($fila['numero_puesto']).'  '.trim(encodeToUtf8($fila['nombre_puesto']))
					, trim(encodeToUtf8($fila['porcentaje']).'%')
					, trim(encodeToUtf8($fila['nom_escolaridad']))
					, trim($fila['idu_region']).'  '.trim(encodeToUtf8($fila['nombre_region']))
					, trim($fila['idu_ciudad']).'  '.trim(encodeToUtf8($fila['nombre_ciudad']))
					, $fechaIngreso
					// , trim($fila['idu_usuario'])
					, trim($fila['idu_usuario']).'  '.trim(encodeToUtf8($fila['nom_usuario']))
					, trim($fila['idu_puesto_usuario']).'  '.trim(encodeToUtf8($fila['nom_puesto_usuario']))
					, trim($fila['idu_centro_usuario']).'  '.trim(encodeToUtf8($fila['nom_centro_usuario']))
					, $fechaRegistro
				);
				$i++;
			}
		}else if($iTipoMovimientoBitacora == 8){
			foreach($ds as $fila){
				$fechaIngreso = date("d/m/Y", strtotime($fila['fec_alta']));
				$fechaMovimiento = date("d/m/Y", strtotime($fila['fec_registro']));

				$respuesta->rows[$i]['cell'] = array(
					trim($fila['idu_empleado']).'  '.trim(encodeToUtf8($fila['nombre_empleado']))
					, trim($fila['idu_centro']).'  '.trim(encodeToUtf8($fila['nombre_centro']))
					, trim($fila['numero_puesto']).'  '.trim(encodeToUtf8($fila['nombre_puesto']))
					, trim(encodeToUtf8($fila['porcentaje']).'%')
					, trim(encodeToUtf8($fila['nom_escolaridad']))
					, trim(encodeToIso($fila['justificacion']))
					, $fechaIngreso
					, $fechaMovimiento // Revisar Fecha Movimiento
					, trim($fila['idu_usuario']).'  '.trim(encodeToUtf8($fila['nom_usuario']))
					, trim($fila['idu_puesto_usuario']).'  '.trim(encodeToUtf8($fila['nom_puesto_usuario']))
					, trim($fila['idu_centro_usuario']).'  '.trim(encodeToUtf8($fila['nom_centro_usuario']))
				);
				$i++;
			}
		}
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