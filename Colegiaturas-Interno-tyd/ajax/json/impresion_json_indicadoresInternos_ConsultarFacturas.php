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
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dias_respuesta';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
	$columns = 'numemp, nombre,reembolsoConIsr, reembolsoSinIsr, region, folio_fiscal,nom_escolaridad,fecha_solicitud,fecha_autoriza_gerente, fecha_reviso_analista, fecha_pago, nom_estatus,dias_respuesta,
	anio, mes,nom_analista, numcentro_analista, nomcentro_analista, mes_rev_analista, anio_rev_analista';

	$fechaIni = isset($_GET['FechaIni']) ? $_GET['FechaIni'] : '20200101';
	$fechaFin = isset($_GET['FechaFin']) ? $_GET['FechaFin'] : '20240101';
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;

		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Número de <br> Colaborador</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Nombre</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Monto a Reembolsar <br> (CON ISR)</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Monto a Reembolsar <br> (SIN ISR)</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="14%"><b>Región</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Folio Fiscal</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Escolaridad</b></td>
			</tr>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Analista</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha Solicitud</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha <br> Autoriza Gerente</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha <br> Revisión Analista</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha Pago</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Días de Respuesta</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Año</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Mes</b></td>
			</tr>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="80%"><b>Centro</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Mes <br> Revisión Analista</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Año <br> Revisión Analista</b></td>
			</tr>';
			
	if ($datos_conexion["estado"] != 0) {
		error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT * FROM FUN_OBTENER_FACTURAS_INDICADORES_INTERNOS ($iEstatus
						, '$fechaIni'
						, '$fechaFin'
						, null
						, null
						, '$orderby'
						, '$ordertype'
						, '$columns')";
		
		
		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		$con->close();

		//CONEXIÓN A SQL SERVER
		$CDB = obtenConexion(BDPERSONALSQLSERVER);
		$CCSS = $CDB['conexion'];
		$con = new OdbcConnection($CCSS);
		$con->open();
		$cmdss = $con->createCommand();

			foreach($matriz as $fila) 
			{
				$numemp = $fila['numemp'];
				$importe = str_replace(".", "", $fila['reembolsosinisr']); 
				
				// CALCULA ISR
				try
				{
					$cmdss->setCommandText("{CALL proc_generar_isr_colegiaturas $numemp, '<Root><r e=\"$numemp\" i=\"$importe\"></r></Root>'}");
					$ds = $cmdss->executeDataSet();
					
				}
				catch(exception $ex)
				{
					$mensaje="Ocurrió un error al intentar conectarse a la base de datos server";
					$estado=-2;
				}
		
				$isr_colegiatura = number_format($ds[0]['isr_colegiatura'] / 100, 2);
				//CALCULA ISR

                $fecha_solicitud = ($fila['fecha_solicitud'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($fila['fecha_solicitud']));
                $fecha_autoriza_gerente = ($fila['fecha_autoriza_gerente'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($fila['fecha_autoriza_gerente']));
                $fecha_revision_analista = ($fila['fecha_reviso_analista'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($fila['fecha_reviso_analista']));
                $fecha_pago = ($fila['fecha_pago'] == '1900-01-01 00:00:00') ? 'N/A' : date("d/m/Y", strtotime($fila['fecha_pago']));
				$centro_analista = ($fila['numcentro_analista'] == 0) ? '' : $fila['numcentro_analista']. ' ' .$fila['nomcentro_analista'];
				$anio = ($fila['anio'] == '1900') ? '' : $fila['anio'];
				$imprimir.='<tr >
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['numemp'].' </td>  
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$fila['nombre'].' </td> 
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> $'.number_format(($fila['reembolsosinisr']+$isr_colegiatura ),2).' </td>
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> $'.number_format($fila['reembolsosinisr'],2).' </td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="14%"> '.$fila['region'].' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$fila['folio_fiscal'].' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$fila['nom_escolaridad'].' </td>
				</tr >
				<tr > 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$fila['nombre_analista'].' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fecha_solicitud.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fecha_autoriza_gerente.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fecha_revision_analista.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fecha_pago.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['nom_estatus'].' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['dias_respuestas'].' </td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$anio.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['mes'].' </td>  
				</tr >
				<tr >
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="80%"> '.$centro_analista.' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['mes_rev_analista'].' </td> 
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['anio_rev_analista'].' </td> 
				</tr>
				<br>';
				
			}

		$con->close(); //CIERRA CONEXIÓN SERVER
	} 
	catch (Exception $ex) {
		$mensaje="Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
		error_log(date("g:i:s a")." -> Error al consumir query \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
	}

	$imprimir.='</table>';
    // echo $imprimir;
	
	//Sección de Filtros.
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	$dfechaIni = substr($fechaini,-2).'/'.substr($fechaini,-4,2).'/'.substr($fechaini,-8,4);
	$dfechaFin = substr($fechafin,-2).'/'.substr($fechafin,-4,2).'/'.substr($fechafin,-8,4);
	$nom_estatus = ($iEstatus == "-1") ? "TODOS" : $matriz[0]['nom_estatus'];
	$imprimir.=
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS:&nbsp;&nbsp;'.$nom_estatus.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHA DE&nbsp;'.$fechaIni.'&nbsp;A&nbsp;'.$fechaFin.'</td>
			</tr>
		</table>';
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
	$pdf->SetTitle('Consulta de Facturas');

// set default header data
$fecha = date('d/m/Y');
$pdf->SetHeaderData('', '',  '', "CONSULTA DE FACTURAS INDICADORES INTERNOS\nImpreso el: $fecha");

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
$pdf->Output('IndicadoresInternos_ConsultaFacturas.pdf', 'D');

?>