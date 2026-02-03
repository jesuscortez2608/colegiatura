<?php
   header('X-Frame-Options: SAMEORIGIN');
   header("Content-type:text/html;charset=utf-8;");
   header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<!--<script type="text/javascript">
	this.document.getElementById("pag_title").innerHTML = "";
</script>-->

<div class="alert alert-warning">
	<button data-dismiss="alert" class="close" type="button">
		<i class="icon-remove"></i>
	</button>
		<strong>Atención!</strong>
		Var{mensaje}
	<br>
</div>