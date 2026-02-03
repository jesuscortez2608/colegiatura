<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/frm_reportePagosPorcentaje.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>

<div class="page-content">
	<div class="form-horizontal">
		<div class="row-fluid">
			<div class="span6">
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
			</div>
			<div class="span6">
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
			</div>
		</div>
			
		<div class="row-fluid">
			<div class="span6">
				<label class="control-label" >Porcentaje:</label>
				<div class="controls">
					<select id="cbo_porcentaje" style="width:100px;">
					</select>
				</div>
				<br>
			</div>
			<div class="span6">
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<select id="cbo_empresa">
					</select>
				</div>
				<br>
			</div>
		</div>
		<div class="row-fluid">
			<!--Boton Consultar-->								
			<div class="controls">
				<button id="btn_consultar" class="btn btn-small btn-primary" style="float:right">
				<i class="icon-search bigger-110"></i>Consultar</button>
			</div>
		</div>
		<br>
		<hr>
		<div class="row-fluid">
			<div id="gridPorcentaje">
				<table id="gridPorcentaje-table"></table>
				<div id="gridPorcentaje-pager"></div>
			</div>
		</div>
		
		<!--
		<form id="formreporte" name="formreporte" action="http://10.27.112.122:8080/colegiaturas/rest/reportes" method="POST">
			<input type="hidden" id="nombre_reporte" name="nombre_reporte" value="rpt_pagos_por_porcentaje"/>
			<input type="hidden" id="id_conexion" name="id_conexion" value="190"/>
			<input type="hidden" id="formato_reporte" name="formato_reporte" value="pdf"/>
			<input type="hidden" id="porcentaje" name="porcentaje" value="80"/>
			<input type="hidden" id="empresa" name="empresa" value="0"/>
			<input type="hidden" id="fecha_inicial" name="fecha_inicial" value="20180101"/>
			<input type="hidden" id="fecha_final" name="fecha_final" value="20180824"/>
		</form>
		-->
		
	</div>
</div>