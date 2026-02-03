<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>
<!--page specific plugin styles-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_ConfiguracionMetasYEficiencia.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>

<div class="span12;page-header position-relative; form-horizontal"> 
	<div class="span12">	
		<div class="span12">
		<br>
			<div class="control-group">	 
				<br>
				<label class="control-label">Meta:</label>
				<div class="controls">
					<input type="text" class="span2 numbersOnly" id="txt_Meta" maxlength="2">
				</div><br>					
				<label class="control-label">% Eficiencia:</label>
				<div class="controls">
					<input type="text" class="span2 numbersOnly" id="txt_Eficiencia" maxlength="3"> 
				</div><br>
			</div>
		</div>
		<div class="span12">
			<div class="span3">
				<div class="control-group">
					<label class="control-label" > Fecha Inicial: </label>
					<div class="controls">
						<div class="row-fluid input-append">
								<input type="text" id="dp_FechaInicio" class="input-small"  value="<?php echo date('d/m/Y'); ?>"/>
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
						</div>
					</div>
				</div>
			</div>
			<div class="span3">
					<label class="control-label"> Fecha Final: </label>
					<div class="controls">
						<div class="row-fluid input-append">
								<input type="text" id="dp_FechaFin" class="input-small"  value="<?php echo date('d/m/Y'); ?>"/>
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
						</div>
					</div>
			</div>
			<div class="span5">
				<div class="control-group">
					<div class="controls">
						<!---label class="span3"--->
							<button class="btn btn-primary btn-small" id="btn_guardar" type="button">
							<i class="icon-save bigger-110"></i>
							Guardar
						</button>
						<!---/label--->
					</div>
				</div>				
			</div>	
		<div class="row-fluid">	
		<div class="span12">
			<div id="gridConfigMetasEficiencia" style="">
				<table id="gridConfigMetasEficiencia-table"></table>
				<div id="gridConfigMetasEficiencia-pager"></div>
			</div>
			<br>
		</div>
		</div>		
	</div>
</div>