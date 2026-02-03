<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>
<!--[if lte IE 8]>
  <link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css"/>
<[endif]-->
<script type="text/javascript" src="files/js/frm_generarCierre.js"></script>
<link rel="stylesheet"  href="files/css/frm_generarCierre.css"/>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<div class="page-header position-center">
		<h3>Generar Cierre de Colegiaturas</h3>
	</div>
	<div class="row-fluid">
		<div class="form-horizontal">
			<div class="span12;page-header position-relative">
				<div class="control-group">
					<button id="btn_generarCierre" class="btn btn-small btn-primary">Generar el Cierre</button>
				</div>
			</div>
		</div>
	</div>
</div>