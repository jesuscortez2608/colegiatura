<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// session_name("Session-Colegiaturas"); 
	// session_start();
	// $Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//VARIABLES DE FILTRADO
	$valor = isset($_GET['valor']) ? $_GET['valor'] : 0;
	//$inum_empleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
		
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'nombeneficiario';
	$sOrderType = 'asc';	
	
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
			$query = "SELECT records, page, pages, id, nomempresa, numemp, nombre, importe, isr, total, tipo FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS($iCurrentPage,$iRowsPerPage,$valor) ";
			
			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();
			$con->close();
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
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
		->setCellValue('A1', 'Num Emp')
				->setCellValue('B1', 'Incentivo');

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

		$style_normal = array(
			'font' => array(
				'bold' => false,'size' => 10,
			),
			'fill' => array(
				'type' => Fill::FILL_SOLID,
			),
			'borders' => array(
				'vertical' => array(
					'style' => Border::BORDER_THIN,
					'color' => array(
					'argb' => 'FFEFF3F8')
				)),
		);
		$style_normaldos = array(
			'font' => array(
				'bold' => false,'size' => 10,
			),
			'fill' => array(
				'type' => Fill::FILL_SOLID,
				'color' => array(
					'argb' => 'FFF5F5F5'),
			
			),
			'borders' => array(
				'vertical' => array(
					'style' => Border::BORDER_THIN,
					'color' => array(
					'argb' => 'FFEFF3F8')
				)),
		);

		$style_header = array(
			'font' => array(
				'bold' => false
			),
			'fill' => array(
				'type' => Fill::FILL_SOLID,
				'color' => array(
					'argb' => 'FFC0C0C0'),//color de fondo a celda
			),'alignment' => array(
				'horizontal' => Alignment::HORIZONTAL_CENTER,
			)
		);
		/*****************************DATOS*******************************/
		$totales_importe = 0;
		$totales_isr = 0;
		$totales = 0; 
		$colaboradores = 0;

		$fila = 2;
		foreach ($ds as $datos) {	
			$objPHPExcel->setActiveSheetIndex(0)->setCellValue("A" . $fila, encodeToUtf8($datos['numemp']));
			$objPHPExcel->getActiveSheet()->getStyle("A" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);			
				
			$objPHPExcel->setActiveSheetIndex(0)->setCellValue("B" . $fila, $datos['total']);
			$objPHPExcel->getActiveSheet()->getStyle("B" . $fila)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);	

			$fila++;	
		}	
		

		/*****************************FIN DATOS***************************/
		// $objPHPExcel->getActiveSheet()->getStyle('A1:D1')->applyFromArray($style_titulo);
		
		// $objPHPExcel->getActiveSheet()->getStyle('A3:D3')->applyFromArray($style_encabezado);
		
		$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getRowDimension('1')->setRowHeight(20);
		
		// $objPHPExcel->getActiveSheet()->getRowDimension('3')->setRowHeight(15);
		
		$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setAutoSize(true);
		
		/// Renombrando Hoja
		$objPHPExcel->getActiveSheet()->setTitle('Generacion de Incentivos');

		header('Content-Type: application/vnd.ms-excel');
		header('Content-Disposition: attachment;filename="GeneracionIncentivos.xls"');
		header('Cache-Control: max-age=0');

		//$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
		$objWriter = new Xlsx($objPHPExcel, 'Excel5');
		$objWriter->save('php://output');
    }	
 ?>