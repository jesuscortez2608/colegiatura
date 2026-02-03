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
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	//VARIABLES DE FILTRADO.
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iCentro = isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	
	//VARIABLES DE PAGINACIÓN.
	$sOrderColumn = isset($_GET['sidx']) ? $_GET['sidx'] : 'fec_ingreso';
	$sOrderType = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$sColumns = 'numemp,nombre,num_centro,nom_centro,num_puesto,nom_puesto,porcentaje,escolaridad,seccion,parentesco,justificacion,fec_ingreso,fec_movimiento,numemp_autorizo,nombre_autorizo,
	num_centro_autorizo,nom_centro_autorizo,num_puesto_autorizo,nom_puesto_autorizo';
	
	$hoy = date("d-m-Y");
	
	$imprimir = 
		'<table cellpadding="1">
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Colaborador</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Centro</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Puesto</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Porcentaje</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Escolaridad</b></td>
			</tr>
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="100%"><b>Justificación</b></td>
			</tr>
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Parentesco</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Fecha Ingreso</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Colaborador Autorizó</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Puesto Colaborador Autorizó</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Centro Colaborador Autorizó</b></td>
			</tr>';
	$cadena_conexion = $datos_conexion['conexion'];
	
	try{
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT *
				FROM FUN_OBTEN_BIT_COLEGIATURAS_CONFIG_DESCUENTOS(
					  '$dFechaInicio'
					, '$dFechaFin'
					, $iRegion
					, $iCiudad
					, $iEmpleado
					, $iCentro
					, null
					, null
					, '$sOrderColumn'
					, '$sOrderType'
					, '$sColumns')";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		$con->close();
		
		foreach($matriz as $fila){
			$fechaIngreso = date("d/m/Y", strtotime($fila['fec_ingreso']));

			$sColaborador = ($fila['numemp']) ? trim($fila['numemp']).' - '.trim(encodeToUtf8($fila['nombre'])) : '';
			$sCentroCol = ($fila['num_centro']) ? trim($fila['num_centro']).' - '.trim(encodeToUtf8($fila['nom_centro'])) : '';
			$sPuestoCol = ($fila['num_puesto']) ? trim($fila['num_puesto']).' - '.trim(encodeToUtf8($fila['nom_puesto'])) : '';
			
			$iPorcentaje = trim($fila['porcentaje']);
			$sEscolaridad = trim(encodeToUtf8($fila['escolaridad']));
			$sParentesco = trim(encodeToUtf8($fila['parentesco']));
			$sJustificacion = trim(encodeToUtf8($fila['justificacion']));

			$sUsuario = ($fila['numemp_autorizo']) ? trim($fila['numemp_autorizo']).' - '.trim(encodeToUtf8($fila['nombre_autorizo'])) : '';
			$sCentroUsu = ($fila['num_centro_autorizo']) ? trim($fila['num_centro_autorizo']).' - '.trim(encodeToUtf8($fila['nom_centro_autorizo'])) : '';
			$sPuestoUsu = ($fila['num_puesto_autorizo']) ? trim($fila['num_puesto_autorizo']).' - '.trim(encodeToUtf8($fila['nom_puesto_autorizo'])) : '';
			
			$imprimir.=
				'<tr>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sColaborador.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sCentroCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sPuestoCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$iPorcentaje.'%</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sEscolaridad.'</td>
					
				</tr>    
				<tr>
					<td align="lefth" style="border: 1px solid #000000;" width="100%">'.$sJustificacion.'</td>
					
				</tr>                                                         
				<tr>
					<td align="center" 	style="border: 1px solid #000000;" width="20%">'.$sParentesco.'</td>
					<td align="lefth" 	style="border: 1px solid #000000;" width="20%">'.$fechaIngreso.'</td>
					<td align="lefth" 	style="border: 1px solid #000000;" width="20%">'.$sUsuario.'</td>
					<td align="lefth" 	style="border: 1px solid #000000;" width="20%">'.$sPuestoUsu.'</td>
					<td align="center" 	style="border: 1px solid #000000;" width="20%">'.$sCentroUsu.'</td>
				</tr>
				<br>';
		}
		$imprimir.='</table>';
		
	}catch(Exception $ex){
		
	}
	$FechaIni = substr($dFechaInicial,-2).'/'.substr($dFechaInicial,-4,2).'/'.substr($dFechaInicial,-8,4);
	$FechaFin = substr($dFechaFinal,-2).'/'.substr($dFechaFinal,-4,2).'/'.substr($dFechaFinal,-8,4);	
			
	//FILTROS
	$imprimir.=
		'<br><br><br>
		<font size="8">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">';
		if($iEmpleado != 0){
			$imprimir.=
				'<tr>
					<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;COLABORADOR:&nbsp;'.$sColaborador.'</td>
				</tr>';
		}
		$imprimir.=
			'<tr>
				<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;TIPO MOVIMIENTO:&nbsp;'.$sNomTipoMovimiento.'</td>
			</tr>';
		if($iCentro != 0){
			$imprimir.=
				'<tr>
					<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;CENTRO:&nbsp;'.$iCentro.'  '.$sNomCentro.'</td>
				</tr>';
		}
		$imprimir.=
			'<tr>
				<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;FECHAS DE&nbsp;'.$FechaIni.'&nbsp;A&nbsp;'.$FechaFin.'</td>
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
	$pdf->SetHeaderData('', '',  '', "".encodeToUtf8("REPORTE BITÁCORA CONFIGURACIÓN DE DESCUENTO")."\nImpreso el: $hoy");
	
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
$pdf->Output('REPORTE BITACORA CONFIGURACION DE DESCUENTO.pdf', 'D');
?>