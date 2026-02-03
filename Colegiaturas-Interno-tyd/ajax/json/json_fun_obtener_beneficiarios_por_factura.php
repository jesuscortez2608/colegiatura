<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
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
			$mensaje="Error al codificar JSON.";
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
                $cmd = $con->createCommand();
				
				// print_r("{CALL fun_obtener_beneficiarios_por_factura_postProduccion( $iEmpleado, $iFactura)}");
				// exit();
				
				

                $cmd->setCommandText("{CALL fun_obtener_beneficiarios_por_factura( $iEmpleado, $iFactura)}");
                $ds = $cmd->executeDataSet();
                $con->close();
				
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
				$json->escolaridades = array();
				$respuesta->escolaridades = array();
				$mesBeneficiario = 'Mes';
				$anioBeneficiario = 'Año';
                $i = 0;
				if($ds!= '')
				{
					$Total=0;
					$Escolaridades = '';
					foreach ($ds as $fila)
					{
						$anioBeneficiario = ($fila['edad_anio_beneficiario'] > 1) ? $fila['edad_anio_beneficiario'] . ' Años' : (($fila['edad_anio_beneficiario'] == 1) ? $fila['edad_anio_beneficiario'] . ' Año' : '');
						$mesBeneficiario = ($fila['edad_mes_beneficiario'] > 1) ? $fila['edad_mes_beneficiario'] . ' Meses' : (($fila['edad_mes_beneficiario'] == 1) ? $fila['edad_mes_beneficiario'] . ' Mes' : '');
						$Total+=$fila['imp_importe'];
						$respuesta->rows[$i]['cell']=array(
							$fila['idu_hoja_azul'],
							$fila['idu_beneficiario'],
							trim(encodeToUtf8($fila['nom_beneficiario'])),
							trim(encodeToUtf8($fila['fec_nac_beneficiario'])),
							$anioBeneficiario . ' ' . $mesBeneficiario,
							$fila['idu_parentesco'],
							trim(encodeToUtf8($fila['nom_parentesco'])),
							$fila['idu_tipo_pago'],
							trim(encodeToUtf8($fila['des_tipo_pago'])),
							trim(encodeToUtf8($fila['nom_periodo'])),
							$fila['idu_escolaridad'],
							trim(encodeToUtf8($fila['nom_escolaridad'])),
							$fila['idu_carrera'],
							trim(encodeToUtf8($fila['nom_carrera'])),
							'$'.number_format($fila['imp_importe'],2),
							$fila['imp_importe'],
							$fila['idu_grado'],
							trim(encodeToUtf8($fila['nom_grado'])),
							$fila['idu_ciclo'],
							$fila['nom_ciclo_escolar'],
							$fila['descuento'].' %',
							trim(encodeToUtf8($fila['comentario'])),
							$fila['keyx']	
						);
						if ($i > 0){
							$Escolaridades = $Escolaridades.', '.$fila['idu_escolaridad'];
						} else {
							$Escolaridades = $Escolaridades.$fila['idu_escolaridad'];
						}
						$i++;
					}
					$respuesta->rows[$i]['cell']=array(
						'','','','','','','','','','','','','',
						trim('<b>TOTAL</b>'),
						'<b>$'.number_format($Total,2).'</b>',
						'','','','','','','',''
					);
					$respuesta->escolaridades = $Escolaridades;
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
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($respuesta);
		}catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
		}
    
 ?>