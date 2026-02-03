<?php
	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	
	$Session = $_GETS['session_name'];
	$iUsuario = $_SESSION[$Session]['USUARIO']['num_empleado'];
	$idsession = $_SESSION[$Session]['USUARIO']['num_empleado'];
	$G_nemp = $_SESSION[$Session]['USUARIO']['num_empleado'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../cache/cache.class.php';
	
	$estado = "";
	$mensaje = "";
	
	$script_name = basename($_SERVER['SCRIPT_NAME'], ".php");
	$_GETI = filter_input_array(INPUT_POST, FILTER_SANITIZE_NUMBER_INT); //para gets y post
	$_GETS = filter_input_array(INPUT_POST, FILTER_SANITIZE_SPECIAL_CHARS); //para gets y post

	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = isset($_GET['sidx']) ? $_GET['sidx'] : 'idu_localidad';
	$sOrderType = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$sSearchField = isset($_GET['search_field']) ? $_GET['search_field'] : '';
	$sSearchValue = isset($_GET['search_value']) ? $_GET['search_value'] : '';
	$sSearchType = isset($_GET['search_type']) ? $_GET['search_type'] : '';
	$sColumns = 'idfactura,fec_factura,fol_factura,serie,id_empleado,nom_empleado,id_centro, nom_centro,ottp,fec_captura,id_escuela,nom_escuela,imp_factura,fec_pago,id_rutapago,nom_rutapago,imp_a_pagar,id_ciclo_escolar,ciclo_escolar,id_estatus,nom_estatus,fec_estatus,num_modifico_estatus, nom_modifico_estatus,num_tarjeta,fec_baja,des_observaciones'; // '*' también es válido
	$sColumns = '*';
	
	$iEstatus = $_GETS['estatus'];
	$dFechaini = $_GETS['fechaini'];
	$dFechafin = $_GETS['fechafin'];
	$iCheckFecha = isset($_GET['CheckFecha']) ? $_GETI['CheckFecha'] : 0;	
	$cFolioFactura = isset($_GET['FolioFactura']) ? $_GET['FolioFactura'] : '';
	
	$sSearchField = 'fol_factura';
	$sSearchValue = $cFolioFactura;
	$sSearchType = "like";
	
	try {
		$query = "SELECT idfactura
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
				FROM fun_obtener_listado_facturas_colegiaturas ($iEstatus, $iCheckFecha, '$dFechaini', '$dFechafin')";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		// $cacheApp = new CacheApp($Session, "csp_" . $iEstatus . "_" . $dFechaini . "_" . $dFechafin, $_SERVER['SCRIPT_NAME'], $query);
		$cacheApp = new CacheApp($Session, "csp_" . $iEstatus . "_" . $dFechaini . "_" . $dFechafin, $_SERVER['SCRIPT_NAME'], $query);
		$cacheApp->set_hours_for_update(0.08); // 5 minutos
		$cache = $cacheApp->get_cache();
		
		if ( count($cache["data"]) <= 0 ) {
			$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
			$estado = $CDB['estado'];
			$mensaje = $CDB['mensaje'];
			$json = new stdClass();
			if($estado != 0){
				$estado = -1;
				$mensaje = date("g:i:s a")." -> Error al conectar [BDPERSONALPOSTGRESQLVERSIONNUEVA]";
				$ds = array();
			} else {
				$estado = 1;
				$mensaje = "Datos obtenidos desde la BD";
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				$cmd->setCommandText($query);
				$ds = $cmd->executeDataSet();
				$con->close();
				$ds = $cacheApp->convert_array_to_utf8($ds);
				$cacheApp->set_cache($query, $ds);
				$cache = $cacheApp->get_cache();
			}
		} else {
			$estado = 1;
			$mensaje = "Datos obtenidos desde Cache";
			$ds = $cache["data"];
		}
		
		$respuesta = new stdClass();
		$respuesta = $cacheApp->get_data_grid($iCurrentPage, $iRowsPerPage, $sOrderColumn, $sOrderType, $sColumns, $sSearchField, $sSearchValue, $sSearchType);
		$respuesta->estado = $estado;
		$respuesta->mensaje = $mensaje;
		
		echo json_encode($respuesta);
	} catch (JsonException $ex) {
		
		$json->estado = -2;
		$json->mensaje = "Error al cargar datos a Json"; //$ex->getMessage();
		$json->datos = array();
		try{
		echo json_encode($json);
		}
		catch(JsonException $ex){
			$json->estado = -2;
			$json->mensaje = "Error al cargar datos a Json"; //$ex->getMessage();

		}
	}