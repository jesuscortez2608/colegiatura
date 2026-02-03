<?php
	//REPORTE DE PAGOS DE COLEGIATURAS GENERAL.
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	
	//VARIABLES DE FILTRADO.
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$cRutaPago = isset($_GET['cRutaPago']) ? $_GET['cRutaPago'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$cEstatus = isset($_GET['cEstatus']) ? $_GET['cEstatus'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$cEmpresa = isset($_GET['cEmpresa']) ? $_GET['cEmpresa'] : '';
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'idu_empresa,rango_fecha_mes,tipo_movimiento';
	$sOrderType = 'asc';
	$sColumns = 'tipo_movimiento,idu_empresa,nom_empresa,rango_fecha_mes,id_ruta_pago,id_factura,num_empleado,nom_empleado,
				fecha,idu_centro,nombre_centro,num_tarjeta,importe_concepto,importe_pagado,
				idu_tipo_deduccion, tipo_deduccion, descuento, folio_factura';
	
	//VARIABLES DE CONEXION.
	//$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $datos_conexion['mensaje'];
	$estado = $datos_conexion['estado'];
	$json = new stdClass();
	
	$imprimir='
		<table cellpadding="2">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>Año - Mes</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"><b>ID Empresa</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="16%"><b>Nom.Empresa</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"><b>Colaborador</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="16%"><b>Nombre</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"><b>Fecha</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="16%"><b>Número y Nombre Centro</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="7%"><b>#Tarjeta</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="9%"><b>Importe Concepto &nbsp;&nbsp;</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="9%"><b>Importe Pagado &nbsp;&nbsp;</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tipo de deducción </b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="4%"><b>Desc.</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="12%"><b>Factura</b></td>
			</tr>';
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."impresion_json_fun_obtener_reporte_de_pagos_colegiaturas.txt";
    } 
	else 
	{
		try
		{
			// $con = new OdbcConnection($CDB['conexion']);
			// $cadena_conexion = $datos_conexion["conexion"];
			
			$cadena_conexion = $datos_conexion["conexion"];
			
			
			$con = new OdbcConnection($cadena_conexion);
			$con->open();
			$cmd = $con->createCommand();
			
			$query = "SELECT * FROM fun_obtener_reporte_de_pagos_colegiaturas($iEmpresa, $iRutaPago, $iEstatus, '$dFechaInicio', '$dFechaFin', $iRowsPerPage, $iCurrentPage, '$sOrderColumn', '$sOrderType','$sColumns')";
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			
			// print_r($query);
			// exit();
			
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			
			foreach ($ds as $fila)
			{
				$RangoFecha = "";
				$Fecha = "";
				$Descuento = "";
				$DescripcionRenglon = "";
				$ImporteConcepto = "";
				$ImportePagado = "";
				if ($fila['tipo_movimiento'] == 0)
				{
					$RangoFecha = $fila['rango_fecha_mes'];
					$Fecha = date("d/m/Y", strtotime($fila['fecha']));
					$Descuento = number_format($fila['descuento'],0).'%';
					$DescripcionRenglon = $fila['nom_empleado'];
					$ImporteConcepto = number_format($fila['importe_concepto'],2);
					$ImportePagado = number_format($fila['importe_pagado'],2);
				}
				if ($fila['tipo_movimiento'] > 0){
					$DescripcionRenglon = '<b>'.$fila['nom_empleado'].'</b>';
					$ImporteConcepto = '<b>'.number_format($fila['importe_concepto'],2).'</b>';
					$ImportePagado = '<b>'.number_format($fila['importe_pagado'],2).'</b>';
				}
				
				$imprimir.='<tr>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$RangoFecha.' </td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"> <b>'.($fila['idu_empresa']).'</b> </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="16%"> <b>'. $fila['nom_empresa'] .'</b> </td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"> '.($fila['num_empleado']).' </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="16%"> '.$DescripcionRenglon.' </td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="6%"> '.$Fecha.' </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="16%"> '.$fila['idu_centro'].' '.$fila['nombre_centro'].' </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="7%"> '.$fila['num_tarjeta'].'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="9%"> '.$ImporteConcepto.'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="9%"> '.$ImportePagado.'&nbsp;&nbsp;&nbsp; </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['tipo_deduccion'].'&nbsp;&nbsp;&nbsp; </td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="4%"> '.$Descuento.' </td>
						<td align="left" valign="middle" style="border: 1px solid #000000;" width="12%"> '.$fila['folio_factura'].'&nbsp;&nbsp;&nbsp; </td>
					</tr>';
				// if ($fila['tipo_movimiento'] == 1){
					// $imprimir.='<hr size="10" />';
				// }
				$i++;
			}
			
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$mensaje = $ex->getMessage();
			$json->estado=-2;
		}
    }
	//echo json_encode($respuesta);
	
	
	$imprimir.='</table>';
	
	//Sacar las fechas en formato string. Ex. (22/12/2016)
	$fechaIni = substr($dFechaInicio,-2).'/'.substr($dFechaInicio,-4,2).'/'.substr($dFechaInicio,-8,4);
	$fechaFin = substr($dFechaFin,-2).'/'.substr($dFechaFin,-4,2).'/'.substr($dFechaFin,-8,4);
	
	//Sección de Filtros.
	$imprimir.=
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;EMPRESA: '.$cEmpresa.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;RUTA DE PAGO: '.$cRutaPago.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS: '.$cEstatus.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHAS DE '.$fechaIni.' A '.$fechaFin.'</td>
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
	$pdf->SetTitle('Reportes - Pagos Colegiaturas General.');


// set default header data
		$fecha = date('d/m/Y');
		$pdf->SetHeaderData('', '',  '', "IMPRESION PAGOS COLEGIATURAS GENERAL\nImpreso el: $fecha");
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
		
// $tabla = utf8_encode($tabla);

// $imprimir = $imprimir;
	$html = <<<EOD
	$imprimir
EOD;
	try {
		$pdf->writeHTML($html, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML
		// Close and output PDF document
		// This method has several options, check the source code documentation for more information.
		ob_end_clean ();
		$pdf->Output('ReportePagoColegiaturas.pdf', 'D');
	} catch (Exception $ex) {
		$desc_mensaje = "Ocurrió un error al generar el archivo.";
		// echo "<pre>";
		// print_r($desc_mensaje);
		// echo "</pre>";
		// exit();
		echo $desc_mensaje;
	}
?>