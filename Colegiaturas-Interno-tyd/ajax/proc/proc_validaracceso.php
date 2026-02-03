<?php
	function obtenerJson($sData,$ipservicio,$inumemp,$cSistema){
		$ipservicio = filter_var($ipservicio, FILTER_SANITIZE_FULL_SPECIAL_CHARS);
		$inumemp = filter_var($inumemp, FILTER_VALIDATE_INT);
		if($inumemp != 0){
			$iemp = $inumemp;
			$sistema = $cSistema;
		}
		else{
			$tamanio = $sData[0] . $sData[1];
				$data = $sData;
				$tamanio = $tamanio + 0;
				$total = strlen($data);
				$sistema = '';
				$iemp = '';
				$index = 0;
				for($i=2;$i < $total; $i++)
				{
					if($i%2 == 0 && $index < $tamanio)
					{
						$sistema .= $data[$i];
						$index++;
					}
					else
						{
							if($i < 19)
								$iemp .= $data[$i];
							else 
								{
									$sistema .= $data[$i];
									$index++;
								}
						}							
				}
		}
		$ret = new stdClass();
		$idu_estado = -1;
		$des_mensaje = 'Error interno del sistema. Favor de Reportarlo a Sistemas Programacion';
		/*$ipConsultaPerfil = getIpConsultaPerfil();
		if ( $ipConsultaPerfil == '' ) {
			$idu_estado = -1;
			$des_mensaje = 'Error al obtener configuracion de usuario';
		} else*/ if(!$iemp) {
			$idu_estado = -1;
			$des_mensaje = 'Error al recibir el parametro Empleado.';
		} else {
			try {
				$cliente = new SoapClient('http://' . $ipservicio/*$_SESSION[$Session]['IPWEBSERV']*/ . '/connect/ConsultaPerfil?wsdl');
				$doc = new stdClass();
				$doc->num_empleado=$iemp;				
                $response = $cliente->consultaPerfilEmpExterno($doc);
              if($response->num_empleado == -1)
              {
                $des_mensaje = $response->nom_empleado; 
                $response = $cliente->ConsultaPerfil($doc);		
                if(!isset($response->emp_cancelado))
                {
                    $jsonRetorno = '{"idu_estado":"' . $idu_estado .
                    '","des_mensaje":"' . $des_mensaje . '"}';
                    echo $jsonRetorno;
                    return;
                }
              } 
                        //$response = $cliente->ConsultaPerfil($doc);
			//print_r($response); exit();
				if($response->emp_cancelado == 0) {
					if( (isset($response->perfil) ? $response->perfil: 0) == 0) {
						$idu_estado = '-1';
						$des_mensaje = 'El empleado no tiene acceso a Sistemas Coppel.';
					} else {
						$idu_estado = '0';
						$des_mensaje = 'OK';
						$ipConsultaPerfil = $_SESSION['SISTEMAS']['IPWEBSERV'];
						unset($_SESSION['SISTEMAS']);

						if (!isset($_SESSION['csrf_token'])) {
							$_SESSION['csrf_token'] = bin2hex(random_bytes(32));
						}
						
						$_SESSION['SISTEMAS']['IPWEBSERV'] = $ipConsultaPerfil;
						$_SESSION['SISTEMAS']['USUARIO'] = new stdClass();
						$_SESSION['SISTEMAS']['USUARIO']->num_empleado = $response->num_empleado;
						$_SESSION['SISTEMAS']['USUARIO']->nom_empleado = $response->nom_empleado;
						$_SESSION['SISTEMAS']['USUARIO']->nom_apellidopaterno = $response->nom_apellidopaterno;
						$_SESSION['SISTEMAS']['USUARIO']->nom_apellidomaterno = $response->nom_apellidomaterno;
						$_SESSION['SISTEMAS']['USUARIO']->fechanacimiento = $response->fechanacimiento;
						$_SESSION['SISTEMAS']['USUARIO']->rfcempleado = $response->rfcempleado;
						$_SESSION['SISTEMAS']['USUARIO']->num_centro = $response->num_centro;
						$_SESSION['SISTEMAS']['USUARIO']->nomcentro = $response->nomcentro;
						$_SESSION['SISTEMAS']['USUARIO']->num_gerente = $response->num_gerente;
						$_SESSION['SISTEMAS']['USUARIO']->num_seccion = $response->num_seccion;
						
						$_SESSION['SISTEMAS']['USUARIO']->num_puesto = $response->num_puesto;
						$_SESSION['SISTEMAS']['USUARIO']->nom_puesto = $response->nom_puesto;
						$_SESSION['SISTEMAS']['USUARIO']->emp_cancelado = $response->emp_cancelado;
						$_SESSION['SISTEMAS']['USUARIO']->num_empresa = $response->num_empresa;
						$_SESSION['SISTEMAS']['USUARIO']->num_ciudad = $response->num_ciudad;
						$_SESSION['SISTEMAS']['USUARIO']->nom_ciudad = $response->nom_ciudad;
						$_SESSION['SISTEMAS']['USUARIO']->nom_ciudadinicial = $response->nom_ciudadinicial;
						$_SESSION['SISTEMAS']['USUARIO']->num_region = $response->num_region;
						$_SESSION['SISTEMAS']['USUARIO']->nom_region = $response->nom_region;
						$_SESSION['SISTEMAS']['USUARIO']->gerente = $response->gerente;
						
						$_SESSION['SISTEMAS']['USUARIO']->fechaaltaemp = $response->fechaaltaemp;
						$_SESSION['SISTEMAS']['USUARIO']->sexo = $response->sexo;
						
						/*unset($_SESSION['SISTEMAS']['AREA']);
						unset($_SESSION['SISTEMAS']['SISTEMA']);
						unset($_SESSION['SISTEMAS']['APLICACIONES']);
						*/
						
						$totalAreas =	0;
						$buffer = -1;
						
						for($i = 0;$i < sizeof($response->perfil);$i++ ) {
							if($response->perfil[$i]->idu_area != $buffer) {
								$buffer = $response->perfil[$i]->idu_area;
								$_SESSION['SISTEMAS']['AREA'][$totalAreas] = new stdClass();
								$_SESSION['SISTEMAS']['AREA'][$totalAreas]->idu_area = $response->perfil[$i]->idu_area;
								$_SESSION['SISTEMAS']['AREA'][$totalAreas]->nom_nombrearea = $response->perfil[$i]->nom_nombrearea;
								$_SESSION['SISTEMAS']['AREA'][$totalAreas]->ordenmenuarea = $response->perfil[$i]->ordenmenuarea;
								$_SESSION['SISTEMAS']['AREA'][$totalAreas]->iconoarea = $response->perfil[$i]->iconoarea;
								$_SESSION['SISTEMAS']['AREA'][$totalAreas]->desc_ayudaarea = $response->perfil[$i]->desc_ayudaarea;
								
								$totalAreas++;
							}
						}
						
						$totalSistemas = 0;
						$buffer = "null";
						for($i = 0; $i < sizeof($response->perfil); $i++) {
							if(($response->perfil[$i]->idu_sistema . $response->perfil[$i]->idu_area) != $buffer) {
								$buffer = ($response->perfil[$i]->idu_sistema . $response->perfil[$i]->idu_area);	
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas] = new stdClass();
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->idu_area = $response->perfil[$i]->idu_area;
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->idu_sistema = ($response->perfil[$i]->idu_sistema . $response->perfil[$i]->idu_area);
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->nom_nombresistema = $response->perfil[$i]->nom_nombresistema;
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->urlsistema = $response->perfil[$i]->urlsistema;
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->ordenmenusistema = $response->perfil[$i]->ordenmenusistema;
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->iconosistema = $response->perfil[$i]->iconosistema;
								$_SESSION['SISTEMAS']['SISTEMA'][$totalSistemas]->desc_ayudasistema = $response->perfil[$i]->desc_ayudasistema;
								
								$totalSistemas++;
							}
						}
						
						$totalAplicaciones = 0;
						for($i = 0; $i < sizeof($response->perfil); $i++) {		
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones] =	new stdClass();
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->idu_sistema = ($response->perfil[$i]->idu_sistema . $response->perfil[$i]->idu_area);
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->indice = $response->perfil[$i]->indice;
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->nom_nombreaplicacion = $response->perfil[$i]->nom_nombreaplicacion;
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->urlaplicacion = $response->perfil[$i]->urlaplicacion;
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->ordenmenuaplicacion = $response->perfil[$i]->ordenmenuaplicacion;
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->iconoaplicacion = $response->perfil[$i]->iconoaplicacion;
								$_SESSION['SISTEMAS']['APLICACION'][$totalAplicaciones]->desc_ayudaaplicacion = $response->perfil[$i]->desc_ayudaaplicacion;
						
								$totalAplicaciones++;
						}
						
					}
					$_SESSION['SISTEMAS']['AreaActual'] = -1;
				} else {
					$idu_estado = -1;
					$des_mensaje = "Empleado se encuentra dado de baja";
				}
				
				
			} catch (Exception $ex) {
				$desc_mensaje = $ex->getMessage();
			}
		}
		
		if ($idu_estado != 0){
			return "El empleado no tiene acceso al sistema";
		}
		
		$jsonInfo =  new stdClass();
		$jsonInfo->INDEX = isset($_SESSION['SISTEMAS']['INDEX']) ? $_SESSION['SISTEMAS']['INDEX'] : '#';
		
		$jsonInfo->USUARIO['num_empleado'] = $_SESSION['SISTEMAS']['USUARIO']->num_empleado; 
		$jsonInfo->USUARIO['nom_empleado'] = $_SESSION['SISTEMAS']['USUARIO']->nom_empleado;
		$jsonInfo->USUARIO['nom_apellidopaterno'] =	$_SESSION['SISTEMAS']['USUARIO']->nom_apellidopaterno;
		$jsonInfo->USUARIO['nom_apellidomaterno'] =	 $_SESSION['SISTEMAS']['USUARIO']->nom_apellidomaterno;
		$jsonInfo->USUARIO['fechanacimiento'] = $_SESSION['SISTEMAS']['USUARIO']->fechanacimiento;
		$jsonInfo->USUARIO['rfcempleado'] = $_SESSION['SISTEMAS']['USUARIO']->rfcempleado;
		$jsonInfo->USUARIO['num_centro'] = $_SESSION['SISTEMAS']['USUARIO']->num_centro;
		$jsonInfo->USUARIO['nomcentro'] = $_SESSION['SISTEMAS']['USUARIO']->nomcentro;
		$jsonInfo->USUARIO['num_gerente'] = $_SESSION['SISTEMAS']['USUARIO']->num_gerente;
		$jsonInfo->USUARIO['num_seccion'] = $_SESSION['SISTEMAS']['USUARIO']->num_seccion;
		
		$jsonInfo->USUARIO['num_puesto'] = $_SESSION['SISTEMAS']['USUARIO']->num_puesto; 
		$jsonInfo->USUARIO['nom_puesto'] = $_SESSION['SISTEMAS']['USUARIO']->nom_puesto;
		$jsonInfo->USUARIO['num_empresa'] = $_SESSION['SISTEMAS']['USUARIO']->num_empresa;
		$jsonInfo->USUARIO['num_ciudad'] =	$_SESSION['SISTEMAS']['USUARIO']->num_ciudad;
		$jsonInfo->USUARIO['nom_ciudad'] = $_SESSION['SISTEMAS']['USUARIO']->nom_ciudad;
		$jsonInfo->USUARIO['nom_ciudadinicial'] = $_SESSION['SISTEMAS']['USUARIO']->nom_ciudadinicial;
		$jsonInfo->USUARIO['num_region'] = $_SESSION['SISTEMAS']['USUARIO']->num_region;
		$jsonInfo->USUARIO['nom_region'] = $_SESSION['SISTEMAS']['USUARIO']->nom_region;
		$jsonInfo->USUARIO['gerente'] = $_SESSION['SISTEMAS']['USUARIO']->gerente;
		$jsonInfo->USUARIO['fechaaltaemp'] = $_SESSION['SISTEMAS']['USUARIO']->fechaaltaemp;
		
		$jsonInfo->USUARIO['sexo'] = $_SESSION['SISTEMAS']['USUARIO']->sexo;
		
		/* Obtener un arreglo con todos los ndices
		   del sistema ($nIduSistema)
		----------------------------------------------------------- */
		$arrIndices = array();
		$elemento = 0;
		$permiso = 0;
		for($i = 0; $i < sizeof($_SESSION['SISTEMAS']['SISTEMA']); $i++) {
			if ($_SESSION['SISTEMAS']['SISTEMA'][$i]->nom_nombresistema == $sistema ) {
				$permiso = 1;
				$nIduSistema = $_SESSION['SISTEMAS']['SISTEMA'][$i]->idu_sistema;
				for($posx = 0; $posx < sizeof($_SESSION['SISTEMAS']['APLICACION']); $posx++) {
					if ($_SESSION['SISTEMAS']['APLICACION'][$posx]->idu_sistema == $nIduSistema) {
						$indice = $_SESSION['SISTEMAS']['APLICACION'][$posx]->indice;
						if (  !in_array($indice, $arrIndices, true)  ) {
							$arrIndices[$elemento] = $indice;
							$elemento++;
						}
					}
				}
			}
		}
		if($permiso == 0){
			return '0';
		}
		
		$jsonInfo->APLICACION = 0;
		$jsonApps = array();
		$indexJson = 0;
		$nArea = 0;
		for($i = 0; $i < sizeof($_SESSION['SISTEMAS']['SISTEMA']); $i++) {
			if ($_SESSION['SISTEMAS']['SISTEMA'][$i]->nom_nombresistema == $sistema ) {
				$nArea = $_SESSION['SISTEMAS']['SISTEMA'][$i]->idu_area;
				$nIduSistema = $_SESSION['SISTEMAS']['SISTEMA'][$i]->idu_sistema;
				$base64file = $_SESSION['SISTEMAS']['SISTEMA'][$i]->iconosistema;
				for($indice = 0; $indice < sizeof($arrIndices); $indice++) {
					$nomIndice = $arrIndices[$indice];
					for($posx = 0; $posx < sizeof($_SESSION['SISTEMAS']['APLICACION']); $posx++) {
						if ($_SESSION['SISTEMAS']['APLICACION'][$posx]->idu_sistema == $nIduSistema 
							&& $_SESSION['SISTEMAS']['APLICACION'][$posx]->indice == $nomIndice) {
							$jsonApps[$indexJson] = new stdClass();
							$jsonApps[$indexJson]->idu_sistema = $_SESSION['SISTEMAS']['APLICACION'][$posx]->idu_sistema;
							$jsonApps[$indexJson]->nom_nombresistema = $_SESSION['SISTEMAS']['SISTEMA'][$i]->nom_nombresistema;
							$jsonApps[$indexJson]->indice = $_SESSION['SISTEMAS']['APLICACION'][$posx]->indice;
							$jsonApps[$indexJson]->nom_nombreaplicacion = $_SESSION['SISTEMAS']['APLICACION'][$posx]->nom_nombreaplicacion;
							$jsonApps[$indexJson]->urlaplicacion = $_SESSION['SISTEMAS']['APLICACION'][$posx]->urlaplicacion;
							$jsonApps[$indexJson]->ordenmenuaplicacion = $_SESSION['SISTEMAS']['APLICACION'][$posx]->ordenmenuaplicacion;
							$jsonApps[$indexJson]->iconoaplicacion = $_SESSION['SISTEMAS']['APLICACION'][$posx]->iconoaplicacion;
							$jsonApps[$indexJson]->desc_ayudaaplicacion = $_SESSION['SISTEMAS']['APLICACION'][$posx]->desc_ayudaaplicacion;
							$indexJson++;
						}
					}
				}
				$jsonInfo->APLICACION = $jsonApps;
				$jsonInfo = json_encode($jsonInfo);
				break;
			}
		}
		return $jsonInfo;
	}
 ?>
