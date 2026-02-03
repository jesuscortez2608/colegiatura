<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	//Variables de filtrado 
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GET['iCiudad'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$dFechaInicial = isset($_GET['dFechaInicial']) ? $_GET['dFechaInicial'] : 0;
	$dFechaFinal = isset($_GET['dFechaFinal']) ? $_GET['dFechaFinal'] : 0;
	$iTipoNomina = isset($_GET['iTipoNomina']) ? $_GET['iTipoNomina'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$Consulta = isset($_GET['Consulta']) ? $_GET['Consulta'] : 0;
	
	// echo "<pre>";
	// print_r($iEmpresa);
	// echo "</pre>";
	// exit();
	//Variables para paginación.
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = 'idempleado';
	$ordertype = 'asc';
	$columns = 'IdEmpleado, NombreEmpleado, IdPuesto, Puesto, IdCentro, Centro, IdRegion, Region, IdCiudad, Ciudad
				, IdEmpleadoDeJefeInmediato, JefeInmediato, IdStatus, NumeroDeFacturasEnProceso, IdTipoDocumento
				, TipoDocumento, FecPrimerFactura, TotalGralFacturas,empresa, notificacion, opc_blog_aclaracion, opc_blog_revision,tipo ';
	// $columns = 'IdEmpleado, NombreEmpleado, IdPuesto, Puesto, IdCentro, Centro, IdRegion, Region, IdCiudad, Ciudad
	// 			, IdEmpleadoDeJefeInmediato, JefeInmediato, IdStatus, NumeroDeFacturasEnProceso, IdTipoDocumento
	// 			, TipoDocumento, FecPrimerFactura, TotalGralFacturas, opc_blog_aclaracion, opc_blog_revision,tipo ';
	// if ($Consulta == 0) {
		// $page = 1;
	// }
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_catalogociudades.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_catalogociudades.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_catalogociudades.txt");
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$query = "SELECT
					records, page, pages, id,
					idempleado, nombreempleado, idpuesto,
					puesto, idcentro, centro, idregion, region, idciudad,
					ciudad, idempleadodejefeinmediato,
					jefeinmediato, idstatus, numerodefacturasenproceso,
					idtipodocumento, nomtipodocumento, fecprimerfecha,totalgralfacturas, 
					empresa, notificacion, 
					opc_blog_aclaracion, opc_blog_revision
				FROM fun_obtener_empleados_con_facturas(
					$iEmpleado,
					$iRegion,
					$iCiudad,
					$iEstatus,
					'$dFechaInicial',
					'$dFechaFinal',
					$iTipoNomina,
					$iEmpresa,
					$rowsperpage,
					$page,
					'$orderby',
					'$ordertype',
					'$columns'
			)";

			// var_dump($query);
			
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
			
			$cmd->setCommandText($query);
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
			$TotalFacturas = 0;
			$BlogAclaracion = '';
			$BlogRevision = '';
			foreach ($ds as $fila)
			{
				if ( $fila['opc_blog_aclaracion'] == 1 ) {
					$BlogAclaracion = '<strong><i class="icon-envelope"></i></strong>';
					// $BlogAclaracion = $fila['opc_blog_aclaracion'];
				} else {
					$BlogAclaracion = '';
				}
				if ( $fila['opc_blog_revision'] == 1 ) {
					$BlogRevision = '<strong><i class="icon-envelope"></i></strong>';
					// $BlogRevision = $fila['opc_blog_revision'];
				} else {
					$BlogRevision = '';
				}
				$TotalFacturas = $fila['totalgralfacturas'];
				if ($fila['numerodefacturasenproceso'] == ''){
					$NumeroDeFacturasEnProceso = "<b>".$TotalFacturas."</b>";
					$NomTipoDocumento = "<b>FACTURAS EN TOTAL</b>";
					$BlogAclaracion = '';
					$BlogRevision = '';
				} else {
					$NumeroDeFacturasEnProceso = $fila['numerodefacturasenproceso'];
					$NomTipoDocumento = trim($fila['nomtipodocumento']);
				}
				// $respuesta->rows[$i]['id'] = $i;
				$respuesta->rows[$i]['cell'] = array(
					// $fila['numerodefacturasenproceso'],
					$NumeroDeFacturasEnProceso,
					$fila['idtipodocumento'],			
					$NomTipoDocumento,
					$fila['opc_blog_aclaracion'],
					$BlogAclaracion,
					$fila['opc_blog_revision'],
					$BlogRevision,
					$fila['idempleado'],
					$fila['idempleado'].' '.trim($fila['nombreempleado']),
					$fila['idpuesto'],
					$fila['idpuesto'].' '.trim($fila['puesto']),
					$fila['idcentro'],
					$fila['idcentro'].' '.trim($fila['centro']),
					$fila['idregion'],
					trim($fila['region']),
					$fila['idciudad'],
					trim($fila['ciudad']),
					$fila['idempleadodejefeinmediato'],
					$fila['idempleadodejefeinmediato'].' '.trim($fila['jefeinmediato']),
					trim($fila['empresa']),
					$fila['notificacion'],
					$fila['idstatus']
				);
				$i++;
			}
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrión un error al intentar conectar con la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_catalogociudades \n",3,"log".date('d-m-Y')."json_fun_catalogociudades.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_catalogociudades.txt");
		}
    }
	
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

	
?>