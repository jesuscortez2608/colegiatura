<?php 
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// session_name("Session-Colegiaturas"); 
	// session_start();
	// $Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//VARIABLES DE PAGINACION

	//VARIABLES DE FILTRADO	
	$dFecha = isset($_GET['dFecha']) ? $_GET['dFecha'] : '';
	$iTipoDato = isset($_GET['iTipoDato']) ? $_GET['iTipoDato'] : 0;
	$iDato = isset($_GET['iDato']) ? $_GET['iDato'] : 0;
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();

	// IMRESIÓN DE EXCEL	
	require_once '../../../utilidadesweb/librerias/phpspreadsheet/vendor/autoload.php';
	use PhpOffice\PhpSpreadsheet\Spreadsheet;
	use PhpOffice\PhpSpreadsheet\Style\Fill;
	use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
	use PhpOffice\PhpSpreadsheet\Style\Border;
	use PhpOffice\PhpSpreadsheet\Style\Alignment;
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_exportar_excel_incentivos_colegiaturas.txt";
    } else 
	{		
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			$query = "SELECT * FROM FUN_CALCULA_INDICADORES_INTERNOS ($iTipoDato
								,  $iDato 
								,  '$dFecha')";

			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();
			$con->close();

			//VARIABLES GENERALES
			$reporte_tipo = ($iTipoDato == 1) ? 'CENTRO' : 'COLABORADOR';
			$nombre_cc = $ds[0]['nombre'];
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
			$json->estado=-2;		
		}

		ini_set('memory_limit', '-1');
		$objPHPExcel = new Spreadsheet();

		// Establecer propiedades
		$objPHPExcel->getProperties()
			->setCreator("Coppel - Sistemas administraci�n")
			->setLastModifiedBy("Coppel - Sistemas administraci�n")
			->setTitle("Documento Excel")
			->setSubject("Documento Excel")
			->setDescription("Sin descripci�n.")
			->setKeywords("Excel Office 97 php")
			->setCategory("Exportar a Excel");
		
		// Add some data
		$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', 'Indicadores Internos '.$reporte_tipo)
		->setCellValue('E1', $nombre_cc)
		->setCellValue('C2', 'MENSUAL')
		->setCellValue('M2', 'ACUMULADO')
		->setCellValue('V2', 'ANUAL MÓVIL')
				->setCellValue('A3', 'Año')
				->setCellValue('B3', 'Mes')

				->setCellValue('C3', 'Días de Revisión')
				->setCellValue('D3', 'Solicitudes')
				->setCellValue('E3', 'Meta')
				->setCellValue('F3', 'Tiempo Promedio')
				->setCellValue('G3', '% Cumplimiento')
				->setCellValue('H3', '#Rev. en Tiempo')
				->setCellValue('I3', '% Eficiencia')
				->setCellValue('J3', 'Meta % de Eficiencia')
				->setCellValue('K3', '% Cumplimiento Eficiencia')

				->setCellValue('L3', 'Días de Revisión')
				->setCellValue('M3', 'Solicitudes')
				->setCellValue('N3', 'Meta')
				->setCellValue('O3', 'Tiempo Promedio')
				->setCellValue('P3', '% Cumplimiento')
				->setCellValue('Q3', '#Rev. en Tiempo')
				->setCellValue('R3', '% Eficiencia')
				->setCellValue('S3', 'Meta % de Eficiencia')
				->setCellValue('T3', '% Cumplimiento Eficiencia')
				
				->setCellValue('U3', 'Días de Revisión')
				->setCellValue('V3', 'Solicitudes')
				->setCellValue('W3', 'Meta')
				->setCellValue('X3', 'Tiempo Promedio')
				->setCellValue('Y3', '% Cumplimiento')
				->setCellValue('Z3', '#Rev. en Tiempo')
				->setCellValue('AA3', '% Eficiencia')
				->setCellValue('AB3', 'Meta % de Eficiencia')
				->setCellValue('AC3', '% Cumplimiento Eficiencia');

		 $objPHPExcel->setActiveSheetIndex(0)->mergeCells('A1:D1');
		 $objPHPExcel->setActiveSheetIndex(0)->mergeCells('A2:B2');
		 $objPHPExcel->setActiveSheetIndex(0)->mergeCells('C2:K2');
		 $objPHPExcel->setActiveSheetIndex(0)->mergeCells('L2:T2');
		//  $objPHPExcel->setActiveSheetIndex(0)->mergeCells('U2:AC2');

		//creando estilos para las celdas (Encabezado)
		$style_titulo = [
			'font' => [
				'bold' => true,
				'color' => ['rgb' => 'FFFFFF'], // Color blanco
			],
			'fill' => [
				'fillType' => Fill::FILL_SOLID,
				'startColor' => ['rgb' => '307ECC'], // Color de fondo a celda
			],
			'alignment' => [
				'horizontal' => Alignment::HORIZONTAL_LEFT,
				'vertical' => Alignment::VERTICAL_CENTER,
			],
		];

		$style_encabezado = array(
			'borders' => [
				'outline' => [
					'borderStyle' => Border::BORDER_THIN,
					'color' => ['rgb' => '000000'],
				],
			],
			'fill' => [
				'fillType' => Fill::FILL_SOLID,
				'startColor' => [
					'rgb' => '365266', //9B9B9B
				],
			],
			'alignment' => [
				'horizontal' => Alignment::HORIZONTAL_CENTER, // Center alignment
				'vertical' => Alignment::VERTICAL_CENTER, // Center alignment
			],
			'font' => [
				'color' => ['rgb' => 'FFFFFF'], // Color blanco
			],
			
			'color' => ['rgb' => 'FFFFFF'], 
		);

		$style_campos = array(
			'borders' => [
				'outline' => [
					'borderStyle' => Border::BORDER_THIN,
					'color' => ['rgb' => '000000'],
				],
			],
			'fill' => [
				'fillType' => Fill::FILL_SOLID,
				'startColor' => [
					'rgb' => '75A0CA',
				],
			],
			'alignment' => [
				'horizontal' => Alignment::HORIZONTAL_CENTER, // Center alignment
				'vertical' => Alignment::VERTICAL_CENTER, // Center alignment
			],
		);
		/*****************************DATOS*******************************/

		$fila = 4;
		foreach ($ds as $datos) {			
			$per_cumplimiento_mes = isset($datos['per_cumplimiento_mes']) ? (substr($datos['per_cumplimiento_mes'], -3) === '.00' ? substr($datos['per_cumplimiento_mes'], 0, -3) . '%' : $datos['per_cumplimiento_mes'] . '%') : '';
			$per_eficiencia_mes = isset($datos['per_eficiencia_mes']) ? (substr($datos['per_eficiencia_mes'], -3) === '.00' ? substr($datos['per_eficiencia_mes'], 0, -3) . '%' : $datos['per_eficiencia_mes'] . '%') : '';
			$per_cumpli_efic_mes = isset($datos['per_cumpli_efic_mes']) ? (substr($datos['per_cumpli_efic_mes'], -3) === '.00' ? substr($datos['per_cumpli_efic_mes'], 0, -3) . '%' : $datos['per_cumpli_efic_mes'] . '%') : '';
	
			$per_cumplimiento_acum = isset($datos['per_cumplimiento_acum']) ? (substr($datos['per_cumplimiento_acum'], -3) === '.00' ? substr($datos['per_cumplimiento_acum'], 0, -3) . '%' : $datos['per_cumplimiento_acum'] . '%') : '';
			$per_eficiencia_acum = isset($datos['per_eficiencia_acum']) ? (substr($datos['per_eficiencia_acum'], -3) === '.00' ? substr($datos['per_eficiencia_acum'], 0, -3) . '%' : $datos['per_eficiencia_acum'] . '%') : '';
			$per_cumpli_efic_acum = isset($datos['per_cumpli_efic_acum']) ? (substr($datos['per_cumpli_efic_acum'], -3) === '.00' ? substr($datos['per_cumpli_efic_acum'], 0, -3) . '%' : $datos['per_cumpli_efic_acum'] . '%') : '';
	
			$per_cumplimiento_movil = isset($datos['per_cumplimiento_movil']) ? (substr($datos['per_cumplimiento_movil'], -3) === '.00' ? substr($datos['per_cumplimiento_movil'], 0, -3) . '%' : $datos['per_cumplimiento_movil'] . '%') : '';
			$per_eficiencia_movil = isset($datos['per_eficiencia_movil']) ? (substr($datos['per_eficiencia_movil'], -3) === '.00' ? substr($datos['per_eficiencia_movil'], 0, -3) . '%' : $datos['per_eficiencia_movil'] . '%') : '';
			$per_cumpli_efic_movil = isset($datos['per_cumpli_efic_movil']) ? (substr($datos['per_cumpli_efic_movil'], -3) === '.00' ? substr($datos['per_cumpli_efic_movil'], 0, -3) . '%' : $datos['per_cumpli_efic_movil'] . '%') : '';
			
				//MENSUAL
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("A" . $fila, $datos['anio']);
				$objPHPExcel->getActiveSheet()->getStyle("A" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);			
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("B" . $fila, $datos['mes']);
				$objPHPExcel->getActiveSheet()->getStyle("B" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("C" . $fila, (number_format($datos['dias_revision_mes'], 0 ,"." ,"," )));
				$objPHPExcel->getActiveSheet()->getStyle("C" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);		

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("D" . $fila, (number_format($datos['solicitudes_mes'], 0, '.', ',')));
				$objPHPExcel->getActiveSheet()->getStyle("D" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("E" . $fila, $datos['meta_mes']);
				$objPHPExcel->getActiveSheet()->getStyle("E" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("F" . $fila,$datos['tiempo_promedio_mes']);
				$objPHPExcel->getActiveSheet()->getStyle("F" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("G" . $fila, $per_cumplimiento_mes);
				$objPHPExcel->getActiveSheet()->getStyle("G" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("H" . $fila, (number_format($datos['rev_tiempo_mes'], 0 ,"." ,"," )));
				$objPHPExcel->getActiveSheet()->getStyle("H" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("I" . $fila, number_format($datos['eficiencia_mes'], 2 ,"." ,"," ).'%');
				$objPHPExcel->getActiveSheet()->getStyle("I" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("J" . $fila, $per_eficiencia_mes);
				$objPHPExcel->getActiveSheet()->getStyle("J" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("K" . $fila, $per_cumpli_efic_mes);
				$objPHPExcel->getActiveSheet()->getStyle("K" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);				
				
				//ACUMULADO				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("L" . $fila, (number_format($datos['dias_revision_acum'], 0 ,"." ,"," )));
				$objPHPExcel->getActiveSheet()->getStyle("L" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);		

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("M" . $fila, number_format($datos['solicitudes_acum'], 0, '.', ','));
				$objPHPExcel->getActiveSheet()->getStyle("M" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("N" . $fila, $datos['meta_acum']);
				$objPHPExcel->getActiveSheet()->getStyle("N" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("O" . $fila,$datos['tiempo_promedio_acum']);
				$objPHPExcel->getActiveSheet()->getStyle("O" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("P" . $fila,$per_cumplimiento_acum);
				$objPHPExcel->getActiveSheet()->getStyle("P" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("Q" . $fila,number_format($datos['rev_tiempo_acum'], 0 ,"." ,"," ));
				$objPHPExcel->getActiveSheet()->getStyle("Q" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("R" . $fila, number_format($datos['eficiencia_acum'], 2 ,"." ,"," ).'%');
				$objPHPExcel->getActiveSheet()->getStyle("R" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("S" . $fila, $per_eficiencia_acum);
				$objPHPExcel->getActiveSheet()->getStyle("S" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("T" . $fila, $per_cumpli_efic_acum);
				$objPHPExcel->getActiveSheet()->getStyle("T" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);			
				
				//MÓVIL
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("U" . $fila, (number_format($datos['dias_revision_movil'], 0 ,"." ,"," )));
				$objPHPExcel->getActiveSheet()->getStyle("U" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);		

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("V" . $fila, number_format($datos['solicitudes_movil'], 0, '.', ','));
				$objPHPExcel->getActiveSheet()->getStyle("V" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("W" . $fila, $datos['meta_movil']);
				$objPHPExcel->getActiveSheet()->getStyle("W" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("X" . $fila,$datos['tiempo_promedio_movil']);
				$objPHPExcel->getActiveSheet()->getStyle("X" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("Y" . $fila,$per_cumplimiento_movil);
				$objPHPExcel->getActiveSheet()->getStyle("Y" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("Z" . $fila,(number_format($datos['rev_tiempo_movil'], 0 ,"." ,"," )));
				$objPHPExcel->getActiveSheet()->getStyle("Z" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("AA" . $fila, number_format($datos['eficiencia_movil'], 2 ,"." ,"," ).'%');
				$objPHPExcel->getActiveSheet()->getStyle("AA" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);	
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("AB" . $fila, $per_eficiencia_movil);
				$objPHPExcel->getActiveSheet()->getStyle("AB" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("AC" . $fila, $per_cumpli_efic_movil);
				$objPHPExcel->getActiveSheet()->getStyle("AC" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);				
		
			$fila++;
		}

		/*****************************TOTALES***************************/
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("A" . $fila, "TOTAL COLABORADORES: ".$colaboradores);
		// $objPHPExcel->getActiveSheet()->getStyle("A" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);			
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("B" . $fila,(number_format($totales_importe, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("B" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);			
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("C" . $fila,(number_format($totales_isr, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("C" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);		

		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("D" . $fila,(number_format($totales, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("D" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);	
		

		/*****************************FIN DATOS***************************/
		$objPHPExcel->getActiveSheet()->getStyle('A1:AC1')->applyFromArray($style_titulo);

		$objPHPExcel->getActiveSheet()->getStyle('A2:AC2')->applyFromArray($style_encabezado);
		
		$objPHPExcel->getActiveSheet()->getStyle('A3:AC3')->applyFromArray($style_campos);
		
		$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getRowDimension('1')->setRowHeight(20);
		
		$objPHPExcel->getActiveSheet()->getRowDimension('3')->setRowHeight(15);
		
		$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setAutoSize(true);			
		$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('E')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('F')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('G')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('H')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('I')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('J')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('K')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('L')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('M')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('N')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('O')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('P')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('Q')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('R')->setAutoSize(true);	
		$objPHPExcel->getActiveSheet()->getColumnDimension('S')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('T')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('U')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('V')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('W')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('X')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('Y')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('Z')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('AA')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('AB')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('AC')->setAutoSize(true);
		
		/// Renombrando Hoja
		$objPHPExcel->getActiveSheet()->setTitle('Indicadores Internos '.$reporte_tipo);

		header('Content-Type: application/vnd.ms-excel');
		header('Content-Disposition: attachment;filename="IndicadoresInternos'.$reporte_tipo.'.xls"');
		header('Cache-Control: max-age=0');

		//$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
		$objWriter = new Xlsx($objPHPExcel, 'Excel5');
		$objWriter->save('php://output');
    }	
 ?>