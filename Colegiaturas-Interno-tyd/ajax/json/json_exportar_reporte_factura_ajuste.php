<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iTipoDeduccion = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;	
	$iCicloEscolar = isset($_GET['iCicloEscolar']) ? $_GET['iCicloEscolar'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';	
	$iNumEmp = isset($_GET['iNumEmp']) ? $_GET['iNumEmp'] : 0;
	
	$hoy = date("d-m-Y");
	
	$imprimir = 
		'<table cellpadding="1">
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="10%"><b>Importe Factura</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="5%"><b>Importe Pagado</b></td>				
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Fecha Factura</b></td>				
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Folio Fiscal</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>Becado</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>Parentesco</b></td>				
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>Colaborador</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="5%"><b>% Pagado</b></td>				
			</tr>';
			
	$cadena_conexion = $datos_conexion['conexion'];
	/*try{
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT iimportefactura, iimportepagado, dfechafactura, sfoliofiscal, sbecado, sparentesco, snom_empleado, nporc_pagado
	FROM FUN_OBTENER_REPORTE_FACTURAS_AJUSTE($iRutaPago,$iEscolaridad,$iRegion,$iCiudad,$iTipoDeduccion,$iCicloEscolar,'$dFechaInicio','$dFechaFin',$iNumEmp))";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		$con->close();
		
		foreach($matriz as $fila){				
				$imprimir.=
				
					$iimportefactura = number_format($fila['iimportefactura'],2);
					$iimportepagado = number_format($fila['iimportepagado'],2);
					$dfechafactura = $fila['dfechafactura'];
					$sfoliofiscal = $fila['sfoliofiscal'];
					$sbecado = $fila['sbecado'];
					$sparentesco = trim(encodeToUtf8($fila['sparentesco']));
					$snom_empleado = $fila['$snom_empleado'];
					$nporc_pagado = number_format($fila['nporc_pagado'],2);					
					
					
				
					'<tr>
						<td align="lefth" 	style="border: 1px solid #000000;" width="10%">'.$iimportefactura.'</td>
						<td align="lefth" 	style="border: 1px solid #000000;" width="5%">'.$iimportepagado.'</td>
						<td align="lefth" 	style="border: 1px solid #000000;" width="6%">'.$dfechafactura.'</td>
						<td align="lefth" 	style="border: 1px solid #000000;" width="15%">'.$sfoliofiscal.'</td>
						<td align="lefth" 	style="border: 1px solid #000000;" width="4%">'.$sbecado.'</td>
						<td align="lefth" 	style="border: 1px solid #000000;" width="15%">'.$sparentesco.'</td>
						<td align="right" 	style="border: 1px solid #000000;" width="8%">'.$snom_empleado.'</td>
						<td align="right" 	style="border: 1px solid #000000;" width="8%">'.$nporc_pagado.'</td>
						
						
					</tr>
					<br>';
		}
		$imprimir.=
			'</table>';
	} catch(Exception $ex){
		
	}*/
	
	
	
	
require_once('../../../utilidadesweb/librerias/tcpdf/config/lang/spa.php');
require_once('../../../utilidadesweb/librerias/tcpdf/tcpdf.php');


////////////////////////////////////////////////////////////////////////////////		
// create new PDF document
		$pdf = new TCPDF('L', PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);
//la "L" para horizontal
//la "P" para vertical
// set document information
		$pdf->SetCreator(PDF_CREATOR);
//$pdf->SetAuthor('Coppel');
	//$pdf->SetTitle('Catalogo de Alumnos Inscritos');

// set default header data
	$pdf->SetHeaderData('', '',  '', "REPORTE  DE FACTURAS CON AJUSTE\nImpreso el: $hoy");
	
//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);                                          

// set header and footer fonts
		$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
		$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));
		
// set default monospaced font
		$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

//set margins
		$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);


		$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);


		$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

//set auto page breaks
		$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

//set image scale factor
		$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

//set some language-dependent strings
		$pdf->setLanguageArray($l);
		
// ---------------------------------------------------------

// set default font subsetting mode
		$pdf->setFontSubsetting(true);

// Set font
// dejavusans is a UTF-8 Unicode font, if you only need to
// print standard ASCII chars, you can use core fonts like
// helvetica or times to reduce file size.
		$pdf->SetFont('dejavusans', '', 6, '', true);

// Add a page
// This method has several options, check the source code documentation for more information.
		$pdf->AddPage();
		// echo $imprimir;
// exit();
//$tabla = utf8_encode($tabla);	

	$html = <<<EOD
	$imprimir
EOD;
	
	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
ob_end_clean ();
$pdf->Output('REPORTE_FACTURAS CON AJUSTE.pdf', 'D');
?>