<?php
    header('X-Frame-Options: SAMEORIGIN');
	header("Content-type:text/html;charset=utf-8;");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	
	$Session = 'Colegiaturas';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
?>
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_reporteIncentivos.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="span12 form-horizontal">
	<div class="span12">
		<div class="span6">
			<div class="control-group">
				<label class="control-label">Quincena:</label>
				<div class="controls">
					<select id="cbo_quincena" tabindex="1" class="span6">
					
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Colaborador:</label>
				<div class="controls">
					<input type="text" id="txt_Numemp" maxlength="8" class="span3 numbersOnly" tabindex="2" />
					<input type="text" id="txt_NomEmp" class="span6 textOnly" style="text-transform:uppercase" readonly />
					<button class="btn btn-small btn-primary push-right" id="btn_Consultar" tabindex="4">
					<i class="icon-search bigger-110"></i>Consultar
				</div>				
			</div>
		</div>
		<div class="span6">
			<div class="control-group">
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<select id="cbo_empresa" tabindex="3" class="span6">
					</select>
				</div>
			</div>
			<div class="control-group">
			</div>
		</div>
	</div>
	<div class="span10">
		<div class="control-group">
			<div id="gridIncentivos">
				<table id="gridIncentivos-table"></table>
				<div id="gridIncentivos-pager"></div>
			</div>
		</div>	
	</div>
</div>