<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	
    $CDB = obtenConexion(BDPERSONALSQLSERVER);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $respuesta = new stdClass();
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$iNumCiudad  = isset($_GET['iNumCiudad']) ? $_GET['iNumCiudad'] : 0;
	$iNumRegion  = isset($_GET['iNumRegion']) ? $_GET['iNumRegion'] : 0;
	
	$iRowsPerPage  = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage  = isset($_GET['page']) ? $_GET['page'] : 0;
	$iCentro = 		isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	
	$cNomCentro = strtoupper(isset($_GET['cNomCentro']) ? $_GET['cNomCentro'] : '');
 	$json = new stdClass();
	$respuesta = new stdClass();
	if($iCentro=='')
	{
		$iCentro=0;
	}
 	
    if($estado != 0)
    {
    	$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALSQLSERVER ver -> log".date('d-m-Y')."_json_proc_ayudacentros.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALSQLSERVER \n",3,"log".date('d-m-Y')."_json_proc_ayudacentros_grid.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_proc_ayudacentros_grid.txt");
    }
    //-------------------------------------------------------------------------
	else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();		
			// print_r("{CALL  proc_ayudacentros_grid $iUsuario, $iCentro,'$cNomCentro',$iNumCiudad,$iNumRegion,$iRowsPerPage,$iCurrentPage ,'idu_centro','asc','*'}");
	        $cmd->setCommandText("{CALL  proc_ayudacentros_grid $iUsuario, $iCentro,'$cNomCentro',$iNumCiudad,$iNumRegion,$iRowsPerPage,$iCurrentPage ,'idu_centro','asc','*'}");
			// echo "<pre>";
			// print_r("{CALL  proc_ayudacentros_grid $iUsuario, $iCentro,'$cNomCentro',$iNumCiudad,$iNumRegion,$iRowsPerPage,$iCurrentPage ,'idu_centro','asc','*'}");
			// echo "</pre>";
			// exit();
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			
			$respuesta->page = $ds[0]['page'];
			$respuesta->total = $ds[0]['pages'];
			$respuesta->records = $ds[0]['records'];
			
			foreach ($ds as $fila) 
	        {
			
				$respuesta->rows[$i]['id']=$i;
				$respuesta->rows[$i]['cell']=array(
					$fila['idu_centro'],
					trim($fila['nom_centro']));
				$i++;
	        }	
	    }
	    catch(exception $ex)
	    {
	        $json->mensaje = "Ocurrió un error al conectar a la base de datos.";
	        $json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir proc_ayudacentros_grid \n",3,"log".date('d-m-Y')."_json_proc_ayudacentros_grid.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_proc_ayudacentros_grid.txt");
	    }
	}
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>