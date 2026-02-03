<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');	
?>
<!--page specific plugin styles-->

<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->
<!--page specific plugin scripts-->

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_configuracionSuplentesGte.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div {
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="span12;page-header position-relative; form-horizontal">
	<div class="span12">
		<div class="span6">
			<div class="control-group">
				<h4>Número de Colaborador</h4>
			</div>	
			<div class="control-group">	
				<input id="txt_iduempleado" class="span3 numbersOnly" maxlength="8" type="text" placeholder="" tabindex="1" readonly="readonly">
				<input id="txt_nomempleado" class="span8" type="text" placeholder="" readonly="readonly">
			</div>
			<div class="control-group">
				<input id="txt_idupuesto" class="span3" type="text" readonly="readonly">
				<input id="txt_nompuesto" class="span8" type="text" readonly="readonly">
			</div>
			<div class="control-group">
				<input id="txt_iducentro" class="span3" type="text" readonly="readonly">
				<input id="txt_nomcentro" class="span8" type="text" readonly="readonly">
			</div>
		</div>
		<div class="span6">
			<div class="control-group">
				<h4>Número de Suplente</h4>
			</div>	
			<div class="control-group">	
				<input id="txt_iduempleado2" class="span3 numbersOnly" maxlength="8" type="text" placeholder="Num. Colaborador" tabindex="2">
				<input id="txt_nomempleado2" class="span8" type="text" placeholder="" readonly="readonly">
			</div>
			<div class="control-group">
				<input id="txt_idupuesto2" class="span3" type="text" readonly="readonly">
				<input id="txt_nompuesto2" class="span8" type="text" readonly="readonly">
			</div>
			<div class="control-group">
				<input id="txt_iducentro2" class="span3" type="text" readonly="readonly">
				<input id="txt_nomcentro2" class="span8" type="text" readonly="readonly">
			</div>
		</div>	
	</div>	
	
	<!--Fechas -->
	<div class="span10" >
		<div class="span6">
			<div class="control-group">
				<label class="control-label" for="txt_FechaIni">Fecha Inicial:&nbsp;</label>
				<div class="controls">				
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaIni" class="input-small" readonly tabindex ="3" value="<?php echo date('d/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>						
			</div>
		</div>		
		<div class="span6">
			<div class="control-group">
				<label class="control-label" for="txt_FechaFin">Fecha Final:&nbsp;</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" readonly tabindex="4" value="<?php echo date('d/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>					
		</div>		
	</div>	
	
	<!--Boton Guardar -->
	<div style="right">
		<button class="btn btn-small btn-primary" id="btn_Otro">
			<i class="icon-file bigger-110"></i>
			Nuevo
		</button>	
		<button class="btn btn-small btn-primary" id="btn_guardar">
			<i class="icon-save bigger-110"></i>
			Guardar
		</button>	
	</div>
	
	<!--Grid -->
	<div class="row-fluid">	
		<div class="span12">					
			<div id="gridSuplentes">
				<table id="gridSuplentes-table"></table>
				<div id="gridSuplentes-pager"></div>
			</div>					
		</div>
	</div>	
</div>
