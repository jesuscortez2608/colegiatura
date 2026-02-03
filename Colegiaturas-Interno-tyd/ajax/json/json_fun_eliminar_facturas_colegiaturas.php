<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $idFactura = isset($_POST['idFactura']) ? $_POST['idFactura'] : 0;
	$iFacturaFiscal = isset($_POST['iFacturaFiscal']) ? $_POST['iFacturaFiscal'] : '';
	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	$CDBF = obtenConexion(DBFACTURAFISCALPOSTGRESQL);
	$estado = $CDBF['estado'];   
	$mensaje = $CDBF['mensaje']; 
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
		//throw new Exception("Error al conectarse y obtener informacion de BDPERSONALPOSTGRESQL. ". $mensaje);
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$cmd->setCommandText("SELECT * from fun_eliminar_facturas_colegiaturas( 2, $idFactura)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = 0;
		$rfc = $ds[0][0];
		$serie = $ds[0][1];
		$folioFactura = $ds[0][2];
		$mensaje= 'Factura Eliminada correctamente';
		
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
		// error_log(date("g:i:s a")." -> Error al en ejecucion.... \n",3,"log".date('d-m-Y')."_json_fun_eliminar_facturas_colegiaturastxt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_eliminar_facturas_colegiaturas.txt");
		salir($estado,$mensaje);
		//exit;
	}
	
	if($iFacturaFiscal!='')
	{
		
		BorrarFacturaFiscal($rfc,$serie,$folioFactura, $CDBF );
		// $json->estado = $estado;
		// $json->mensaje = $mensaje;		
		// echo json_encode($json);
		salir($estado,$mensaje);
	}
	else
	{
		// $json->estado = $estado;
		// $json->mensaje = $mensaje;		
		// echo json_encode($json);
		salir($estado,$mensaje);
	}
	
	function BorrarFacturaFiscal($rfc,$serie,$folioFactura, $CDBF )
    {	
		//echo 'RFC '.$rfc.' SERIE '.$serie.' FOLIO '.$folioFactura;
		//BORRAR REGISTROS DE faedatosproveedor Y faeconceptoproveedor BD FACTURAFISCAL
		
		try
		{
			$conF = new OdbcConnection($CDBF['conexion']);
			$conF->open();
			$cmd = $conF->createCommand();
			//echo ("{CALL borrarfacturaselectronicas('$rfc','$serie','$folioFactura')}");
			// $cmd->setCommandText("{CALL borrarfacturaselectronicas('$rfc','$serie','$folioFactura')}"); 
			$cmd->setCommandText("{CALL fun_borrarfacturaselectronicas_v33('$rfc', '$folioFactura')}");
			
			
			//error_log(date("g:i:s a")." -> select borrarfacturaselectronicas('$rfc_emisor','$serie','$foliofiscal')\n",3,"json_fun_eliminar_facturas_colegiaturas.txt");
			$ds = $cmd->executeDataSet();
			$conF->close();
		}
		catch(exception $ex)
		{
			$mensaje = "Ocurrió un error al conectar a la base de datos.";
			$estado=-1;
			// error_log(date("g:i:s a")." -> Error al en ejecucion.... \n",3,"log".date('d-m-Y')."_json_fun_eliminar_facturas_colegiaturas.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_eliminar_facturas_colegiaturas.txt");
			salir($estado,str_replace("\n", ' ', $mensaje));
		}
	}
	function salir($Estado,$Mensaje)
	{
		
		try {
			$json->estado = $Estado;
			$json->mensaje = $Mensaje;	
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	
	
?>