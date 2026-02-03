<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
	$inum_empleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
	$ifiltro = isset($_GET['ifiltro']) ? $_GET['ifiltro'] : 0;
	$cbusqueda = isset($_GET['cbusqueda']) ? $_GET['cbusqueda'] : '';
	
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = -1;
	$iCurrentPage = -1;
	$sOrderColumn = 'fechaCaptura';
	$sOrderType = 'asc';
	$sColumns = 'ottp, empleado, nomEmpleado, beneficiario_hoja_azul, beneficiario, nomBeneficiario, facturaFiscal, fechaFactura, idCiclo, nomCiclo,fechaCaptura,idTipoPago,tipoPago,idPeriodo,periodo, importe_fac,
				importe_pago, idEstudio, estudio,idEscuela,escuela, rfc,descuento,idDeduccion, deduccion,observaciones, idRutaPago,rutaPago, numTarjeta,
				polizaCancelacion,justificacion,idFactura,marcado,usuario';
	
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$imprimir='
		<table>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
			
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="8%"><b>&nbsp;Colaborador</b></td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"><b>&nbsp;Nombre Colaborador</b></td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tipo Movimiento</b></td>				
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="25%"><b>Folio Factura&nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Importe Factura &nbsp;&nbsp;</b></td>
				<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Importe pagado &nbsp;&nbsp;</b></td>
				
			</tr>';
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_impresion_json_fun_imprimir_rechazos_generacion_pagos.txt";
		error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_impresion_json_fun_imprimir_rechazos_generacion_pagos.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_json_fun_imprimir_rechazos_generacion_pagos.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$query = "SELECT * FROM fun_imprimir_rechazos_generacion_pagos()";						
			
			$cmd->setCommandText($query);
			
			$ds = $cmd->executeDataSet();
			
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			
			//TOTALES.
			$TotalImporte=0;
			$TotalCancelado=0;
			
			foreach ($ds as $fila)
			{
				$TipoMov = $fila['idu_ajuste'];
					if($TipoMov > 0){
						$TipoMov = 'AJUSTE';
					}else{
						$TipoMov = 'FACTURA';
					}
				$TotalImporte+=$fila['importe_factura'];
				$TotalCancelado+=$fila['importe_pagado'];
				
				$imprimir.='
					<tr>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['num_empleado'].' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$fila['nombre_empleado'].' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$TipoMov.' </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$fila['folio_factura'].'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"> $'.number_format($fila['importe_factura'],2).'&nbsp;&nbsp;&nbsp; </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"> $'.number_format($fila['importe_pagado'],2).'&nbsp;&nbsp;&nbsp; </td>
					</tr>';
				$i++;
			}
			$imprimir.='
				<tr>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="8%"></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"></td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="25%"><b>TOTAL</b>&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>$'.number_format($TotalImporte, 2).'</b>&nbsp;&nbsp;&nbsp; </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="15%"><b>$'.number_format($TotalCancelado, 2).'</b>&nbsp;&nbsp;&nbsp; </td>
				</tr>';

			
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;
			error_log(date("g:i:s a")." -> Error al consumir fun_imprimir_rechazos_generacion_pagos \n",3,"log".date('d-m-Y')."_impresion_json_fun_imprimir_rechazos_generacion_pagos.txt");
			error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_json_fun_imprimir_rechazos_generacion_pagos.txt");
		}
    }
	
	$imprimir.='</table>';
	
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
	$pdf->SetTitle('Generación de pagos - facturas rechazadas');


// set default header data
		$fecha = date('d/m/Y');
		$pdf->SetHeaderData('', '',  '', "IMPRESION FACTURAS RECHAZADAS\nImpreso el: $fecha");
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
$pdf->Output('ImpresionFacturasRechazadas.pdf', 'D');

?>