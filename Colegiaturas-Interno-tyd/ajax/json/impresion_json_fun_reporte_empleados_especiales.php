<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$page = isset($_GET['page']) ? $_GET['page'] : -1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] :'dfecharegistro';
	$ordertype = isset($_GET['sord']) ? $_GET['sord']: 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] :'idtipomovimiento, snombremovimiento, idempleado, snombre, scentro, snombrecentro, spuesto, snombrepuesto, dfechaingreso, iusuario, snombreusuario, dfecharegistro, sobservaciones';	

	$iduEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$sNombreEmpleado = isset($_GET['sNomEmpleado']) ? $_GET['sNomEmpleado']: '';
	$iOpcionFecha = isset($_GET['iOpcionFecha']) ? $_GET['iOpcionFecha']:0;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
	
	// $iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	$hoy = date("d-m-Y");
	
	$imprimir = 
	'<table cellpadding="1">
		<tr bgcolor="#808080" style="color:#FFFFFF">
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="10%"><b>Tipo Movimiento</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="6%"><b>Num. Colaborador</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Colaborador</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="5%"><b>Num. Centro</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Centro</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="5%"><b>Num. Puesto</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Puesto</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="5%"><b>Num. Usuario</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Usuario Registró</b></td>
			<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="8%"><b>Fecha Registró</b></td>
		</tr>';
	
	$cadena_conexion = $datos_conexion["conexion"];
	
	try{
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT records
						, page
						, pages
						, id
						, idtipomovimiento
						, snombremovimiento
						, idempleado
						, snombre
						, scentro
						, snombrecentro
						, spuesto
						, snombrepuesto
						, dfechaingreso
						, iusuario
						, snombreusuario
						, dfecharegistro
						, sobservaciones
					FROM fun_reporte_empleados_especiales(
					$iduEmpleado::INTEGER
					, $iOpcionFecha::SMALLINT
					, '$dFechaIni'::DATE
					, '$dFechaFin'::DATE
					, $rowsperpage
					, $page
					, '$orderby'::VARCHAR
					, '$ordertype'::VARCHAR
					, '$columns'::VARCHAR)";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		$con->close();
		
		foreach($matriz as $fila){
			$iTipoMovto = $fila['idtipomovimiento'];
			$sNomTipoMovto = encodeToUtf8($fila['snombremovimiento']);
			$iEmpleado = $fila['idempleado'];
			$sNomEmpleado = encodeToUtf8($fila['snombre']);
			$iCentro = $fila['scentro'];
			$sNomCentro = encodeToUtf8($fila['snombrecentro']);
			$iPuesto = $fila['spuesto'];
			$sNomPuesto = encodeToUtf8($fila['snombrepuesto']);
			$iUsuario = $fila['iusuario'];
			$sNomUsuario = encodeToUtf8($fila['snombreusuario']);
			$dFechaRegistro = date("d/m/Y H:i:s", strtotime($fila['dfecharegistro']));
			
			
			$imprimir.=
			'<tr>
				<td align="lefth" style="border: 1px solid #000000;" width="10%">'.$sNomTipoMovto.'</td>
				<td align="right" style="border: 1px solid #000000;" width="6%">'.$iEmpleado.'</td>
				<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sNomEmpleado.'</td>
				<td align="right" style="border: 1px solid #000000;" width="5%">'.$iCentro.'</td>
				<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sNomCentro.'</td>
				<td align="right" style="border: 1px solid #000000;" width="5%">'.$iPuesto.'</td>
				<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sNomPuesto.'</td>
				<td align="right" style="border: 1px solid #000000;" width="5%">'.$iUsuario.'</td>
				<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sNomUsuario.'</td>
				<td align="center" style="border: 1px solid #000000;" width="8%">'.$dFechaRegistro.'</td>
			</tr>';
		}
		$imprimir.='</table>';

	}catch(Exception $ex){
		$mensaje = $ex->getMessage();
		$estado = -2;
	}
	
	$FechaIni = substr($dFechaIni,-2).'/'.substr($dFechaIni,-4,2).'/'.substr($dFechaIni,-8,4);
	$FechaFin = substr($dFechaFin,-2).'/'.substr($dFechaFin,-4,2).'/'.substr($dFechaFin,-8,4);
	
	//SECCION DE FILTROS
	if($iOpcionFecha == 1 || $iduEmpleado > 0){
		$imprimir.=
			'<br><br><br>
			<font size="8">FILTRADO POR:</font>
			<br><br>
			<table cellpadding="2">';
		if ($sNombreEmpleado != ''){
			$imprimir.=
			'<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp;COLABORADOR:&nbsp;'.$iduEmpleado.'&nbsp;-&nbsp;'.$sNombreEmpleado.'</td>
			</tr>';
		}
		if ($iOpcionFecha == 1){
			$imprimir.=
			'<tr>
				<td style="border: 0.5px solid #000000;" width="30%">&nbsp;&nbsp; FECHAS DE&nbsp;'.$FechaIni.'&nbsp;A&nbsp;'.$FechaFin.'</td>
			</tr>';
		}
		$imprimir.='</table>';		
	} else {
		$imprimir.=
			'<br><br><br>
			<font size="8">SIN FILTROS</font>
			<br><br>';
	}
	
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
	$pdf->SetHeaderData('', '',  '', "REPORTE DE COLABORADORES ESPECIALES\nImpreso el: $hoy");
	
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
$pdf->Output('Reporte Empleados Especiales.pdf', 'D');
?>