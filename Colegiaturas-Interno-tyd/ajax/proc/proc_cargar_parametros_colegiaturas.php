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
	
	$estado = "";
	$mensaje = "";
	$bd = false;
	$iObtenerDatos = 0;
	$script_name = basename($_SERVER['SCRIPT_NAME'], ".php");
	try {
		$query = "SELECT idparametro, stipoparametro, svalorparametro, snomparametro FROM fun_obtener_parametros_colegiaturas('');";
		$cacheApp = new CacheApp($Session, 'param', $_SERVER['SCRIPT_NAME'], $query); //iCatalogo se manda del .js
		$cacheApp->set_hours_for_update(1);
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
			$estado = 1;
			$mensaje = "Datos obtenidos desde la BD";
		} else {
			$estado = 1;
			$mensaje = "Datos obtenidos desde Cache";
			$ds = $cache["data"];
		}
		
		$arr = array();  //Trae datos para el archivo
		$values = "";
		$values .= "var oParametrosColegiaturas = {";
		$i = 0;
		foreach ($ds as $row) { //Generar archivo catalogo
			$iObtenerDatos = 1;
			$arr[] = array("snomparametro" =>trim($row['snomparametro'])
				, "svalorparametro" => trim($row['svalorparametro']) );
			$values .= "\n" . "\t" . "\"" . $row['snomparametro'] . "\" : \"" . trim($row['svalorparametro']) . "\",";
		}
		$values = substr($values, 0, strlen($values) - 1);
		$values .= "\n};\n";
		$values .= "";
		
		if ($bd) {
			// Actualizo el archivo de variables
			file_put_contents ("../../files/values/parametros_colegiaturas.js", $values);
		}
	} catch (Exception $ex) {
		$mensaje = "Ocurrió un error al intentar conectar a la base de datos.";
		$estado=-2;
	}
	try {		
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		$json->datos = array();
		if ($iObtenerDatos == 1) {
			$json->datos = $arr;
		}

		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}