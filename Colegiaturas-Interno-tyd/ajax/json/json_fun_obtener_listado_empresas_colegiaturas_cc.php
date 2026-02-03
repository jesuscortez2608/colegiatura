<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = "Colegiaturas";
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	require_once '../../cache/cache.class.php';
	
	$actualizar = isset($_GET['actualizar']) ? $_GET['actualizar'] : '0';
    
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	/** 
	 *  Cargar parámetros de colegiaturas
	 *  fun_obtener_parametros_colegiaturas('')
	 *      ctl_parametros_colegiaturas
	-------------------------------------------------- */
	
	$json = new stdClass();
	$arr = array();
	$estado = 0;
	$mensaje = "";
	$bd = false;
	$script_name = basename($_SERVER['SCRIPT_NAME'], ".php");
	try {
		$query = "SELECT * FROM fun_obtener_listado_empresas_colegiaturas()";
		$cacheApp = new CacheApp($Session, 'empresas', $_SERVER['SCRIPT_NAME'], $query);
		$cacheApp->set_hours_for_update(24*7); // Cada semana
		$cache = $cacheApp->get_cache();
		
		if ( count($cache["data"]) <= 0 || $actualizar == '1' ) {
			$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
			$conexion = $CDB['conexion'];
			$estado = $CDB['estado'];
			$mensaje = $CDB['mensaje'];
			
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			
			$cacheApp->set_cache($query, $ds);
			
			$bd = true;
			$estado = 0;
			$mensaje = "Datos obtenidos desde la BD";
		} else {
			$estado = 0;
			$mensaje = "Datos obtenidos desde Cache";
			$ds = $cache["data"];
		}
		
		foreach($ds as $value) {
			$arr[] = array(
				'value' => $value['idu_empresa'], 'nombre' => encodeToUtf8($value['nom_empresa']), 'rfc' => encodeToUtf8($value['rfc'])
				);
		}
	} catch (Exception $ex) {
		//$mensaje = $ex->getMessage();
		$mensaje = "error al realizar consulta SQL";
		$estado=-2;
	}
	
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	$json->datos = $arr;
	try
	{
	echo json_encode($json);
	}
	catch(JsonException $ex)
	{
		$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
		$json->estado=-2;
	}