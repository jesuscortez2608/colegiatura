<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$opc_busqueda = isset($_GET['opc_busqueda']) ? $_GET['opc_busqueda'] : 1;
	$nBusqueda = isset($_GET['nBusqueda']) ? $_GET['nBusqueda'] : 0;
	$nFiltro = isset($_GET['nFiltro']) ? $_GET['nFiltro'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : '';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : '';
	$columns = 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento,des_comentario';

	$hoy = date("d-m-Y");
	$Tipo='';
	if($opc_busqueda==4)
	{
		$Tipo='COLABORADOR';
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" style="border: 1px solid #000000" width="25%"><b>COLABORADOR</b></td>
				<td align="center" style="border: 1px solid #000000" width="25%"><b>CENTRO</b></td>					
				<td align="center" style="border: 1px solid #000000" width="15%"><b>PUESTO</b></td>
				<td align="center" style="border: 1px solid #000000" width="10%"><b>PARENTESCO</b></td>
				<td align="center" style="border: 1px solid #000000" width="15%"><b>ESCOLARIDAD</b></td>
				<td align="center" style="border: 1px solid #000000" width="10%"><b>DESCUENTO</b></td>
			</tr>';
	}else if($opc_busqueda==6)
	{
		$Tipo='PUESTO';
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" style="border: 1px solid #000000" width="25%"><b>PUESTO</b></td>
				<td align="center" style="border: 1px solid #000000" width="25%"><b>SECCIÓN</b></td>					
				<td align="center" style="border: 1px solid #000000" width="10%"><b>PARENTESCO</b></td>
				<td align="center" style="border: 1px solid #000000" width="15%"><b>ESCOLARIDAD</b></td>
				<td align="center" style="border: 1px solid #000000" width="10%"><b>DESCUENTO</b></td>
			</tr>';
	}
	else if($opc_busqueda==5)
	{
		$Tipo='CENTRO';
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" style="border: 1px solid #000000" width="25%"><b>CENTRO</b></td>
				<td align="center" style="border: 1px solid #000000" width="25%"><b>PUESTO</b></td>					
				<td align="center" style="border: 1px solid #000000" width="10%"><b>PARENTESCO</b></td>
				<td align="center" style="border: 1px solid #000000" width="15%"><b>ESCOLARIDAD</b></td>
				<td align="center" style="border: 1px solid #000000" width="10%"><b>DESCUENTO</b></td>
			</tr>';
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
		
		$query = "SELECT records,
		page,
		pages,
		id,
		numemp,
		nomempleado,
		centro,
		nomcentro,
		puesto,
		nompuesto,
		seccion,
		nomseccion,
		idu_parentesco,
		parentesco,
		idu_estudio,
		estudio,
		por_descuento,
		des_comentario
		FROM fun_obtener_listado_configuraciones_descuentos(
		 $opc_busqueda::integer
		, $nBusqueda::integer
		, $nFiltro::integer
		,$rowsperpage::integer
		, $page::integer			
		, '$orderby'
		, '$ordertype'
		, '$columns')";
		// print_r($query);
		// exit();
				
		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		
		
		foreach($matriz as $fila) 
		{
			if($opc_busqueda==4)
			{
				$imprimir.= '<tr>
					<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['numemp'].' '.$fila['nomempleado'].'</td>
					<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['centro'].' '.$fila['nomcentro'].'</td>					
					<td align="center" style="border: 1px solid #000000" width="15%">'.$fila['puesto'].' '.$fila['nompuesto'].'</td>
					<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['parentesco'].'</td>
					<td align="center" style="border: 1px solid #000000" width="15%">'.$fila['estudio'].'</td>
					<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['por_descuento'].'</td>
				</tr>';
			}
			else if($opc_busqueda==6)
			{
				$imprimir.= '<tr>		
					<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['puesto'].' '.$fila['nompuesto'].'</td>
					<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['seccion'].' '.$fila['nomseccion'].'</td>		
					<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['parentesco'].'</td>
					<td align="center" style="border: 1px solid #000000" width="15%">'.$fila['estudio'].'</td>
					<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['por_descuento'].'</td>
				</tr>';
			}
			else if($opc_busqueda==5)
			{
				$imprimir.='<tr>
						<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['centro'].' '.$fila['nomcentro'].'</td>
						<td align="center" style="border: 1px solid #000000" width="25%">'.$fila['puesto'].' '.$fila['nompuesto'].'</td>					
						<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['parentesco'].'</td>
						<td align="center" style="border: 1px solid #000000" width="15%">'.$fila['estudio'].'</td>
						<td align="center" style="border: 1px solid #000000" width="10%">'.$fila['por_descuento'].'</td>
					</tr>';
			}
		}
		
	} catch (Exception $ex) 
	{
		echo "Error: Ocurrió un error al intentar conectarse a la base de datos";
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
	//$pdf->SetTitle('Catalogo de Alumnos Inscritos');


// set default header data
	$pdf->SetHeaderData('', '',  '', "CONSULTA DE DESCUENTOS ESPECIALES POR $Tipo \nImpreso el: $hoy");
	
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
$pdf->Output('Consulta_Descuentos_Especiales.pdf', 'D');

?>