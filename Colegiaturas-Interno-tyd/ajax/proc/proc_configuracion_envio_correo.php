<?php
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');

    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    
    class EnvioCorreoClass {
        private string $apiUrl;
        private String $usr;
        private String $pwd;
        private String $token;

        public function __construct(){
            $config = require '../../files/values/configCorreo.php';
            $datos_conexion = obtenConexion(BDSYSCOPPELPERSONALSQL);


            if ($datos_conexion["estado"] != 0) {
                echo "Error en la conexion " . $datos_conexion["mensaje"];
                exit();
            }
            
            $cadena_conexion = $datos_conexion["conexion"];

            $con = new OdbcConnection($cadena_conexion);
            $con->open();
            
            $cmd = $con->createCommand();
        

            $cmd->setCommandText("{CALL SAPACCESOSDATOSWEB (603,1)}");
            $ds = $cmd->executeDataSet();

            $con->close();
            
            $connectionString = $ds[0]['connectionstring'];
            $queryString = str_replace(';', '&', $connectionString);
            parse_str($queryString, $parsedArray);
            
            $ip = $parsedArray["SERVERNAME"];
            $key = $parsedArray["PWD"];
        
            $viusr = $_SERVER['API_USR_IV'];
            $vipwd = $_SERVER['API_PWD_IV'];
        
            $dns = "https://$ip/wscorreo/api";

            $this->usr = $this->desencriptar($config['API_USR'], $key, $viusr);
            $this->pwd = $this->desencriptar($config['API_PWD'], $key, $vipwd);
            $this->apiUrl = $dns;
        }

        public function enviarCorreo(String $asunto, String $destinatario, String $html) {
            try {
                $this->token = $this->obtenerToken($this->usr, $this->pwd);

                $post_data = [
                    'asunto' => $asunto,
                    'destinatario' => $destinatario,
                    'html' => $html
                ];

                $headers = [
                    'APITOKEN: '.$this->token,
                    'Content-Type: application/json'
                ];


                $json_data = json_encode($post_data);

                $options = [
                    'http' => [
                        'method' => 'POST',
                        'header' => implode("\r\n", $headers),
                        'content' => $json_data,
                    ],
                ];

                $context = stream_context_create($options);

                $response = file_get_contents($this->apiUrl.'/correo', false, $context);
                
                if ($response === false) {
                    return $response;
                    die('');
                }
                
                $data = json_decode($response, true);
                return $data;
            } catch (\Throwable $th) {
                return false; 
            }
            
        }

        private function obtenerToken($usr, $pwd){
            try {
                $post_data = [
                    'nom_usuario' => $usr,
                    'des_password' => $pwd
                ];

                $json_data = json_encode($post_data);

                $options = [
                    'http' => [
                        'method' => 'POST',
                        'header' => 'Content-Type: application/json',
                        'content' => $json_data,
                    ],
                ];

                $context = stream_context_create($options);

                $response = file_get_contents($this->apiUrl.'/token', false, $context);
                

                if ($response === false) {
                    return $response;
                    die('');
                }

                return $response;
            } catch (\Throwable $th) {
                return false; 
            }
        }

        /*private function encriptar($text, $clave){
            $ivTam = openssl_cipher_iv_length('aes-256-gcm');

            $iv = openssl_random_pseudo_bytes($ivTam);

            $txtCifrado = openssl_encrypt(
                $text, 
                'aes-256-gcm', 
                $clave, 
                OPENSSL_RAW_DATA,
                $iv, 
                $tag);

            return base64_encode($iv.$txtCifrado.$tag);

        }*/

        private function desencriptar($textEncriptado, $clave, $iv){
            $data = base64_decode($textEncriptado);
            $iv = base64_decode($iv);

            $ivTam = openssl_cipher_iv_length('aes-256-gcm');
            //$iv = substr($data, 0, $ivTam);

            $tagTam = 16;

            $tag = substr($data, -$tagTam);

            $textCifrado = substr($data, $ivTam, -$tagTam);

            return openssl_decrypt($textCifrado, 'aes-256-gcm', $clave, OPENSSL_RAW_DATA, $iv, $tag);

        }

    }
