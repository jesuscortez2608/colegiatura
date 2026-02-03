<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	// session_name("Session-Colegiaturas"); 
	// session_start();
	// $Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'fecha';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,
	facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, 
	idTipoDeduccion, TipoDeduccion, motivoRechazo,idfactura, empleado, nombreempleado, fecha, id_tipodocumento, nom_tipodocumento';
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 0;
	$nEmpleado = isset($_GET['nEmpleado']) ? $_GET['nEmpleado'] : 0;
	$nEstatus = isset($_GET['nEstatus']) ? $_GET['nEstatus'] : 0;
	$nCicloEscolar = isset($_GET['nCicloEscolar']) ? $_GET['nCicloEscolar'] : 0;
	$nTipoDeduccion = isset($_GET['nTipoDeduccion']) ? $_GET['nTipoDeduccion'] : 0;
	$fechaini = isset($_GET['fechaini']) ? $_GET['fechaini'] : '19000101';
	$fechafin = isset($_GET['fechafin']) ? $_GET['fechafin'] : '19000101';
	$nRegion = isset($_GET['nRegion']) ? $_GET['nRegion'] : 0;	
	$nCiudad = isset($_GET['nCiudad']) ? $_GET['nCiudad'] : 0;
	$nCentro = isset($_GET['nCentro']) ? $_GET['nCentro'] : 0;

	if ($inicializar == 1) {
		
		try {
			$response = new stdClass();
			echo json_encode($response);
			exit();
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }
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
		
		$query = "SELECT records
						, page
						, pages
						, id
						, idestatus
						, estatus
						, fechaestatus
						, empestatus
						, empestatusnombre
						, fechabaja
						, facturafiscal
						, fechafactura
						, fechacaptura
						, idcicloescolar
						, cicloescolar
						, importefactura
						, importepagado
						, importetope
						, rfc
						, nombreescuela
						, idtipodeduccion
						, tipodeduccion
						, motivorechazo
						, idfactura
						, empleado
						, nombreempleado
						, fecha
						, id_tipodocumento
						, nom_tipodocumento
				 FROM fun_obtener_movimientos_colegiaturas($nEmpleado
														, $nEstatus
														, $nCicloEscolar
														, $nTipoDeduccion
														, '$fechaini'
														, '$fechafin'
														, '$nRegion'
														, '$nCiudad'
														, $nCentro
														, $rowsperpage
														, $page
														, '$orderby'
														, '$ordertype'
														, '$columns')";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		$con->close();
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		$id=0;
		
		foreach($matriz as $fila) {
		// $fila['imp_a_pagar']==0 ? '' : number_format($fila['imp_a_pagar'],2)
			if($fila['idestatus']!=0)
			{
				if($fila['empestatus']!=0)
				{
					$empleadoEstatus=encodeToUtf8(trim($fila['empestatusnombre']));
				}
				else
				{
					$empleadoEstatus='AUTORIZADA POR SISTEMA';
				}
			}
			else
			{
				$empleadoEstatus='';
			}
			$pagado='';
			if($fila['idestatus']==6)
			{
				$pagado='$'.number_format($fila['importepagado'],2);
			}
			if($fila['idestatus'] == 3 && $fila['empestatus'] == 0){
				$empleadoEstatus = 'RECHAZADA POR SISTEMA';
			}
			$respuesta->rows[$id]['cell']=
				array($fila['idestatus']
				,$fila['estatus']
				,$fila['fechaestatus']
				,$empleadoEstatus
				,$fila['empleado']
				,$fila['empleado'].' '.trim($fila['nombreempleado'])
				,$fila['fechabaja']
				,$fila['facturafiscal']
				,$fila['id_tipodocumento']
				,$fila['nom_tipodocumento']				
				,$fila['fechafactura']
				,$fila['fechacaptura']
				,$fila['idcicloescolar']
				,encodeToUtf8($fila['cicloescolar'])
				,'$'.number_format($fila['importefactura'],2)
				,$pagado
				,'$'.number_format($fila['importetope'],2)
				,$fila['rfc']
				,$fila['nombreescuela']
				,$fila['idtipodeduccion']
				,$fila['tipodeduccion']
				,$fila['motivorechazo']
				,$fila['idfactura']
			);
			$id++;
		}
		
		try {
			echo json_encode($respuesta);
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	} 
	catch (Exception $ex) {
		echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
	}
 ?>