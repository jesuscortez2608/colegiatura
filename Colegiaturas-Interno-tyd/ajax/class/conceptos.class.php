<?php

class ConceptosSAT {
	public $catalogos;
	public $session;
	
	function __construct($session) {
		$this->catalogos = new stdClass();
		$this->session = $session;
	}
	
	function fun_actualizar_catalogos_sat() {
		try{
			$json = $this->fun_obtener_id_catalogos();
			foreach($json->data as $reg) {
				$ret = $this->fun_obtener_catalogos_sat($reg['iidu_tablassat']);
			}
		
		} catch (Exception $e) {
			$ret = "Ocurrió un error en conceptos.class 1";
		}
		
		return $ret;
	}
	
	function fun_obtener_id_catalogos() {
		$json = new stdClass();
		$json->estado = 0;
		$json->mensaje = "";
		$json->data = array();
		
		$ds = array();
		$query = "SELECT iidu_tablassat, sdes_tablassat FROM fun_obtenerIduCatalogo()";
		try {
			$CDB = obtenConexion(BDFACTURACIONELECTRONICA);
			$conexion = $CDB['conexion'];
			$CDB['conexion'] = str_replace('factelectronica', 'facturacionelectronica', $conexion);
			$estado = $CDB['estado'];
			$mensaje = $CDB['mensaje'];
			
			$con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			
	        $cmd->setCommandText("{CALL fun_obtenerIduCatalogo()}");
	        $ds = $cmd->executeDataSet();
	       	$con->close();
			
		} catch (Exception $ex) {
			$json->estado = -1;
			$json->mensaje = "Exception:  Error al intentar conectar con la base de datos";
		}
		
		$json->data = $ds;
		
		return $json;
	}
	
	function fun_obtener_catalogos_sat($id_catalogo) {
		$json = new stdClass();
		require_once '../../cache/cache.class.php';
		
		$estado = "";
		$mensaje = "";
		$bd = false;
		$script_name = basename($_SERVER['SCRIPT_NAME'], ".php");
		
		try {
			$query = "SELECT clave, des_clave FROM fun_obtenerCatalogosSat($id_catalogo::INTEGER, ''::VARCHAR, 1::INTEGER);";
			$cacheApp = new CacheApp($this->session, $id_catalogo, $_SERVER['SCRIPT_NAME'], $query); //iCatalogo se manda del .js
			$cache = $cacheApp->get_cache();
			
			if ( count($cache["data"]) <= 0 ) {
				$CDB = obtenConexion(BDFACTURACIONELECTRONICA);
				$conexion = $CDB['conexion'];
				$CDB['conexion'] = str_replace('factelectronica', 'facturacionelectronica', $conexion);
				$estado = $CDB['estado'];
				$mensaje = $CDB['mensaje'];
				
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				
				$cmd->setCommandText("SET client_encoding = 'UTF8';");
				$cmd->executeNonQuery();
				
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
			$values = "{";
			$i = 0;
			foreach ($ds as $row) { //Generar archivo catalogo
				$arr[] = array("clave" =>$row['clave']
					, "des_clave" => trim($row['des_clave']) );
				$values .= "\n" . "\t" . "\"idSAT" . $row['clave'] . "\" : \"" . trim($row['des_clave']) . "\",";
			}
			$values = substr($values, 0, strlen($values) - 1);
			$values .= "\n}";
			
			if ($bd) {
				// Actualizo el archivo de variables
				file_put_contents ("../../files/values/strval_" . $id_catalogo . ".json", $values);
			}
		} catch (Exception $ex) {
			$mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
			$estado=-2;
		}
		
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		$json->datos = array();
		if ($iObtenerDatos == 1) {
			$json->datos = $arr;
		}
		
		return $json;
	}
}