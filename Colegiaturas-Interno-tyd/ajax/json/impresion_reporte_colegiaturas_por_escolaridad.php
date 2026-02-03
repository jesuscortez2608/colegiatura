<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO.
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iTipoDeduccion  = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;
	//$iTipoEscuela = isset($_GET['iTipoEscuela']) ? $_GET['iTipoEscuela'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	
	//VARIABLES DE DESCRIPCION DE LOS FILTROS USADOS.
	$cRutaPago = isset($_GET['cRutaPago']) ? $_GET['cRutaPago'] : 0;
	$cEstatus = isset($_GET['cEstatus']) ? $_GET['cEstatus'] : 0;
	$cRegion = isset($_GET['cRegion']) ? $_GET['cRegion'] : 0;
	$cCiudad = isset($_GET['cCiudad']) ? $_GET['cCiudad'] : 0;
	$cTipoDeduccion = isset($_GET['cTipoDeduccion']) ? $_GET['cTipoDeduccion'] : 0;
	//$cTipoEscuela = isset($_GET['cTipoEscuela']) ? $_GET['cTipoEscuela'] : '';
	$cEmpresa= isset($_GET['cEmpresa']) ? $_GET['cEmpresa'] : '';
	
	
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$imprimir='
		<table cellpadding="2">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="16%"><b>&nbsp; Empresa</b></td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="16%"><b>&nbsp; Nivel de Estudios</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%"><b>Colaboradores por Nivel &nbsp;&nbsp;</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%"><b>Facturas Ingresadas &nbsp;&nbsp;</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="14%"><b>Importe &nbsp;&nbsp;</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="14%"><b>Reembolso &nbsp;&nbsp;</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Colaboradores &nbsp;&nbsp;</b></td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Facturas &nbsp;&nbsp;</b></td>
			</tr>';
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_impresion_reporte_colegiaturas_por_escolaridad.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$query = "{CALL fun_obtener_reporte_colegiaturas_por_escolaridad($iRutaPago, $iEstatus, $iRegion, $iCiudad, $iTipoDeduccion, $iEmpresa, '$dFechaInicio', '$dFechaFin')}";
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			
			//TOTALES.
			$TotalColaboradores=0;
			$TotalFacturasIngresadas=0;
			$TotalImporte=0;
			$TotalReembolso=0;
			
			foreach ($ds as $fila)
			{
				//$TotalColaboradores+=$fila['total_colaboradores'];
				$TotalColaboradores=$fila['total_colaboradores'];
				$TotalFacturasIngresadas+=$fila['facturas_ingresadas'];
				$TotalImporte+=$fila['importe'];
				$TotalReembolso+=$fila['reembolso'];
				
				$imprimir.='
					<tr>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="16%"> '.$fila['snom_empresa'].' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="16%"> '.$fila['snom_escolaridad'].' </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%"> '.number_format($fila['icolaboradores_por_nivel'],0).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%"> '.number_format($fila['ifacturas_ingresadas'],0).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="14%"> '.number_format($fila['nimporte'],2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="14%"> '.number_format($fila['nreembolso'],2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['nporcentaje_colaboradores'],2).'%'.'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['nporcentaje_facturas'],2).'%'.'&nbsp;&nbsp;&nbsp; </td>
						
					</tr>';
				$i++;
			}
			/*
			$imprimir.='
				<tr>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="24%"><b>TOTAL</b>&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%">'.number_format($TotalColaboradores,0).'&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="12%">'.number_format($TotalFacturasIngresadas,0).'&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="16%">'.number_format($TotalImporte,2).'&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="16%">'.number_format($TotalReembolso,2).'&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%">100%'.'&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%">100%'.'&nbsp;&nbsp;&nbsp;</td>
				</tr>';
			*/
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;
		}
    }
	
	$imprimir.='</table>';
	
	
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	$fechaIni = substr($dFechaInicio,-2).'/'.substr($dFechaInicio,-4,2).'/'.substr($dFechaInicio,-8,4);
	$fechaFin = substr($dFechaFin,-2).'/'.substr($dFechaFin,-4,2).'/'.substr($dFechaFin,-8,4);
	
	//Sección de Filtros.
	$imprimir.=
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;RUTA DE PAGO: &nbsp;'.$cRutaPago.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS:&nbsp;'.$cEstatus.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;REGIÓN:&nbsp;'.$cRegion.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;CIUDAD:&nbsp;'.$cCiudad.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;TIPO DE DEDUCCIÓN:&nbsp;'.$cTipoDeduccion.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;EMPRESA:&nbsp;'.$cEmpresa.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHAS DE&nbsp;'.$fechaIni.'&nbsp;A&nbsp;'.$fechaFin.'</td>
			</tr>
		</table>';
	
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
	$pdf->SetTitle('Reportes - Becas otorgadas por nivel de estudios');

// set default header data
		$fecha = date('d/m/Y');
		$pdf->SetHeaderData('', '',  '', "BECAS OTORGADAS POR ESCOLARIDAD\nImpreso el: $fecha");
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
		
$tabla = $tabla;	
$imprimir = $imprimir;
	$html = <<<EOD
	$imprimir
EOD;
	
	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
	ob_end_clean ();
$pdf->Output('ReporteBecasPorEscolaridad.pdf', 'D');

?>