<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

class InteraccionAlfresco {
	public $url_servicio = "";
	public $usuario = "";
	public $password  = "";
	public $ciclo_escolar = "";
	public $directorio = "Personal/Colegiaturas";
	public $wsclient = NULL;
	
	function __construct() {
		
		$this->consultarSapIpsAdmon();
	
		if ($this->usuario == "") {
			$clave_alfresco = ADMINISTRACIONALFRESCO;
			throw new Exception("No fue posible obtener los datos del servicio de Alfresco ($clave_alfresco)");
		}
		try{
			
			$this->wsclient = new SoapClient($this->url_servicio, array('cache_wsdl' => WSDL_CACHE_NONE));

		} catch(Exception $ex) {
			$mensaje = "Ocurrió un error al intentar conectar RR.".$ex->getMessage();
		}

		if (!$this->validarConexionAlfresco()) {

			throw new Exception("No se obtuvo respuesta del servicio de Alfresco");
		}
		
	}
	
	function __destroy(){
		
	}
	
	function getExtensionArchivo($filename) {
		return substr(strrchr($filename, '.'), 1);
	}
	
	function getBase64($url) {
	//	$url = filter_var($url, FILTER_VALIDATE_URL);
		$url = filter_var($url, FILTER_SANITIZE_SPECIAL_CHARS);
	//	print_r($url);
	//	exit();
		if($fp = fopen($url,"rb", 0)) {
			$picture = fread($fp,filesize($url));
			fclose($fp);
			$base64 = chunk_split(base64_encode($picture));
			return $base64;
		}
	}
	
	function consultarSapIpsAdmon() {
		// --------------------------------------------------------
		// Preparar conexión con la base de datos
		$conexion = obtenConexion(BDSYSCOPPELPERSONALSQL);
		if ($conexion["estado"] != 0) {
			throw new Exception("Error en la conexion con Personal SQLServer: " . $conexion["mensaje"]);
		}
		
		$cadena_conexion = $conexion["conexion"];
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$clave_alfresco = ADMINISTRACIONALFRESCO;
		// echo ("{CALL SAPACCESOSDATOS ($clave_alfresco)}");
		// exit();
		$cmd->setCommandText("{CALL SAPACCESOSDATOSWEB ($clave_alfresco,1)}");
		$ds = $cmd->executeDataSet();

		
		$connectionString = $ds[0]['connectionstring'];
		$queryString = str_replace(';', '&', $connectionString);
		parse_str($queryString, $parsedArray);
		
		$ip = $parsedArray["SERVERNAME"];
		
		$this->url_servicio = "https://$ip/alfresco/ws_server.php?wsdl";

		$this->usuario = $parsedArray["UID"];
		$this->password = $parsedArray["PWD"];

	}
	
	function validarConexionAlfresco(){
		$response = NULL;
		$directorio = "Personal";
		try{
			$doc = array('user'=>$this->usuario,
					'password'=>$this->password,
					'path'=>'Personal/Colegiaturas');
					// 'path'=>"/");
			
			$response = $this->wsclient->getContent($doc);

			if (isset($response[0])) {
				return TRUE;
			} else {
				return FALSE;
			}
		} catch (Exception $ex) {
			return FALSE;
		}
	}
	
	function setCiclo($ciclo) {
		// Validar si existe la carpeta del ciclo escolar
		$this->ciclo_escolar = $ciclo;
		if (!$this->existeCarpeta($this->directorio, $ciclo)) {
			// Si no existe debe crearla
			if ( !$this->crearCarpeta($this->directorio, $ciclo) ) {
				throw new Exception("No se pudo crear la carpeta para el ciclo escolar $ciclo");
			}
		}
	}
	
	function existeCarpeta($directorio, $carpeta){
		try{
			$response = NULL;
			$doc = array('user'=>$this->usuario,
					'password'=>$this->password,
					'path'=>$directorio);
			$response = $this->wsclient->getContent($doc);
			
			if (!isset($response[0])) {
				return FALSE;
			} else {
				$existecarpeta = FALSE;
				for($i = 0; $i < count($response); $i++) {
					if (  strtoupper(trim($response[$i]->name)) == strtoupper($carpeta)  ) {
						$existecarpeta = TRUE;
					}
				}
				
				return $existecarpeta;
			}
		} catch (Exception $ex) {
			return FALSE;
		}
	}
	
