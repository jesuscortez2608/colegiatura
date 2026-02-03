 <?php
 session_name("Session-Colegiaturas");
 session_start();
 header ('Content-type: text/html; charset=utf-8');
 $Session = $_POST['session_name'];
 if(!isset($_SESSION[$Session]))
 {
 	echo '{"activa":"false","mensaje":"Se Cerro el Sistema..."}';
 }
 else {
     echo '{"activa":"true","mensaje":"OK"}';
 }
 ?>