<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'id_empleado';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] : 'idfactura,fec_factura,fol_factura,serie,id_empleado,nom_empleado,id_centro, nom_centro,ottp,fec_captura,id_escuela,nom_escuela,imp_factura,fec_pago,id_rutapago,nom_rutapago,imp_a_pagar,id_ciclo_escolar,ciclo_escolar,id_estatus,nom_estatus,fec_estatus,num_modifico_estatus, nom_modifico_estatus,num_tarjeta,fec_baja,des_observaciones, id_tipodocumento, nom_tipodocumento';
	$iEstatus = $_GET['estatus'];
	$dFechaini = $_GET['fechaini'];
	$dFechafin = $_GET['fechafin'];
	$iCheckFecha = isset($_GET['CheckFecha']) ? $_GET['CheckFecha'] : 0;	
	$cFolioFactura = isset($_GET['FolioFactura']) ? $_GET['FolioFactura'] : '';
		

	
	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT records
					, page
					, pages
					, id
					, idfactura
					, fec_factura
					, fol_factura
					, serie
					, id_empleado
					, nom_empleado
					, id_centro
					, nom_centro
					, ottp
					, fec_captura
					, id_escuela
					, nom_escuela
					, imp_factura
					, fec_pago
					, id_rutapago
					, nom_rutapago
					, imp_a_pagar
					, id_ciclo_escolar
					, ciclo_escolar
					, id_estatus
					, nom_estatus
					, fec_estatus
					, num_modifico_estatus
					, nom_modifico_estatus
					, num_tarjeta
					, fec_baja
					, des_observaciones
					, id_tipodocumento
					, nom_tipodocumento
				FROM fun_obtener_listado_facturas_colegiaturas ($iEstatus
						, '$dFechaini'
						, '$dFechafin'
						, $iCheckFecha
						, '$cFolioFactura'
						, $rowsperpage
						, $page
						, '$orderby'
						, '$ordertype'
						, '$columns')";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		$id=0;
		
	
			foreach($matriz as $fila) 
			{
				if($fila['id_estatus'] != 0) {
					if($fila['num_modifico_estatus'] != 0) {
						$empleadoEstatus = trim($fila['nom_modifico_estatus']);
					} else {
						$empleadoEstatus = 'AUTORIZADA POR SISTEMA';
					}
				} else {
					$empleadoEstatus = '';
				}
				if($fila['id_estatus'] == 3 && $fila['num_modifico_estatus'] == 0) {
					$empleadoEstatus = 'RECHAZADA POR SISTEMA';
				}
				$respuesta->rows[$id]['id']=$id;				
				$respuesta->rows[$id]['cell']=
					array(
					$fila['idfactura']
					,($fila['fec_factura'] == '1900-01-01 00:00:00') ? '' : date("d/m/Y", strtotime($fila['fec_factura']))
					,$fila['fol_factura']
					,$fila['id_tipodocumento']
					,$fila['nom_tipodocumento']
					,$fila['serie']
					,$fila['id_empleado']
					,$fila['nom_empleado']
					,$fila['id_centro']
					,$fila['nom_centro']
					,(trim($fila['ottp']) > 1) ? 1 : 0
					,($fila['fec_captura'] == '1900-01-01 00:00:00') ? '' : date("d/m/Y", strtotime($fila['fec_captura']))
					,$fila['id_escuela']
					,$fila['nom_escuela']
					,'$'.number_format($fila['imp_factura'],2)
					,($fila['fec_pago'] == '1900-01-01 00:00:00') ? '' : date("d/m/Y", strtotime($fila['fec_pago']))
					// ,($fila['id_estatus'] <> 5) ? '' : date("d/m/Y", strtotime($fila['fec_estatus']))
					,$fila['id_rutapago']
					,$fila['nom_rutapago']
					,$fila['imp_a_pagar']==0 ? '' : '$'.number_format($fila['imp_a_pagar'],2)
					,$fila['id_ciclo_escolar']
					,$fila['ciclo_escolar']
					,$fila['id_estatus']
					,$fila['nom_estatus']
					,($fila['id_estatus'] == 0) ? '' : date("d/m/Y", strtotime($fila['fec_estatus']))
					,($fila['id_estatus'] == 0) ? '' : $fila['num_modifico_estatus']
					// ,($fila['id_estatus'] == 0) ? '' : $fila['nom_modifico_estatus'])
					, $empleadoEstatus
					,$fila['num_tarjeta']
					,($fila['fec_baja'] == '1900-01-01 00:00:00') ? '' : date("d/m/Y", strtotime($fila['fec_baja']))	
					,$fila['des_observaciones']
				);
				$id++;
			
			}	
		try{
			echo json_encode($respuesta);
		} catch (Exception $ex) {
			//echo "Error: " . $ex->getMessage();
			echo "No se logro encode";
		}
	}
	catch(JsonException $ex){
		$json->estado = -2;
		$json->mensaje = "Error al cargar datos a Json"; //$ex->getMessage();

	}
 ?>