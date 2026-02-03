<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$page = isset($_GET['page']) ? $_GET['page'] : 0;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : '';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : '';
	
	
	$iEstado = isset($_GET['iEstado']) ? $_GET['iEstado'] : 0;
	$iMunicipio = isset($_GET['iMunicipio']) ? $_GET['iMunicipio'] : 0;
	$iLocalidad = isset($_GET['iLocalidad']) ? $_GET['iLocalidad'] : 0;
	$iBusqueda = isset($_GET['iBusqueda']) ? $_GET['iBusqueda'] : 1;
	$sBuscar = isset($_GET['sBuscar']) ? $_GET['sBuscar'] : '';
	
	$iTipoEscuela = isset($_GET['iTipoEscuela']) ? $_GET['iTipoEscuela'] : 0;
	$iConfiguracion = isset($_GET['iConfiguracion']) ? $_GET['iConfiguracion'] : 0;
	
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
	$iAyuda = isset($_GET['iAyuda']) ? $_GET['iAyuda'] : 0;
		
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
		// echo("SELECT * FROM fun_obtener_escuelas_colegiaturas( $iEstado, $iMunicipio, $iLocalidad, $iBusqueda, '$sBuscar',$iTipoEscuela, $iConfiguracion, $rowsperpage::integer, $page::integer, '$orderby', '$ordertype', '*', $iAyuda)");
		// exit();
		$query = "SELECT *
			FROM fun_obtener_escuelas_colegiaturas(
				 $iEstado, $iMunicipio, $iLocalidad, $iBusqueda, '$sBuscar',$iTipoEscuela, $iConfiguracion
				, $rowsperpage::integer
				, $page::integer			
				, '$orderby'
				, '$ordertype'
				, '*', $iAyuda)";
		 // print_r($query);
		 // exit();
		
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		
		$id=0;
		//echo ($iOpcion);
		//exit();
		if ($iOpcion == 1) {
			foreach($matriz as $fila) 
			{
				$FechaReg = date("d/m/Y", strtotime($fila['fec_captura']));
				$respuesta->rows[$id]['id']=$id;
				$respuesta->rows[$id]['cell']=array($fila['idu_escuela']
					, $fila['rfc_clave_sep']
					, $fila['nom_escuela']
					, $fila['opc_tipo_escuela']
					, $fila['nom_tipo_escuela']
					, $fila['clave_sep']=='' ? $fila['rfc_clave_sep'] : $fila['clave_sep']
					, $fila['idu_escolaridad']
					, $fila['nom_escolaridad']
					//,utf8_encode($fila['nom_carrera'])
					, $fila['opc_obligatorio_pdf']
					, $fila['opc_obligatorio_pdf']==0 ? 'NO': 'SI' //$fila['obligatorio_pdf']
					// ,$fila['opc_nota_credito']
					// ,$fila['opc_nota_credito']==0 ? 'NO': 'SI' //$fila['obligatorio_pdf']
					, $fila['opc_escuela_bloqueada']
					, $fila['opc_escuela_bloqueada']==0 ? 'NO': 'SI'
					// ,$fila['fec_captura']
					, $FechaReg
					, $fila['idu_empleado_registro'].' '.$fila['nom_empleado_registro']
					, $fila['opc_educacion_especial']
					, $fila['opc_educacion_especial']==0 ? 'NO' :'SI'
					, $fila['idu_tipo_deduccion']
					, $fila['nom_tipo_deduccion']
					, $fila['observaciones']
				);
				
				$id++;
			}
		} else if ($iOpcion == 2) {
			foreach($matriz as $fila) 
			{
				$FechaReg = date("d/m/Y", strtotime($fila['fec_captura']));
				$respuesta->rows[$id]['id']=$id;
				$respuesta->rows[$id]['cell']=array($fila['idu_escuela']
					,$fila['rfc_clave_sep']
					,$fila['nom_escuela']
					,$fila['nom_tipo_escuela']
					,$fila['nom_tipo_deduccion']
					,$fila['nom_escolaridad']
					,$fila['nom_carrera']
					,$fila['opc_educacion_especial']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong></font>' :''
					,$fila['opc_obligatorio_pdf']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong></font>': ''
					,$fila['opc_nota_credito']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong></font>': ''
					,$fila['opc_escuela_bloqueada']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong></font>': ''
					// ,$fila['fec_captura']
					, $FechaReg
					,$fila['idu_empleado_registro'].' '.$fila['nom_empleado_registro']
					,$fila['opc_tipo_escuela']
					,$fila['idu_escolaridad']
					,$fila['opc_educacion_especial']
					,$fila['opc_obligatorio_pdf']
					,$fila['opc_nota_credito']
					,$fila['opc_escuela_bloqueada']
					,$fila['observaciones']
					,$fila['idu_tipo_deduccion']
					,$fila['idu_carrera']
					,$fila['clave_sep']
					,$fila['idu_estado']
					,$fila['nom_estado']
					,$fila['idu_municipio']
					,$fila['nom_municipio']
					,$fila['idu_localidad']
					,$fila['nom_localidad']
				);
				$id++;
			}
		}
		try {
			echo json_encode($respuesta);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	} 
	catch (Exception $ex) {
		echo "Error: Ocurrió un error al intentar conectar con la base de datos json_fun_obtener_escuelas_colegiaturas";
	}
 ?>