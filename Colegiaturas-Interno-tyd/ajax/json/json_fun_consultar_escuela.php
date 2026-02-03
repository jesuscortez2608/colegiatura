<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$iFactura = isset($_POST['idFactura']) ? $_POST['idFactura'] : 0;
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$mensaje = $CDB['mensaje'];
		$json = new stdClass();
		if($estado != 0){
			$json->estado = $estado;
		} else {
			try {
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				
				$cmd->setCommandText("{CALL fun_consultar_escuela($iFactura)}");
				// echo "<pre>";
				// print_r("CALL fun_consultar_escuela($iFactura)");
				// echo "</pre>";
				// exit();
				$ds = $cmd->executeDataSet();
				$con->close();
				
				$json->datos = array();
				
				if ($ds[0] != null){
					$estado = 1;
					if($iOpcion == 1){
						$i = 0;
						$json->datos = array();
						
						foreach($ds as $value){
							$json->datos[$i] = new stdClass();
							$json->datos[$i]->idEscuela = (isset($value['iescuela'])) ? $value['iescuela']: '';
							$json->datos[$i]->nomEscuela = encodeToUtf8(trim($value['sescuela']));
							$i++;
							// $arr[] = array();
							// $arr[] = array(
								// 'value'=> $value['iescuela'], 'nombre' => (utf8_encode($value['sescuela']))
							// );
							$json->estado = 0;
							$json->mensaje = 'OK';
						}
						echo json_encode($json);
					} else {
						$arr = array();
						
						$arr[] = array(
							'iescuela' => $ds[0]['iescuela']
							, 'sescuela' => trim(encodeToUtf8($ds[0]['sescuela']))
							, 'iestado' => $ds[0]['iestado']
							, 'sestado' => trim(encodeToUtf8($ds[0]['sestado']))
							, 'imunicipio' => $ds[0]['imunicipio']
							, 'smunicipio' => trim(encodeToUtf8($ds[0]['smunicipio']))
							, 'srfc' => trim(encodeToUtf8($ds[0]['srfc']))
							, 'srazonsocial' => trim(encodeToUtf8($ds[0]['srazon_social']))
							, 'sclavesep' => trim(encodeToUtf8($ds[0]['sclave_sep']))
						);
						
						$json->datos = $arr;
						echo json_encode($arr);
					}
				} else {
					$estado = -1;
				}
			}
			catch(JsonException $ex){
				$json->mensaje = $ex->getMessage();
				$json->estado=-2;
			}
			catch (Exception $ex) {
				$json->mensaje = $ex->getMessage();
				$json->estado=-2;
			}
		}
?>