<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$_GETS = filter_input_array(INPUT_GET,FILTER_SANITIZE_SPECIAL_CHARS);
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GETS['rows'] : 0;
	$page = isset($_GET['page']) ? $_GETS['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GETS['sidx'] : 'fec_orden';
	// $orderby = 'fec_orden';
	// $ordertype = 'desc';
	$ordertype = isset($_GET['sord']) ? $_GETS['sord'] : 'desc';
	$columns = isset($_GET['columns']) ? $_GETS['columns'] : 'fechaasignacion, fechaconcluyo, estatusrevision
		, nom_estatusrevision, otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
		, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
		, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela, iFactura,empleado, nom_empleado, comentario,aclaracion, observaciones
		, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus, rutapago, nom_rutapago, archivo1, archivo2, fechaFac, fecestatus,prc_descuento,tipo_deduccion
		, idtipodocumento, nombretipodocumento, opc_blog, opc_blog_colaborador, idNotaCredito, folionota, importeaplicado,idu_motivo_revision,des_motivo_revision, opc_modifico_pago, des_metodo_pago, fol_relacionado,imotivo_rechazo,fec_orden';
	$inicializar = isset($_GET['inicializar']) ? $_GETS['inicializar'] : 0;
	$iOpcion = isset($_GET['iOpcion']) ? $_GETS['iOpcion'] : 0;
	$fechaini = isset($_GET['fechaini']) ? $_GETS['fechaini'] : '19000101';
	$fechafin = isset($_GET['fechafin']) ? $_GETS['fechafin'] : '19000101';
	$tipo = isset($_GET['tipo']) ? $_GETS['tipo'] : 0;	
	$sEmpleados = isset($_GET['sEmpleados']) ? $_GET['sEmpleados'] : 0;
	$cicloEscolar = isset($_GET['cicloEscolar']) ? $_GETS['cicloEscolar'] : 0;
	// echo('opcion='.$iOpcion);
	// exit();
	if($sEmpleados=="" || $sEmpleados == 0)
	{
		$sEmpleados=(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;
	}
	if (($inicializar == 1)) {
		$response = new stdClass();
		try {
			echo json_encode($response);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit();
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
		/*print_r("SELECT records, page, pages, id
				, otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
				, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
				, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela,iFactura, empleado
				, comentario,aclaracion, observaciones
				, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus
				, rutapago, nom_rutapago,fecestatus,prc_descuento, tipo_deduccion
				, idtipodocumento, nombretipodocumento,opc_blog
			FROM fun_obtener_facturas_colegiaturas_por_empleado('$sEmpleados', $tipo
			, $rowsperpage
			, $page
			, '$orderby'
			, '$ordertype'
			, '$columns'
			, '$fechaini'
			, '$fechafin'
			,$cicloEscolar
			,$iOpcion)");
		exit();*/
		
		$query = "SELECT records, page, pages, id, fechaasignacion, fechaconcluyo, estatusrevision
				, nom_estatusrevision, otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
				, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela
				, tipoEscuela,iFactura, empleado, nom_empleado, comentario,aclaracion, observaciones, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus
				, rutapago, nom_rutapago, archivo1, archivo2, fecestatus,prc_descuento, tipo_deduccion, idtipodocumento, nombretipodocumento, opc_blog, opc_blog_colaborador, 
				idNotaCredito, folionota, importeaplicado,idu_motivo_revision,des_motivo_revision, opc_modifico_pago, des_metodo_pago, fol_relacionado, des_metodo_pago, fol_relacionado, imotivo_rechazo 
			FROM fun_obtener_facturas_colegiaturas_por_empleado('$sEmpleados', $tipo
			, $rowsperpage
			, $page
			, '$orderby'
			, '$ordertype'
			, '$columns'
			, '$fechaini'
			, '$fechafin'
			, $cicloEscolar
			, $iOpcion)";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		$id=0;
		if($iOpcion==0)//autorizar y rechazar facturas
		{
			foreach($matriz as $fila) {
				$respuesta->rows[$id]['id']=$id;
				$marcaTope="";
				$otpp="";
				if($fila['marcatope']==1)
				{	
					$marcaTope='<font color="#FF0000" size="4"><b>* </b></font>';
					$importeCalculdao='<font color="#FF0000" size="4"><b>'.number_format($fila['importecal'],2).' </b></font>';
				}
				else
				{
					$importeCalculdao=number_format($fila['importecal'],2);
				}
				if($fila['otpp']==1)
				{
					$otpp='<font color="#00A400"><b>&#8730;</b></font>';
				}
				if ($fila['factura']=='0') // total factura
				{
					
				}
				else
				{
					/*idTipoEscuela, tipoEscuela, iFactura,empleado, comentario,aclaracion, observaciones
		, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus, rutapago, nom_rutapago, archivo1, archivo2, fechaFac, fecestatus,prc_descuento,tipo_deduccion
		, idtipodocumento, nombretipodocumento*/
					$blog='';
					if ($fila['opc_blog']==1) { 
						$blog= '<i class="icon-envelope"></i>' ;
					}
					
					$blog_colaborador='';
					if ($fila['opc_blog_colaborador']==1) { 
						$blog_colaborador= '<i class="icon-envelope"></i>' ;
						//$blog_colaborador= 'hola' ;
					}
					
					if ($fila['fechaconcluyo']=='01/01/1900'){
						$fechaConcluyo='';
					}else{
						$fechaConcluyo=$fila['fechaconcluyo'];
					};
		
					$respuesta->rows[$id]['cell']=
						array('',
						$fila['fechaasignacion'],
						$fechaConcluyo,
						$fila['estatusrevision'],
						$fila['nom_estatusrevision'],
						$otpp,
						$fila['idbeneficiario']
						,encodeToUtf8($fila['nombrebecado'])
						,$fila['factura']
						,$fila['fechafactura']
						,$fila['fechacaptura']
						,number_format($fila['importerealfact'],2)//$fila['importerealfact']
						,number_format($fila['importeconcepto'],2)//$fila['importeconcepto']
						,$marcaTope.'  '.number_format($fila['topefactura'],2)//$fila['topefactura']
						,$importeCalculdao//number_format($fila['importecal'],2)//$fila['importecal']
						,$fila['importepagar'] == 0 ? '0.00' : number_format($fila['importepagar'],2)
						,$fila['rfc']
						,$fila['idescuela']
						,encodeToUtf8($fila['nombreescuela'])
						,substr($fila['fechafactura'],6,4)//$fila['ciclo']//$fila['idciclo']
						// ,$fila['idciclo']
						,$fila['ciclo']
						,$fila['idtipoescuela']
						,encodeToUtf8($fila['tipoescuela'])
						,$fila['ifactura']
						,$fila['empleado']
						// ,$fila['empleado'].' - '.utf8_encode($fila['nombrebecado'])
						,encodeToUtf8($fila['comentario'])
						,encodeToUtf8($fila['aclaracion'])
						,encodeToUtf8($fila['observaciones'])						
						,encodeToUtf8($fila['archivo1'])
						,encodeToUtf8($fila['archivo2'])
						,$fila['tipo_deduccion']
						,$fila['idtipodocumento']
						,encodeToUtf8($fila['nombretipodocumento'])
						,$fila['opc_blog']
						,$blog
						,$fila['opc_blog_colaborador']
						,$blog_colaborador
						//--nota de credito
						,$fila['idnotacredito'] 
						,$fila['folionota'] 
						,$fila['importeaplicado']	
						,$fila['idu_motivo_revision']
						,$fila['des_motivo_revision']
						,$fila['opc_modifico_pago']
						,$fila['des_metodo_pago']
						,$fila['fol_relacionado']
						,$fila['idciclo']
					);
				}	
				$id++;
			}
		} 
		else if($iOpcion==1) 
		{ // Seguimiento de Facturas Electronicas por Colaborador
			// if($tipo!=5)
			// {
				// $fechaPago='';
			// }
			// else//
			// {
				// $fechaPago=$fila['fecha_estatus'];
			// }
			
			
			foreach($matriz as $fila) {
				$Pagado=0;
				if($fila['fecha_estatus']=='01/01/1900')
				{
					$fechaE=$fila['fechacaptura'];
				}
				else
				{
					$fechaE= strtotime($fila['fecestatus']); // antes era ['fecha_estatus'] pero pasaron cosas
					$fechaE = date('d/m/Y',$fechaE);
				}
				if($fila['estatus']==0 && $fila['emp_estatus'] == 0)
				{
					$modifico='';
				}else{
					$modifico = encodeToUtf8($fila['nom_empleado_estatus']);
				}
				
				$blog_colaborador='';
				if ($fila['opc_blog_colaborador']==1) { 
					$blog_colaborador= '<i class="icon-envelope"></i>' ;
					//$blog_colaborador= 'hola' ;
				}
				// else
				// {
					/*
					if($fila['emp_estatus']==0)
					{
						$modifico='';
						// $modifico=$fila['nom_empleado_estatus'];
					}
					else
					{
						//$modifico=$fila['emp_estatus'].'  '.$fila['nom_empleado_estatus'];
						$modifico=$fila['nom_empleado_estatus'];
					}*/
				// }
				if ($fila['nombreescuela']=='')
				{
					$escuela='<b>TOTAL</b>';
					$fechafactura='';
					$fechaE='';
					$Pagado=$fila['importepagar'];
				}
				else
				{
					$escuela=encodeToUtf8($fila['rfc']).' - '.encodeToUtf8($fila['nombreescuela']);
					//$escuela=utf8_encode($fila['rfc']).' - '.utf8_encode($fila['nombreescuela']);
					$fechafactura=$fila['fechafactura'];
					$Pagado=$fila['estatus'] != 6 ? 0 :$fila['importepagar'];
				}
				if($fila['estatus'] == 0 && $fila['observaciones'] != '' && $fila['imotivo_rechazo'] > 0){
					$NomEstatus = 'RECHAZADO POR GERENTE';
				} else {
					$NomEstatus = $fila['nom_estatus'];
				}
				$respuesta->rows[$id]['id']=$id;
				$respuesta->rows[$id]['cell']=
					array(
					$fechafactura
					,$fila['estatus']
					// ,$fila['nom_estatus']
					, $NomEstatus
					//,$fila['fecha_estatus']
					,$fechaE
					,$modifico//$fila['emp_estatus'].' '.$fila['nom_empleado_estatus']
					,$fila['factura']=='0' ? '': $fila['factura']
					,$fila['idtipodocumento']
					,encodeToUtf8($fila['nombretipodocumento'])  //se agrega el nombre del tipo documento
					,$escuela
					,number_format($fila['importerealfact'],2)
					,$fila['importerealfact']
					,$fila['estatus']==6 ? $fila['fecha_estatus'] : ' '//$fechaPago
					,$Pagado==0 ? '' : number_format($Pagado,2)
					,$Pagado==0 ? '' : $Pagado
					,$fila['idtipoescuela']
					,substr($fechafactura,6,4)//$fila['ciclo']//$fila['idciclo']//$fila['idciclo']
					// ,$fila['idciclo']
					,$fila['ciclo']
					//OALH, $fila['idu_motivo_revision']
					//OALH, encodeToUtf8($fila['des_motivo_revision'])
					,encodeToUtf8($fila['observaciones'])
					,$fila['ifactura']
					,$fila['empleado']
					//,$fila['empleado'].' - '.utf8_encode($fila['nombrebecado'])
					,trim(encodeToUtf8($fila['archivo1']))
					,trim(encodeToUtf8($fila['archivo2']))
					,$fila['idescuela']
					,$fila['rfc']
					,encodeToUtf8($fila['nombreescuela'])
					,$fila['idNotaCredito'] 
					,$fila['folionota'] 
					,$fila['importeaplicado']
					,$fila['opc_blog_colaborador']
					,$blog_colaborador
					
				);
				$id++;
			}	
		} else if($iOpcion==2) { //Autorizar facturas gerente
			$TotalImportePagado=0;
			foreach($matriz as $fila) {
				
				if($fila['fecha_estatus']=='01/01/1900')
				{
					$fechaE=$fila['fechacaptura'];
				}
				else
				{
					$fechaE=$fila['fecha_estatus'];
				}
			if($fila['estatus']==0 && $fila['emp_estatus'] == 0){
					$modifico = '';
			}else{
				$modifico=encodeToUtf8($fila['nom_empleado_estatus']);
			}
				/*else
				{
					if($fila['emp_estatus']==0)
					{
						$modifico=encodeToUtf8($fila['nom_empleado_estatus']);
					}
					else
					{
						//$modifico=$fila['emp_estatus'].'  '.$fila['nom_empleado_estatus'];
						$modifico=encodeToUtf8($fila['nom_empleado_estatus']);
					}
				}
				*/
				$respuesta->rows[$id]['id']=$id;
				if($fila['estatus'] == 0 && $fila['observaciones'] != '' && $fila['imotivo_rechazo'] > 0){
					$NomEstatus = 'RECHAZADO POR GERENTE';
				} else {
					$NomEstatus = $fila['nom_estatus'];
				}
				if($fila['factura']=='0')//total
				{
					$respuesta->rows[$id]['cell']=
						array(
						''
						,''
						,''
						,''
						,'<B>TOTAL</B>'
						,'$'.number_format($fila['importerealfact'],2)
						,$fila['importerealfact']
						,''
						,''
						,$TotalImportePagado == 0 ? '' : '$'.number_format($TotalImportePagado,2)//$fila['importepagar'] == 0 ? '' : number_format($fila['importepagar'],2)
						,$TotalImportePagado == 0 ? '' : $TotalImportePagado
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						
						
					);
				}
				else
				{
					if($fila['estatus'] == 0 && $fila['observaciones'] != ''){
						$NomEstatus = 'RECHAZADO POR GERENTE';
					} else {
						$NomEstatus = $fila['nom_estatus'];
					}
					$TotalImportePagado+=$fila['estatus']!=6 ? 0 : $fila['importepagar'];
					$respuesta->rows[$id]['cell']=
						array(
						$fila['fechafactura']
						,$fila['factura']
						,$fila['idtipodocumento']
						,encodeToUtf8($fila['nombretipodocumento'])
						,encodeToUtf8($fila['rfc']).' - '.encodeToUtf8($fila['nombreescuela'])
						,'$'.number_format($fila['importerealfact'],2)
						,$fila['importerealfact']
						,$fila['estatus']==6 ? $fila['fecha_estatus'] : ' '//$fechaPago
						,$fila['estatus']==6 ? encodeToUtf8($fila['nom_rutapago']) : ' '
						,$fila['estatus']!=6 ?'' : '$'.number_format($fila['importepagar'],2)
						,$fila['estatus']!=6 ? '' : $fila['importepagar']
						// ,number_format($fila['importepagar'],2)
						// ,$fila['importepagar']
						,$fila['idtipoescuela']
						,substr($fila['fechafactura'],6,4)//$fila['ciclo']//$fila['idciclo']//$fila['idciclo']
						// ,$fila['idciclo']
						,$fila['ciclo']
						,encodeToUtf8($fila['observaciones'])
						,$fila['ifactura']
						,$fila['empleado']
						,$fila['empleado'].' - '.encodeToUtf8($fila['nom_empleado'])
						,$fila['rutapago']
						,$fila['estatus']
						// ,$fila['nom_estatus']
						, $NomEstatus
						,$fechaE
						,$modifico
						,$fila['archivo1']
						,$fila['archivo2']
					);
				}
				$id++;
			}	
		}try {
			echo json_encode($respuesta);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	} 
	catch (Exception $ex) {
		echo "Error: " . "Ocurrió un error al conectar a la base de datos."; //$ex->getMessage();
	}
 ?>