<?php

class CacheApp {
	public $hours_for_update = 5; // Tiempo que tardará en actualizar el caché en horas
	public $one_hour = 3600; // 1 hr = 3600 segundos
	public $localurl = "../../cache/temp";
	private $session_name = "";
	private $file_name = "";
	private $script_name = "";
	private $query_string = "";
	private $cache_file = "";
	
	function __construct($session_name, $file_name, $script_name, $query_string) {
		$this->session_name = $session_name;
		$this->file_name = $file_name;
		$this->script_name = basename($script_name, ".php");
		$this->query_string = $query_string;
		$this->cache_file = $this->session_name . "_" . $this->file_name . "_" . $this->script_name . ".json";
	}
	
	public function get_cache() {
		$json = new stdClass();
		$file_controller = -1;
		$file_string = "";
		
		try {
			if (!is_dir($this->localurl)) {
				mkdir($this->localurl);
			}
			
			$file = $this->localurl . "/" . $this->cache_file;
			$age_of_file = time() - filemtime($file);
			
			if(file_exists($file) && ( $age_of_file < ( $this->hours_for_update * $this->one_hour ) )) {		
				try {
					// Revisa si el archivo existe y si no ha expirado aún
					$file_string = file_get_contents($file);
					$json = json_decode($file_string, true); // Si el segundo parámetro es true, regresa un array; de lo contrario, regresa un objeto
					if ( trim($this->query_string) != trim($json["query"]) ) {
						$json["data"] = array();
					}
				} catch (\Throwable $th) {
					echo 'Error en la codificación JSON: ';
				}
			} else {
				if (file_exists($file)) {
					unlink($file);
				}
		
				try {
					$json->query = $this->query_string;
					$json->data = array();
					$json = json_encode($json);
					$json = json_decode($json, true);
				} catch (\Throwable $th) {
					echo 'Error en la codificación JSON: ';
				}
			}
		} catch (Exception $ex) {
			$desc_mensaje = $ex->getMessage();
			throw new Exception($desc_mensaje);
		}
		return $json;
	}
	
