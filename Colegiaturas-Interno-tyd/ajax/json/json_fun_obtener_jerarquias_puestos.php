<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	
	$_REQUESTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);
	$Session = $_REQUESTS['session_name'];
	$iUsuario = $_SESSION[$Session]['USUARIO']['num_empleado'];
	$idsession = $_SESSION[$Session]['USUARIO']['num_empleado'];
	$G_nemp = $_SESSION[$Session]['USUARIO']['num_empleado'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../cache/cache.class.php';
	
	$estado = "";
	$mensaje = "";
	
	$script_name = basename($_SERVER['SCRIPT_NAME'], ".php");
	
	// Variables de búsqueda
	$sOrderColumn = isset($_REQUEST['order_column']) ? $_REQUEST['order_column'] : '';
	$sOrderType = isset($_REQUEST['order_type']) ? $_REQUEST['order_type'] : '';
	$sSearchField = isset($_REQUEST['search_field']) ? $_REQUEST['search_field'] : '';
	$sSearchValue = isset($_REQUEST['search_value']) ? $_REQUEST['search_value'] : '';
	$sSearchType = isset($_REQUEST['search_type']) ? $_REQUEST['search_type'] : '';
	$sColumns = 'idu_puesto, nom_puesto, nivel_jerarquico'; // '*' también es válido
	
	// Obtener los puestos y su nivel jerarquico
	// y guardarlos en un arreglo
	try {
		$query = "SELECT idu_puesto
						, nom_puesto
						, nivel_jerarquico
				FROM fun_obtener_jerarquias_puestos()";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cacheApp = new CacheApp($Session, "csp_", $_SERVER['SCRIPT_NAME'], $query);
		$cacheApp->set_hours_for_update(24); // Actualiza cada 24 horas
		$cache = $cacheApp->get_cache();
		
		if ( count($cache["data"]) <= 0 ) {
			$CDB = obtenConexion(BDADMINISTRACIONPOSTGRESQL);
			$estado = $CDB['estado'];
			$mensaje = $CDB['mensaje'];
			$json = new stdClass();
			if($estado != 0){
				$estado = -1;
				$mensaje = date("g:i:s a")." -> Error al conectar [BDADMINISTRACIONPOSTGRESQL]";
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
			$estado = 2;
			$mensaje = "Datos obtenidos desde Cache";
			$ds = $cache["data"];
		}
		
		$respuesta = new stdClass();
		$respuesta->datos = $cacheApp->get_data($sOrderColumn, $sOrderType, $sColumns, $sSearchField, $sSearchValue, $sSearchType);
		$respuesta->estado = $estado;
		$respuesta->mensaje = $mensaje;

		try {
			echo json_encode($respuesta);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}

	} catch (Exception $ex) {

		try {
			$json->estado = -2;
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
			$json->datos = array();
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	
	