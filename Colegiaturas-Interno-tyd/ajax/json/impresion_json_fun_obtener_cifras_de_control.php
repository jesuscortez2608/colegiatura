<?php


error_reporting(E_ALL);
ini_set("display_errors", 1);
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//VARIABLES DE FILTRADO
	$Session = $_GET['session_name'];
	$Empleado = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$TotalISR = isset($_GET['TotalISR']) ? $_GET['TotalISR'] : 0;
	
	
	
	$hoy = date("d-m-Y");
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	// echo "<pre>";
	// print_r($TotalISR);
	// echo "</pre>";
	// exit();
	$imprimir='
		<table>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>    </b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Colaborador(es) &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Movimientos &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Importe &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Prestación &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Importe Ajuste &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>ISR &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>TOTAL GRAL. &nbsp;&nbsp;</b></td>
			</tr>';
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_impresion_json_fun_obtener_cifras_de_control.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_impresion_json_fun_obtener_cifras_de_control.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_json_fun_obtener_cifras_de_control.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$query = "SELECT * FROM fun_obtener_cifras_de_control($Empleado)";
			
			$cmd->setCommandText($query);
			
			$ds = $cmd->executeDataSet();
			
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			
			//TOTALES.
			$TotalMovtos=0;
			$TotalImporte=0;
			$TotalPrestacion=0;
			$TotalCancelado=0;
			$TotalGral = 0;
			
			//rutapago,nomrutapago,movimientos,importe,prestacion,importecancelado
			
			foreach ($ds as $fila)
			{
				
				$TotalEmpleados = 0;
				$TotalMovimientos = 0;
				$TotalImporteFac = 0;
				$TotalImportePagos = 0;
				$TotalImporteAjuste = 0;
				$TotalGral = $fila['importe_pagos'] + $fila['importe_ajuste'] + $TotalISR;
					
				$fechaFac= date("d/m/Y", strtotime($fila['fechafactura']));
				$fechaCaptura= date("d/m/Y", strtotime($fila['fechacaptura']));
				$imprimir.='
					<tr>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="5%"><b>TOTAL</b>&nbsp;&nbsp;&nbsp;</td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%">'.number_format($fila['empleados'],0).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%">'.number_format($fila['movimientos'], 0).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">$'.number_format($fila['importe_factura'], 2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">$'.number_format($fila['importe_pagos'], 2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">$'.number_format($fila['importe_ajuste'], 2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">$'.number_format($TotalISR, 2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">$'.number_format($TotalGral,2).'&nbsp;&nbsp;&nbsp; </td>
					</tr>';
				$i++;
			}
			/*$imprimir.='
				<tr>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="7%"></td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="33%">TOTAL&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">'.number_format($TotalMovtos,0).'&nbsp;&nbsp;&nbsp; </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">'.number_format($TotalImporte, 2).'&nbsp;&nbsp;&nbsp; </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">'.number_format($TotalPrestacion, 2).'&nbsp;&nbsp;&nbsp; </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%">'.number_format($TotalCancelado, 2).'&nbsp;&nbsp;&nbsp; </td>
				</tr>';*/

			
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$mensaje = "Ocurrió un error al intentar conectar con la base de datos"; //$ex->getMessage();
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_cifras_de_control \n",3,"log".date('d-m-Y')."_impresion_json_fun_obtener_cifras_de_control.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_json_fun_obtener_cifras_de_control.txt");
		}
    }
	//echo json_encode($respuesta);
	
	
	$imprimir.='</table>';
	// echo ($imprimir);		
	// exit();
	
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
	$pdf->SetTitle('Traspaso de Movimientos - cifras de control');


// set default header data
$hoy = date('d/m/Y');
		$pdf->SetHeaderData('', '',  '', "IMPRESION CIFRAS CONTROL\nImpreso el: $hoy ");
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
		
$tabla = encodeToUtf8($tabla);	
$imprimir = $imprimir;
	$html = <<<EOD
	$imprimir
EOD;
	
	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
	ob_end_clean ();
$pdf->Output('ImpresionCifrasControl.pdf', 'D');

?>