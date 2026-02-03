<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iFactura = isset($_GET['iFactura']) ? $_GET['iFactura'] : 0;
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 1;
	
	if ($inicializar == 1) {
		try{
		$response = new stdClass();
		echo json_encode($response);
		exit();
		}
		catch(JsonException $ex){
			$mensaje="";
			$mensaje = $ex->getMessage();
		}
	}
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
	$json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_beneficiarios_por_factura.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiarios_por_factura.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiarios_por_factura.txt");
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
				// print_r( " select * from fun_obtener_beneficiarios_por_factura_modificar_pagos($iEmpleado, $iFactura)");
				// exit();
                $cmd = $con->createCommand();
                $cmd->setCommandText("{CALL fun_obtener_beneficiarios_por_factura_modificar_pagos($iEmpleado, $iFactura)}");				
                $ds = $cmd->executeDataSet();
                $con->close();
				
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
				
                $i = 0;
				if($ds!= '') {
					foreach ($ds as $fila) {
						$respuesta->rows[$i]['cell']=array(
							$fila['idu_hoja_azul'],
							$fila['idu_beneficiario'],
							//trim(utf8_encode($fila['nom_beneficiario'])),
							trim(mb_convert_encoding($fila['nom_beneficiario'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							$fila['idu_parentesco'],
							//trim(utf8_encode($fila['nom_parentesco'])),
							trim(mb_convert_encoding($fila['nom_parentesco'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							$fila['idu_tipo_pago'],
							//trim(utf8_encode($fila['des_tipo_pago'])),
							trim(mb_convert_encoding($fila['des_tipo_pago'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							//trim(utf8_encode($fila['nom_periodo'])),
							trim(mb_convert_encoding($fila['nom_periodo'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							$fila['idu_escolaridad'],
							//trim(utf8_encode($fila['nom_escolaridad'])),
							trim(mb_convert_encoding($fila['nom_escolaridad'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							//number_format($fila['imp_importe'],2),
							$fila['imp_importe'],
							$fila['imp_importefactura'],
							$fila['imp_importe_pagado'],
							$fila['idu_grado'],
							//trim(utf8_encode($fila['nom_grado'])),
							trim(mb_convert_encoding($fila['nom_grado'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							$fila['idu_ciclo'],
							$fila['nom_ciclo_escolar'],
							$fila['descuento'], //.'%',
							//trim(utf8_encode($fila['comentario'])),
							trim(mb_convert_encoding($fila['comentario'], mb_detect_encoding($string, "UTF-8, ISO-8859-1, ISO-8859-15", true))),
							$fila['keyx'],
							$fila['idfactura']
						);
						$i++;
					}
                }

            }
			
            catch(exception $ex)
            {
                $json->mensaje = $ex->getMessage();
                $json->estado=-2;
                        // error_log(date("g:i:s a")." -> Error al consumir fun_obtener_beneficiarios_por_factura \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_por_factura.txt");
                        // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_por_factura.txt");
            }
    }
	try{
    echo json_encode($respuesta);
	}catch(JsonException $ex){
		$mensaje="";
		$mensaje = $ex->getMessage();
	}
 ?>