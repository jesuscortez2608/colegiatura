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

	$rowsperpage = isset($_GET['rows']) ? $_GETS['rows'] : -1;
	$page = isset($_GET['page']) ? $_GETS['page'] : -1;
	$orderby = isset($_GET['sidx']) ? $_GETS['sidx'] : 'fechaFactura';
	$ordertype = isset($_GET['sord']) ? $_GETS['sord'] : 'asc';
	$columns = isset($_GET['columns']) ? $_GETS['columns'] : 'otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
		, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
		, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela, iFactura,empleado, comentario,aclaracion, observaciones
		, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus, rutapago, nom_rutapago, archivo1, archivo2';
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 0;
	$iOpcion = isset($_GET['iOpcion']) ? $_GETS['iOpcion'] : 0;
	$fechaini = isset($_GET['fechaini']) ? $_GETS['fechaini'] : '19000101';
	$fechafin = isset($_GET['fechafin']) ? $_GETS['fechafin'] : '19000101';
	$tipo = isset($_GET['tipo']) ? $_GETS['tipo'] : 0;	
	$empleado = isset($_GET['empleado']) ? $_GETS['empleado'] : 0;
	$nom_empleado = isset($_GET['nom_empleado']) ? $_GET['nom_empleado'] : '';
	$cEstatus = isset($_GET['cEstatus']) ? $_GET['cEstatus'] : 0;
	$cicloEscolar = isset($_GET['cicloEscolar']) ? $_GETS['cicloEscolar'] : 0;
	if($empleado==0)
	{
		$empleado=(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;
	}
	// print_r($empleado);
	// exit();
//$iOpcion 2	
	$hoy = date("d-m-Y");
	if($iOpcion ==1)
	{
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Fecha Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"><b>Modificó Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="25%"><b>Factura</b></td>
			</tr>	
			<tr bgcolor="#808080" style="color: #FFFFFF" >	
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="35%"><b>Escuela</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Importe Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Fecha Pago</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Importe Pagado</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="15%"><b>Ciclo Escolar</b></td>
			</tr>';
	}
	if($iOpcion ==2)
	{
		$imprimir='<table cellpadding="4">
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="30%"><b>Escuela</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Importe Factura</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Pago</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"><b>Ruta de pago</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Importe Pagado</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Ciclo Escolar</b></td>
			</tr>
			<tr bgcolor="#808080" style="color: #FFFFFF" >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"><b>Fecha Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"><b>Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="30%"><b>Modificó Estatus</b></td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="42%"><b>Observaciones</b></td>
			</tr>';
	}			
	if ($datos_conexion["estado"] != 0) {
		error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT records, page, pages, id
				, otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
				, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
				, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela,iFactura, empleado
				, comentario,aclaracion, observaciones
				, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus
				, rutapago, nom_rutapago, archivo1, archivo2
			FROM fun_obtener_facturas_colegiaturas_por_empleado($empleado, $tipo
			, $rowsperpage
			, $page
			, '$orderby'
			, '$ordertype'
			, '$columns'
			,'$fechaini'
			,'$fechafin'
			,$cicloEscolar
			,$iOpcion)";
		
		// echo($query);
		// exit();
		$cmd->setCommandText($query);
		
		$matriz = $cmd->executeDataSet();
		$con->close();
		// print_r($matriz);
		// exit();
		if($iOpcion ==1)
		{
			foreach($matriz as $fila) 
			{
				
				if($fila['factura']!='0')
				{
				
					$factura= $fila['factura'];
				}
				else
				{
					$factura= '';
				}	
				if ($fila['rfc']=='')
				{
				
					$escuela='<B>TOTAL</B>';
					$pagado=$fila['importepagar']==0 ? '' : number_format($fila['importepagar'],2);
				}
				else
				{	
					$escuela=$fila['rfc'].' - '.$fila['nombreescuela'];
					$pagado=$fila['estatus']==5 ? number_format($fila['importepagar'],2) :  '';
				}	
				
				//$fechaestatus=$fila['nom_rutapago']=='01/01/1900' ? '' : $fila['fecha_estatus'];
				$fechaestatus=$fila['factura'] == 0 ? $fila['fechacaptura'] :  $fila['fecha_estatus'];
				$modifico= $fila['estatus']==0 ?'' :$fila['emp_estatus'].'  '.$fila['nom_empleado_estatus'];
				$fechafactura=$fila['rfc']==''? '': $fila['fechafactura'];
				$factura=$fila['factura'] == 0 ? '': $fila['factura'];
				
				$fecpago=$fila['estatus']==5  ? $fila['fecha_estatus']: '' ;
				
				//utf8_encode($fila['rfc']).' - '.utf8_encode($fila['nombreescuela']).' </td>
				
				//if($fila['factura']!='0')
				if($fila['rfc']!='')
				{
					$imprimir.='<tr >
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fechafactura.' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="15%"> '.$fila['nom_estatus'].' </td>
						<td align="center" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fechaestatus.' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$modifico.' </td>
						<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="25%"> '.$fila['factura'].' </td>
					</tr>';
				
				}
				$imprimir.='<tr >
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="35%"> '.$escuela.' </td>  
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.number_format($fila['importerealfact'],2).' </td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="15%"> '.$fecpago.' </td>
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$pagado.' </td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="15%"> '.$fila['ciclo'].' </td>
				</tr>';
				
			}
		}	
		if($iOpcion ==2)
		{
			foreach($matriz as $fila) 
			{
				
				$factura=$fila['factura'] == 0 ? '': $fila['factura'];
				$escuela=$fila['rfc']=='' ? '<B>TOTAL</B>' : $fila['rfc'].' - '.$fila['nombreescuela'];
				$pagado= $fila['estatus'] == 5 ?  number_format($fila['importepagar'],2) : '';
				$rutaPago=$fila['nom_rutapago']=='01/01/1900' ? '' : $fila['nom_rutapago'];
				
				$modifico= $fila['estatus']==0 ?'' :$fila['emp_estatus'].'  '.$fila['nom_empleado_estatus'];
				$fechafactura=$fila['rfc']==''? '': $fila['fechafactura'];
				$fechaestatus=$fila['factura'] == 0 ? $fila['fechacaptura'] :  $fila['fecha_estatus'];
				//utf8_encode($fila['rfc']).' - '.utf8_encode($fila['nombreescuela']).' </td>
				$imprimir.='<tr >
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fechafactura.' </td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$factura.' </td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="30%"> '.$escuela.' </td>  
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.number_format($fila['importerealfact'],2).' </td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$rutaPago.' </td>
				<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="10%"> '.$fila['nom_rutapago'].' </td>
				<td align="rigth" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$pagado.' </td>
				<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fila['ciclo'].' </td>
				</tr>';
				if($fila['rfc']!='')
				{
					$imprimir.='<tr>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="8%"> '.$fechaestatus.' </td>
					<td align="center" valign="middle" style="border: 1px solid #000000;" width="20%"> '.$fila['nom_estatus'].' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="30%"> '.$modifico.' </td>
					<td align="lefth" valign="middle" style="border: 1px solid #000000;" width="42%"> '.$fila['observaciones'].' </td>
					</tr>';
				}
			
				
			}
		}	
		// echo ($imprimir);		
		// exit();
	} 
	catch (Exception $ex) {
		$mensaje="Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
		error_log(date("g:i:s a")." -> Error al consumir $query \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_impresion_facturas_colegiaturas_por_empleado.txt");
	}

	$imprimir.='</table>';
	
	//Sección de Filtros.
	//Sacar las fechas en formato string. Ex. DE (20161222) A ===> (22/12/2016).
	$dfechaIni = substr($fechaini,-2).'/'.substr($fechaini,-4,2).'/'.substr($fechaini,-8,4);
	$dfechaFin = substr($fechafin,-2).'/'.substr($fechafin,-4,2).'/'.substr($fechafin,-8,4);
	
	$imprimir.=
		'<br><br><br>
		<font size="10">FILTRADO POR:</font>
		<br><br>
		<table cellpadding="2">
			<tr>
				<td style="border: 1px solid #000000;" width="25%">&nbsp;&nbsp;ESTATUS:&nbsp;&nbsp;'.$cEstatus.'</td>
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
		//$pdf->SetHeaderData('', '',  '', 'CONSULTA DE FACTURAS DE COLEGIATURAS\nImpreso el: '.$fecha);
		if($iOpcion ==1)
		{
			$pdf->SetHeaderData('', '',  '', "CONSULTA DE FACTURAS DE COLEGIATURAS\nImpreso el: $fecha\nColaborador: $empleado $nom_empleado");
			//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);                                          
		}
		if($iOpcion ==2)
		{
			$pdf->SetHeaderData('', '',  '', "CONSULTA DE FACTURAS DE COLEGIATURAS\nImpreso el: $fecha\nColaborador: $empleado $nom_empleado");
			//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);                                          
		}

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
$pdf->Output('ConsultaFacturasColegiaturas.pdf', 'D');

?>