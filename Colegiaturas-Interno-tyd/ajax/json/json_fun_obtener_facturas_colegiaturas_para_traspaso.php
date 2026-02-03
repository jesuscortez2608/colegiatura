<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	//VARIABLES DE FILTRADO
	$_GETI = filter_input_array(INPUT_GET, FILTER_SANITIZE_NUMBER_INT);
	$_GETS = filter_input_array(INPUT_GET,FILTER_SANITIZE_SPECIAL_CHARS);

	$iInicializar = isset($_GET['iInicializar']) ? $_GETI['iInicializar'] : 0;
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
	$inum_empleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
	$ifiltro = isset($_GET['ifiltro']) ? $_GETI['ifiltro'] : 0;
	$cbusqueda = isset($_GET['cbusqueda']) ? $_GETS['cbusqueda'] : '';
	$itipomov = isset($_GET['itipomov']) ? $_GETI['itipomov'] : '';
	$iquincena = isset($_GET['iquincena']) ? $_GETI['iquincena'] : 0;
	$itiponomina = isset($_GET['itiponomina']) ? $_GETI['itiponomina'] : '';

	// echo("QUINCENA NUMERO=".$iquincena.'  TIPO DE NOMINA POR='.$itiponomina);
	// exit();

	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'nombeneficiario';
	$sOrderType = 'asc';
	/*
	cbusqueda
	iOpcion	1
	ifiltro	0 ->Cbo_BUSCAR
	itipomov	0
	nd	1530902073368
	page	1
	rows	20
	session_name	Colegiaturas
	sidx	fechafactura
	sord	asc




	*/
	$sColumns='clv_tipo_registro
		,des_tipo_registro
		,ottp
		,empleado
		,nomempleado
		,beneficiario_hoja_azul
		,beneficiario
		,nombeneficiario
		,facturafiscal
		,fechafactura
		,idciclo
		,nomciclo
		,fechacaptura
		,idtipopago
		,tipopago
		,periodo
		,des_periodo
		,importe_fac
		,importe_pago
		,idestudio
		,estudio
		,idescuela
		,escuela
		,rfc
		,descuento
		,iddeduccion
		,deduccion
		,observaciones
		,idrutapago
		,rutapago
		,numtarjeta
		,idfactura
		,marcado
		,usuario
		,conexion';
	
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();

	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_facturas_colegiaturas_para_traspaso.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_facturas_colegiaturas_para_traspaso.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_facturas_colegiaturas_para_traspaso.txt");
    } else
	{
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();

			$query = ("SELECT * FROM fun_obtener_facturas_colegiaturas_para_traspaso($iCurrentPage,$iRowsPerPage,$inum_empleado,'$sOrderColumn','$sOrderType','$sColumns',$iInicializar,$inum_empleado,$ifiltro,'$cbusqueda',$itipomov, $iquincena, $itiponomina)");
			//$query = ("SELECT * FROM fun_obtener_facturas_colegiaturas_para_traspaso($iCurrentPage,$iRowsPerPage,$inum_empleado,'$sOrderColumn','$sOrderType','$sColumns',$iOpcion,$inum_empleado,$ifiltro,'$cbusqueda',$itipomov, $iquincena, $itiponomina, ''::xml)");
			//echo "<pre>";
			//print_r($query);
			//echo "</pre>";
			//  exit();

			$cmd->setCommandText(encodeToUtf8($query));
			
			$ds = $cmd->executeDataSet();

			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$respuesta = new stdClass();
			$respuesta->page = $ds[0]['page'];
			$respuesta->total = $ds[0]['pages'];
			$respuesta->records = $ds[0]['records'];

			foreach ($ds as $fila)
			{
				$otpp='';
				if($fila['iottp']==1)
				{
					$otpp='<font color="#00A400" size="4"><b>&#8730;</b></font>';
				}

				$marcado='';
				// if($fila['imarcado']==1)
				// {
					// $marcado='<font color="#00A400" size="4"><b>&#8730;</b></font>';
				// }
				if($fila['dfechacaptura'] == ''){
					$FechaCaptura = '';
				}else{
					$FechaCaptura = date("d/m/Y", strtotime($fila['dfechacaptura']));
				}
				if($fila['dfechafactura'] == ''){
					$FechaFactura = '';
				}else{
					$FechaFactura = date("d/m/Y", strtotime($fila['dfechafactura']));
				}

				$respuesta->rows[$i]['cell'] = array(
					$fila['imarcado'],
					$fila['id'],
					$fila['iclv_tipo_registro'],
					encodeToUtf8($fila['sdes_tipo_registro']),
					$otpp,
					$fila['iempleado'],
					encodeToUtf8($fila['snomempleado']),
					$fila['ibeneficiario_hoja_azul'],
					$fila['ibeneficiario'],
					encodeToUtf8($fila['snombeneficiario']),
					encodeToUtf8($fila['sfacturafiscal']),
					// $fila['dfechafactura'],
					$FechaFactura,
					$fila['iidciclo'],
					encodeToUtf8($fila['snomciclo']),
					// $fila['dfechacaptura'],
					$FechaCaptura,
					$fila['iidtipopago'],
					encodeToUtf8($fila['stipopago']),
					encodeToUtf8($fila['speriodo']),
					encodeToUtf8($fila['speriodo']),
					//$fila['sdes_periodo'],
					'$'.number_format($fila['nimporte_fac'],2),
					'$'.number_format($fila['nimporte_pago'],2),
					$fila['iidestudio'],
					encodeToUtf8($fila['sestudio']),
					$fila['iidescuela'],
					encodeToUtf8($fila['sescuela']),
					$fila['srfc'],
					$fila['idescuento'].'%',
					$fila['iiddeduccion'],
					encodeToUtf8($fila['sdeduccion']),
					encodeToUtf8($fila['sobservaciones']),
					$fila['iidrutapago'],
					encodeToUtf8($fila['srutapago']),
					$fila['snumtarjeta'],
					$fila['iidfactura'],
					//$marcado,
					$fila['imarcado'],
					$fila['iusuario']
				);
				$i++;
			}
			$mensaje="Ok";
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_facturas_colegiaturas_para_traspaso \n",3,"log".date('d-m-Y')."json_fun_obtener_facturas_colegiaturas_para_traspaso.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_facturas_colegiaturas_para_traspaso.txt");
		}
    }
	
	try{
		echo json_encode($respuesta);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar el Json";
	}
 ?>