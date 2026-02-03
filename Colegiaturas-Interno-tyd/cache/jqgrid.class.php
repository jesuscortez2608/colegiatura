<?php

class JQGridCache {
	public $rawdata;
	public $columns;
	public $simple_array;
	public $cache_file;
	
	function __construct($cache_file, $rawdata, $sColumns) {
		// Parámetro: $rawdata; Arreglo de datos tal y cual proviene de la BD
		$this->cache_file = $cache_file;
		$this->rawdata = $rawdata;
		$this->columns = $this->obtain_columns($sColumns);
		$this->simple_array = $this->obtain_simple_array();
	}
	
	private function obtain_columns($sColumns) {
		$aColumns = array();
		if (count($this->rawdata) != 0) {
			// Obtiene los nombres de las columnas
			if ( trim($sColumns) == "*" ) {
				// desde la primera fila
				foreach($this->rawdata[0] as $key => $value) {
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
		}
		
		return $aColumns;
	}
	
	private function obtain_simple_array() {
		$this->simple_array = array();
		$rawdata = $this->rawdata;
		$aColumns = $this->columns;
		
		$simple_array = array();
		$idx = 0;
		foreach ($rawdata as $row) {
			// Formar array simple con los nombres de las columnas recabados en $this->columns
			$new_row = array();
			foreach($aColumns as $colname) {
				$new_row[$colname] = $row[$colname];
			}
			// Agregar columnas para 
				// opc_selected - campo para establecer u obtener un checkbox de <seleccionado>
				// keyx - una clave única con la cual actualizar datos del caché sin recurrir a la BD
				// row - un espacio donde depositar el registro completo tal y como está guardado en el caché
			try {		
				$new_row["keyx"] = $idx;
				$new_row["row"] = json_encode($row);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
			
			$simple_array[] = $new_row;
			
			$idx++;
		}
		
		return $simple_array;
	}
	
	public function get_data($iCurrentPage, $iRowsPerPage, $sOrderColumn, $sOrderType, $sSearchColumn, $sSearchValue, $sSearchType) {
		$response = new stdClass();
		$response->page = $iCurrentPage;
		$response->total = 0;
		$response->records = 0;
		$rawdata = $this->rawdata;
		$simple_array = array();
		
		// La búsqueda es sensible a mayúsculas y minúsculas
		$sSearchValue = $this->encode_to_utf8($sSearchValue); // ESTACIÃ³N -- ESTACIÃ“N ABUYA
		$filter_data = $sSearchColumn != "" && $sSearchValue != "" ? true : false;
		
		$aColumns = array();
		if (count($rawdata) != 0) {
			$aColumns = $this->columns;
			
			// Filtrar los datos
			if ($filter_data) {
				foreach($this->simple_array as $row) {
					if ($sSearchType === 'like') {
						if (!(mb_strpos($row[$sSearchColumn],$sSearchValue) === FALSE)) {
							$simple_array[] = $row;
						}
					} else if ($sSearchType === 'exact') {
						if ($row[$sSearchColumn] == $sSearchValue) {
							$simple_array[] = $row;
						}
					}
				}
			} else {
				$simple_array = $this->simple_array;
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
	
	public function encode_to_iso($string) {
		return mb_convert_encoding($string, "ISO-8859-1", mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true));
	}
	
	public function encode_to_utf8($string) {
		return mb_convert_encoding($string, "UTF-8", mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true)); //, Windows-1250
	}
}