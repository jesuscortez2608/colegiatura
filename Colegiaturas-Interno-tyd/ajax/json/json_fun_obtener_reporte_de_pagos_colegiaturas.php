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
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'idu_empresa,rango_fecha_mes,tipo_movimiento,idu_centro,num_empleado';
	$sOrderType = 'asc';
	$sColumns = 'tipo_movimiento,idu_empresa,nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura,num_empleado,nom_empleado,
				fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,
				idu_tipo_deduccion, tipo_deduccion, descuento, folio_factura';
	
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
		$query = "{CALL fun_obtener_reporte_de_pagos_colegiaturas($iEmpresa, $iRutaPago, $iEstatus, '$dFechaInicio', '$dFechaFin', $iRowsPerPage, $iCurrentPage, '$sOrderColumn', '$sOrderType','$sColumns')}";
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
		
		foreach ($ds as $fila)
		{
			$RangoFechaMes = "";
			$Fecha = "";
			$Descuento = "";
			$DescripcionRenglon = "";
			$ImporteConcepto = "";
			$ImportePagado = "";
			$Empresa = $fila['nom_empresa'];
			if($fila['tipo_movimiento'] == 0)
			{
				$RangoFechaMes = trim($fila['rango_fecha_mes']);
				$Fecha = date("d/m/Y", strtotime($fila['fecha']));
				$Descuento = number_format($fila['descuento'],0).'%';
				$DescripcionRenglon = trim($fila['nom_empleado']);
				$ImporteConcepto = number_format($fila['importe_concepto'],2);
				$ImportePagado = number_format($fila['importe_pagado'],2);
			}
			
			if($fila['tipo_movimiento'] > 0)
			{
				$DescripcionRenglon = '<b>'.trim($fila['nom_empleado']).'</b>';
				$ImporteConcepto = '<b>'.number_format($fila['importe_concepto'],2).'</b>';
				$ImportePagado = '<b>'.number_format($fila['importe_pagado'],2).'</b>';
				$Empresa = '';
			}
			
			$respuesta->rows[$i]['cell'] = array(
				$fila['tipo_movimiento'],
				$RangoFechaMes,
				$fila['idu_empresa'],
				// trim(utf8_encode($fila['nom_empresa'])),
				$Empresa,
				trim($fila['id_ruta_pago']),
				trim($fila['num_empleado']),
				$DescripcionRenglon,
				
				$Fecha,
				
				trim($fila['idu_centro']),
				trim($fila['idu_centro']).' '.trim($fila['nombre_centro']),
				trim($fila['num_tarjeta']),
				
				$ImporteConcepto,
				$ImportePagado,
				
				trim($fila['idu_tipo_deduccion']),
				trim($fila['tipo_deduccion']),
				
				$Descuento,
				
				trim($fila['folio_factura']),
				trim($fila['id_factura'])
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
		echo "Error al generar JSON";
	}
	
?>