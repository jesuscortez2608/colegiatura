<?php
	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/frm_reporteBecasEscolaridad.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<form class="form-horizontal">
		<div class="row-fluid">
			<div class="span6 control-group">
			
				<!--Ruta Pago-->
				<label class="control-label">Ruta de Pago:</label>
				<div class="controls">
					<select id="cbo_rutaPago"></select>
				</div>
				<br>
				
				<!--Estatus-->						
				<label class="control-label">Estatus:</label>
				<div class="controls">
					<select id="cbo_Estatus"></select>
				</div>
				<br>

				<!--Region-->		
				<label class="control-label">Región:</label>
				<div class="controls">
					<select id="cbo_Region"></select>
				</div>
				<br>
				
				<!--Ciudad-->	
				<label class="control-label">Ciudad:</label>
				<div class="controls">
					<select id="cbo_Ciudad">
						<option value='0'>TODAS</option>
					</select>
				</div>
				<br>
					
			</div>
			
			<div class="span6 control-group">
				
				<!--Tipos de Deducción-->
				<label class="control-label">Tipos de Deducción:</label>
				<div class="controls">
					<select id="cbo_tipoDeduccion"></select>
				</div>
				<br>
				
				<!-- Fecha Inicial -->
				<label class="control-label" for="txt_FechaInicio">Fecha Inicial:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaInicio" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of this month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
				<br>
				
				<!-- Fecha Final -->
				<label class="control-label" for="txt_FechaFin">Fecha Final:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
				<br>
				
				<!-- Tipo de Escuela -->
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<select id="cbo_empresa"></select>
				</div>
				<!--
				<div class="controls">
					<select id="cbo_Tipo_Escuela">
						<option value="0">TODAS</option>
						<option value="1">PUBLICA</option>
						<option value="2">PRIVADA</option>
					</select>
				</div>-->
				<br>
			</div>
		</div>
		<div class="row-fluid">
			<div class="span12" align="right">
				<!-- Boton Consultar -->
				<div class="controls">
					<button id="btn_consultar" class="btn btn-small btn-primary">
					<i class="icon-search bigger-110"></i>Consultar</button>
				</div>
				<br>
			</div>
		</div>
		<div class="row-fluid">
			<div class="span12">				
				<div class="control-group">
					<table id="gridReporteNivelEstudio"></table>
					<div id="gridReporteNivelEstudio-pager"></div>
				</div>
				<br>
			</div>
		</div>
	</form>
</div>