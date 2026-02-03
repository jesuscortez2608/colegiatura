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
	
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$dFechaInicial = isset($_GET['dFechaInicial']) ? $_GET['dFechaInicial'] : 0;
	$dFechaFinal = isset($_GET['dFechaFinal']) ? $_GET['dFechaFinal'] : 0;
	$iTipoNomina = isset($_GET['iTipoNomina']) ? $_GET['iTipoNomina'] : 0;
	$cEstatus = isset($_GET['cEstatus']) ? $_GET['cEstatus'] : 0;
	$cCiudad = isset($_GET['cCiudad']) ? $_GET['cCiudad'] : 0;
	$cRegion = isset($_GET['cRegion']) ? $_GET['cRegion'] : 0;
	$cTipoNomina = isset($_GET['cNomina']) ? $_GET['cNomina'] : ''; 
	//Variables para paginación.
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$page = isset($_GET['page']) ? $_GET['page'] : -1;
	$orderby = 'idempleado';
	$ordertype = 'asc';
	$columns = 'IdEmpleado, NombreEmpleado, IdPuesto, Puesto, IdCentro, Centro, IdRegion, Region, IdCiudad, Ciudad, IdEmpleadoDeJefeInmediato, JefeInmediato, IdStatus, NumeroDeFacturasEnProceso, IdTipoDocumento, TipoDocumento, FecPrimerFactura, TotalGralFacturas,empresa, opc_blog_aclaracion, opc_blog_revision, tipo';
	

	$hoy = date("d-m-Y");
	
	if ( $iEstatus == 4 ) {
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>TIPO DOCUMENTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="7%"><b>BLOG ACLARACIÓN</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="33%"><b>COLABORADOR</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>PUESTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"><b>CENTRO</b></td>
			</tr><tr bgcolor="#808080" style="color: #FFFFFF" >	
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>FACTURAS</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>REGIÓN</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>CIUDAD</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="30%"><b>JEFE INMEDIATO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>EMPRESA</b></td>
			</tr>	
		';
	} else if ( $iEstatus == 5 ) {
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>TIPO DOCUMENTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="7%"><b>BLOG REVISIÓN</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="33%"><b>COLABORADOR</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>PUESTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"><b>CENTRO</b></td>
			</tr><tr bgcolor="#808080" style="color: #FFFFFF" >	
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>FACTURAS</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>REGIÓN</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>CIUDAD</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="30%"><b>JEFE INMEDIATO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>EMPRESA</b></td>
			</tr>	
		';
	} else {
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>TIPO DOCUMENTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="40%"><b>COLABORADOR</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>PUESTO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"><b>CENTRO</b></td>
			</tr><tr bgcolor="#808080" style="color: #FFFFFF" >	
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="5%"><b>FACTURAS</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>REGIÓN</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>CIUDAD</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="30%"><b>JEFE INMEDIATO</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>EMPRESA</b></td>
			</tr>	
		';
	}
	
			
	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT
					records, page, pages, id,
					idempleado, nombreempleado, idpuesto,
					puesto, idcentro, centro, idregion, region, idciudad,
					ciudad, idempleadodejefeinmediato,
					jefeinmediato, idstatus, numerodefacturasenproceso, idtipodocumento, nomtipodocumento, fecprimerfecha, totalgralfacturas, empresa,
					opc_blog_aclaracion,opc_blog_revision
				FROM fun_obtener_empleados_con_facturas(
					$iEmpleado
					, $iRegion
					, $iCiudad
					, $iEstatus
					, '$dFechaInicial'
					, '$dFechaFinal'
					, $iTipoNomina
					, $iEmpresa
					, $rowsperpage
					, $page
					, '$orderby'
					, '$ordertype'
					, '$columns'
			)";
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
	
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		$con->close();
		
		$TotalFacturas = 0;
		foreach($matriz as $fila) 
		{
			$TotalFacturas = $fila['totalgralfacturas'];
			$nombreEmp=$fila['idempleado'].' '.trim($fila['nombreempleado']);
			$nombrePuesto=$fila['idpuesto'].' '.trim($fila['puesto']);
			$nombreCentro=$fila['idcentro'].' '.trim($fila['centro']);
			$nombreRegion=$fila['idregion'].' '.trim($fila['region']);
			$nombreCiudad=$fila['idciudad'].' '.trim($fila['ciudad']);
			$Jefe=$fila['idempleadodejefeinmediato'].' '.trim($fila['jefeinmediato']);
			$TipoDocumento = trim($fila['nomtipodocumento']);
			$sEmpresa = trim(encodeToUtf8($fila['empresa']));

			if ( $fila['opc_blog_aclaracion'] == 1 ) {
				// $BlogAclaracion = '<strong><i class="icon-envelope"></i></strong>';
				$BlogAclaracion = 'Sí';
			} else {
				$BlogAclaracion = '';
			}
			if ( $fila['opc_blog_revision'] == 1 ) {
				// $BlogRevision = '<strong><i class="icon-envelope"></i></strong>';
				$BlogRevision = 'Sí';
			} else {
				$BlogRevision = '';
			}
			
			//utf8_encode($fila['rfc']).' - '.utf8_encode($fila['nombreescuela']).' </td>
			if ( $iEstatus == 4 ) {
				$imprimir.='<tr >
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$TipoDocumento.'</td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="7%"> '.$BlogAclaracion.'</td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="33%"> '.$nombreEmp.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombrePuesto.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$nombreCentro.' </td>
				</tr> 
				<tr>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['numerodefacturasenproceso'].' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreRegion.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreCiudad.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="30%"> '.$Jefe.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$sEmpresa.' </td>
				</tr>
				<br>';
			} else if ( $iEstatus == 5 ) {
				$imprimir.='<tr >
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$TipoDocumento.'</td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="7%"> '.$BlogRevision.'</td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="33%"> '.$nombreEmp.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombrePuesto.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$nombreCentro.' </td>
				</tr> 
				<tr>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['numerodefacturasenproceso'].' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreRegion.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreCiudad.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="30%"> '.$Jefe.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$sEmpresa.' </td>
				</tr>
				<br>';
			} else {
				$imprimir.='<tr >
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$TipoDocumento.'</td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="40%"> '.$nombreEmp.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombrePuesto.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$nombreCentro.' </td>
				</tr> 
				<tr>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="5%"> '.$fila['numerodefacturasenproceso'].' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreRegion.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$nombreCiudad.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="30%"> '.$Jefe.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$sEmpresa.' </td>
				</tr>
				<br>';
			}
			
			
		}
		$imprimir.='
			<tr>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="95%"> <b>'.$TotalFacturas.' FACTURAS EN TOTAL</b></td>
			</tr>';
	}	
	catch (Exception $ex) {
		echo "Error: Al intentar conectar a la base de datos";
	}

	$imprimir.='</table>';
	
	
	//Sección de Filtros.
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	
	
	$dfechaIni = substr($dFechaInicial,-2).'/'.substr($dFechaInicial,-4,2).'/'.substr($dFechaInicial,-8,4);
	$dfechaFin = substr($dFechaFinal,-2).'/'.substr($dFechaFinal,-4,2).'/'.substr($dFechaFinal,-8,4);

	$imprimir.=
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;REGIÓN:&nbsp;&nbsp;'.$cRegion.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;CIUDAD:&nbsp;&nbsp;'.$cCiudad.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS:&nbsp;&nbsp;'.$cEstatus.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;TIPO DE NOMINA:&nbsp;&nbsp;'.$cNomina.'</td>
			</tr>
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;FECHA DE&nbsp;'.$dfechaIni.'&nbsp;A&nbsp;'.$dfechaFin.'</td>
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
		$pdf->SetHeaderData('', '',  '', "SEGUIMIENTO DE FACTURAS POR PERSONAL ADMINISTRACIÓN\nImpreso el: $fecha ");
		
		
			//$pdf->SetHeaderData('', '',  '', "CONSULTA DE FACTURAS DE COLEGIATURAS\nImpreso el: $fecha\nEmpleado: $empleado $nom_empleado");
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
$pdf->Output('SeguimientoFacturasPA.pdf', 'D');

?>