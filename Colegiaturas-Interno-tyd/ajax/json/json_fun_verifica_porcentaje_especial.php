<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas"); 
//	session_start();
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//-----------------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];

    $json = new stdClass();
    $respuesta = new stdClass();
	$iColaborador = isset($_POST['iColaborador']) ? $_POST['iColaborador'] : '';
    
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = "Error al conectar con base de datos";
    }else {
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
            $cmd = $con->createCommand();
            $cmd->setCommandText("{CALL fun_verifica_porcentaje_especial($iColaborador)}");
            $ds = $cmd->executeDataSet();
            $con->close();
            $json->estado = 0;
            $json->mensaje = "OK";
            $json->datos = array();$i = 0;
            if($ds!= '') {
                foreach ($ds as $fila) {
                    $respuesta->rows[$i]['cell']=array(
                        $fila['idu_escolaridad'],
                        trim(mb_convert_encoding($fila['nom_escolaridad'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
                        $fila['idu_parentesco'],
                        trim(mb_convert_encoding($fila['nom_parentesco'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
                        $fila['porcentaje'] . ' %',
                        trim(utf8_decode($fila['justificacion'])),
                        $fila['fec_registro'],
                        $fila['num_registro'],                        
                        trim(mb_convert_encoding($fila['nom_registro'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true)))
                    );
                    $i++;
                }
            }

        }
        
        catch(exception $ex)
        {
            $json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
            $json->estado=-2;
                    // error_log(date("g:i:s a")." -> Error al consumir fun_obtener_beneficiarios_por_factura \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_por_factura.txt");
                    // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_por_factura.txt");
        }
}
try{
echo json_encode($respuesta);
}catch(JsonException $ex){
    $mensaje="Ocurrió un error al codificar JSON."; //$ex->getMessage();
}
 ?>