	public function set_cache($query_string, $ds) {
		try {
			$json = new stdClass();
			$json->query = $query_string;
			$json->data = $ds;
			
			if (!is_dir($this->localurl)) {
				mkdir($this->localurl);
			}
		
			try {
				$file = $this->localurl . "/" . $this->cache_file;
				$strJson = json_encode($json);
				file_put_contents ($file, $strJson);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
		} catch (Exception $ex) {
			$desc_mensaje = $ex->getMessage();
			throw new Exception($desc_mensaje);
		}
	}
	
	public function get_data($sOrderColumn, $sOrderType, $sColumns, $sSearchColumn, $sSearchValue, $sSearchType) {
		$cache = $this->get_cache();
		$rawdata = $cache["data"];
		$simple_array = array();
		
		$sSearchValue = $this->encode_to_utf8($sSearchValue);
		$filter_data = $sSearchColumn != "" && $sSearchValue != "" ? true : false;
		
		$aColumns = array();
		if (count($rawdata) != 0) {
			// Obtiene los nombres de las columnas
			if ( trim($sColumns) == "*" ) {
				// desde la primera fila
				foreach($rawdata[0] as $key => $value) {
					if ( $key === strtolower($key) )
						$aColumns[] = $key;
				}
			} else {
				$aColumns = explode(",",$sColumns);
				array_walk(
					$aColumns,
					function (&$entry) {
						$entry = strtolower(trim($entry));
					}
				);
			}
			
			// Pasar los datos a un arreglo simple y ordenarlo por la columna sOrderColumn
			foreach ($rawdata as $row) {
				// Formar array simple con los nombres de las columnas recabados en la sección anterior
				$new_row = array();
				foreach($aColumns as $colname) {
					$new_row[$colname] = $row[$colname];
				}
				// Filtrar los datos
				if ($filter_data) {
					if ($sSearchType === 'like') {
						if (!(mb_strpos($new_row[$sSearchColumn],$sSearchValue) === FALSE)) {
							$simple_array[] = $new_row;
						}
					} else if ($sSearchType === 'exact') {
						if ($new_row[$sSearchColumn] == $sSearchValue) {
							$simple_array[] = $new_row;
						}
					}
				} else {
					$simple_array[] = $new_row;
				}
			}
			
			// Ordenarlos
			if ($sOrderColumn != "") {
				$order = array();
				foreach ($simple_array as $key => $row) {
					$order[$key] = $row[ $sOrderColumn ];
				}
				
				if (strtolower($sOrderType) == 'desc')
					array_multisort($order, SORT_DESC, $simple_array);
				else
					array_multisort($order, SORT_ASC, $simple_array);
			}
			
			// Total de registros y páginas
			$response = array();
			
			// Obtiene los registros que coformarán los datos devueltos
			// Deben tener el siguiente formato
			// "rows" : [
				// ["cell11", "cell12", "cell13"],
				// ["cell21", "cell22", "cell23"],
				// ... ]
			$limit = count($simple_array);
			$start = 0;
			$i = (int)$start;
			for ($i = $start; $i < $limit; $i++ ) {
				$row = isset($simple_array[$i]) ? $simple_array[$i] : null;
				if ($row != null) {
					$row_data = array();
					foreach($aColumns as $colname) {
						$row_data[$colname] = $row[$colname];
					}
					$response[] = $row_data;
				}
			}
		}
		return $response;
	}
	
	public function get_data_grid($iCurrentPage, $iRowsPerPage, $sOrderColumn, $sOrderType, $sColumns, $sSearchColumn, $sSearchValue, $sSearchType) {
		require_once "jqgrid.class.php";
		
		$response = new stdClass();
		$cache = $this->get_cache();
		
		$jq_grid_cache = new JQGridCache($this->cache_file, $cache["data"], $sColumns);
		$response = $jq_grid_cache->get_data($iCurrentPage, $iRowsPerPage, $sOrderColumn, $sOrderType, $sSearchColumn, $sSearchValue, $sSearchType);
		
		return $response;
	}
	
	public function __get_data_grid($iCurrentPage, $iRowsPerPage, $sOrderColumn, $sOrderType, $sColumns, $sSearchColumn, $sSearchValue, $sSearchType) {
		$response = new stdClass();
		$response->page = $iCurrentPage;
		$response->total = 0;
		$response->records = 0;
		$cache = $this->get_cache();
		$rawdata = $cache["data"];
		$simple_array = array();
		
		// La búsqueda es sensible a mayúsculas y minúsculas
		$sSearchValue = $this->encode_to_utf8($sSearchValue); // ESTACIÃ³N -- ESTACIÃ“N ABUYA
		$filter_data = $sSearchColumn != "" && $sSearchValue != "" ? true : false;
		
		$aColumns = array();
		if (count($rawdata) != 0) {
			// Obtiene los nombres de las columnas
			if ( trim($sColumns) == "*" ) {
				// desde la primera fila
				foreach($rawdata[0] as $key => $value) {
					if ( $key === strtolower($key) )
						$aColumns[] = $key;
				}
			} else {
				$aColumns = explode(",",$sColumns);
				array_walk(
					$aColumns,
					function (&$entry) {
						$entry = strtolower(trim($entry));
					}
				);
			}
			
			// Pasar los datos a un arreglo simple y ordenarlo por la columna sOrderColumn
			foreach ($rawdata as $row) {
				// Formar array simple con los nombres de las columnas recabados en la sección anterior
				$new_row = array();
				foreach($aColumns as $colname) {
					$new_row[$colname] = $row[$colname];
				}
				// Filtrar los datos
				if ($filter_data) {
					if ($sSearchType === 'like') {
						if (!(mb_strpos($new_row[$sSearchColumn],$sSearchValue) === FALSE)) {
							$simple_array[] = $new_row;
						}
					} else if ($sSearchType === 'exact') {
						if ($new_row[$sSearchColumn] == $sSearchValue) {
							$simple_array[] = $new_row;
						}
					}
				} else {
					$simple_array[] = $new_row;
				}
			}
			
			// Ordenarlos
			$order = array();
			foreach ($simple_array as $key => $row) {
				$order[$key] = $row[ $sOrderColumn ];
			}
			
			if (strtolower($sOrderType) == 'desc')
				array_multisort($order, SORT_DESC, $simple_array);
			else
				array_multisort($order, SORT_ASC, $simple_array);
			
			// Total de registros y páginas
			try {
				$response->records = count($simple_array);
				$response->total = floor($response->records / $iRowsPerPage);
				$response->total += ( $response->records % $iRowsPerPage ) > 0 ? 1 : 0;
				$response->rows = array();
			} catch (\Throwable $th) {
				echo 'Error en la operacion / ';
			}
			
			// Obtiene los registros que coformarán los datos del grid
			// Deben tener el siguiente formato
			// "rows" : [
				// {"id" :"1", "cell" :["cell11", "cell12", "cell13"]},
				// {"id" :"2", "cell" :["cell21", "cell22", "cell23"]},
				// ... ]
			$limit = $response->page * $iRowsPerPage;
			$start = $limit - $iRowsPerPage;
			$i = (int)$start;
			for ($i = $start; $i < $limit; $i++ ) {
				$row = isset($simple_array[$i]) ? $simple_array[$i] : null;
				if ($row != null) {
					$row_data = array();
					foreach($aColumns as $colname) {
						$row_data[$colname] = $row[$colname];
					}
					$new_row = new stdClass();
					$new_row->id = $i;
					$new_row->cell = $row_data;
					
					$response->rows[] = $new_row;
				}
			}
		}
		return $response;
	}
	
	public function convert_array_to_utf8($ds) {
		array_walk_recursive(
			$ds,
			function (&$entry) {
				// $entry = iconv('Windows-1250', 'UTF-8', $entry);
				$entry = mb_convert_encoding($entry, "UTF-8", mb_detect_encoding($entry, "UTF-8, ISO-8859-1, ISO-8859-15", true)); //, Windows-1250
			}
		);
		
		return $ds;
	}
	
	public function encode_to_iso($string) {
		return mb_convert_encoding($string, "ISO-8859-1", mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true));
	}
	
	public function encode_to_utf8($string) {
		return mb_convert_encoding($string, "UTF-8", mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true)); //, Windows-1250
	}
	
	public function delete_cache($sNameOfFile) {
		$sPattern = "";
		$arr = array();
		try {
			if (is_dir($this->localurl)) {
				if ($dh = opendir($this->localurl)) {
					while (($file = readdir($dh)) !== false) {
						if (filetype($this->localurl . "/" . $file) == "file") {
							$fileName = $this->localurl . "/" . $file;
							if (strpos($fileName, $sNameOfFile) !== false) {
								unlink($fileName);
							}
						}
					}
					closedir($dh);
				}
			}
		} catch (Exception $ex) {
			$desc_mensaje = $ex->getMessage();
			throw new Exception($desc_mensaje);
		}
	}
	
	public function set_hours_for_update($hours) {
		$this->hours_for_update = $hours;
	}
}