	function crearCarpeta($directorio, $carpeta) {
		try{
			$doc =array('user'=>$this->usuario,
					'password'=>$this->password,
					'path'=>$directorio,
					'name'=>$carpeta,
					'title'=>'Title',
					'description'=>'Description'
				);
			$response = $this->wsclient->createNode($doc);
			return $response->success;
		} catch (Exception $ex) {
			return false;
		}
	}
	
	function guardarDocumento($idu_empleado, $filename, $base64file) {
		if ($this->ciclo_escolar == "") {
			throw new Exception("No ha especificado el ciclo escolar donde se guardará el documento");
		}
		
		if (!$this->existeCarpeta($this->directorio . '/' . $this->ciclo_escolar, $idu_empleado)) {
			if (!$this->crearCarpeta($this->directorio . '/' . $this->ciclo_escolar, $idu_empleado)) {
				throw new Exception("No fue posible crear el directorio par el empleado: " . $this->directorio . '/' . $this->ciclo_escolar . '/' . $idu_empleado);
			}
		}
		
		try{
			$doc3 = new stdClass();
			$doc3->user = $this->usuario;
			$doc3->password = $this->password;
			$doc3->path = $this->directorio . '/' . $this->ciclo_escolar . '/' . $idu_empleado;
			$doc3->fileName = $filename;
			$doc3->fileContent = $base64file;
			$doc3->replaceFile = true;
			
			$response=$this->wsclient->uploadFile($doc3);

			return $response->success; // antes $response->return;
		} catch (Exception $ex) {
			return false;
		}
	}
	
	function eliminarDocumento($idu_empleado, $filename) {
		if ($this->ciclo_escolar == "") {
			throw new Exception("No ha especificado el ciclo escolar");
		}
		
		try{
			$doc3 = new stdClass();
			$doc3->user = $this->usuario;
			$doc3->password = $this->password;
			$doc3->path =$this->directorio . '/' . $this->ciclo_escolar . '/' . $idu_empleado;
			$doc3->fileName = $filename;
			$doc3->dataTypeReturn = 'NORMAL';
			
			$response = $this->wsclient->deleteFile($doc3);
			
			return $response->success; // antes $response->return;
		} catch (Exception $ex) {
			return false;
		}
	}
	
	function obtenerUrlImagen($idu_empleado, $filename) {
		if ($this->ciclo_escolar == "") {
			throw new Exception("No ha especificado el ciclo escolar de donde se obtendrá el documento");
		}
		
		try{

			$doc3 = new stdClass();
			$doc3->user = $this->usuario;
			$doc3->password = $this->password;
			$doc3->path = $this->directorio . '/' . $this->ciclo_escolar . '/' . $idu_empleado;
			$doc3->dataTypeReturn = 'NORMAL';

			
			
			$response=$this->wsclient->getContent($doc3);
			
			$i = 0;
			$max = sizeof($response);
			$urlimagen = '';
			
			for ($i = 0; $i < $max; $i++) {
				if ( trim($response[$i]->name) == $filename ) {
					$urlimagen = trim($response[$i]->url);
				}
			}
			
			return $urlimagen; // antes $response->return;
		} catch (Exception $ex) {
			return '';
		}
	}
	
	function getContext() {
		$username = $this->usuario;
		$password = $this->password;
		
		$context = stream_context_create(array(
			'http' => array(
				'header'  => "Authorization: Basic " . base64_encode("$username:$password")
			)
		));
		
		return $context;
	}
	
	function obtenerSecuenciaDocumento() {
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];  
		$mensaje = $CDB['mensaje'];
		$secuencia = 0;
		
		$json = new stdClass(); 
		$datos = array();	
		if($estado != 0) {
			return -1;
		}
		
		try {
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$cmd->setCommandText("SELECT fun_obtener_secuencia_colegiaturas() AS secuencia");
			$ds = $cmd->executeDataSet();
			
			$secuencia = $ds[0]['secuencia'];
		} catch(exception $ex) {
			$secuencia=-2;
		}
		
		return $secuencia;
	}
}
?>