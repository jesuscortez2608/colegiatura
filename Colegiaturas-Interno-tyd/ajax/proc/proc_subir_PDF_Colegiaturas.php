<?php
	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	require_once "proc_interaccionalfresco.php";
    //-------------------------------------------------------------------------
	$estado = 0;
	$mensaje = 'OK';
	$data = array();
	$res = 0;

	$Session = isset($_POST['session_name1']) ?  $_POST['session_name1'] : "Session-Colegiaturas";
	$iFactura = isset($_POST['txt_ifactura']) ? $_POST['txt_ifactura'] : 0;
	$iEditar = isset($_POST['txt_EditarFactura']) ? $_POST['txt_EditarFactura'] : 0;
	$cComentario = isset($_POST['hidden_MotivoAclaracion']) ? $_POST['hidden_MotivoAclaracion'] : 0;
	//VARIABLES DE LA SESSION
	
	// $iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	// $iEmpresa = isset($_SESSION[$Session]["USUARIO"]['num_empresa'])?$_SESSION[$Session]['USUARIO']['num_empresa']:'';
	// $iCentro = isset($_SESSION[$Session]["USUARIO"]['num_centro'])?$_SESSION[$Session]['USUARIO']['num_centro']:'';
	
	// $iCentro = str_replace ("-", "", $iCentro);
	$iTipoComprobante=isset($_POST['txt_tipo_comprobante']) ? $_POST['txt_tipo_comprobante'] : 4;
	$iExterno=isset($_POST['txt_externo']) ? $_POST['txt_externo'] : 0;
	$iBeneficiarioExt=isset($_POST['txt_beneficiario_ext']) ? $_POST['txt_beneficiario_ext'] : 0;
	$iduEmpleado = isset($_POST['txt_idu_empleado']) ? $_POST['txt_idu_empleado'] :0 ;
	$iCentro = isset($_POST['txt_idu_Centro']) ? $_POST['txt_idu_Centro'] : 0;
	$iEmpresa = isset($_POST['txt_Empresa']) ? $_POST['txt_Empresa'] : 0;
	
	$sFechaFac = isset($_POST['txt_FechaFactura']) ? $_POST['txt_FechaFactura'] : 0;
	$sRfc = isset($_POST['txt_Rfc_fac']) ? $_POST['txt_Rfc_fac'] : 0;
	
	$tipoXml= isset($_POST['txt_tipoXml']) ? $_POST['txt_tipoXml'] : 1;	
	
	if($iExterno == 1){
		$iTipoComprobante = 4;
	}
