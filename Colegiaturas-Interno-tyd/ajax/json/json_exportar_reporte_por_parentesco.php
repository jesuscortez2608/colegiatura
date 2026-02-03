<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	////Variable conexi�n
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		
	////Variables filtrado
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudadParametro = isset($_GET['iCiudadParametro']) ? $_GET['iCiudadParametro'] : 0;
	$iDeduccionParametro = isset($_GET['iDeduccionParametro']) ? $_GET['iDeduccionParametro'] : 0;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iParentesco = isset($_GET['iParentesco']) ?  $_GET['iParentesco'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	
	//VARIABLES DE DESCRIPCION DE LOS FILTROS USADOS.
	$cRutaPago = isset($_GET['cRutaPago']) ? $_GET['cRutaPago'] : '';
	$cRegion = isset($_GET['cRegion']) ? $_GET['cRegion'] : '';
	$cCiudadParametro = isset($_GET['cCiudad']) ? $_GET['cCiudad'] : '';
	$cDeduccionParametro = isset($_GET['cDeduccion']) ? $_GET['cDeduccion'] : '';
	$cEscolaridad = isset($_GET['cEscolaridad']) ? $_GET['cEscolaridad'] : '';
	$cParentesco = isset($_GET['cParentesco']) ? $_GET['cParentesco'] : '';
	$cEmpresa = isset($_GET['cEmpresa']) ? $_GET['cEmpresa'] : '';
	
	$hoy = date("d-m-Y");
	$imprimir = '';
	$imprimir.='<table cellpadding="4">
				<tr bgcolor="#808080" style="color: #FFFFFF" >
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>EMPRESA</b></td>
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>PARENTESCO</b></td>
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>TOTAL BECADOS</b></td>
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>TOTAL FACTURAS</b></td>
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>PORCENTAJE BECADOS</b></td>
					<td align="center" style="border: 0.5px solid #000000" width="16%"><b>PORCENTAJE FACTURAS</b></td>							
				</tr>';						

	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT * 
		FROM fun_obtener_reporte_becas_por_parentesco(
			$iRutaPago
			,$iRegion
			,$iCiudadParametro
			,$iDeduccionParametro
			,'$dFechaIni'
			,'$dFechaFin'
			,$iEscolaridad
			,$iParentesco
			,$iEmpresa)";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		
		
		foreach($matriz as $fila) 
		{
			if($fila['tipo']==1) {
				$NomParentesco = $fila['nom_parentesco'];
			} else if($fila['tipo']==2) {
				$NomParentesco='<b>TOTAL</b>';				
			} else if($fila['tipo'] == 3) {
				$NomParentesco = "<b>TOTAL GENERAL</b>";
			}
						
			$imprimir.= '<tr>
				<td align="center" 	style="border: 0.5px solid #000000" width="16%">'.encodeToUtf8($fila['nom_empresa']).'</td>
				<td align="center" 	style="border: 0.5px solid #000000" width="16%">'.$NomParentesco.'</td>
				<td align="right" 	style="border: 0.5px solid #000000" width="16%">'.$fila['total_beneficiarios'].'</td>
				<td align="right" 	style="border: 0.5px solid #000000" width="16%">'.$fila['total_facturas'].'</td>
				<td align="right" 	style="border: 0.5px solid #000000" width="16%">'.number_format($fila['prc_beneficiarios'],2).' %</td>
				<td align="right" 	style="border: 0.5px solid #000000" width="16%">'.number_format($fila['prc_facturas'],2).' %</td>	
			</tr>';		
		
		}
		
		$imprimir.='</table>';
		

	} catch (Exception $ex) 
	{
		echo "Error: Al intentar conectar con la base de datos.";
	}
		
	
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	$FechaIni = substr($dFechaIni,-2).'/'.substr($dFechaIni,-4,2).'/'.substr($dFechaIni,-8,4);
	$FechaFin = substr($dFechaFin,-2).'/'.substr($dFechaFin,-4,2).'/'.substr($dFechaFin,-8,4);
	
	//Secci�n de Filtros.
	$imprimir.=
		'<br><br>
		<font size="8">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;RUTA DE PAGO: &nbsp;'.$cRutaPago.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;REGION:&nbsp;'.$cRegion.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;CIUDAD:&nbsp;'.$cCiudadParametro.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;TIPO DE DEDUCCION:&nbsp;'.$cDeduccionParametro.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;ESCOLARIDAD:&nbsp;'.$cEscolaridad.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;PARENTESCO:&nbsp;'.$cParentesco.'</td>
			</tr>
			<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;FECHAS DE&nbsp;'.$FechaIni.'&nbsp;A&nbsp;'.$FechaFin.'</td>
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
	//$pdf->SetTitle('Catalogo de Alumnos Inscritos');


// set default header data
	$pdf->SetHeaderData('', '',  '', "REPORTE DE BECAS OTORGADAS POR TIPO BENEFICIARIO\nImpreso el: $hoy");
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
		$pdf->SetFont('dejavusans', '', 6.5, '', true);

// Add a page
// This method has several options, check the source code documentation for more information.
		$pdf->AddPage();
//$tabla = utf8_encode($tabla);	

	$html = <<<EOD
	$imprimir
EOD;
	
	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
ob_end_clean ();
$pdf->Output('Reporte_becas_por_parentesco.pdf', 'D');

echo("entra");
exit();
?>