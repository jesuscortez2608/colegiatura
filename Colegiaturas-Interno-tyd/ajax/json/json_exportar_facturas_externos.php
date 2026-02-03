<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

session_name("Session-Colegiaturas"); 
session_start();
$Session = $_GET['session_name'];

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
$page = isset($_GET['page']) ? $_GET['page'] : -1;
$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dfecharegistro';
$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
$columns = isset($_GET['columns']) ? $_GET['columns'] : 'dfechafactura, cfolfiscal, nimportefactura, iprcdescuento, nimportecalculado, ibeneficiarioexterno, cnombeneficiarioexterno, iempleadocaptura, cnombrecaptura, dfecharegistro';

$FolioFiscal = isset($_GET['Fol_Fiscal']) ? $_GET['Fol_Fiscal'] : '';
$iUsuarioExterno = isset($_GET['iUsuario']) ? $_GET['iUsuario'] : 0;
$NomUsuario = isset($_GET['NomUsuario']) ? $_GET['NomUsuario'] : '';
$iOpcRango = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
$fechaIni = isset($_GET['FechaIni']) ? $_GET['FechaIni'] : '19000101';
$fechaFin = isset($_GET['FechaFin']) ? $_GET['FechaFin'] : '19000101';
$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;


$hoy = date("d-m-Y");

$imprimir.='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="7%"><b>FECHA FACTURA</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>FOLIO</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="7%"><b>IMPORTE FACTURA</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>DESCUENTO</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>IMPORTE CALCULADO</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>BENEFICIARIO</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>COLABORADOR</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="7%"><b>FECHA REGISTR&Oacute;</b></td>

			</tr>';

if ($datos_conexion["estado"] != 0) {
	echo "Error en la conexion " . $datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];
try{
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
	
	$query = "SELECT records
			, page
			, pages
			, id
			, dFechaFactura
			, cFolFiscal
			, nImporteFactura
			, iPrcDescuento
			, nImporteCalculado
			, iBeneficiarioExterno
			, cNomBeneficiarioExterno
			, iEmpleadoCaptura
			, cNombreCaptura
			, dFechaRegistro
		FROM fun_consultar_facturas_externos(
				$rowsperpage
				, $page
				, '$orderby'
				, '$ordertype'
				, '$columns'
				, '$FolioFiscal'
				, $iUsuarioExterno
				, $iOpcRango
				, '$fechaIni'::DATE
				, '$fechaFin'::DATE
				, $iEstatus)";
				
	
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
	
	
	$cmd->setCommandText($query);
	$matriz = $cmd->executeDataSet();
	
	foreach($matriz as $fila){
		$imprimir.='<tr>
		<td align="center" style="border: 1px solid #000000;" width="7%"> '.date("d/m/Y", strtotime($fila['dfechafactura'])).' </td>
		<td align="left" style="border: 1px solid #000000;" width="20%"> '.$fila['cfolfiscal'].' </td>
		<td align="right" style="border: 1px solid #000000;" width="7%"> '.number_format($fila['nimportefactura'],2).' </td>
		<td align="right" style="border: 1px solid #000000;" width="8%"> '.$fila['iprcdescuento'].'%'.' </td>
		<td align="right" style="border: 1px solid #000000;" width="8%"> '.number_format($fila['nimportecalculado'],2).' </td>
		<td align="left" style="border: 1px solid #000000;" width="20%"> '.$fila['cnombeneficiarioexterno'].' </td>
		<td align="left" style="border: 1px solid #000000;" width="20%"> '.$fila['iempleadocaptura'].' - '.$fila['cnombrecaptura'].' </td>
		<td align="center" style="border: 1px solid #000000;" width="7%"> '.date("d/m/Y", strtotime($fila['dfecharegistro'])).' </td>
		
		
		</tr>';
	}
	// echo($imprimir);
	// exit();
} catch (Exception $ex) {
	echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
}
	$imprimir.='</table>';
	//Secci�n de Filtros.
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	
	
	$dfechaIni = substr($fechaIni,-2).'/'.substr($fechaIni,-4,2).'/'.substr($fechaIni,-8,4);
	$dfechaFin = substr($fechaFin,-2).'/'.substr($fechaFin,-4,2).'/'.substr($fechaFin,-8,4);	
	if($dfechaIni == '01/01/1900' && $dfechaFin == '01/01/1900'){
		$dfechaIni = '';
		$dfechaFin = '';
	}
	// echo('ESTATUS: '.$iEstatus);
	// exit();
	if($iEstatus == 0){
		$cEstatus = 'PENDIENTE';
	}
	if($iEstatus == 3){
		$cEstatus = 'RECHAZADA';
	}
	
	if($iEstatus == 6){
		$cEstatus = 'PAGADA';
	}
	
	$imprimir.=
		'<br><br><br>
		<font size="8">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			';
	if($iUsuarioExterno != 0){
		$imprimir.='
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;COLABORADOR: &nbsp;'.$iUsuarioExterno.' - '.$NomUsuario.'</td>
			</tr>';
	}else {
		$imprimir.=
			'
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;FOLIO: &nbsp;'.$FolioFiscal.'</td>
			</tr>			
		';		
	}
	$imprimir.='
		<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;ESTATUS: &nbsp;'.$cEstatus.'</td>
		</tr>';
			


	if($iOpcRango == 1){
		$imprimir.='
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;FECHA DE: &nbsp;'.$dfechaIni.'&nbsp;A&nbsp;'.$dfechaFin.'</td>
			</tr>
		</table>';
	}else{
		$imprimir.='
		</table>';
	}

		
		// echo($imprimir);
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
	//$pdf->SetTitle('Catalogo de Alumnos Inscritos');
// set default header data}
	$pdf->SetHeaderData('', '',  '', "CONSULTA DE FACTURAS DE EXTERNOS\nImpreso el: $hoy");
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
		$pdf->SetFont('dejavusans', '', 5.8, '', true);

// Add a page
// This method has several options, check the source code documentation for more information.
		$pdf->AddPage();
		
//$tabla = utf8_encode($tabla);
// echo($imprimir)	;
// exit();
$imprimir = $imprimir;
	$html = <<<EOD
	$imprimir
EOD;
	
	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
$pdf->Output('Consulta_FacturasExternos.pdf', 'D');	
?>