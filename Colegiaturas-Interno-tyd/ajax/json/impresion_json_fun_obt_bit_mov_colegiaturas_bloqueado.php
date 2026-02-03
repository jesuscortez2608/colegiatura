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
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : -1;
	$sOrderColumn = isset($_GET['sidx']) ? $_GET['sidx'] : 'fec_registro,idu_empleado';
	$sOrderType = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$sColumns = 'fec_registro, idu_tipo_movimiento, nom_tipo_movimiento, folio_factura, importe_original
					, importe_pagado, opc_bloqueado_estatus, idu_empleado, nombre_empleado, numero_puesto, nombre_puesto
					, fec_alta, idu_centro, nombre_centro, idu_ciudad, nombre_ciudad, idu_region, nombre_region, justificacion
					, estatus_empleado, idu_usuario, nom_usuario, idu_puesto_usuario, nom_puesto_usuario, idu_centro_usuario, nom_centro_usuario, porcentaje, nom_escolaridad';	
	
	$dFechaInicial = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '19000101';
	$dFechaFinal = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iTipoMovimiento = isset($_GET['iTipoMovimientoBitacora']) ? $_GET['iTipoMovimientoBitacora'] : 1;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iCentro = isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	$sNomTipoMovimiento = isset($_GET['sNomTipoMovimiento']) ? $_GET['sNomTipoMovimiento'] : '';
	$sNomEmpleado = isset($_GET['sNomEmpleado']) ? $_GET['sNomEmpleado'] : '';
	$sNomRegion = isset($_GET['sNomRegion']) ? $_GET['sNomRegion'] : '';
	$sNomCiudad = isset($_GET['sNomCiudad']) ? $_GET['sNomCiudad'] : '';
	$sNomCentro = isset($_GET['sNomCentro']) ? $_GET['sNomCentro'] : '';
	
	$hoy = date("d-m-Y");
	
	$imprimir = 
		'<table cellpadding="1">
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="14%"><b>Fecha</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="27%"><b>Colaborador</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="23%"><b>Puesto</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Porcentaje</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Escolaridad</b></td>
			</tr>
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="25%"><b>Centro</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="24%"><b>Ciudad</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="20%"><b>Región</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Estatus</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="15%"><b>Estatus Bloqueo</b></td>
			</tr>
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="33%"><b>Colaborador Autorizó</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="33%"><b>Puesto Colaborador Autorizó</b></td>
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="33%"><b>Centro Colaborador Autorizó</b></td>
			</tr>
			<tr bgcolor="#808080" style="color:#FFFFFF">
				<td align="center" style="border: 1px solid #000000;vertical-align:middle;" width="99%"><b>Justificación</b></td>
			</tr>';
	$cadena_conexion = $datos_conexion['conexion'];
	
	try{
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT records
						, page
						, pages
						, id
						, fec_registro
						, idu_tipo_movimiento
						, nom_tipo_movimiento
						, folio_factura
						, importe_original
						, importe_pagado
						, opc_bloqueado_estatus
						, idu_empleado
						, nombre_empleado
						, numero_puesto
						, nombre_puesto
						, fec_alta
						, idu_centro
						, nombre_centro
						, idu_ciudad
						, nombre_ciudad
						, idu_region
						, nombre_region
						, justificacion
						, estatus_empleado
						, idu_usuario
						, nom_usuario
						, idu_puesto_usuario
						, nom_puesto_usuario
						, idu_centro_usuario
						, nom_centro_usuario
						, porcentaje
						, nom_escolaridad
				FROM fun_obtener_bitacora_movimientos_colegiaturas(
					'$dFechaInicial'
					, '$dFechaFinal'
					, $iEmpleado
					, $iTipoMovimiento
					, $iRegion
					, $iCiudad
					, $iCentro
					, $iRowsPerPage
					, $iCurrentPage
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
			$fechaRegistro = date("d/m/Y H:i:s", strtotime($fila['fec_registro']));
			$idColaborador = trim($fila['idu_empleado']);
			$sColaborador = trim($fila['idu_empleado']).'  '.trim(encodeToUtf8($fila['nombre_empleado']));
			$idPuestoCol = trim($fila['numero_puesto']);
			$sPuestoCol = trim($fila['numero_puesto']).'  '.trim(encodeToUtf8($fila['nombre_puesto']));
			$idCentroCol = trim($fila['idu_centro']);
			$sCentroCol = trim($fila['idu_centro']).' '.trim(encodeToUtf8($fila['nombre_centro']));
			$idCiudadCol = trim($fila['idu_ciudad']);
			$sCiudadCol = trim($fila['idu_ciudad']).' '.trim(encodeToUtf8($fila['nombre_ciudad']));
			$idRegionCol = trim($fila['idu_region']);
			$sRegionCol = trim($fila['idu_region']).' '.trim(encodeToUtf8($fila['nombre_region']));
			$sEstatus = trim(encodeToUtf8($fila['estatus_empleado']));
			$sEstatusBloqueo = trim(encodeToUtf8($fila['opc_bloqueado_estatus']));
			$idUsuario = trim($fila['idu_usuario']);
			$sUsuario = trim($fila['idu_usuario']).' '.trim(encodeToUtf8($fila['nom_usuario']));
			$idPuestoUsu = trim($fila['idu_puesto_usuario']);
			$sPuestoUsu = trim($fila['idu_puesto_usuario']).' '.trim(encodeToUtf8($fila['nom_puesto_usuario']));
			$idCentroUsu = trim($fila['idu_centro_usuario']);
			$sCentroUsu = trim($fila['idu_centro_usuario']).' '.trim(encodeToUtf8($fila['nom_centro_usuario']));
			$sJustificacion = trim(encodeToUtf8($fila['justificacion']));
			$iPorcentaje = trim($fila['porcentaje']);
			$sEscolaridad = trim(encodeToUtf8($fila['nom_escolaridad']));
			
			$imprimir.=
				'<tr>
					<td align="center" style="border: 1px solid #000000;" width="14%">'.$fechaRegistro.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="27%">'.$sColaborador.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="23%">'.$sPuestoCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$iPorcentaje.'%</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sEscolaridad.'</td>
				</tr>
				<tr>
					<td align="lefth" style="border: 1px solid #000000;" width="25%">'.$sCentroCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="24%">'.$sCiudadCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="20%">'.$sRegionCol.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sEstatus.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="15%">'.$sEstatusBloqueo.'</td>
				</tr>
				<tr>
					<td align="lefth" style="border: 1px solid #000000;" width="33%">'.$sUsuario.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="33%">'.$sPuestoUsu.'</td>
					<td align="lefth" style="border: 1px solid #000000;" width="33%">'.$sCentroUsu.'</td>
				</tr>
				<tr>
					<td align="lefth" style="border: 1px solid #000000;" width="99%">'.$sJustificacion.'</td>
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
			</tr>
			<tr>
				<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;REGION:&nbsp;'.$sNomRegion.'</td>
			</tr>
			<tr>
				<td style="border:0.5px solid #000000;" width="30%">&nbsp;&nbsp;CIUDAD:&nbsp;'.$sNomCiudad.'</td>
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
	$pdf->SetHeaderData('', '',  '', "REPORTE ".encodeToUtf8("BITÁCORA")." COLABORADOR BLOQUEADO\nImpreso el: $hoy");
	
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
$pdf->Output('REPORTE BITACORA COLABORADOR BLOQUEADO.pdf', 'D');
?>