<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas"); 
	session_start();
	// $Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'fecha';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,
	facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, 
	idTipoDeduccion, TipoDeduccion, motivoRechazo,idfactura, empleado, nombreempleado, fecha, id_tipodocumento, nom_tipodocumento';
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 0;
	$nEmpleado = isset($_GET['nEmpleado']) ? $_GET['nEmpleado'] : 0;
	$nEstatus = isset($_GET['nEstatus']) ? $_GET['nEstatus'] : 0;
	$nCicloEscolar = isset($_GET['nCicloEscolar']) ? $_GET['nCicloEscolar'] : 0;
	$nTipoDeduccion = isset($_GET['nTipoDeduccion']) ? $_GET['nTipoDeduccion'] : 0;
	$fechaini = isset($_GET['fechaini']) ? $_GET['fechaini'] : '19000101';
	$fechafin = isset($_GET['fechafin']) ? $_GET['fechafin'] : '19000101';
	$nRegion = isset($_GET['nRegion']) ? $_GET['nRegion'] : 0;	
	$nCiudad = isset($_GET['nCiudad']) ? $_GET['nCiudad'] : 0;
	$nCentro = isset($_GET['nCentro']) ? $_GET['nCentro'] : 0;
	
	$cEstatus = isset($_GET['cEstatus']) ? $_GET['cEstatus'] : '';
	$cCiclo = isset($_GET['cCiclo']) ? $_GET['cCiclo'] : '';
	$cDeduccion = isset($_GET['cDeduccion']) ? $_GET['cDeduccion'] : '';
	$cRegion = isset($_GET['cRegion']) ? $_GET['cRegion'] : '';
	$cCiudad = isset($_GET['cCiudad']) ? $_GET['cCiudad'] : '';
	$cCentro = isset($_GET['cCentro']) ? $_GET['cCentro'] : '';
	$cEmpleado = isset($_GET['cEmpleado']) ? $_GET['cEmpleado'] : '';
	$nomColaborador = isset($_GET['nomColaborador']) ? $_GET['nomColaborador'] : '';
	
	$hoy = date("d-m-Y");
	$imprimir='<table cellpadding="2">
		<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="12%"><b>Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="24%"><b>Colaborador Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="22%"><b>Colaborador</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Baja</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="21%"><b>Factura Fiscal</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tipo Documento</b></td>
				
				
			</tr>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="12%"><b>Fecha Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Captura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Ciclo Escolar</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Importe Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Importe Pagado</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Importe Tope</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="14%"><b>RFC-Escuela Clave SEP</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="29%"><b>Nombre Escuela</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tipo Deducción</b></td>
				
			</tr>';
	if($datos_conexion["estado"] != 0){
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
						, idestatus
						, estatus
						, fechaestatus
						, empestatus
						, empestatusnombre
						, fechabaja
						, facturafiscal
						, fechafactura
						, fechacaptura
						, idcicloescolar
						, cicloescolar
						, importefactura
						, importepagado
						, importetope
						, rfc
						, nombreescuela
						, idtipodeduccion
						, tipodeduccion
						, motivorechazo
						, idfactura
						, empleado
						, nombreempleado
						, fecha
						, id_tipodocumento
						, nom_tipodocumento
				 FROM fun_obtener_movimientos_colegiaturas($nEmpleado, $nEstatus,$nCicloEscolar,$nTipoDeduccion,'$fechaini','$fechafin','$nRegion','$nCiudad',$nCentro, $rowsperpage, $page, '$orderby', '$ordertype', '$columns')";
		
		// echo($query);
		// exit();

		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		$con->close();
		foreach($matriz as $fila){
			if($fila['idestatus'] != 0){
				if($fila['empestatus'] == 0){
					$empleadoEstatus = 'AUTORIZADA POR SISTEMA';
				}else{
					$empleadoEstatus = $fila['empestatus'].' '.trim($fila['empestatusnombre']);
				}
			}else{
				$empleadoEstatus = '';
			}
			//$empleadoEstatus = $fila['empestatus']. ' '.trim($fila['empestatusnombre']);
			$pagado = '';
			if($fila['idestatus'] == 6){
				$pagado = '$'.number_format($fila['importepagado'],2);
			}
			$imprimir.='<tr>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="12%"> '.$fila['estatus'].' </td>
			<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['fechaestatus'].' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="24%"> '.$empleadoEstatus.' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="22%"> '.$fila['empleado'].' '.$fila['nombreempleado'].' </td>
			<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['fechabaja'].' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="21%"> '.$fila['facturafiscal'].' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['nom_tipodocumento'].'</td>
			
			</tr>
			<tr>
			<td align="center" valign="middle" style="border: 1px solid #000000;" width="12%"> '.$fila['fechafactura'].' </td>
			<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['fechacaptura'].' </td>
			<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['cicloescolar'].' </td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.'$'.number_format($fila['importefactura'],2).' </td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$pagado.' </td>
			<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.'$'.number_format($fila['importetope'],2).' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="14%"> '.$fila['rfc'].' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="29%"> '.$fila['nombreescuela'].' </td>
			<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['tipodeduccion'].' </td>
			</tr>';
		}
		//echo ($imprimir);
		//exit();
	}
	catch (Exception $ex) {
		echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
	}
	$imprimir.='</table>';
	
	$dfechaIni = substr($fechaini,-2).'/'.substr($fechaini,-4,2).'/'.substr($fechaini,-8,4);
	$dfechaFin = substr($fechafin,-2).'/'.substr($fechafin,-4,2).'/'.substr($fechafin,-8,4);
	
	$imprimir.=
	'<br><br><br>
	<font size="10">FILTRADO POR:</font>
	<br><br>
	<table cellpadding="2">';
	if($cEmpleado != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;COLABORADOR:&nbsp;&nbsp;'.$cEmpleado.' '.$nomColaborador.'</td>
		</tr>';
	}
	$imprimir.=
	'<tr>
		<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS:&nbsp;&nbsp;'.$cEstatus.'</td>
	</tr>';
	if($cDeduccion != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;TIPO DEDUCCIÓN:&nbsp;&nbsp;'.$cDeduccion.'</td>
		</tr>';
	}
	if($cRegion != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;REGIÓN:&nbsp;&nbsp;'.$cRegion.'</td>
		</tr>';
	}
	if($cCiudad != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;CIUDAD:&nbsp;&nbsp;'.$cCiudad.'</td>
		</tr>';
	}
	if($cCentro != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;CENTRO:&nbsp;&nbsp;'.$cCentro.'</td>
		</tr>';
	}
	if($cCiclo != ''){
		$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;CICLO ESCOLAR:&nbsp;&nbsp;'.$cCiclo.'</td>
		</tr>';
	}
	$imprimir.=
		'<tr>
			<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHA DE&nbsp;'.$dfechaIni.'&nbsp;A&nbsp;'.$dfechaFin.'</td>
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
	$pdf->SetTitle('Consulta de Movimientos');
	
// set default header data

$fecha = date('d/m/Y');
		//$pdf->SetHeaderData('', '',  '', 'CONSULTA DE FACTURAS DE COLEGIATURAS\nImpreso el: '.$fecha);
		
		$pdf->SetHeaderData('', '',  '', "CONSULTA DE MOVIMIENTOS DE COLEGIATURAS\nImpreso el: $fecha");
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

//$tabla = utf8_encode($tabla);	
$imprimir = $imprimir;
	$html = <<<EOD
	$imprimir
EOD;

	$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
	ob_end_clean ();
$pdf->Output('ConsultaMovimientos.pdf', 'D');	
	// echo ("TABLA");
	// exit();
?>