// fun_grabar_factura_colegiatura(
// $iduEmpleado
// , $iBeneficiarioExt
// , $iFactura
// , $iEditar
// , '$cComentario'
// , '$nom_archivo1'
// , '$nom_archivo2'
// , $iEmpresa
// , $iCentro
// , $iTipoComprobante)
	$cComentario=mb_convert_encoding($cComentario, 'UTF-8', 'ISO-8859-1');
	$serie='';
	$foliofiscal='';
	$rfc_emisor='';
	$iNuevoFactura=0;
	$nom_archivo1='';
	$nom_archivo2='';
	
	$estado = 0;
	$mensaje = "OK";
	//Obtener la ruta para el WS para subir la factura
	try{
		$CDB=obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado=$CDB['estado'];
		$mensaje=$CDB['mensaje'];
		$sNomParametro='URL_SERVICIO_FACTURACION';	//---------> Con ese valor,  Obtiene la ruta de pruebas para desarrollo(ASI SE TIENE AL MOMENTO)
													//Para tester toma la ruta de produccion previamente cargada en la tabla ctl_parametros_colegiaturas(SE INCLUYE EN EL SCRIPT DE LA TABLA COMO UN REGISTRO DE INSERCION)

		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		//echo ("SELECT * from fun_obtener_parametros_colegiaturas('$sNomParametro')");
		//exit();
		$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = 0;

		$valorParametro=$ds[0][2];
		$mensaje2 = "Error al consultar parametros de colegitaruas";
		
	}catch(Exception $ex){
		salir($estado, $mensaje2, array(), 0, 0);
	}
	
	// --------------------------------------------------------
	// Validar que se haya importado sin errores
	$error = $_FILES['filePdf']['error'];
	if ($error != 0) {
		if ($error == 1){
			$maxperm = ini_get('upload_max_filesize');
			$mensaje="El archivo excede el máximo permitido: $maxperm";
			$estado=-1;
		} else {
			$mensaje='Ocurrió un error al subir el archivo';
			$estado=-2;
		}
		return;
	}
	
	// --------------------------------------------------------
	// Validar que el archivo no exceda 1MB
	if (  (($_FILES['filePdf']['size']/1024)/1024) > 2   ) {
        $mensaje="El archivo debe medir menos de 1MB";
		$estado=-1;
    }
	
	if ($estado < 0) {
		salir($estado, $mensaje, array(), 0, 0);
	}
	
	// --------------------------------------------------------
	// Validar el formato
	$nombrearchivo = $_FILES['filePdf']['name'];
	$formato = $_FILES['filePdf']['type'];
	
	$extension = strtolower(trim(extension($nombrearchivo)));
	

	
	if (($formato != 'image/jpeg'
		&& $formato != 'image/pjpeg'
		&& $formato != 'image/gif'
		&& $formato != 'image/png'
		&& $formato != 'image/x-png'
		&& $formato != 'application/pdf') || ($extension != 'jpg' && $extension != 'gif' && $extension != 'png' && $extension != 'pdf' ) ) {
		$mensaje=mb_convert_encoding('Solo se permiten archivos con formato jpg, gif, png o pdf', 'UTF-8', 'ISO-8859-1');
		$estado=-3;
	}
	
	if ($estado < 0) {
		salir($estado, $mensaje, array(), 0, 0);
	}
	
	// ------------------SUBIR A ALFRESCO----------------------------------------------------------
	if(isset($_FILES["filePdf"]) )//Si existe PDF o XML
	{
		try {

			$anio=date('Y');
			$objAlfresco = new InteraccionAlfresco();
			$objAlfresco->setCiclo($anio);
			foreach ($_FILES as $file) {
				$extension = $objAlfresco->getExtensionArchivo($file['name']);
				$secuencia_documento =$objAlfresco->obtenerSecuenciaDocumento();
				$nom_archivo = "$sFechaFac-$sRfc-$secuencia_documento.$extension";
				$b64 = $objAlfresco->getBase64($file['tmp_name']);			
				$objAlfresco->guardarDocumento($iduEmpleado, $nom_archivo, $b64);
				
				$nom_archivo2 = $nom_archivo;
			}
			
			$estado = 1;
			$mensaje = 'Se subió documento al Servicio Alfresco';

		} catch (Exception $ex) {
			$mensaje="Ocurrio un error al subir el archivo en Alfresco, intentelo mas tarde: error al leer PDF";
			$estado=-1001;
		}
	} else {
		$mensaje = "No existe archivo PDF";
		$estado = -1002; 
	}
	if ($estado < 0) {
		salir($estado, $mensaje, array(), 0, 0);
	}
	try{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$mensaje = $CDB['mensaje'];
		$data = array();
		if($estado != 0){
			throw new Exception("Error al conectarse y obtener informacion de BDPERSONALPOSTGRESQ.".$mensaje);
		}
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo "<pre>";
		// print_r("{CALL fun_grabar_factura_colegiatura($iduEmpleado, $iBeneficiarioExt, $iFactura, $iEditar, '$cComentario', '$nom_archivo1', '$nom_archivo2', $iEmpresa, $iCentro, $iTipoComprobante)}");
		// echo "</pre>";
		// exit();
		$cmd->setCommandText("{CALL fun_grabar_factura_colegiatura($iduEmpleado, $iBeneficiarioExt, $iFactura, $iEditar, '$cComentario', '$nom_archivo1', '$nom_archivo2', $iEmpresa, $iCentro, $iTipoComprobante)}");
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = $ds[0][0];
		
		
		$estado = ($estado == NULL) ? -1017 : $estado;
		$mensaje = $ds[0][1];
		$mensaje2 = "error al consultar fun_grabar_factura_colegiatura";
		
		if ($estado < 0){
			throw new Exception("Ocurrió un error al guardar la factura del colaborador en Personal: $mensaje");
			// salir($estado, $mensaje, array(), 0, 0);
			salir($estado, $mensaje, array(), 0, 0);
		}
	salir($estado, $mensaje, ' ', array(), 0, 0);
	}catch(Exception $ex){
		salir($estado, $mensaje2, array(), 0, 0);
	}
	

	function salir($estado, $mensaje, $nom_archivo, $data, $iFactura, $iNuevoFactura){
		$json = new stdClass();
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		$json->data = $data;
		$json->nom_archivo = $nom_archivo;
		
		switch($estado) {
			case -1001:
				break; // No pudo guardar en Alfresco
			case -1002:
				break; // No se incluyó XML o PDF
			case -1003:
				break; // El archivo proporcionado no es un XML
			case -1004:
				break; // El archivo XML tiene un formato invalido
			case -1005:
				break; // No existe elemento Comprobante en archivo XML
			case -1006:
				break; // Versión de XML no válido, menor a la v. 3.3;
			case -1007:
				break; // No tiene el elemento Folio
			case -1008:
				break; // No tiene el atributo Fecha
			case -1009:
				break; // No tiene el atributo Fecha
			case -1010:
				break; // No tiene el atributo Version
			case -1011:
				break; // No tiene atributo RFC del emisor
			case -1012:
				break; // No tiene atributo Total
			case -1013:
				break; // No tiene atributo Total
			case -1014:
				break; // Error en la ejecución del método GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1015:
				break; // Despliega el error que se generó al invocar alguno de los métodos GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1016:
				break; // Despliega el error que se generó al invocar alguno de los métodos GuardarCFDI_colegiaturas_64 | GuardarCFDI_empleados_64
			case -1017:
				break; // Ocurrió un error al guardar la factura del colaborador en Personal
			default:
				break;
		}
		
		if ($estado < 0) {
			
		}
		try{
		echo json_encode($json); 
		die();
		}
		catch(JsonException $ex){
			echo("Error al cargar Json");
		}
	}
	
	function extension($filename) {
		return substr(strrchr($filename, '.'), 1);
	}