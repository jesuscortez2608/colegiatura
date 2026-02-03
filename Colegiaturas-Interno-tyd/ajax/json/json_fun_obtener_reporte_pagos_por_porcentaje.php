	<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	// $rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	// $page = isset($_GET['page']) ? $_GET['page'] : 0;
	// $orderby = isset($_GET['sidx']) ? $_GET['sidx'] : '';
	// $ordertype = isset($_GET['sord']) ? $_GET['sord'] : '';
	// $columns = isset($_GET['columns']) ? $_GET['columns'] : 'tipo,fechacorte,num_empleado,nom_empleado,num_centro,nom_centro,total_importe_facturas,total_pagado,total_facturas,ruta_pago,nom_ruta_pago,num_tarjeta,prc_descuento, total_movimientos, total_empleados';
	
	$iPorcentaje = isset($_GET['iPorcentaje']) ? $_GET['iPorcentaje'] : 0;
	$dFechaInicial = isset($_GET['dFechaInicial']) ? $_GET['dFechaInicial'] : '';
	$dFechaFinal = isset($_GET['dFechaFinal']) ? $_GET['dFechaFinal'] : '';
	$iEmpresa = isset($_GET['idEmpresa']) ? $_GET['idEmpresa'] : 0;
	

	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT * 
					FROM fun_obtener_reporte_pagos_por_porcentaje($iPorcentaje
					, $iEmpresa
					, '$dFechaInicial'
					, '$dFechaFinal')";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		$con->close();
		
		$i = 0;
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		
		if (sizeof($ds) > 1){
			foreach($ds as $fila){
				$fechaCorte = "";
				$idEmpresa = 0;
				$sNomEmpresa = '';
				$idColaborador = 0;
				$sNomColaborador = '';
				$idCentro = 0;
				$sNomCentro = '';
				$TotalImpFac = 0;
				$TotalPagado = 0;
				$TotalFacturas = 0;
				$idRutaPago = 0;
				$sNomRutaPago = '';
				$sNumTarjeta = '';
				$PorcentajeDsc = 0;
				$TotalColaboradores = 0;
				
				if($fila['tipo'] == 0){
					$fechaCorte = date("d/m/Y", strtotime($fila['fechacorte']));
					
					$idEmpresa = $fila['idu_empresa'];
					$sNomEmpresa = trim(encodeToUtf8($fila['nom_empresa']));
					$idColaborador = $fila['num_empleado'];
					$sNomColaborador = trim(encodeToUtf8($fila['nom_empleado']));
					$idCentro = $fila['num_centro'];
					$sNomCentro = trim(encodeToUtf8($fila['nom_centro']));
					$TotalImpFac = number_format($fila['total_importe_facturas'],2);
					$TotalPagado = number_format($fila['total_pagado'],2);
					$TotalFacturas = $fila['total_facturas'];
					$idRutaPago = $fila['ruta_pago'];
					$sNomRutaPago = trim(encodeToUtf8($fila['nom_ruta_pago']));
					$sNumTarjeta = trim(encodeToUtf8($fila['num_tarjeta']));
					$PorcentajeDsc = $fila['prc_descuento'];
					// $TotalColaboradores  = $fila['total_empleados'];
					$TotalColaboradores  = '';
					
					
				} else if($fila['tipo'] == 1){//TOTAL POR MES
					$MesIniciales = "";
					$MesNumero = substr($fila['fecha'], -2);//OBTIENE EL NUMERO DE MES DE LA CADENA 'yyyy-MM'
					switch($MesNumero){
						case "01":
							$MesIniciales = "ENE";
						break;
						case "02":
							$MesIniciales = "FEB";
						break;
						case "03":
							$MesIniciales = "MAR";
						break;
						case "04":
							$MesIniciales = "ABR";
						break;
						case "05":
							$MesIniciales = "MAY";
						break;
						case "06":
							$MesIniciales = "JUN";
						break;
						case "07":
							$MesIniciales = "JUL";
						break;
						case "08":
							$MesIniciales = "AGO";
						break;
						case "09":
							$MesIniciales = "SEP";
						break;
						case "10":
							$MesIniciales = "OCT";
						break;
						case "11":
							$MesIniciales = "NOV";
						break;
						case "12":
							$MesIniciales = "DIC";
						break;
					}
					$fechaCorte = "<b>Total Mes ".$MesIniciales."/".substr($fila['fecha'], -7, 4)."</b>";
				} else{
					$fechaCorte = "<b>TOTAL GENERAL</b>";
				}
				
				if($fila['tipo'] >= 1){
					$TotalImpFac = "<b>".number_format($fila['total_importe_facturas'],2)."</b>";
					$TotalPagado = "<b>".number_format($fila['total_pagado'],2)."</b>";
					$TotalFacturas = "<b>".number_format($fila['total_facturas'],0)."</b>";
					$TotalColaboradores  = "<b>".number_format($fila['total_empleados'],0)."</b>";
					$idColaborador = '';
					$idCentro = '';
					$PorcentajeDsc = '';
				}
				$respuesta->rows[$i]['cell'] = array(
					$sNomEmpresa
					// $idEmpresa
					, $fechaCorte
					, $idColaborador
					, $sNomColaborador
					, $idCentro
					, $sNomCentro
					, $TotalImpFac
					, $TotalPagado
					, $TotalFacturas
					, $idRutaPago
					, $sNomRutaPago
					, $sNumTarjeta
					, $PorcentajeDsc
					, $TotalColaboradores
				);
				$i++;
			}
		}
	} catch (Exception $ex) {
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