<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	$_GETS = filter_input_array(INPUT_GET,FILTER_SANITIZE_SPECIAL_CHARS);

	$dFecha = isset($_GET['dFecha']) ? $_GETS['dFecha'] : '';
	$iTipoDato = isset($_GET['iTipoDato']) ? $_GETS['iTipoDato'] : 0;
	$iDato = isset($_GET['iDato']) ? $_GETS['iDato'] : 0;

		
			
	if ($datos_conexion["estado"] != 0) {
		error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_impresion_indicadores_internos_CentroColab.txt");
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT * FROM FUN_CALCULA_INDICADORES_INTERNOS ($iTipoDato
		,  $iDato 
		,  '$dFecha')";
						
		
		
		$cmd->setCommandText($query);		
		$matriz = $cmd->executeDataSet();
		$con->close();

		// echo "<pre>";
		// print_r($matriz);
		// echo "</pre>";
		// exit();

		// IMPRIME MES
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="100%"><b>MENSUAL</b></td>
			</tr>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>Año</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="9%"><b>Mes</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Días de Revisión</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Solicitudes</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tiempo Promedio</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>#Rev. en Tiempo</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Eficiencia</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta % de Eficiencia</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento Eficiencia</b></td>
			</tr>';
		
			foreach($matriz as $fila) 
			{
				$per_cumplimiento_mes = isset($fila['per_cumplimiento_mes']) ? (substr($fila['per_cumplimiento_mes'], -3) === '.00' ? substr($fila['per_cumplimiento_mes'], 0, -3) . '%' : $fila['per_cumplimiento_mes'] . '%') : '';
				$per_eficiencia_mes = isset($fila['per_eficiencia_mes']) ? (substr($fila['per_eficiencia_mes'], -3) === '.00' ? substr($fila['per_eficiencia_mes'], 0, -3) . '%' : $fila['per_eficiencia_mes'] . '%') : '';
				$per_cumpli_efic_mes = isset($fila['per_cumpli_efic_mes']) ? (substr($fila['per_cumpli_efic_mes'], -3) === '.00' ? substr($fila['per_cumpli_efic_mes'], 0, -3) . '%' : $fila['per_cumpli_efic_mes'] . '%') : '';
		
				$imprimir.='<tr >
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['anio'].' </td>  
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="9%"> '.$fila['mes'].' </td> 
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['dias_revision_mes'], 0, '.', ',').' </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['solicitudes_mes'], 0, '.', ',').' </td> 
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['meta_mes'].' </td> 
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['tiempo_promedio_mes'].' </td>
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumplimiento_mes.' </td>
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['rev_tiempo_mes'], 0, '.', ',').' </td>
					<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.(($fila['eficiencia_mes']) ? $fila['eficiencia_mes'].'%' : '').' </td> 
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$per_eficiencia_mes.' </td>
					<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumpli_efic_mes.' </td>
				</tr >';
				
			}
			
			// IMPRIME ACUMULADO
			$imprimir1='<table cellpadding="4">
				<tr bgcolor="#808080" style="color: #FFFFFF" >
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="100%"><b>ACUMULADO</b></td>
				</tr>
				<tr bgcolor="#808080" style="color: #FFFFFF" >
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>Año</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="9%"><b>Mes</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Días de Revisión</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Solicitudes</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tiempo Promedio</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>#Rev. en Tiempo</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Eficiencia</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta % de Eficiencia</b></td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento Eficiencia</b></td>
				</tr>';
			
				foreach($matriz as $fila) 
				{
					$per_cumplimiento_acum = isset($fila['per_cumplimiento_acum']) ? (substr($fila['per_cumplimiento_acum'], -3) === '.00' ? substr($fila['per_cumplimiento_acum'], 0, -3) . '%' : $fila['per_cumplimiento_acum'] . '%') : '';
					$per_eficiencia_acum = isset($fila['per_eficiencia_acum']) ? (substr($fila['per_eficiencia_acum'], -3) === '.00' ? substr($fila['per_eficiencia_acum'], 0, -3) . '%' : $fila['per_eficiencia_acum'] . '%') : '';
					$per_cumpli_efic_acum = isset($fila['per_cumpli_efic_acum']) ? (substr($fila['per_cumpli_efic_acum'], -3) === '.00' ? substr($fila['per_cumpli_efic_acum'], 0, -3) . '%' : $fila['per_cumpli_efic_acum'] . '%') : '';
			
					$imprimir1.='<tr >
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['anio'].' </td>  
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="9%"> '.$fila['mes'].' </td> 
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['dias_revision_acum'], 0, '.', ',').' </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['solicitudes_acum'], 0, '.', ',').' </td> 
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['meta_acum'].' </td> 
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['tiempo_promedio_acum'].' </td>
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumplimiento_acum.' </td>
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['rev_tiempo_acum'], 0, '.', ',').' </td>
						<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.(($fila['eficiencia_acum']) ? $fila['eficiencia_acum'].'%' : '').' </td> 
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$per_eficiencia_acum.' </td>
						<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumpli_efic_acum.' </td>
					</tr >';
					
				}
			
				// IMPRIME MÓVIL
				$imprimir2='<table cellpadding="4">
					<tr bgcolor="#808080" style="color: #FFFFFF" >
						<td align="center" valign="middle" style="border: 2px solid #000000;" width="100%"><b>ANUAL MÓVIL</b></td>
					</tr>
					<tr bgcolor="#808080" style="color: #FFFFFF" >
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>Año</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="9%"><b>Mes</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Días de Revisión</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Solicitudes</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Tiempo Promedio</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>#Rev. en Tiempo</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Eficiencia</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Meta % de Eficiencia</b></td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>% Cumplimiento Eficiencia</b></td>
					</tr>';
				
					foreach($matriz as $fila) 
					{
						$per_cumplimiento_movil = isset($fila['per_cumplimiento_movil']) ? (substr($fila['per_cumplimiento_movil'], -3) === '.00' ? substr($fila['per_cumplimiento_movil'], 0, -3) . '%' : $fila['per_cumplimiento_movil'] . '%') : '';
						$per_eficiencia_movil = isset($fila['per_eficiencia_movil']) ? (substr($fila['per_eficiencia_movil'], -3) === '.00' ? substr($fila['per_eficiencia_movil'], 0, -3) . '%' : $fila['per_eficiencia_movil'] . '%') : '';
						$per_cumpli_efic_movil = isset($fila['per_cumpli_efic_movil']) ? (substr($fila['per_cumpli_efic_movil'], -3) === '.00' ? substr($fila['per_cumpli_efic_movil'], 0, -3) . '%' : $fila['per_cumpli_efic_movil'] . '%') : '';
				
						$imprimir2.='<tr >
							<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['anio'].' </td>  
							<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="9%"> '.$fila['mes'].' </td> 
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['dias_revision_movil'], 0, '.', ',').' </td>
							<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['solicitudes_movil'], 0, '.', ',').' </td> 
							<td align="right" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['meta_movil'].' </td> 
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['tiempo_promedio_movil'].' </td>
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumplimiento_movil.' </td>
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['rev_tiempo_movil'], 0, '.', ',').' </td>
							<td align="right" valign="middle" style="border: 1px solid #000000;" width="10%"> '.(($fila['eficiencia_movil']) ? $fila['eficiencia_movil'].'%' : '').' </td> 
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$per_eficiencia_movil.' </td>
							<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$per_cumpli_efic_movil.' </td>
						</tr >';
						
					}
	} 
	catch (Exception $ex) {
		$mensaje="Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
		error_log(date("g:i:s a")." -> Error al consumir query \n",3,"log".date('d-m-Y')."_impresion_indicadores_internos_CentroColab.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_indicadores_internos_CentroColab.txt");
	}

	$imprimir.='</table>'; //MES
	$imprimir1.='</table>'; // ACUMULADO
	$imprimir2.='</table>'; // ANUAL
    // echo $imprimir;
	
	$reporte_tipo = ($iTipoDato == 1) ? 'CENTRO' : 'COLABORADOR';
	$nombre_cc = $matriz[0]['nombre'];
	// MES
	$pie =
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;'.$reporte_tipo.':&nbsp;&nbsp;'.$nombre_cc.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHA DE&nbsp;'.$dFecha.'</td>
			</tr>
		</table>';

	$imprimir.= $pie;
	$imprimir1.= $pie;
	$imprimir2.= $pie;
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
	$pdf->SetTitle('Consulta de '.$reporte_tipo);

// set default header data
$fecha = date('d/m/Y');
$pdf->SetHeaderData('', '',  '', "CONSULTA DE INDICADORES INTERNOS ".$reporte_tipo."\nImpreso el: $fecha");


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

		
//$tabla = utf8_encode($tabla);	

// $imprimir = $imprimir;
// 	$html = <<<EOD
// 	$imprimir
// EOD;

// Add a page
// This method has several options, check the source code documentation for more information.
$pdf->AddPage();
$pdf->writeHTML($imprimir, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML MENSUAL
$pdf->AddPage();
$pdf->writeHTML($imprimir1, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML ACUMULADO
$pdf->AddPage();
$pdf->writeHTML($imprimir2, true, false, true, false, '');//ESTE ES PARA INSERTAR HTML ANUAL
	

	// Close and output PDF document
	// This method has several options, check the source code documentation for more information.
	ob_end_clean ();
$pdf->Output('IndicadoresInternos_'.$reporte_tipo.'.pdf', 'D');

?>