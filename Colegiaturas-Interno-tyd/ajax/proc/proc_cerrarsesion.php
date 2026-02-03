<?php
  session_name("Session-Colegiaturas"); 
  session_start();
  $Session = $_POST['session_name'];
  if(!isset($_SESSION[$Session]))
  {
  	$url = "index.php";
	echo '{"idu_estado":"0","mensaje":"OK", "url":"'.$url.'"}';
  }
  else
  	{
		$url = isset($_SESSION[$Session]['ORIGEN']) ? $_SESSION[$Session]['ORIGEN'] : $_SESSION[$Session]["INDEX"]."index.php";
		unset($_SESSION[$Session]);
		session_destroy(); 
	  	echo '{"idu_estado":"0","mensaje":"OK", "url":"'.$url.'"}';
  	}
  return;
  
?>
