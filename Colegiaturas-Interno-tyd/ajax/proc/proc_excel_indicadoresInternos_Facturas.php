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
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dias_respuesta';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$columns = 'numemp, nombre,reembolsoConIsr, reembolsoSinIsr, region, folio_fiscal,nom_escolaridad,fecha_solicitud,fecha_autoriza_gerente, fecha_reviso_analista, fecha_pago, nom_estatus,dias_respuesta,
	anio, mes,nom_analista, numcentro_analista, nomcentro_analista, mes_rev_analista, anio_rev_analista';

	//VARIABLES DE FILTRADO
	$fechaIni = isset($_GET['FechaIni']) ? $_GET['FechaIni'] : '20200101';
	$fechaFin = isset($_GET['FechaFin']) ? $_GET['FechaFin'] : '20240101';
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	
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
			$query = "SELECT * FROM FUN_OBTENER_FACTURAS_INDICADORES_INTERNOS ($iEstatus
						, '$fechaIni'
						, '$fechaFin'
						, null
						, null
						, '$orderby'
						, '$ordertype'
						, '$columns')";

			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();
			$con->close();

			//CONEXIÓN A SQL SERVER
			$CDB = obtenConexion(BDPERSONALSQLSERVER);
			$CCSS = $CDB['conexion'];
			$con = new OdbcConnection($CCSS);
			$con->open();
			$cmdss = $con->createCommand();

			//VARIABLES GENERALES
			$nom_estatus = ($iEstatus == "-1") ? "TODOS" : $matriz[0]['nom_estatus'];
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
		->setCellValue('A1', 'Indicadores Internos Facturas')
		->setCellValue('C1', $nom_estatus)
				->setCellValue('A3', 'Número de Colaborador')
				->setCellValue('B3', 'Nombre')
				->setCellValue('C3', 'Monto a Reembolsar (CON ISR)')
				->setCellValue('D3', 'Monto a Reembolsar (SIN ISR)')
				->setCellValue('E3', 'Región')
				->setCellValue('F3', 'Folio Fiscal')
				->setCellValue('G3', 'Escolaridad')
				->setCellValue('H3', 'Analista')
				->setCellValue('I3', 'Fecha Solicitud')
				->setCellValue('J3', 'Fecha Autoriza')
				->setCellValue('K3', 'Fecha Revisión')
				->setCellValue('L3', 'Fecha Pago')
				->setCellValue('M3', 'Estatus')
				->setCellValue('N3', 'Días de Respuesta')
				->setCellValue('O3', 'Año')
				->setCellValue('P3', 'Mes')
				->setCellValue('Q3', 'Centro')
				->setCellValue('R3', 'Mes Revisión Analista')
				->setCellValue('S3', 'Año Revisión');

		 $objPHPExcel->setActiveSheetIndex(0)->mergeCells('A1:B1');

		//creando estilos para las celdas (Encabezado)
		$style_titulo = array(
			'font' => array(
				'bold' => TRUE,
				'color' => array(
					'argb' => 'FFFFFF')
			),
			'fill' => array(
				'type' => Fill::FILL_SOLID,
				'color' => array(
					'argb' => 'FF307ECC'),//color de fondo a celda
			),'alignment' => array(
				'horizontal' => Alignment::HORIZONTAL_LEFT,
				'vertical' => Alignment::HORIZONTAL_CENTER,
			)
		);

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
					'rgb' => '9B9B9B',
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
			$numemp = $datos['numemp'];
			$importe = str_replace(".", "", $datos['reembolsosinisr']); 
			
			// CALCULA ISR
			try
			{
				$cmdss->setCommandText("{CALL proc_generar_isr_colegiaturas $numemp, '<Root><r e=\"$numemp\" i=\"$importe\"></r></Root>'}");
				$ds = $cmdss->executeDataSet();
				
			}
			catch(exception $ex)
			{
				$mensaje="Ocurrió un error al intentar conectarse a la base de datos server";
				$estado=-2;
			}

			$isr_colegiatura = number_format($ds[0]['isr_colegiatura'] / 100, 2);
			//CALCULA ISR

				$fecha_solicitud = ($datos['fecha_solicitud'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($datos['fecha_solicitud']));
				$fecha_autoriza_gerente = ($datos['fecha_autoriza_gerente'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($datos['fecha_autoriza_gerente']));
				$fecha_revision_analista = ($datos['fecha_reviso_analista'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($datos['fecha_reviso_analista']));
				$fecha_pago = ($datos['fecha_pago'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($datos['fecha_pago']));
				$centro_analista = ($datos['numcentro_analista'] == 0) ? '' : $datos['numcentro_analista']. ' ' .$datos['nomcentro_analista'];
				$anio = ($datos['anio'] == '1900') ? '' : $datos['anio'];

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("A" . $fila, encodeToUtf8($datos['numemp']));
				$objPHPExcel->getActiveSheet()->getStyle("A" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);			
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("B" . $fila, encodeToUtf8($datos['nombre']));
				$objPHPExcel->getActiveSheet()->getStyle("B" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);		
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("C" . $fila, '$'.number_format(($datos['reembolsosinisr']+$isr_colegiatura), 2 ,"." ,"," ));
				$objPHPExcel->getActiveSheet()->getStyle("C" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);		

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("D" . $fila,'$'.number_format($datos['reembolsosinisr'], 2 ,"." ,"," ));
				$objPHPExcel->getActiveSheet()->getStyle("D" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);		

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("E" . $fila, encodeToUtf8($datos['region']));
				$objPHPExcel->getActiveSheet()->getStyle("E" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("F" . $fila, encodeToUtf8($datos['folio_fiscal']));
				$objPHPExcel->getActiveSheet()->getStyle("F" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("G" . $fila, encodeToUtf8($datos['nom_escolaridad']));
				$objPHPExcel->getActiveSheet()->getStyle("G" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("H" . $fila, encodeToUtf8($datos['nombre_analista']));
				$objPHPExcel->getActiveSheet()->getStyle("H" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("I" . $fila, encodeToUtf8($fecha_solicitud));
				$objPHPExcel->getActiveSheet()->getStyle("I" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("J" . $fila, encodeToUtf8($fecha_autoriza_gerente));
				$objPHPExcel->getActiveSheet()->getStyle("J" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("K" . $fila, encodeToUtf8($fecha_revision_analista));
				$objPHPExcel->getActiveSheet()->getStyle("K" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("L" . $fila, encodeToUtf8($fecha_pago));
				$objPHPExcel->getActiveSheet()->getStyle("L" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("M" . $fila, encodeToUtf8($datos['nom_estatus']));
				$objPHPExcel->getActiveSheet()->getStyle("M" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("MN" . $fila, encodeToUtf8($datos['dias_respuestas']));
				$objPHPExcel->getActiveSheet()->getStyle("N" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("O" . $fila, encodeToUtf8($anio));
				$objPHPExcel->getActiveSheet()->getStyle("O" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("P" . $fila, encodeToUtf8($datos['mes']));
				$objPHPExcel->getActiveSheet()->getStyle("P" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("Q" . $fila, encodeToUtf8($centro_analista));
				$objPHPExcel->getActiveSheet()->getStyle("Q" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("R" . $fila, encodeToUtf8($datos['mes_rev_analista']));
				$objPHPExcel->getActiveSheet()->getStyle("R" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);	

				$objPHPExcel->setActiveSheetIndex(0)->setCellValue("S" . $fila, encodeToUtf8($datos['anio_rev_analista']));
				$objPHPExcel->getActiveSheet()->getStyle("S" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);
		
			$fila++;
		}
		$con->close(); //CIERRA CONEXIÓN SERVER

		/*****************************TOTALES***************************/
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("A" . $fila, "TOTAL COLABORADORES: ".$colaboradores);
		// $objPHPExcel->getActiveSheet()->getStyle("A" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);			
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("B" . $fila,(number_format($totales_importe, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("B" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);			
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("C" . $fila,(number_format($totales_isr, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("C" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);		

		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue("D" . $fila,(number_format($totales, 2 ,"." ,"," )));
		// $objPHPExcel->getActiveSheet()->getStyle("D" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);	
		

		/*****************************FIN DATOS***************************/
		$objPHPExcel->getActiveSheet()->getStyle('A1:S1')->applyFromArray($style_titulo);
		
		$objPHPExcel->getActiveSheet()->getStyle('A3:S3')->applyFromArray($style_encabezado);
		
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
		
		/// Renombrando Hoja
		$objPHPExcel->getActiveSheet()->setTitle('Indicadores Internos Facturas');

		header('Content-Type: application/vnd.ms-excel');
		header('Content-Disposition: attachment;filename="IndicadoresInternosFacturas.xls"');
		header('Cache-Control: max-age=0');

		//$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
		$objWriter = new Xlsx($objPHPExcel, 'Excel5');
		$objWriter->save('php://output');
    }	
 ?>