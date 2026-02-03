<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO
	$valor = isset($_POST['valor']) ? $_POST['valor'] : 0;
	$FechaActual = isset($_POST['FechaActual']) ? $_POST['FechaActual'] : '';
	$iConexion = isset($_POST['conexion']) ? $_POST['conexion'] : 0;
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
			
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
		
    } else 
	{		
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			// OBTENER LISTADO
			$query = "SELECT inumemp, ntotal FROM fun_complementar_incentivos($valor) ";
			 // echo($query);
			 // exit();			
			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();			
			$con->close();
			
			if ($ds[0]!=null) {
			
				$respuesta = new stdClass();
				$arrXml = array();

				$i=0;
				$xml = $xml.'<Root>' ;
				foreach ($ds as $row)
				{				
					//$arrXml[]=array("numemp" =>$fila['numemp'],"total"=>(trim(utf8_encode($fila['total']))));
					$numemp = $row['inumemp'];
					$total = $row['ntotal']*100;				
					
					//$xml .= "<row><e>$numemp</e><i>$total</i></row>" ;
					//$xml .= "<r e=$numemp i=$total></r>" ;
					$xml = $xml.'<r e="'.$numemp.'" i="'.$total.'"></r>';
					
					$i++;
					
					if ($i == 50) {
						$xml = $xml.'</Root>' ;
						$arrXml[] = $xml;
						$xml = "";
						$xml = $xml.'<Root>' ;
						$i = 0;
					}					
				}
				
				if ($i > 0) {
					$xml = $xml.'</Root>' ;
					$arrXml[] = $xml;
				}
				 // echo ($xml);
				 // exit();
				// Actualizar el nivel de estudios en la BD de Personal SQLSERVER
				$CDB = obtenConexion(BDPERSONALSQLSERVER);
				$estado = $CDB['estado'];
				$mensaje = $CDB['mensaje'];
				
				if($estado != 0) {
					$json->estado = $estado;
					$json->mensaje = "Ha ocurrido un error al conectarse con la bd personal, favor de intentar de nuevo";
					$json->mensaje_tecnico = date("g:i:s a")." -> Error al conectar [BDPERSONALSQLSERVER] ver -> log".date('d-m-Y')."_$script_name.txt";				
				} else {
					try {
						$con = new OdbcConnection($CDB['conexion']);
						$con->open();
						$cmd = $con->createCommand();
						$cmd->setCommandText("{CALL proc_validar_traspaso_incentivos}");
						$ds = $cmd->executeDataSet();
						$con->close();
						$Resultado = $ds[0][0];
						if($Resultado == 1){
							$json->estado = -2;
							$json->mensaje = "No es posible enviar los incentivos nuevamente, debido a que ya se realizó el traspaso de incentivos por parte de Sueldos y Compensaciones";
							$json->mensaje_tecnico = "";
						} else {
							try {
								$con = new OdbcConnection($CDB['conexion']);
								$con->open();
								$cmd = $con->createCommand();
								$cmd->setCommandText("{CALL snObtenFechaCorteQuincena}");
								$ds = $cmd->executeDataSet();
								$con->close();
								$fechaCorte = $ds[0][2];
								$fechaCorte = date("d/m/Y", strtotime($fechaCorte));
								$separator = explode("/", $fechaCorte);
								$dia = $separator[0] + 1;
								$mes = $separator[1];
								$anio = $separator[2];
								
								$fechaCorte2 = $dia.'/'.$mes.'/'.$anio;
								if($FechaActual > $fechaCorte2) {
									$json->estado = -2;
									$json->mensaje = "La ultima fecha para envio de incentivos fue: ".$fechaCorte2." ";
									$json->mensaje_tecnico = "";
								} else {
									try {
										$con = new OdbcConnection($CDB['conexion']);
										$con->open();
										$cmd = $con->createCommand();
										
										for ($i = 0; $i < count($arrXml); $i++) {
											$xml = $arrXml[$i];
											//echo ("{CALL proc_enviar_incentivos_colegiaturas $iUsuario, '$xml', $iConexion, $i}");
											//exit();
											$query = "{CALL proc_enviar_incentivos_colegiaturas $iUsuario, '$xml', $iConexion, $i}";
											$cmd->setCommandText($query);
											$ds = $cmd->executeDataSet();
											flush();
										}
										
										$con->close();
										
										$json->estado=0;
										$json->mensaje = "Incentivos enviados correctamente";
										$json->mensaje_tecnico = "";
									} catch (Exception $ex) {
										$json->estado=-2;
										$json->mensaje = "Ha ocurrido un error, favor de intentar de nuevo ";
										$json->mensaje_tecnico = "Ha ocurrido un error al conectarse con la bd personal, favor de intentar de nuevo";					
									}							
								}
							} catch (Exception $ex) {
								$json->mensaje = "Ha ocurrido un error al conectarse con la bd personal, favor de intentar de nuevo";
								$json->estado=-2;
							}
						}
					} catch (Exception $ex) {
						$json->mensaje = "Ha ocurrido un error al conectarse con la bd personal, favor de intentar de nuevo";
						$json->estado=-2;
					}
				}
			}else{
				//echo ('valor null');
				$json->estado=1;
				$json->mensaje = "No se han generado los incentivos, favor de revisar";
				$json->mensaje_tecnico = "";				
			}
			
			// echo json_encode($arrXml);		
			// exit();			
			// $mensaje="Ok";
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ha ocurrido un error al conectarse con la bd personal, favor de intentar de nuevo";
			$json->estado=-2;			
		}
    }

	try {
		echo json_encode($json);	
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

 ?>